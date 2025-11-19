import * as functions from "firebase-functions/v1";
import * as admin from "firebase-admin";

/**
 * Check budgets yang sudah melebihi threshold dan kirim alert
 * Dijalankan setiap hari jam 7 pagi WIB
 */
export const checkBudgetAlerts = functions.pubsub
  .schedule("0 7 * * *") // Setiap hari jam 7 pagi
  .timeZone("Asia/Jakarta")
  .onRun(async (_context: functions.EventContext) => {
    const db = admin.firestore();
    const messaging = admin.messaging();

    const now = new Date();
    const currentMonth = new Date(now.getFullYear(), now.getMonth(), 1);
    const nextMonth = new Date(now.getFullYear(), now.getMonth() + 1, 1);

    // Get semua budgets untuk bulan ini
    const budgetsSnapshot = await db
      .collection("budgets")
      .where(
        "startDate", ">=",
        admin.firestore.Timestamp.fromDate(currentMonth)
      )
      .where(
        "startDate", "<", admin.firestore.Timestamp.fromDate(nextMonth)
      )
      .get();

    // Group by userId
    const budgetsByUser = new Map<string, any[]>();

    budgetsSnapshot.docs.forEach((doc) => {
      const budget = doc.data();
      const userId = budget.userId;
      if (!budgetsByUser.has(userId)) {
        budgetsByUser.set(userId, []);
      }
      budgetsByUser.get(userId)!.push(budget);
    });

    // Check each user's budgets
    for (const [userId, budgets] of budgetsByUser.entries()) {
      const userDoc = await db.collection("users").doc(userId).get();
      if (!userDoc.exists) continue;

      const userData = userDoc.data();
      const fcmTokens = userData?.fcmTokens || [];
      if (fcmTokens.length === 0) continue;

      const tokens = fcmTokens.map((t: any) => t.token).filter(Boolean);
      if (tokens.length === 0) continue;

      // Get transactions for this month
      const transactionsSnapshot = await db
        .collection("transactions")
        .where("userId", "==", userId)
        .where("date", ">=", admin.firestore.Timestamp.fromDate(currentMonth))
        .where("date", "<", admin.firestore.Timestamp.fromDate(nextMonth))
        .where("type", "==", "expense")
        .get();

      const expenses = transactionsSnapshot.docs.map((doc) => doc.data());

      // Check each budget
      const exceededBudgets: any[] = [];
      const warningBudgets: any[] = [];

      for (const budget of budgets) {
        const budgetAmount = budget.amount || 0;
        const categoryId = budget.categoryId;

        // Calculate total expense for this category
        const categoryExpenses = expenses
          .filter((t: any) => t.categoryId === categoryId)
          .reduce((sum: number, t: any) => sum + (t.amount || 0), 0);

        const percentage = budgetAmount > 0 ?
          (categoryExpenses / budgetAmount) * 100 : 0;

        if (percentage >= 100) {
          // Budget exceeded
          exceededBudgets.push({
            categoryName: budget.categoryName || "Unknown",
            budgetAmount,
            spent: categoryExpenses,
            percentage: percentage.toFixed(1),
          });
        } else if (percentage >= 80) {
          // Budget warning (80% threshold)
          warningBudgets.push({
            categoryName: budget.categoryName || "Unknown",
            budgetAmount,
            spent: categoryExpenses,
            percentage: percentage.toFixed(1),
          });
        }
      }

      // Send notifications if there are alerts
      if (exceededBudgets.length > 0 || warningBudgets.length > 0) {
        let title = "";
        let body = "";
        let priority = "medium";

        if (exceededBudgets.length > 0) {
          title = `🚨 ${exceededBudgets.length} Budget Melebihi Limit!`;
          body = exceededBudgets
            .map((b) => `${b.categoryName}: ${b.percentage}%`)
            .join(", ");
          priority = "urgent";
        } else if (warningBudgets.length > 0) {
          title = `⚠️ ${warningBudgets.length} Budget Mendekati Limit`;
          body = warningBudgets
            .map((b) => `${b.categoryName}: ${b.percentage}%`)
            .join(", ");
          priority = "high";
        }

        const message = {
          notification: {
            title: title,
            body: body,
          },
          data: {
            type: "budget",
            action: exceededBudgets.length > 0 ? "exceeded" : "warning",
            exceededCount: exceededBudgets.length.toString(),
            warningCount: warningBudgets.length.toString(),
            priority: priority,
          },
          tokens: tokens,
        };

        try {
          const response = await messaging.sendEachForMulticast(message);
          console.log(
            `Budget alert sent to user: ${userId}, ` +
            `success: ${response.successCount}, ` +
            `failed: ${response.failureCount}`
          );
        } catch (error) {
          console.error(`Error sending to user ${userId}:`, error);
        }
      }
    }

    return null;
  });


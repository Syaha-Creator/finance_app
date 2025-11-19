import * as functions from "firebase-functions/v1";
import * as admin from "firebase-admin";

admin.initializeApp();

/**
 * Generate dan kirim daily financial summary ke semua user
 * Dijalankan setiap hari jam 8 pagi WIB
 */
export const sendDailySummary = functions.pubsub
  .schedule("0 8 * * *") // Setiap hari jam 8 pagi (UTC)
  .timeZone("Asia/Jakarta")
  .onRun(async (_context: functions.EventContext) => {
    const db = admin.firestore();
    const messaging = admin.messaging();

    // Get semua users
    const usersSnapshot = await db.collection("users").get();

    for (const userDoc of usersSnapshot.docs) {
      const userId = userDoc.id;
      const userData = userDoc.data();
      const fcmTokens = userData.fcmTokens || [];

      if (fcmTokens.length === 0) continue;

      // Get transactions hari ini
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      const tomorrow = new Date(today);
      tomorrow.setDate(tomorrow.getDate() + 1);

      const transactionsSnapshot = await db
        .collection("transactions")
        .where("userId", "==", userId)
        .where("date", ">=", admin.firestore.Timestamp.fromDate(today))
        .where("date", "<", admin.firestore.Timestamp.fromDate(tomorrow))
        .get();

      const todayTransactions = transactionsSnapshot.docs.map(
        (doc) => doc.data()
      );

      const totalIncome = todayTransactions
        .filter((t) => t.type === "income")
        .reduce((sum: number, t: any) => sum + (t.amount || 0), 0);

      const totalExpense = todayTransactions
        .filter((t) => t.type === "expense")
        .reduce((sum: number, t: any) => sum + (t.amount || 0), 0);

      const netIncome = totalIncome - totalExpense;

      // Prepare notification
      const tokens = fcmTokens.map((t: any) => t.token).filter(Boolean);
      if (tokens.length === 0) continue;

      const message = {
        notification: {
          title: "📊 Ringkasan Finansial Hari Ini",
          body: `Pemasukan: Rp ${totalIncome.toLocaleString("id-ID")} | ` +
            `Pengeluaran: Rp ${totalExpense.toLocaleString("id-ID")} | ` +
            `Saldo: Rp ${netIncome.toLocaleString("id-ID")}`,
        },
        data: {
          type: "daily_summary",
          action: "view",
          totalIncome: totalIncome.toString(),
          totalExpense: totalExpense.toString(),
          netIncome: netIncome.toString(),
          priority: "medium",
        },
        tokens: tokens,
      };

      try {
        const response = await messaging.sendEachForMulticast(message);
        console.log(
          `Daily summary sent to user: ${userId}, ` +
          `success: ${response.successCount}, ` +
          `failed: ${response.failureCount}`
        );
      } catch (error) {
        console.error(`Error sending to user ${userId}:`, error);
      }
    }

    return null;
  });


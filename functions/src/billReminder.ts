import * as functions from "firebase-functions/v1";
import * as admin from "firebase-admin";

/**
 * Check bills yang akan jatuh tempo besok dan kirim reminder
 * Dijalankan setiap hari jam 9 pagi WIB
 */
export const sendBillReminders = functions.pubsub
  .schedule("0 9 * * *") // Setiap hari jam 9 pagi
  .timeZone("Asia/Jakarta")
  .onRun(async (_context: functions.EventContext) => {
    const db = admin.firestore();
    const messaging = admin.messaging();

    // Get tanggal besok
    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);
    tomorrow.setHours(0, 0, 0, 0);
    const dayAfter = new Date(tomorrow);
    dayAfter.setDate(dayAfter.getDate() + 1);

    // Get semua bills yang akan jatuh tempo besok
    const billsSnapshot = await db
      .collection("bills")
      .where("status", "==", "pending")
      .where("dueDate", ">=", admin.firestore.Timestamp.fromDate(tomorrow))
      .where("dueDate", "<", admin.firestore.Timestamp.fromDate(dayAfter))
      .get();

    // Group by userId
    const billsByUser = new Map<string, any[]>();

    billsSnapshot.docs.forEach((doc) => {
      const bill = doc.data();
      const userId = bill.userId;
      if (!billsByUser.has(userId)) {
        billsByUser.set(userId, []);
      }
      billsByUser.get(userId)!.push(bill);
    });

    // Send notifications
    for (const [userId, bills] of billsByUser.entries()) {
      const userDoc = await db.collection("users").doc(userId).get();
      if (!userDoc.exists) continue;

      const userData = userDoc.data();
      const fcmTokens = userData?.fcmTokens || [];
      if (fcmTokens.length === 0) continue;

      const tokens = fcmTokens.map((t: any) => t.token).filter(Boolean);
      if (tokens.length === 0) continue;

      const billsCount = bills.length;
      const totalAmount = bills.reduce(
        (sum: number, b: any) => sum + (b.amount || 0), 0
      );

      const message = {
        notification: {
          title: `⏰ ${billsCount} Tagihan Jatuh Tempo Besok`,
          body: `Total: Rp ${totalAmount.toLocaleString("id-ID")}`,
        },
        data: {
          type: "bill",
          action: "due_soon",
          billsCount: billsCount.toString(),
          totalAmount: totalAmount.toString(),
          priority: "high",
        },
        tokens: tokens,
      };

      try {
        const response = await messaging.sendEachForMulticast(message);
        console.log(
          `Bill reminder sent to user: ${userId}, ` +
          `success: ${response.successCount}, ` +
          `failed: ${response.failureCount}`
        );
      } catch (error) {
        console.error(`Error sending to user ${userId}:`, error);
      }
    }

    return null;
  });


import * as functions from "firebase-functions/v1";
import * as admin from "firebase-admin";

/**
 * Generate dan kirim monthly financial report
 * Dijalankan tanggal 1 setiap bulan jam 8 pagi WIB
 */
export const sendMonthlyReport = functions.pubsub
  .schedule("0 8 1 * *") // Tanggal 1 setiap bulan jam 8 pagi
  .timeZone("Asia/Jakarta")
  .onRun(async (_context: functions.EventContext) => {
    const db = admin.firestore();
    const messaging = admin.messaging();

    const lastMonth = new Date();
    lastMonth.setMonth(lastMonth.getMonth() - 1);
    lastMonth.setDate(1);
    lastMonth.setHours(0, 0, 0, 0);

    const thisMonth = new Date();
    thisMonth.setDate(1);
    thisMonth.setHours(0, 0, 0, 0);

    // Get semua users
    const usersSnapshot = await db.collection("users").get();

    for (const userDoc of usersSnapshot.docs) {
      const userId = userDoc.id;
      const userData = userDoc.data();
      const fcmTokens = userData.fcmTokens || [];

      if (fcmTokens.length === 0) continue;

      try {
        // Get transactions bulan lalu
        const transactionsSnapshot = await db
          .collection("transactions")
          .where("userId", "==", userId)
          .where("date", ">=", admin.firestore.Timestamp.fromDate(lastMonth))
          .where("date", "<", admin.firestore.Timestamp.fromDate(thisMonth))
          .get();

        const transactions = transactionsSnapshot.docs.map((doc) => doc.data());

        const totalIncome = transactions
          .filter((t) => t.type === "income")
          .reduce((sum: number, t: any) => sum + (t.amount || 0), 0);

        const totalExpense = transactions
          .filter((t) => t.type === "expense")
          .reduce((sum: number, t: any) => sum + (t.amount || 0), 0);

        const netIncome = totalIncome - totalExpense;
        const transactionCount = transactions.length;

        // Get month name in Indonesian
        const monthNames = [
          "Januari", "Februari", "Maret", "April", "Mei", "Juni",
          "Juli", "Agustus", "September", "Oktober", "November", "Desember",
        ];
        const monthName = monthNames[lastMonth.getMonth()];

        const tokens = fcmTokens.map((t: any) => t.token).filter(Boolean);
        if (tokens.length === 0) continue;

        const message = {
          notification: {
            title: `📈 Laporan Finansial Bulan ${monthName}`,
            body: `Pemasukan: Rp ${totalIncome.toLocaleString("id-ID")} | ` +
              `Pengeluaran: Rp ${totalExpense.toLocaleString("id-ID")} | ` +
              `Saldo: Rp ${netIncome.toLocaleString("id-ID")} | ` +
              `Transaksi: ${transactionCount}`,
          },
          data: {
            type: "report",
            action: "monthly",
            totalIncome: totalIncome.toString(),
            totalExpense: totalExpense.toString(),
            netIncome: netIncome.toString(),
            transactionCount: transactionCount.toString(),
            month: monthName,
            priority: "medium",
          },
          tokens: tokens,
        };

        const response = await messaging.sendEachForMulticast(message);
        console.log(
          `Monthly report sent to user: ${userId}, ` +
          `success: ${response.successCount}, ` +
          `failed: ${response.failureCount}`
        );
      } catch (error) {
        console.error(`Error sending monthly report to user ${userId}:`, error);
      }
    }

    return null;
  });


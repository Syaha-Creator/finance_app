import * as functions from "firebase-functions/v1";
import * as admin from "firebase-admin";

/**
 * Auto-create transactions dari recurring transactions
 * Dijalankan setiap hari jam 6 pagi WIB
 */
export const createRecurringTransactions = functions.pubsub
  .schedule("0 6 * * *") // Setiap hari jam 6 pagi
  .timeZone("Asia/Jakarta")
  .onRun(async (_context: functions.EventContext) => {
    const db = admin.firestore();
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    // Get semua recurring transactions yang aktif
    const recurringSnapshot = await db
      .collection("recurring_transactions")
      .where("isActive", "==", true)
      .get();

    let createdCount = 0;
    let errorCount = 0;

    for (const doc of recurringSnapshot.docs) {
      const recurring = doc.data();
      const nextDueDate = recurring.nextDueDate?.toDate();

      // Check jika sudah waktunya create transaction
      if (nextDueDate && nextDueDate <= today) {
        try {
          // Create transaction
          const transaction = {
            userId: recurring.userId,
            type: recurring.type,
            amount: recurring.amount,
            category: recurring.category,
            account: recurring.account,
            description: recurring.description,
            date: admin.firestore.Timestamp.fromDate(today),
            isRecurring: true,
            recurringTransactionId: doc.id,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          };

          await db.collection("transactions").add(transaction);

          // Update nextDueDate berdasarkan frequency
          const newNextDueDate = new Date(nextDueDate);
          switch (recurring.frequency) {
          case "daily":
            newNextDueDate.setDate(newNextDueDate.getDate() + 1);
            break;
          case "weekly":
            newNextDueDate.setDate(newNextDueDate.getDate() + 7);
            break;
          case "monthly":
            newNextDueDate.setMonth(newNextDueDate.getMonth() + 1);
            break;
          case "yearly":
            newNextDueDate.setFullYear(newNextDueDate.getFullYear() + 1);
            break;
          default:
            // Default to monthly if frequency is unknown
            newNextDueDate.setMonth(newNextDueDate.getMonth() + 1);
          }

          await doc.ref.update({
            nextDueDate: admin.firestore.Timestamp.fromDate(newNextDueDate),
            lastCreatedAt: admin.firestore.FieldValue.serverTimestamp(),
          });

          createdCount++;
          console.log(`Created transaction from recurring: ${doc.id}`);
        } catch (error) {
          errorCount++;
          console.error(
            `Error creating transaction from recurring ${doc.id}:`,
            error
          );
        }
      }
    }

    console.log(
      "Recurring transactions processed: " +
      `${createdCount} created, ${errorCount} errors`
    );
    return null;
  });


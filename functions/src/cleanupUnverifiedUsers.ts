/**
 * Scheduled function untuk cleanup unverified users
 *
 * Menghapus user yang tidak verified dalam 7 hari
 * Run setiap hari jam 2 pagi (WIB)
 */

import * as functions from "firebase-functions/v1";
import * as admin from "firebase-admin";

const UNVERIFIED_USER_EXPIRY_DAYS = 7;

export const cleanupUnverifiedUsers = functions.pubsub
  .schedule("0 2 * * *") // Setiap hari jam 2 pagi (UTC)
  .timeZone("Asia/Jakarta")
  .onRun(async () => {
    const now = Date.now();
    const expiryTime =
      now - (UNVERIFIED_USER_EXPIRY_DAYS * 24 * 60 * 60 * 1000);

    try {
      // Get all users
      const listUsersResult = await admin.auth().listUsers(1000);
      const unverifiedUsers: string[] = [];

      // Filter unverified users yang sudah expired
      for (const user of listUsersResult.users) {
        // Skip Google users (already verified)
        const isGoogleUser = user.providerData.some(
          (provider) => provider.providerId === "google.com"
        );

        if (!isGoogleUser && !user.emailVerified) {
          // Check creation time
          const creationTime = user.metadata.creationTime ?
            new Date(user.metadata.creationTime).getTime() :
            0;

          if (creationTime < expiryTime) {
            unverifiedUsers.push(user.uid);
          }
        }
      }

      // Delete unverified users
      let deletedCount = 0;
      for (const uid of unverifiedUsers) {
        try {
          // Delete user data from Firestore first
          const userDocRef = admin
            .firestore()
            .collection("users")
            .doc(uid);

          const userDoc = await userDocRef.get();
          if (userDoc.exists) {
            // Delete all subcollections
            const subcollections = [
              "categories",
              "paymentMethods",
              "incomeSources",
            ];

            for (const subcollection of subcollections) {
              const subcollectionRef = userDocRef.collection(subcollection);
              const subcollectionDocs = await subcollectionRef.get();

              const deletePromises = subcollectionDocs.docs.map((doc) =>
                doc.ref.delete()
              );
              await Promise.all(deletePromises);
            }

            // Delete user document
            await userDocRef.delete();
          }

          // Delete user from Auth
          await admin.auth().deleteUser(uid);
          deletedCount++;

          functions.logger.info(`Deleted unverified user: ${uid}`);
        } catch (error) {
          functions.logger.error(
            `Error deleting user ${uid}:`,
            error
          );
        }
      }

      functions.logger.info(
        `Cleanup completed. Deleted ${deletedCount} unverified users.`
      );

      return {
        success: true,
        deletedCount,
        totalChecked: listUsersResult.users.length,
      };
    } catch (error) {
      functions.logger.error("Error in cleanupUnverifiedUsers:", error);
      throw error;
    }
  });


# 🔥 Firebase Functions Setup Guide

## 📋 Overview

Firebase Functions memungkinkan Anda menjalankan backend code di server tanpa perlu manage server sendiri. Perfect untuk:
- Scheduled tasks (cron jobs)
- Automated notifications
- Data processing
- Background calculations

---

## 🚀 Setup Firebase Functions

### **1. Install Firebase CLI**

```bash
npm install -g firebase-tools
```

### **2. Login ke Firebase**

```bash
firebase login
```

### **3. Initialize Functions di Project**

```bash
cd /path/to/your/project
firebase init functions
```

Pilih:
- ✅ JavaScript atau TypeScript (recommended: TypeScript)
- ✅ Install dependencies? Yes

### **4. Project Structure**

Setelah init, struktur akan seperti ini:

```
finance_app/
├── functions/
│   ├── src/
│   │   └── index.ts
│   ├── package.json
│   └── tsconfig.json
├── lib/
└── ...
```

---

## 📝 Contoh Firebase Functions untuk Finance App

### **1. Daily Financial Summary (Scheduled Task)**

Buat file `functions/src/dailySummary.ts`:

```typescript
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();

/**
 * Generate dan kirim daily financial summary ke semua user
 * Dijalankan setiap hari jam 8 pagi
 */
export const sendDailySummary = functions.pubsub
  .schedule('0 8 * * *') // Setiap hari jam 8 pagi (UTC)
  .timeZone('Asia/Jakarta')
  .onRun(async (context) => {
    const db = admin.firestore();
    const messaging = admin.messaging();

    // Get semua users
    const usersSnapshot = await db.collection('users').get();

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
        .collection('transactions')
        .where('userId', '==', userId)
        .where('date', '>=', admin.firestore.Timestamp.fromDate(today))
        .where('date', '<', admin.firestore.Timestamp.fromDate(tomorrow))
        .get();

      const todayTransactions = transactionsSnapshot.docs.map(
        (doc) => doc.data()
      );

      const totalIncome = todayTransactions
        .filter((t) => t.type === 'income')
        .reduce((sum, t) => sum + (t.amount || 0), 0);

      const totalExpense = todayTransactions
        .filter((t) => t.type === 'expense')
        .reduce((sum, t) => sum + (t.amount || 0), 0);

      // Prepare notification
      const tokens = fcmTokens.map((t: any) => t.token);
      const message = {
        notification: {
          title: '📊 Ringkasan Finansial Hari Ini',
          body: `Pemasukan: Rp ${totalIncome.toLocaleString('id-ID')} | Pengeluaran: Rp ${totalExpense.toLocaleString('id-ID')}`,
        },
        data: {
          type: 'daily_summary',
          action: 'view',
          totalIncome: totalIncome.toString(),
          totalExpense: totalExpense.toString(),
          priority: 'medium',
        },
        tokens: tokens,
      };

      try {
        await messaging.sendEachForMulticast(message);
        console.log(`Daily summary sent to user: ${userId}`);
      } catch (error) {
        console.error(`Error sending to user ${userId}:`, error);
      }
    }

    return null;
  });
```

### **2. Bill Reminder (Scheduled Task)**

Buat file `functions/src/billReminder.ts`:

```typescript
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

/**
 * Check bills yang akan jatuh tempo besok dan kirim reminder
 * Dijalankan setiap hari jam 9 pagi
 */
export const sendBillReminders = functions.pubsub
  .schedule('0 9 * * *') // Setiap hari jam 9 pagi
  .timeZone('Asia/Jakarta')
  .onRun(async (context) => {
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
      .collection('bills')
      .where('status', '==', 'pending')
      .where('dueDate', '>=', admin.firestore.Timestamp.fromDate(tomorrow))
      .where('dueDate', '<', admin.firestore.Timestamp.fromDate(dayAfter))
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
      const userDoc = await db.collection('users').doc(userId).get();
      if (!userDoc.exists) continue;

      const userData = userDoc.data();
      const fcmTokens = userData?.fcmTokens || [];
      if (fcmTokens.length === 0) continue;

      const tokens = fcmTokens.map((t: any) => t.token);
      const billsCount = bills.length;
      const totalAmount = bills.reduce((sum, b) => sum + (b.amount || 0), 0);

      const message = {
        notification: {
          title: `⏰ ${billsCount} Tagihan Jatuh Tempo Besok`,
          body: `Total: Rp ${totalAmount.toLocaleString('id-ID')}`,
        },
        data: {
          type: 'bill',
          action: 'due_soon',
          billsCount: billsCount.toString(),
          totalAmount: totalAmount.toString(),
          priority: 'high',
        },
        tokens: tokens,
      };

      try {
        await messaging.sendEachForMulticast(message);
        console.log(`Bill reminder sent to user: ${userId}`);
      } catch (error) {
        console.error(`Error sending to user ${userId}:`, error);
      }
    }

    return null;
  });
```

### **3. Overdue Bills Checker**

Buat file `functions/src/overdueBills.ts`:

```typescript
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

/**
 * Check bills yang sudah overdue dan kirim alert
 * Dijalankan setiap hari jam 10 pagi
 */
export const checkOverdueBills = functions.pubsub
  .schedule('0 10 * * *') // Setiap hari jam 10 pagi
  .timeZone('Asia/Jakarta')
  .onRun(async (context) => {
    const db = admin.firestore();
    const messaging = admin.messaging();

    const today = new Date();
    today.setHours(0, 0, 0, 0);

    // Get semua bills yang overdue
    const billsSnapshot = await db
      .collection('bills')
      .where('status', '==', 'pending')
      .where('dueDate', '<', admin.firestore.Timestamp.fromDate(today))
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
      const userDoc = await db.collection('users').doc(userId).get();
      if (!userDoc.exists) continue;

      const userData = userDoc.data();
      const fcmTokens = userData?.fcmTokens || [];
      if (fcmTokens.length === 0) continue;

      const tokens = fcmTokens.map((t: any) => t.token);
      const billsCount = bills.length;
      const totalAmount = bills.reduce((sum, b) => sum + (b.amount || 0), 0);

      const message = {
        notification: {
          title: `🚨 ${billsCount} Tagihan Terlambat!`,
          body: `Total: Rp ${totalAmount.toLocaleString('id-ID')}`,
        },
        data: {
          type: 'bill',
          action: 'overdue',
          billsCount: billsCount.toString(),
          totalAmount: totalAmount.toString(),
          priority: 'urgent',
        },
        tokens: tokens,
      };

      try {
        await messaging.sendEachForMulticast(message);
        console.log(`Overdue bills alert sent to user: ${userId}`);
      } catch (error) {
        console.error(`Error sending to user ${userId}:`, error);
      }
    }

    return null;
  });
```

### **4. Auto Create Recurring Transactions**

Buat file `functions/src/recurringTransactions.ts`:

```typescript
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

/**
 * Auto-create transactions dari recurring transactions
 * Dijalankan setiap hari jam 6 pagi
 */
export const createRecurringTransactions = functions.pubsub
  .schedule('0 6 * * *') // Setiap hari jam 6 pagi
  .timeZone('Asia/Jakarta')
  .onRun(async (context) => {
    const db = admin.firestore();
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    // Get semua recurring transactions yang aktif
    const recurringSnapshot = await db
      .collection('recurring_transactions')
      .where('isActive', '==', true)
      .get();

    for (const doc of recurringSnapshot.docs) {
      const recurring = doc.data();
      const nextDueDate = recurring.nextDueDate?.toDate();

      // Check jika sudah waktunya create transaction
      if (nextDueDate && nextDueDate <= today) {
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

        await db.collection('transactions').add(transaction);

        // Update nextDueDate berdasarkan frequency
        let newNextDueDate = new Date(nextDueDate);
        switch (recurring.frequency) {
          case 'daily':
            newNextDueDate.setDate(newNextDueDate.getDate() + 1);
            break;
          case 'weekly':
            newNextDueDate.setDate(newNextDueDate.getDate() + 7);
            break;
          case 'monthly':
            newNextDueDate.setMonth(newNextDueDate.getMonth() + 1);
            break;
          case 'yearly':
            newNextDueDate.setFullYear(newNextDueDate.getFullYear() + 1);
            break;
        }

        await doc.ref.update({
          nextDueDate: admin.firestore.Timestamp.fromDate(newNextDueDate),
          lastCreatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        console.log(`Created transaction from recurring: ${doc.id}`);
      }
    }

    return null;
  });
```

### **5. Monthly Financial Report**

Buat file `functions/src/monthlyReport.ts`:

```typescript
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

/**
 * Generate dan kirim monthly financial report
 * Dijalankan tanggal 1 setiap bulan jam 8 pagi
 */
export const sendMonthlyReport = functions.pubsub
  .schedule('0 8 1 * *') // Tanggal 1 setiap bulan jam 8 pagi
  .timeZone('Asia/Jakarta')
  .onRun(async (context) => {
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
    const usersSnapshot = await db.collection('users').get();

    for (const userDoc of usersSnapshot.docs) {
      const userId = userDoc.id;
      const userData = userDoc.data();
      const fcmTokens = userData.fcmTokens || [];

      if (fcmTokens.length === 0) continue;

      // Get transactions bulan lalu
      const transactionsSnapshot = await db
        .collection('transactions')
        .where('userId', '==', userId)
        .where('date', '>=', admin.firestore.Timestamp.fromDate(lastMonth))
        .where('date', '<', admin.firestore.Timestamp.fromDate(thisMonth))
        .get();

      const transactions = transactionsSnapshot.docs.map((doc) => doc.data());

      const totalIncome = transactions
        .filter((t) => t.type === 'income')
        .reduce((sum, t) => sum + (t.amount || 0), 0);

      const totalExpense = transactions
        .filter((t) => t.type === 'expense')
        .reduce((sum, t) => sum + (t.amount || 0), 0);

      const netIncome = totalIncome - totalExpense;

      const tokens = fcmTokens.map((t: any) => t.token);
      const message = {
        notification: {
          title: '📈 Laporan Finansial Bulanan',
          body: `Pemasukan: Rp ${totalIncome.toLocaleString('id-ID')} | Pengeluaran: Rp ${totalExpense.toLocaleString('id-ID')} | Saldo: Rp ${netIncome.toLocaleString('id-ID')}`,
        },
        data: {
          type: 'report',
          action: 'monthly',
          totalIncome: totalIncome.toString(),
          totalExpense: totalExpense.toString(),
          netIncome: netIncome.toString(),
          priority: 'medium',
        },
        tokens: tokens,
      };

      try {
        await messaging.sendEachForMulticast(message);
        console.log(`Monthly report sent to user: ${userId}`);
      } catch (error) {
        console.error(`Error sending to user ${userId}:`, error);
      }
    }

    return null;
  });
```

---

## 📦 Setup Functions Project

### **1. Install Dependencies**

```bash
cd functions
npm install firebase-functions firebase-admin
npm install --save-dev @types/node typescript
```

### **2. Update `functions/src/index.ts`**

```typescript
import * as functions from 'firebase-functions';
import { sendDailySummary } from './dailySummary';
import { sendBillReminders } from './billReminder';
import { checkOverdueBills } from './overdueBills';
import { createRecurringTransactions } from './recurringTransactions';
import { sendMonthlyReport } from './monthlyReport';

// Export semua functions
export { sendDailySummary };
export { sendBillReminders };
export { checkOverdueBills };
export { createRecurringTransactions };
export { sendMonthlyReport };
```

### **3. Deploy Functions**

```bash
firebase deploy --only functions
```

---

## ⚙️ Configuration

### **1. Update `functions/package.json`**

```json
{
  "name": "functions",
  "scripts": {
    "build": "tsc",
    "serve": "npm run build && firebase emulators:start --only functions",
    "shell": "npm run build && firebase functions:shell",
    "start": "npm run shell",
    "deploy": "firebase deploy --only functions",
    "logs": "firebase functions:log"
  },
  "engines": {
    "node": "18"
  },
  "main": "lib/index.js",
  "dependencies": {
    "firebase-admin": "^12.0.0",
    "firebase-functions": "^4.5.0"
  },
  "devDependencies": {
    "typescript": "^4.9.0",
    "@types/node": "^18.0.0"
  },
  "private": true
}
```

### **2. Update `functions/tsconfig.json`**

```json
{
  "compilerOptions": {
    "module": "commonjs",
    "noImplicitReturns": true,
    "noUnusedLocals": true,
    "outDir": "lib",
    "sourceMap": true,
    "strict": true,
    "target": "es2017"
  },
  "compileOnSave": true,
  "include": [
    "src"
  ]
}
```

---

## 🧪 Testing Functions Locally

### **1. Start Emulator**

```bash
firebase emulators:start --only functions
```

### **2. Test Function**

```bash
# Test scheduled function
firebase functions:shell
> sendDailySummary()
```

---

## 📊 Monitoring & Logs

### **View Logs**

```bash
firebase functions:log
```

### **View di Firebase Console**

1. Buka Firebase Console
2. Pilih project
3. Klik "Functions" di sidebar
4. Lihat logs dan metrics

---

## 💰 Pricing

Firebase Functions menggunakan **pay-as-you-go**:
- **Free tier**: 2 juta invocations/bulan
- **Paid**: $0.40 per 1 juta invocations setelah free tier

Untuk finance app dengan scheduled tasks:
- Daily summary: ~30 invocations/bulan per user
- Bill reminders: ~30 invocations/bulan per user
- Monthly report: ~12 invocations/tahun per user

**Total**: ~72 invocations/bulan per user (sangat terjangkau!)

---

## 🎯 Next Steps

1. **Setup Functions project** sesuai guide di atas
2. **Copy contoh functions** ke `functions/src/`
3. **Deploy functions** ke Firebase
4. **Monitor logs** untuk memastikan functions bekerja
5. **Test dengan Firebase Console** → Functions → Test

---

## 📝 Notes

- Functions dijalankan di **UTC timezone**, gunakan `.timeZone()` untuk timezone lokal
- **FCM tokens** diambil dari `users/{userId}/fcmTokens` array
- **Scheduled functions** menggunakan Cloud Scheduler (gratis untuk 3 jobs pertama)
- **Always test functions** di emulator sebelum deploy ke production


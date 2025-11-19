# 🔥 Firebase Functions untuk Finance App

## 📋 Daftar Functions

### 1. **Daily Financial Summary** (`sendDailySummary`)
- **Schedule**: Setiap hari jam 8 pagi WIB
- **Fungsi**: Mengirim ringkasan finansial harian (pemasukan, pengeluaran, saldo)
- **File**: `src/dailySummary.ts`

### 2. **Bill Reminder** (`sendBillReminders`)
- **Schedule**: Setiap hari jam 9 pagi WIB
- **Fungsi**: Mengirim reminder untuk tagihan yang jatuh tempo besok
- **File**: `src/billReminder.ts`

### 3. **Overdue Bills Checker** (`checkOverdueBills`)
- **Schedule**: Setiap hari jam 10 pagi WIB
- **Fungsi**: Mengirim alert untuk tagihan yang sudah terlambat
- **File**: `src/overdueBills.ts`

### 4. **Recurring Transactions** (`createRecurringTransactions`)
- **Schedule**: Setiap hari jam 6 pagi WIB
- **Fungsi**: Auto-create transactions dari recurring transactions yang aktif
- **File**: `src/recurringTransactions.ts`

### 5. **Monthly Report** (`sendMonthlyReport`)
- **Schedule**: Tanggal 1 setiap bulan jam 8 pagi WIB
- **Fungsi**: Mengirim laporan finansial bulanan
- **File**: `src/monthlyReport.ts`

### 6. **Budget Alert** (`checkBudgetAlerts`)
- **Schedule**: Setiap hari jam 7 pagi WIB
- **Fungsi**: Mengirim alert untuk budget yang melebihi limit atau mendekati limit (80%)
- **File**: `src/budgetAlert.ts`

---

## 🚀 Development

### Build Functions
```bash
cd functions
npm run build
```

### Test Locally (Emulator)
```bash
npm run serve
```

### Deploy Functions
```bash
# Deploy semua functions
firebase deploy --only functions

# Deploy function tertentu
firebase deploy --only functions:sendDailySummary
```

### View Logs
```bash
firebase functions:log
```

---

## 📝 Notes

- Semua functions menggunakan **v1 API** dengan scheduled triggers
- Functions menggunakan **timezone Asia/Jakarta (WIB)**
- Notifications dikirim via **FCM (Firebase Cloud Messaging)**
- FCM tokens diambil dari `users/{userId}/fcmTokens` array
- Functions akan skip user yang tidak punya FCM tokens

---

## ⚙️ Configuration

### Schedule Format (Cron)
```
┌───────────── minute (0 - 59)
│ ┌───────────── hour (0 - 23)
│ │ ┌───────────── day of month (1 - 31)
│ │ │ ┌───────────── month (1 - 12)
│ │ │ │ ┌───────────── day of week (0 - 6) (Sunday to Saturday)
│ │ │ │ │
* * * * *
```

### Contoh:
- `0 8 * * *` = Setiap hari jam 8 pagi
- `0 8 1 * *` = Tanggal 1 setiap bulan jam 8 pagi
- `0 */6 * * *` = Setiap 6 jam

---

## 🔒 Security

- Functions menggunakan **Firestore Security Rules** untuk validasi data
- Hanya user yang authenticated yang bisa menerima notifications
- FCM tokens disimpan per user dengan isolasi yang aman

---

## 💰 Pricing

Firebase Functions menggunakan **pay-as-you-go**:
- **Free tier**: 2 juta invocations/bulan
- **Paid**: $0.40 per 1 juta invocations setelah free tier

Dengan 6 functions yang dijalankan setiap hari:
- Per user: ~180 invocations/bulan
- 1000 users: ~180,000 invocations/bulan (masih dalam free tier!)

---

## 📊 Monitoring

Monitor functions di Firebase Console:
1. Buka Firebase Console
2. Pilih project
3. Klik "Functions" di sidebar
4. Lihat logs, metrics, dan errors


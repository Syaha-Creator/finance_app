# 🚀 Firebase Functions Deploy Guide

## ✅ Status Functions

Semua functions sudah siap dan **tidak ada error**:
- ✅ Build berhasil
- ✅ Lint: 0 errors, 27 warnings (warnings tidak menghalangi deploy)
- ✅ Semua 6 functions sudah dibuat dan siap deploy

---

## 📋 Daftar Functions yang Siap Deploy

1. **sendDailySummary** - Daily financial summary (jam 8 pagi WIB)
2. **sendBillReminders** - Bill reminders (jam 9 pagi WIB)
3. **checkOverdueBills** - Overdue bills alert (jam 10 pagi WIB)
4. **createRecurringTransactions** - Auto-create recurring transactions (jam 6 pagi WIB)
5. **sendMonthlyReport** - Monthly report (tanggal 1 setiap bulan jam 8 pagi WIB)
6. **checkBudgetAlerts** - Budget alerts (jam 7 pagi WIB)

---

## 🔥 Upgrade ke Blaze Plan (Required)

Firebase Functions **memerlukan Blaze plan** untuk deploy. Tapi jangan khawatir:

### **Blaze Plan = Pay-as-you-go**
- ✅ **Free tier tetap gratis** untuk:
  - 2 juta function invocations/bulan
  - 400,000 GB-seconds compute time/bulan
  - 5 GB egress/bulan

### **Cara Upgrade:**
1. Buka: https://console.firebase.google.com/project/finance-app-b875c/usage/details
2. Klik **"Upgrade to Blaze"**
3. Masukkan payment method (tidak akan dikenakan biaya kecuali melebihi free tier)
4. Setelah upgrade, deploy functions

### **Estimasi Biaya:**
Dengan 6 functions yang dijalankan setiap hari:
- Per user: ~180 invocations/bulan
- 1000 users: ~180,000 invocations/bulan
- **Masih dalam free tier!** (2 juta invocations gratis)

---

## 🚀 Deploy Functions

Setelah upgrade ke Blaze plan:

```bash
cd /Users/syahrulazhar/StudioProjects/finance_app
firebase deploy --only functions
```

### **Deploy Function Tertentu:**
```bash
# Deploy hanya daily summary
firebase deploy --only functions:sendDailySummary

# Deploy hanya bill reminders
firebase deploy --only functions:sendBillReminders
```

---

## 🧪 Test di Emulator (Tanpa Upgrade)

Jika belum upgrade, bisa test di emulator lokal:

```bash
cd functions
npm run serve
```

Ini akan:
- Start Firebase Emulator
- Functions bisa di-test secara lokal
- Tidak perlu Blaze plan

---

## 📊 Monitor Functions

Setelah deploy, monitor di Firebase Console:
1. Buka Firebase Console → Functions
2. Lihat logs, metrics, dan errors
3. Check execution time dan invocations

---

## ⚠️ Catatan Penting

1. **Blaze plan diperlukan** untuk deploy functions
2. **Free tier sangat generus** - kemungkinan besar tidak akan dikenakan biaya
3. **Functions akan otomatis berjalan** sesuai schedule setelah deploy
4. **Monitor logs** untuk memastikan functions bekerja dengan baik

---

## ✅ Checklist Sebelum Deploy

- [x] Build berhasil (no errors)
- [x] Lint: 0 errors
- [x] Semua functions sudah dibuat
- [ ] Upgrade ke Blaze plan
- [ ] Deploy functions
- [ ] Monitor logs

---

## 🎯 Next Steps

1. **Upgrade ke Blaze plan** (jika belum)
2. **Deploy functions** dengan `firebase deploy --only functions`
3. **Monitor logs** di Firebase Console
4. **Test functions** dengan membuat data test di Firestore

---

## 💡 Tips

- **Test di emulator dulu** sebelum deploy ke production
- **Monitor invocations** untuk memastikan tidak melebihi free tier
- **Set up alerts** di Firebase Console untuk monitoring
- **Check logs regularly** untuk memastikan functions bekerja


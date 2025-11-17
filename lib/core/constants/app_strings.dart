/// Centralized string constants for the application
/// This class prepares the structure for future localization
/// Currently contains Indonesian strings, but can be extended with localization support
class AppStrings {
  AppStrings._();

  // App Info
  static const String appName = 'Finance App';
  static const String appTagline = 'Kelola keuangan Anda dengan mudah';

  // Authentication
  static const String login = 'Masuk';
  static const String register = 'Daftar';
  static const String logout = 'Keluar';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Konfirmasi Password';
  static const String name = 'Nama';
  static const String forgotPassword = 'Lupa Password?';
  static const String resetPassword = 'Reset Password';
  static const String sendResetLink = 'Kirim Link Reset';
  static const String loginNow = 'Masuk Sekarang';
  static const String registerNow = 'Daftar Sekarang';
  static const String loginWithGoogle = 'Masuk dengan Google';
  static const String dontHaveAccount = 'Belum punya akun?';
  static const String alreadyHaveAccount = 'Sudah punya akun?';
  static const String welcomeBack = 'Selamat Datang! 👋';
  static const String loginSubtitle = 'Masuk ke akunmu untuk melanjutkan';
  static const String createAccount = 'Buat Akun Baru';
  static const String registerSubtitle =
      'Daftar sekarang dan mulai kelola keuanganmu';
  static const String agreeToTerms = 'Saya menyetujui syarat dan ketentuan';
  static const String mustAgreeToTerms =
      'Anda harus menyetujui syarat dan ketentuan terlebih dahulu';
  static const String emailSent = 'Email reset password telah dikirim';
  static const String checkEmail = 'Cek email Anda untuk link reset password';

  // Common Actions
  static const String save = 'Simpan';
  static const String cancel = 'Batal';
  static const String delete = 'Hapus';
  static const String edit = 'Edit';
  static const String add = 'Tambah';
  static const String update = 'Update';
  static const String submit = 'Kirim';
  static const String back = 'Kembali';
  static const String next = 'Selanjutnya';
  static const String previous = 'Sebelumnya';
  static const String done = 'Selesai';
  static const String close = 'Tutup';
  static const String confirm = 'Konfirmasi';
  static const String yes = 'Ya';
  static const String no = 'Tidak';
  static const String ok = 'OK';

  // Transactions
  static const String transactions = 'Transaksi';
  static const String income = 'Pemasukan';
  static const String expense = 'Pengeluaran';
  static const String transfer = 'Transfer';
  static const String addTransaction = 'Tambah Transaksi';
  static const String editTransaction = 'Edit Transaksi';
  static const String deleteTransaction = 'Hapus Transaksi';
  static const String transactionDetail = 'Detail Transaksi';
  static const String amount = 'Jumlah';
  static const String description = 'Deskripsi';
  static const String date = 'Tanggal';
  static const String category = 'Kategori';
  static const String account = 'Akun';
  static const String recurringTransaction = 'Transaksi Berulang';
  static const String addRecurring = 'Tambah Transaksi Berulang';

  // Goals
  static const String goals = 'Tujuan';
  static const String addGoal = 'Tambah Tujuan';
  static const String editGoal = 'Edit Tujuan';
  static const String goalDetail = 'Detail Tujuan';
  static const String targetAmount = 'Target Jumlah';
  static const String currentAmount = 'Jumlah Saat Ini';
  static const String progress = 'Progress';
  static const String deadline = 'Batas Waktu';

  // Assets
  static const String assets = 'Aset';
  static const String addAsset = 'Tambah Aset';
  static const String editAsset = 'Edit Aset';
  static const String assetType = 'Jenis Aset';
  static const String assetValue = 'Nilai Aset';

  // Debts
  static const String debts = 'Hutang';
  static const String addDebt = 'Tambah Hutang';
  static const String editDebt = 'Edit Hutang';
  static const String debtAmount = 'Jumlah Hutang';
  static const String remainingAmount = 'Sisa Hutang';
  static const String paid = 'Lunas';
  static const String unpaid = 'Belum Lunas';

  // Bills
  static const String bills = 'Tagihan';
  static const String addBill = 'Tambah Tagihan';
  static const String editBill = 'Edit Tagihan';
  static const String billName = 'Nama Tagihan';
  static const String dueDate = 'Tanggal Jatuh Tempo';
  static const String paidBill = 'Sudah Dibayar';
  static const String unpaidBill = 'Belum Dibayar';

  // Budget
  static const String budget = 'Anggaran';
  static const String monthlyBudget = 'Anggaran Bulanan';
  static const String budgetLimit = 'Batas Anggaran';
  static const String spent = 'Terpakai';
  static const String remaining = 'Sisa';

  // Investments
  static const String investments = 'Investasi';
  static const String addInvestment = 'Tambah Investasi';
  static const String editInvestment = 'Edit Investasi';
  static const String investmentType = 'Jenis Investasi';
  static const String investmentValue = 'Nilai Investasi';

  // Receipts
  static const String receipts = 'Struk';
  static const String addReceipt = 'Tambah Struk';
  static const String receiptManagement = 'Manajemen Struk';
  static const String scanReceipt = 'Scan Struk';

  // Dashboard
  static const String dashboard = 'Dashboard';
  static const String overview = 'Ringkasan';
  static const String totalIncome = 'Total Pemasukan';
  static const String totalExpense = 'Total Pengeluaran';
  static const String balance = 'Saldo';
  static const String netWorth = 'Kekayaan Bersih';
  static const String monthlyComparison = 'Perbandingan Bulanan';
  static const String financialHealth = 'Kesehatan Keuangan';

  // Settings
  static const String settings = 'Pengaturan';
  static const String profile = 'Profil';
  static const String editProfile = 'Edit Profil';
  static const String changePassword = 'Ubah Password';
  static const String notifications = 'Notifikasi';
  static const String language = 'Bahasa';
  static const String theme = 'Tema';
  static const String about = 'Tentang';
  static const String help = 'Bantuan';
  static const String privacy = 'Privasi';
  static const String terms = 'Syarat & Ketentuan';

  // Master Data
  static const String masterData = 'Data Master';
  static const String categories = 'Kategori';
  static const String accounts = 'Akun';
  static const String addCategory = 'Tambah Kategori';
  static const String editCategory = 'Edit Kategori';
  static const String addAccount = 'Tambah Akun';
  static const String editAccount = 'Edit Akun';

  // Messages
  static const String loading = 'Memuat...';
  static const String noData = 'Tidak ada data';
  static const String error = 'Terjadi kesalahan';
  static const String success = 'Berhasil';
  static const String warning = 'Peringatan';
  static const String info = 'Informasi';
  static const String confirmDelete = 'Apakah Anda yakin ingin menghapus?';
  static const String deleteSuccess = 'Berhasil dihapus';
  static const String saveSuccess = 'Berhasil disimpan';
  static const String updateSuccess = 'Berhasil diupdate';
  static const String addSuccess = 'Berhasil ditambahkan';

  // Validation Messages
  static const String fieldRequired = 'Field ini wajib diisi';
  static const String invalidEmail = 'Email tidak valid';
  static const String passwordTooShort = 'Password minimal 6 karakter';
  static const String passwordNotMatch = 'Password tidak cocok';
  static const String invalidAmount = 'Jumlah tidak valid';
  static const String invalidDate = 'Tanggal tidak valid';

  // Time
  static const String today = 'Hari Ini';
  static const String yesterday = 'Kemarin';
  static const String thisWeek = 'Minggu Ini';
  static const String thisMonth = 'Bulan Ini';
  static const String thisYear = 'Tahun Ini';
  static const String lastMonth = 'Bulan Lalu';
  static const String lastYear = 'Tahun Lalu';
  static const String allTime = 'Semua Waktu';

  // Months
  static const String january = 'Januari';
  static const String february = 'Februari';
  static const String march = 'Maret';
  static const String april = 'April';
  static const String may = 'Mei';
  static const String june = 'Juni';
  static const String july = 'Juli';
  static const String august = 'Agustus';
  static const String september = 'September';
  static const String october = 'Oktober';
  static const String november = 'November';
  static const String december = 'Desember';

  // Days
  static const String monday = 'Senin';
  static const String tuesday = 'Selasa';
  static const String wednesday = 'Rabu';
  static const String thursday = 'Kamis';
  static const String friday = 'Jumat';
  static const String saturday = 'Sabtu';
  static const String sunday = 'Minggu';
}

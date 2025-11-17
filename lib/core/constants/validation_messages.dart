class ValidationMessages {
  ValidationMessages._();

  // Common
  static const String fieldRequired = 'Field ini tidak boleh kosong';
  static const String fieldCannotBeEmpty = 'Field ini harus diisi';
  static const String invalidInput = 'Input tidak valid';

  // Name
  static const String nameRequired = 'Nama tidak boleh kosong';
  static const String nameMinLength = 'Nama minimal 2 karakter';
  static const String nameMaxLength = 'Nama maksimal 100 karakter';

  // Email
  static const String emailRequired = 'Email tidak boleh kosong';
  static const String emailInvalid = 'Email tidak valid';
  static const String emailFormat = 'Format email tidak valid';

  // Password
  static const String passwordRequired = 'Password tidak boleh kosong';
  static const String passwordMinLength = 'Password minimal 6 karakter';
  static const String passwordMaxLength = 'Password maksimal 50 karakter';
  static const String passwordNotMatch = 'Password tidak cocok';
  static const String confirmPasswordRequired = 'Konfirmasi password tidak boleh kosong';
  static const String confirmPasswordNotMatch = 'Konfirmasi password tidak cocok';

  // Amount
  static const String amountRequired = 'Jumlah tidak boleh kosong';
  static const String amountInvalid = 'Jumlah tidak valid';
  static const String amountMustBePositive = 'Jumlah harus lebih dari 0';
  static const String amountMinValue = 'Jumlah minimal adalah 1';

  // Date
  static const String dateRequired = 'Tanggal tidak boleh kosong';
  static const String dateInvalid = 'Tanggal tidak valid';
  static const String dateMustBeFuture = 'Tanggal harus di masa depan';
  static const String dateMustBePast = 'Tanggal harus di masa lalu';

  // Category
  static const String categoryRequired = 'Kategori harus dipilih';
  static const String categoryInvalid = 'Kategori tidak valid';

  // Account
  static const String accountRequired = 'Akun harus dipilih';
  static const String accountInvalid = 'Akun tidak valid';

  // Description
  static const String descriptionRequired = 'Deskripsi tidak boleh kosong';
  static const String descriptionMinLength = 'Deskripsi minimal 3 karakter';
  static const String descriptionMaxLength = 'Deskripsi maksimal 500 karakter';

  // Title
  static const String titleRequired = 'Judul tidak boleh kosong';
  static const String titleMinLength = 'Judul minimal 3 karakter';
  static const String titleMaxLength = 'Judul maksimal 200 karakter';

  // Terms and Conditions
  static const String termsRequired = 'Anda harus menyetujui syarat dan ketentuan terlebih dahulu';

  // Goal
  static const String goalNameRequired = 'Nama tujuan tidak boleh kosong';
  static const String targetAmountRequired = 'Jumlah target tidak boleh kosong';
  static const String targetDateRequired = 'Tanggal target tidak boleh kosong';

  // Debt
  static const String personNameRequired = 'Nama orang tidak boleh kosong';
  static const String debtAmountRequired = 'Jumlah utang tidak boleh kosong';

  // Bill
  static const String billTitleRequired = 'Judul tagihan harus diisi';
  static const String billAmountRequired = 'Jumlah tagihan harus diisi';
  static const String billAmountMustBePositive = 'Jumlah tagihan harus lebih dari 0';

  // Receipt
  static const String merchantNameRequired = 'Nama merchant harus diisi';
  static const String receiptAmountRequired = 'Total amount harus diisi';
  static const String receiptAmountMustBePositive = 'Total amount harus lebih dari 0';

  // Asset
  static const String assetNameRequired = 'Nama aset tidak boleh kosong';
  static const String assetValueRequired = 'Nilai aset tidak boleh kosong';
  static const String assetValueMustBePositive = 'Nilai aset harus lebih dari 0';

  // Investment
  static const String investmentNameRequired = 'Nama investasi tidak boleh kosong';
  static const String investmentAmountRequired = 'Jumlah investasi tidak boleh kosong';
  static const String investmentAmountMustBePositive = 'Jumlah investasi harus lebih dari 0';
}


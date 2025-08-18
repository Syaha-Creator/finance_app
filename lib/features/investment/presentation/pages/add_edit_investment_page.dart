import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/thousand_input_formatter.dart';
import '../../data/models/investment_model.dart';
import '../provider/investment_provider.dart';

class AddEditInvestmentPage extends ConsumerStatefulWidget {
  final InvestmentModel? investment;

  const AddEditInvestmentPage({super.key, this.investment});

  @override
  ConsumerState<AddEditInvestmentPage> createState() =>
      _AddEditInvestmentPageState();
}

class _AddEditInvestmentPageState extends ConsumerState<AddEditInvestmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _symbolController = TextEditingController();
  final _quantityController = TextEditingController();
  final _averagePriceController = TextEditingController();
  final _currentPriceController = TextEditingController();
  final _notesController = TextEditingController();

  InvestmentType _selectedType = InvestmentType.stock;
  DateTime _selectedPurchaseDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.investment != null) {
      _loadInvestmentData();
    }
  }

  void _loadInvestmentData() {
    final investment = widget.investment!;
    _nameController.text = investment.name;
    _symbolController.text = investment.symbol;
    _quantityController.text = investment.quantity.toString();
    _averagePriceController.text = investment.averagePrice.toString();
    _currentPriceController.text = investment.currentPrice.toString();
    _notesController.text = investment.notes ?? '';
    _selectedType = investment.type;
    _selectedPurchaseDate = investment.purchaseDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _symbolController.dispose();
    _quantityController.dispose();
    _averagePriceController.dispose();
    _currentPriceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.investment != null;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Investasi' : 'Tambah Investasi'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (isEditing)
            IconButton(
              onPressed: _showDeleteDialog,
              icon: const Icon(Icons.delete_outline),
              color: AppColors.error,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Basic Information
            _buildSectionCard(
              title: 'Informasi Dasar',
              icon: Icons.info_outline,
              children: [
                _buildTextField(
                  controller: _nameController,
                  label: 'Nama Investasi',
                  hint: 'Contoh: Saham Bank BCA',
                  icon: Icons.trending_up,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama investasi harus diisi';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                _buildTextField(
                  controller: _symbolController,
                  label: 'Symbol/Ticker',
                  hint: 'Contoh: BBCA',
                  icon: Icons.tag,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Symbol harus diisi';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                _buildDropdownField(
                  label: 'Jenis Investasi',
                  icon: Icons.category,
                  value: _selectedType,
                  items:
                      InvestmentType.values.map((type) {
                        String label;
                        switch (type) {
                          case InvestmentType.stock:
                            label = 'Saham';
                            break;
                          case InvestmentType.mutualFund:
                            label = 'Reksadana';
                            break;
                          case InvestmentType.crypto:
                            label = 'Cryptocurrency';
                            break;
                          case InvestmentType.bond:
                            label = 'Obligasi';
                            break;
                          case InvestmentType.gold:
                            label = 'Emas';
                            break;
                          case InvestmentType.property:
                            label = 'Properti';
                            break;
                          case InvestmentType.other:
                            label = 'Lainnya';
                            break;
                        }
                        return DropdownMenuItem<InvestmentType>(
                          value: type,
                          child: Text(label),
                        );
                      }).toList(),
                  onChanged: (InvestmentType? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedType = newValue;
                      });
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Investment Details
            _buildSectionCard(
              title: 'Detail Investasi',
              icon: Icons.analytics_outlined,
              children: [
                _buildTextField(
                  controller: _quantityController,
                  label: 'Jumlah Unit',
                  hint: '0',
                  icon: Icons.analytics_outlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [ThousandInputFormatter()],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Jumlah unit harus diisi';
                    }
                    final quantity = double.tryParse(value.replaceAll('.', ''));
                    if (quantity == null || quantity <= 0) {
                      return 'Jumlah unit harus lebih dari 0';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                _buildTextField(
                  controller: _averagePriceController,
                  label: 'Harga Rata-rata per Unit',
                  hint: '0',
                  icon: Icons.price_check_outlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [ThousandInputFormatter()],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harga rata-rata harus diisi';
                    }
                    final price = double.tryParse(value.replaceAll('.', ''));
                    if (price == null || price <= 0) {
                      return 'Harga rata-rata harus lebih dari 0';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                _buildTextField(
                  controller: _currentPriceController,
                  label: 'Harga Sekarang per Unit',
                  hint: '0',
                  icon: Icons.trending_up_outlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [ThousandInputFormatter()],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harga sekarang harus diisi';
                    }
                    final price = double.tryParse(value.replaceAll('.', ''));
                    if (price == null || price <= 0) {
                      return 'Harga sekarang harus lebih dari 0';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                _buildDateField(),
              ],
            ),

            const SizedBox(height: 16),

            // Notes
            _buildSectionCard(
              title: 'Catatan',
              icon: Icons.note_outlined,
              children: [
                _buildTextField(
                  controller: _notesController,
                  label: 'Catatan (Opsional)',
                  hint: 'Catatan tambahan tentang investasi ini',
                  icon: Icons.note_outlined,
                  maxLines: 3,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Save Button
            ElevatedButton(
              onPressed: _saveInvestment,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isEditing ? 'Update Investasi' : 'Simpan Investasi',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required IconData icon,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          initialValue: value,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tanggal Pembelian',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  '${_selectedPurchaseDate.day}/${_selectedPurchaseDate.month}/${_selectedPurchaseDate.year}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Spacer(),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedPurchaseDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedPurchaseDate) {
      setState(() {
        _selectedPurchaseDate = picked;
      });
    }
  }

  void _saveInvestment() {
    if (_formKey.currentState!.validate()) {
      final quantity = double.parse(
        _quantityController.text.replaceAll('.', ''),
      );
      final averagePrice = double.parse(
        _averagePriceController.text.replaceAll('.', ''),
      );
      final currentPrice = double.parse(
        _currentPriceController.text.replaceAll('.', ''),
      );
      final totalInvested = quantity * averagePrice;
      final currentValue = quantity * currentPrice;
      final profitLoss = currentValue - totalInvested;
      final profitLossPercentage =
          totalInvested > 0 ? (profitLoss / totalInvested) * 100 : 0.0;

      final investment = InvestmentModel(
        id: widget.investment?.id ?? '',
        userId: '',
        name: _nameController.text.trim(),
        symbol: _symbolController.text.trim().toUpperCase(),
        type: _selectedType,
        quantity: quantity,
        averagePrice: averagePrice,
        currentPrice: currentPrice,
        totalInvested: totalInvested,
        currentValue: currentValue,
        profitLoss: profitLoss,
        profitLossPercentage: profitLossPercentage,
        status: InvestmentStatus.active,
        purchaseDate: _selectedPurchaseDate,
        sellDate: null,
        notes:
            _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
        createdAt: widget.investment?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.investment != null) {
        ref
            .read(investmentNotifierProvider.notifier)
            .updateInvestment(investment);
      } else {
        ref.read(investmentNotifierProvider.notifier).addInvestment(investment);
      }

      Navigator.pop(context);
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.delete_outline, color: AppColors.error),
                SizedBox(width: 8),
                Text('Hapus Investasi'),
              ],
            ),
            content: Text(
              'Apakah Anda yakin ingin menghapus investasi "${widget.investment!.name}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ref
                      .read(investmentNotifierProvider.notifier)
                      .deleteInvestment(widget.investment!.id);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Ya, Hapus'),
              ),
            ],
          ),
    );
  }
}

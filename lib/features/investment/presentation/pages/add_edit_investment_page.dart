import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/thousand_input_formatter.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/widgets/loading_action_button.dart';
import '../../data/models/investment_model.dart';
import '../providers/investment_provider.dart';

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
                CoreTextField(
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

                CoreTextField(
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

                CoreDropdown<InvestmentType>(
                  value: _selectedType,
                  onChanged: (newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedType = newValue;
                      });
                    }
                  },
                  label: 'Jenis Investasi',
                  icon: Icons.category,
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
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Investment Details
            _buildSectionCard(
              title: 'Detail Investasi',
              icon: Icons.analytics_outlined,
              children: [
                CoreTextField(
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

                CoreAmountInput(
                  controller: _averagePriceController,
                  label: 'Harga Rata-rata per Unit',
                  hint: '0',
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

                CoreAmountInput(
                  controller: _currentPriceController,
                  label: 'Harga Sekarang per Unit',
                  hint: '0',
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

                CoreDatePicker(
                  selectedDate: _selectedPurchaseDate,
                  onDateSelected: (date) {
                    setState(() => _selectedPurchaseDate = date);
                  },
                  label: 'Tanggal Pembelian',
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Notes
            _buildSectionCard(
              title: 'Catatan',
              icon: Icons.note_outlined,
              children: [
                CoreTextField(
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
            LoadingActionButton(
              onPressed: _saveInvestment,
              isLoading: false,
              text: isEditing ? 'Update Investasi' : 'Simpan Investasi',
              icon: isEditing ? Icons.save_outlined : Icons.add,
              height: 56,
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

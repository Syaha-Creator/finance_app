import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/thousand_input_formatter.dart';
import '../../application/currency_service.dart';
import '../../data/models/currency_model.dart';

class CurrencyConverterPage extends ConsumerStatefulWidget {
  const CurrencyConverterPage({super.key});

  @override
  ConsumerState<CurrencyConverterPage> createState() =>
      _CurrencyConverterPageState();
}

class _CurrencyConverterPageState extends ConsumerState<CurrencyConverterPage> {
  final _amountController = TextEditingController();
  final _feeController = TextEditingController();

  String _fromCurrency = 'IDR';
  String _toCurrency = 'USD';
  double _amount = 0.0;
  double _feePercentage = 0.0;
  Map<String, double> _exchangeRates = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _feeController.text = '0.0';
    _loadExchangeRates();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  Future<void> _loadExchangeRates() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final rates = await CurrencyService.getCurrentExchangeRates();
      if (mounted) {
        setState(() {
          _exchangeRates = rates;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat kurs mata uang: $e')),
        );
      }
    }
  }

  void _onAmountChanged(String value) {
    if (value.isEmpty) {
      setState(() {
        _amount = 0.0;
      });
      return;
    }

    final amount = double.tryParse(value.replaceAll('.', ''));
    if (amount != null) {
      setState(() {
        _amount = amount;
      });
    }
  }

  void _onFeeChanged(String value) {
    if (value.isEmpty) {
      setState(() {
        _feePercentage = 0.0;
      });
      return;
    }

    final fee = double.tryParse(value);
    if (fee != null) {
      setState(() {
        _feePercentage = fee;
      });
    }
  }

  void _swapCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
    });
  }

  Map<String, dynamic>? get _conversionSummary {
    if (_amount <= 0 || _exchangeRates.isEmpty) return null;

    return CurrencyService.getConversionSummary(
      _amount,
      _fromCurrency,
      _toCurrency,
      _exchangeRates,
      _feePercentage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Konverter Mata Uang'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadExchangeRates,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 16,
                ),
                children: [
                  // Exchange Rate Overview
                  _buildExchangeRateCard(),

                  const SizedBox(height: 24),

                  // Currency Converter
                  _buildConverterCard(),

                  const SizedBox(height: 24),

                  // Conversion Result
                  if (_conversionSummary != null) ...[
                    _buildResultCard(),
                    const SizedBox(height: 24),
                  ],

                  // Currency List
                  _buildCurrencyListCard(),
                ],
              ),
    );
  }

  Widget _buildExchangeRateCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.currency_exchange,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Kurs Mata Uang',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  'Terakhir Update: ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Top currencies
            Row(
              children: [
                Expanded(child: _buildRateItem('USD', 'Dollar AS')),
                Expanded(child: _buildRateItem('EUR', 'Euro')),
                Expanded(child: _buildRateItem('SGD', 'Dollar Singapura')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRateItem(String currency, String name) {
    final rate = _exchangeRates[currency] ?? 0.0;
    final formattedRate =
        rate > 0.01 ? rate.toStringAsFixed(4) : rate.toStringAsFixed(6);

    return Column(
      children: [
        Text(
          currency,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        Text(
          formattedRate,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        Text(
          name,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildConverterCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Konverter Mata Uang',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),

            // Amount Input
            _buildTextField(
              controller: _amountController,
              label: 'Jumlah',
              hint: 'Masukkan jumlah',
              onChanged: _onAmountChanged,
              inputFormatters: [ThousandInputFormatter()],
            ),

            const SizedBox(height: 16),

            // Currency Selection
            Row(
              children: [
                Expanded(
                  child: _buildCurrencyDropdown(
                    label: 'Dari',
                    value: _fromCurrency,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _fromCurrency = value;
                        });
                      }
                    },
                  ),
                ),

                // Swap Button
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: IconButton(
                    onPressed: _swapCurrencies,
                    icon: const Icon(Icons.swap_horiz),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ),

                Expanded(
                  child: _buildCurrencyDropdown(
                    label: 'Ke',
                    value: _toCurrency,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _toCurrency = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Fee Input
            _buildTextField(
              controller: _feeController,
              label: 'Biaya (%)',
              hint: '0.0',
              onChanged: _onFeeChanged,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final summary = _conversionSummary!;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hasil Konversi',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),

            // Main Result
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.1),
                    AppColors.primaryLight.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '${summary['originalAmount']} ${summary['originalCurrency']}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Icon(
                    Icons.arrow_downward,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    CurrencyService.formatCurrency(
                      summary['finalAmount'],
                      summary['targetCurrency'],
                    ),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Conversion Details
            _buildDetailRow(
              'Kurs',
              '1 ${summary['originalCurrency']} = ${summary['exchangeRate'].toStringAsFixed(6)} ${summary['targetCurrency']}',
            ),
            _buildDetailRow(
              'Biaya',
              '${summary['feePercentage']}% (${CurrencyService.formatCurrency(summary['fee'], summary['targetCurrency'])})',
            ),
            _buildDetailRow(
              'Sebelum Biaya',
              CurrencyService.formatCurrency(
                summary['convertedAmount'],
                summary['targetCurrency'],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyListCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mata Uang Tersedia',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            ...PredefinedCurrencies.currencies.map((currency) {
              final rate = _exchangeRates[currency.code] ?? 0.0;
              final isSelected =
                  _fromCurrency == currency.code ||
                  _toCurrency == currency.code;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        isSelected
                            ? AppColors.primary.withValues(alpha: 0.3)
                            : Colors.transparent,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      currency.symbol,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currency.code,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            currency.name,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (currency.code != 'IDR') ...[
                      Text(
                        rate > 0.01
                            ? rate.toStringAsFixed(4)
                            : rate.toStringAsFixed(6),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ] else ...[
                      Text(
                        '1.000000',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required Function(String) onChanged,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
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
          onChanged: onChanged,
          inputFormatters: inputFormatters,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
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

  Widget _buildCurrencyDropdown({
    required String label,
    required String value,
    required Function(String?) onChanged,
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
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          items:
              PredefinedCurrencies.currencies.map((currency) {
                return DropdownMenuItem<String>(
                  value: currency.code,
                  child: Row(
                    children: [
                      Text(currency.symbol),
                      const SizedBox(width: 8),
                      Text(currency.code),
                    ],
                  ),
                );
              }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/investment.dart';
import '../../../core/providers/finance_provider.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';

class AddInvestmentScreen extends ConsumerStatefulWidget {
  final String? editInvestmentId;

  const AddInvestmentScreen({
    super.key,
    this.editInvestmentId,
  });

  @override
  ConsumerState<AddInvestmentScreen> createState() => _AddInvestmentScreenState();
}

class _AddInvestmentScreenState extends ConsumerState<AddInvestmentScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _investedController;
  late TextEditingController _currentValController;
  late TextEditingController _quantityController;
  late TextEditingController _symbolController;
  late TextEditingController _notesController;

  InvestmentType _selectedType = InvestmentType.mutualFunds;
  DateTime _purchaseDate = DateTime.now().subtract(const Duration(days: 90));
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _investedController = TextEditingController();
    _currentValController = TextEditingController();
    _quantityController = TextEditingController(text: '1');
    _symbolController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      if (widget.editInvestmentId != null) {
        final finance = ref.read(financeProvider);
        final inv = finance.investments.where((i) => i.id == widget.editInvestmentId).firstOrNull;
        if (inv != null) {
          _nameController.text = inv.name;
          _investedController.text = inv.investedAmount.toString();
          _currentValController.text = inv.currentValue.toString();
          _quantityController.text = inv.quantity.toString();
          _symbolController.text = inv.symbol ?? '';
          _notesController.text = inv.notes ?? '';
          _selectedType = inv.type;
          _purchaseDate = inv.purchaseDate;
        }
      }
      _isInit = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _investedController.dispose();
    _currentValController.dispose();
    _quantityController.dispose();
    _symbolController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveInvestment() {
    if (!_formKey.currentState!.validate()) return;

    final invested = double.tryParse(_investedController.text) ?? 0.0;
    final current = double.tryParse(_currentValController.text) ?? invested;
    final qty = double.tryParse(_quantityController.text) ?? 1.0;

    final financeNotifier = ref.read(financeProvider.notifier);

    final inv = Investment(
      id: widget.editInvestmentId ?? 'inv_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      type: _selectedType,
      investedAmount: invested,
      currentValue: current,
      purchaseDate: _purchaseDate,
      quantity: qty,
      symbol: _symbolController.text.trim().isNotEmpty ? _symbolController.text.trim() : null,
      notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
    );

    if (widget.editInvestmentId != null) {
      financeNotifier.updateInvestment(inv);
    } else {
      financeNotifier.addInvestment(inv);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.editInvestmentId != null ? 'Holding updated' : 'Asset "${inv.name}" added to portfolio',
        ),
        backgroundColor: AppColors.deepForest,
      ),
    );

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final finance = ref.watch(financeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppConstants.tabletBreakpoint;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(widget.editInvestmentId != null ? 'Edit Investment' : 'Track New Asset'),
        actions: [
          TextButton(
            onPressed: _saveInvestment,
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 24 : 18,
                  vertical: 18,
                ),
                children: [
                  AppTextField(
                    controller: _nameController,
                    label: 'Asset / Fund Name',
                    hintText: 'e.g. Parag Parikh Flexi Cap, Tata Motors, Gold SGB',
                    prefixIcon: const Icon(LucideIcons.lineChart, size: 18),
                    validator: (v) => v == null || v.isEmpty ? 'Asset name is required' : null,
                  ),
                  const SizedBox(height: 16),

                  // Asset Type
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Asset Category',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<InvestmentType>(
                        initialValue: _selectedType,
                        isExpanded: true,
                        items: InvestmentType.values.map((t) {
                          return DropdownMenuItem(
                            value: t,
                            child: Text(t.displayName, overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedType = val);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _investedController,
                          label: 'Invested Capital (${finance.profile.currency})',
                          hintText: '50000',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          prefixIcon: const Icon(LucideIcons.coins, size: 18),
                          validator: (v) => v == null || v.isEmpty ? 'Enter invested amount' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          controller: _currentValController,
                          label: 'Current Valuation (${finance.profile.currency})',
                          hintText: '62500',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          prefixIcon: const Icon(LucideIcons.trendingUp, size: 18),
                          validator: (v) => v == null || v.isEmpty ? 'Enter current value' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _quantityController,
                          label: 'Quantity / Units',
                          hintText: '1.0',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          prefixIcon: const Icon(LucideIcons.scale, size: 18),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          controller: _symbolController,
                          label: 'Symbol / Ticker (Optional)',
                          hintText: 'e.g. NIFTY50, TATAMTR',
                          prefixIcon: const Icon(LucideIcons.hash, size: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Purchase / SIP Start Date', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _purchaseDate,
                            firstDate: DateTime(2015),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) setState(() => _purchaseDate = picked);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                          ),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.calendar, size: 18, color: AppColors.sage),
                              const SizedBox(width: 10),
                              Text(DateFormatter.format(_purchaseDate), style: const TextStyle(fontSize: 13.5)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  AppTextField(
                    controller: _notesController,
                    label: 'Investment Strategy / Notes (Optional)',
                    hintText: 'e.g. Long-term compounding bluechip fund',
                    maxLines: 2,
                    prefixIcon: const Icon(LucideIcons.fileText, size: 18),
                  ),
                  const SizedBox(height: 24),

                  AppButton(
                    label: widget.editInvestmentId != null ? 'Update Holding' : 'Save Investment',
                    onPressed: _saveInvestment,
                    height: 50,
                  ),
                  const SizedBox(height: 10),
                  AppButton(
                    label: 'Cancel',
                    variant: AppButtonVariant.outlined,
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

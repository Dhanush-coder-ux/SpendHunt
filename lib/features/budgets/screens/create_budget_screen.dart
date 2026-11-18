import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/budget.dart';
import '../../../core/providers/finance_provider.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';

class CreateBudgetScreen extends ConsumerStatefulWidget {
  final String? editBudgetId;

  const CreateBudgetScreen({
    super.key,
    this.editBudgetId,
  });

  @override
  ConsumerState<CreateBudgetScreen> createState() => _CreateBudgetScreenState();
}

class _CreateBudgetScreenState extends ConsumerState<CreateBudgetScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _amountController;

  String? _selectedCategoryId;
  String? _selectedCategoryName;
  BudgetPeriod _selectedPeriod = BudgetPeriod.monthly;
  DateTime _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _endDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
  double _alertThreshold = 0.8; // 80%

  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _amountController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final finance = ref.read(financeProvider);
      if (widget.editBudgetId != null) {
        final existing = finance.budgets.where((b) => b.id == widget.editBudgetId).firstOrNull;
        if (existing != null) {
          _nameController.text = existing.name;
          _amountController.text = existing.amount.toString();
          _selectedCategoryId = existing.categoryId;
          _selectedCategoryName = existing.categoryName;
          _selectedPeriod = existing.period;
          _startDate = existing.startDate;
          _endDate = existing.endDate;
          _alertThreshold = existing.alertThreshold;
        }
      } else {
        if (finance.categories.isNotEmpty) {
          final firstExpense = finance.categories.firstWhere(
            (c) => c.type.name == 'expense',
            orElse: () => finance.categories.first,
          );
          _selectedCategoryId = firstExpense.id;
          _selectedCategoryName = firstExpense.name;
          _nameController.text = firstExpense.name;
        }
      }
      _isInit = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _saveBudget() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a budget amount greater than 0')),
      );
      return;
    }

    final financeNotifier = ref.read(financeProvider.notifier);

    final bgt = Budget(
      id: widget.editBudgetId ?? 'bgt_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      categoryId: _selectedCategoryId ?? 'cat_other',
      categoryName: _selectedCategoryName ?? 'Other',
      amount: amount,
      period: _selectedPeriod,
      startDate: _startDate,
      endDate: _endDate,
      alertThreshold: _alertThreshold,
    );

    if (widget.editBudgetId != null) {
      financeNotifier.updateBudget(bgt);
    } else {
      financeNotifier.addBudget(bgt);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.editBudgetId != null
              ? 'Budget updated successfully'
              : 'Budget "${bgt.name}" created',
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
        title: Text(widget.editBudgetId != null ? 'Edit Budget' : 'Create Budget'),
        actions: [
          TextButton(
            onPressed: _saveBudget,
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
                    label: 'Budget Name',
                    hintText: 'e.g. Dining Out, Weekend Groceries',
                    prefixIcon: const Icon(LucideIcons.tag, size: 18),
                    validator: (v) => v == null || v.isEmpty ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 16),

                  // Category Selection
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Target Category',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCategoryId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(LucideIcons.shapes, size: 18),
                        ),
                        items: finance.categories.map((c) {
                          return DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name, overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            final cat = finance.categories.firstWhere((c) => c.id == val);
                            setState(() {
                              _selectedCategoryId = cat.id;
                              _selectedCategoryName = cat.name;
                              if (_nameController.text.isEmpty) {
                                _nameController.text = cat.name;
                              }
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Budget Amount
                  AppTextField(
                    controller: _amountController,
                    label: 'Budget Limit Amount (${finance.profile.currency})',
                    hintText: '15000',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    prefixIcon: const Icon(LucideIcons.coins, size: 18),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Please enter budget limit';
                      if (double.tryParse(v) == null) return 'Enter a valid number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Period Selection
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Budget Cycle Period',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<BudgetPeriod>(
                        initialValue: _selectedPeriod,
                        isExpanded: true,
                        items: BudgetPeriod.values.map((p) {
                          return DropdownMenuItem(
                            value: p,
                            child: Text(p.displayName, overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedPeriod = val);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Date Range Row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Start Date', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _startDate,
                                  firstDate: DateTime(2022),
                                  lastDate: DateTime(2030),
                                );
                                if (picked != null) setState(() => _startDate = picked);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceLight,
                                  borderRadius: BorderRadius.circular(13),
                                  border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                                ),
                                child: Text(DateFormatter.formatShort(_startDate), style: const TextStyle(fontSize: 13.5)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('End Date', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _endDate,
                                  firstDate: DateTime(2022),
                                  lastDate: DateTime(2030),
                                );
                                if (picked != null) setState(() => _endDate = picked);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceLight,
                                  borderRadius: BorderRadius.circular(13),
                                  border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                                ),
                                child: Text(DateFormatter.formatShort(_endDate), style: const TextStyle(fontSize: 13.5)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Alert Threshold Slider
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Alert Notification Threshold', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          Text(
                            '${(_alertThreshold * 100).toInt()}% of budget',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.warmBronze),
                          ),
                        ],
                      ),
                      Slider(
                        value: _alertThreshold,
                        min: 0.5,
                        max: 1.0,
                        divisions: 10,
                        activeColor: AppColors.deepForest,
                        onChanged: (val) => setState(() => _alertThreshold = val),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  AppButton(
                    label: widget.editBudgetId != null ? 'Update Budget' : 'Save Budget',
                    onPressed: _saveBudget,
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

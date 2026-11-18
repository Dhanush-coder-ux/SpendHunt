import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/savings_goal.dart';
import '../../../core/providers/finance_provider.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';

class CreateGoalScreen extends ConsumerStatefulWidget {
  final String? editGoalId;

  const CreateGoalScreen({
    super.key,
    this.editGoalId,
  });

  @override
  ConsumerState<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends ConsumerState<CreateGoalScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _targetAmountController;
  late TextEditingController _initialAmountController;

  String _category = 'General';
  String _selectedIcon = 'piggyBank';
  DateTime _targetDate = DateTime.now().add(const Duration(days: 180));

  bool _isInit = false;

  final Map<String, IconData> _iconOptions = {
    'piggyBank': LucideIcons.piggyBank,
    'shieldCheck': LucideIcons.shieldCheck,
    'bike': LucideIcons.bike,
    'plane': LucideIcons.plane,
    'laptop': LucideIcons.laptop,
    'home': LucideIcons.house,
    'car': LucideIcons.car,
    'gift': LucideIcons.gift,
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _targetAmountController = TextEditingController();
    _initialAmountController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      if (widget.editGoalId != null) {
        final finance = ref.read(financeProvider);
        final existing = finance.savingsGoals.where((g) => g.id == widget.editGoalId).firstOrNull;
        if (existing != null) {
          _nameController.text = existing.name;
          _targetAmountController.text = existing.targetAmount.toString();
          _initialAmountController.text = existing.currentAmount.toString();
          _category = existing.category;
          _selectedIcon = existing.iconName;
          _targetDate = existing.targetDate;
        }
      }
      _isInit = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
    _initialAmountController.dispose();
    super.dispose();
  }

  void _saveGoal() {
    if (!_formKey.currentState!.validate()) return;

    final target = double.tryParse(_targetAmountController.text) ?? 0.0;
    final initial = double.tryParse(_initialAmountController.text) ?? 0.0;
    if (target <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Target amount must be greater than 0')),
      );
      return;
    }

    final financeNotifier = ref.read(financeProvider.notifier);

    final goal = SavingsGoal(
      id: widget.editGoalId ?? 'goal_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      targetAmount: target,
      currentAmount: initial,
      targetDate: _targetDate,
      category: _category,
      iconName: _selectedIcon,
    );

    if (widget.editGoalId != null) {
      financeNotifier.updateSavingsGoal(goal);
    } else {
      financeNotifier.addSavingsGoal(goal);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.editGoalId != null ? 'Goal updated successfully' : 'Goal "${goal.name}" created',
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
        title: Text(widget.editGoalId != null ? 'Edit Savings Goal' : 'Create Savings Goal'),
        actions: [
          TextButton(
            onPressed: _saveGoal,
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
                    label: 'Goal Name',
                    hintText: 'e.g. Emergency Fund, EV Scooter, Japan Trip',
                    prefixIcon: const Icon(LucideIcons.target, size: 18),
                    validator: (v) => v == null || v.isEmpty ? 'Goal name is required' : null,
                  ),
                  const SizedBox(height: 16),

                  // Target Amount & Initial Stash
                  AppTextField(
                    controller: _targetAmountController,
                    label: 'Target Goal Amount (${finance.profile.currency})',
                    hintText: '200000',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    prefixIcon: const Icon(LucideIcons.coins, size: 18),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Enter target amount';
                      if (double.tryParse(v) == null) return 'Enter a valid number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  AppTextField(
                    controller: _initialAmountController,
                    label: 'Current Saved Amount (Optional)',
                    hintText: '0.00',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    prefixIcon: const Icon(LucideIcons.piggyBank, size: 18),
                  ),
                  const SizedBox(height: 16),

                  // Target Date Picker
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Target Completion Date', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _targetDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2035),
                          );
                          if (picked != null) setState(() => _targetDate = picked);
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
                              Text(DateFormatter.format(_targetDate), style: const TextStyle(fontSize: 13.5)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Category Dropdown
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Category', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: _category,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(value: 'General', child: Text('General', overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'Safety', child: Text('Safety / Emergency', overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'Vehicle', child: Text('Vehicle & Mobility', overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'Travel', child: Text('Travel & Vacation', overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'Tech', child: Text('Tech & Electronics', overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'Housing', child: Text('Housing & Real Estate', overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'Education', child: Text('Education & Upskilling', overflow: TextOverflow.ellipsis)),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _category = val);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Goal Icon Picker
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Select Icon Emblem', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 12,
                        runSpacing: 10,
                        children: _iconOptions.entries.map((entry) {
                          final isSelected = _selectedIcon == entry.key;
                          return InkWell(
                            onTap: () => setState(() => _selectedIcon = entry.key),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.deepForest
                                    : (isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceSecondaryLight),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? AppColors.deepForest : AppColors.borderLight,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  entry.value,
                                  size: 22,
                                  color: isSelected ? Colors.white : AppColors.deepForest,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  AppButton(
                    label: widget.editGoalId != null ? 'Update Goal' : 'Save Goal',
                    onPressed: _saveGoal,
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

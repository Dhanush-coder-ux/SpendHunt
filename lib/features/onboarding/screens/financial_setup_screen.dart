import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/finance_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/fin_section.dart';

class FinancialSetupScreen extends ConsumerStatefulWidget {
  const FinancialSetupScreen({super.key});

  @override
  ConsumerState<FinancialSetupScreen> createState() => _FinancialSetupScreenState();
}

class _FinancialSetupScreenState extends ConsumerState<FinancialSetupScreen> {
  int _currentStep = 0;

  // Step 1: Currency & Income
  String _currency = 'INR';
  late final TextEditingController _incomeController;

  // Step 2: Main Goal & Budgeting Style
  String _selectedGoal = 'Build 6-Month Emergency Fund';
  String _selectedBudgetStyle = '50/30/20 Rule (Needs, Wants, Savings)';

  final List<String> _goals = [
    'Build 6-Month Emergency Fund',
    'Pay Off High-Interest Debt',
    'Save for Home Downpayment',
    'Invest for Long-Term Wealth',
    'Track Daily Personal Expenses',
  ];

  final List<String> _budgetStyles = [
    '50/30/20 Rule (Needs, Wants, Savings)',
    'Zero-Based Budgeting (Every Rupee Assigned)',
    'Pay Yourself First (Aggressive Savings)',
    'Envelope / Category Allocation',
  ];

  @override
  void initState() {
    super.initState();
    final profile = ref.read(financeProvider).profile;
    _currency = profile.currency;
    _incomeController = TextEditingController(text: profile.monthlyIncome.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _incomeController.dispose();
    super.dispose();
  }

  void _finishSetup() {
    final income = double.tryParse(_incomeController.text.trim()) ?? 120000.0;
    final currentProfile = ref.read(financeProvider).profile;

    ref.read(financeProvider.notifier).updateProfile(
          currentProfile.copyWith(
            currency: _currency,
            monthlyIncome: income,
            primaryGoal: _selectedGoal,
            budgetingStyle: _selectedBudgetStyle.split(' (').first,
          ),
        );

    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppConstants.tabletBreakpoint;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Financial Baseline Wizard'),
        actions: [
          TextButton(
            onPressed: _finishSetup,
            child: const Text('Skip to App'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 32 : 20,
                vertical: 20,
              ),
              children: [
                // Step Progress Indicator
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.deepForest,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: _currentStep >= 1
                              ? AppColors.deepForest
                              : (isDark ? AppColors.borderDark : AppColors.borderLight),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                if (_currentStep == 0) ...[
                  const Text(
                    'Step 1: Currency & Baseline Income',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'SpendHunt personalizes dashboards and automated calculations around your base cash flow.',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
                  ),
                  const SizedBox(height: 24),

                  FinSection(
                    padding: const EdgeInsets.all(20),
                    children: [
                      const Text(
                        'Preferred Currency',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _currency,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'INR',
                            child: Text(
                              'INR (₹) — Indian Rupee',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'USD',
                            child: Text(
                              'USD (\$) — US Dollar',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'EUR',
                            child: Text(
                              'EUR (€) — Euro',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'GBP',
                            child: Text(
                              'GBP (£) — British Pound',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _currency = val);
                        },
                      ),
                      const SizedBox(height: 18),

                      AppTextField(
                        controller: _incomeController,
                        label: 'Estimated Net Monthly Income',
                        hintText: '120000',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        prefixIcon: const Icon(LucideIcons.coins, size: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  AppButton(
                    label: 'Next Step: Goals & Budgeting',
                    onPressed: () => setState(() => _currentStep = 1),
                    height: 50,
                  ),
                ] else ...[
                  const Text(
                    'Step 2: Goals & Budgeting Philosophy',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Helps AI Assistant craft proactive suggestions and threshold benchmarks tailored to you.',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
                  ),
                  const SizedBox(height: 24),

                  FinSection(
                    padding: const EdgeInsets.all(20),
                    children: [
                      const Text(
                        'Primary Financial Ambition',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      ..._goals.map((goal) {
                        final isSelected = _selectedGoal == goal;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            onTap: () => setState(() => _selectedGoal = goal),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.deepForest.withValues(alpha: 0.1)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? AppColors.deepForest : AppColors.borderLight,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected ? LucideIcons.circleCheck : LucideIcons.circle,
                                    size: 16,
                                    color: isSelected ? AppColors.deepForest : AppColors.textSecondaryLight,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      goal,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 16),

                      const Text(
                        'Preferred Budgeting Style',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      ..._budgetStyles.map((style) {
                        final isSelected = _selectedBudgetStyle == style;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            onTap: () => setState(() => _selectedBudgetStyle = style),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.warmBronze.withValues(alpha: 0.1)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? AppColors.warmBronze : AppColors.borderLight,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected ? LucideIcons.circleCheck : LucideIcons.circle,
                                    size: 16,
                                    color: isSelected ? AppColors.warmBronze : AppColors.textSecondaryLight,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      style,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 28),

                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: 'Back',
                          variant: AppButtonVariant.outlined,
                          onPressed: () => setState(() => _currentStep = 0),
                          height: 50,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: AppButton(
                          label: 'Complete Setup & Launch',
                          onPressed: _finishSetup,
                          height: 50,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

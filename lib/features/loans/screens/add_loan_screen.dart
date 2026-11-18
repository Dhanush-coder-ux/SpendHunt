import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/loan.dart';
import '../../../core/providers/finance_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_text_field.dart';

class AddLoanScreen extends ConsumerStatefulWidget {
  final String? editLoanId;

  const AddLoanScreen({
    super.key,
    this.editLoanId,
  });

  @override
  ConsumerState<AddLoanScreen> createState() => _AddLoanScreenState();
}

class _AddLoanScreenState extends ConsumerState<AddLoanScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _principalController;
  late TextEditingController _rateController;
  late TextEditingController _tenureController;
  late TextEditingController _lenderController;

  LoanType _selectedType = LoanType.vehicle;
  DateTime _startDate = DateTime.now();
  DateTime _nextPaymentDate = DateTime.now().add(const Duration(days: 30));
  double _calculatedEmi = 0.0;
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _principalController = TextEditingController();
    _rateController = TextEditingController(text: '8.5');
    _tenureController = TextEditingController(text: '60');
    _lenderController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      if (widget.editLoanId != null) {
        final finance = ref.read(financeProvider);
        final loan = finance.loans.where((l) => l.id == widget.editLoanId).firstOrNull;
        if (loan != null) {
          _nameController.text = loan.name;
          _principalController.text = loan.principalAmount.toString();
          _rateController.text = loan.annualInterestRate.toString();
          _tenureController.text = loan.tenureMonths.toString();
          _lenderController.text = loan.lender;
          _selectedType = loan.type;
          _startDate = loan.startDate;
          _nextPaymentDate = loan.nextPaymentDate;
          _calculatedEmi = loan.monthlyEmi;
        }
      }
      _recalculateEmi();
      _isInit = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _principalController.dispose();
    _rateController.dispose();
    _tenureController.dispose();
    _lenderController.dispose();
    super.dispose();
  }

  void _recalculateEmi() {
    final principal = double.tryParse(_principalController.text) ?? 0.0;
    final rate = double.tryParse(_rateController.text) ?? 0.0;
    final tenure = int.tryParse(_tenureController.text) ?? 0;

    if (principal > 0 && tenure > 0) {
      setState(() {
        _calculatedEmi = Loan.calculateEmi(
          principal: principal,
          annualRate: rate,
          tenureMonths: tenure,
        );
      });
    }
  }

  void _saveLoan() {
    if (!_formKey.currentState!.validate()) return;

    final principal = double.tryParse(_principalController.text) ?? 0.0;
    final rate = double.tryParse(_rateController.text) ?? 0.0;
    final tenure = int.tryParse(_tenureController.text) ?? 12;

    final emi = _calculatedEmi > 0
        ? _calculatedEmi
        : Loan.calculateEmi(principal: principal, annualRate: rate, tenureMonths: tenure);

    final financeNotifier = ref.read(financeProvider.notifier);

    final loan = Loan(
      id: widget.editLoanId ?? 'loan_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      type: _selectedType,
      principalAmount: principal,
      outstandingBalance: principal,
      annualInterestRate: rate,
      tenureMonths: tenure,
      startDate: _startDate,
      monthlyEmi: emi,
      nextPaymentDate: _nextPaymentDate,
      lender: _lenderController.text.trim().isNotEmpty ? _lenderController.text.trim() : 'Bank',
    );

    if (widget.editLoanId != null) {
      financeNotifier.updateLoan(loan);
    } else {
      financeNotifier.addLoan(loan);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.editLoanId != null ? 'Loan updated' : 'Loan "${loan.name}" registered',
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
        title: Text(widget.editLoanId != null ? 'Edit Loan' : 'Add Loan Account'),
        actions: [
          TextButton(
            onPressed: _saveLoan,
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
                  // Calculated EMI Preview Card
                  AppCard(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    color: isDark ? AppColors.surfaceDark : AppColors.surfaceSecondaryLight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CALCULATED MONTHLY EMI',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6,
                                  color: AppColors.warmBronze,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Live formula auto-computed',
                                style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          CurrencyFormatter.format(_calculatedEmi, currencyCode: finance.profile.currency),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.deepForest,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  AppTextField(
                    controller: _nameController,
                    label: 'Loan Title / Purpose',
                    hintText: 'e.g. Hyundai Creta Car Loan, Home Loan',
                    prefixIcon: const Icon(LucideIcons.tag, size: 18),
                    validator: (v) => v == null || v.isEmpty ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 16),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Loan Type', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<LoanType>(
                        initialValue: _selectedType,
                        isExpanded: true,
                        items: LoanType.values.map((t) {
                          return DropdownMenuItem(
                            value: t,
                            child: Text(
                              t.displayName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedType = val);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  AppTextField(
                    controller: _principalController,
                    label: 'Principal Loan Amount (${finance.profile.currency})',
                    hintText: '500000',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    prefixIcon: const Icon(LucideIcons.coins, size: 18),
                    onChanged: (_) => _recalculateEmi(),
                    validator: (v) => v == null || v.isEmpty ? 'Principal is required' : null,
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _rateController,
                          label: 'Interest Rate (% p.a.)',
                          hintText: '8.5',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          prefixIcon: const Icon(LucideIcons.percent, size: 18),
                          onChanged: (_) => _recalculateEmi(),
                          validator: (v) => v == null || v.isEmpty ? 'Rate is required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          controller: _tenureController,
                          label: 'Tenure (Months)',
                          hintText: '60',
                          keyboardType: TextInputType.number,
                          prefixIcon: const Icon(LucideIcons.clock, size: 18),
                          onChanged: (_) => _recalculateEmi(),
                          validator: (v) => v == null || v.isEmpty ? 'Tenure is required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  AppTextField(
                    controller: _lenderController,
                    label: 'Lending Bank / Financial Provider',
                    hintText: 'e.g. HDFC Bank, SBI, ICICI Bank',
                    prefixIcon: const Icon(LucideIcons.landmark, size: 18),
                  ),
                  const SizedBox(height: 16),

                  // Dates Row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Disbursal Date', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _startDate,
                                  firstDate: DateTime(2015),
                                  lastDate: DateTime.now(),
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
                                child: Text(DateFormatter.formatShort(_startDate), style: const TextStyle(fontSize: 13)),
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
                            const Text('Next Payment Date', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _nextPaymentDate,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                );
                                if (picked != null) setState(() => _nextPaymentDate = picked);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceLight,
                                  borderRadius: BorderRadius.circular(13),
                                  border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                                ),
                                child: Text(DateFormatter.formatShort(_nextPaymentDate), style: const TextStyle(fontSize: 13)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),

                  AppButton(
                    label: widget.editLoanId != null ? 'Update Loan' : 'Register Loan',
                    onPressed: _saveLoan,
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

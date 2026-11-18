import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/subscription.dart';
import '../../../core/providers/finance_provider.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';

class AddSubscriptionScreen extends ConsumerStatefulWidget {
  final String? editSubscriptionId;

  const AddSubscriptionScreen({
    super.key,
    this.editSubscriptionId,
  });

  @override
  ConsumerState<AddSubscriptionScreen> createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends ConsumerState<AddSubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _amountController;

  BillingCycle _cycle = BillingCycle.monthly;
  DateTime _nextDate = DateTime.now().add(const Duration(days: 30));
  String _category = 'Entertainment';
  String? _selectedAccountId;
  String? _selectedAccountName;
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
      if (widget.editSubscriptionId != null) {
        final existing = finance.subscriptions
            .where((s) => s.id == widget.editSubscriptionId)
            .firstOrNull;
        if (existing != null) {
          _nameController.text = existing.name;
          _amountController.text = existing.amount.toString();
          _cycle = existing.cycle;
          _nextDate = existing.nextBillingDate;
          _category = existing.category;
          _selectedAccountId = existing.accountId;
          _selectedAccountName = existing.accountName;
        }
      } else {
        if (finance.accounts.isNotEmpty) {
          _selectedAccountId = finance.accounts.first.id;
          _selectedAccountName = finance.accounts.first.name;
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

  void _saveSubscription() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount greater than 0')),
      );
      return;
    }

    final financeNotifier = ref.read(financeProvider.notifier);

    final sub = Subscription(
      id: widget.editSubscriptionId ?? 'sub_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      amount: amount,
      cycle: _cycle,
      nextBillingDate: _nextDate,
      category: _category,
      accountId: _selectedAccountId ?? 'acc_1',
      accountName: _selectedAccountName ?? 'Account',
      status: SubscriptionStatus.active,
    );

    if (widget.editSubscriptionId != null) {
      financeNotifier.updateSubscription(sub);
    } else {
      financeNotifier.addSubscription(sub);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.editSubscriptionId != null ? 'Subscription updated' : 'Subscription "${sub.name}" registered',
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
        title: Text(widget.editSubscriptionId != null ? 'Edit Subscription' : 'Add Recurring Bill'),
        actions: [
          TextButton(
            onPressed: _saveSubscription,
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
                    label: 'Subscription / Bill Title',
                    hintText: 'e.g. Netflix, Spotify, Airtel Fiber, Gym Membership',
                    prefixIcon: const Icon(LucideIcons.calendarClock, size: 18),
                    validator: (v) => v == null || v.isEmpty ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _amountController,
                          label: 'Billing Amount (${finance.profile.currency})',
                          hintText: '649',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          prefixIcon: const Icon(LucideIcons.coins, size: 18),
                          validator: (v) => v == null || v.isEmpty ? 'Amount is required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Billing Cycle', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<BillingCycle>(
                              initialValue: _cycle,
                              isExpanded: true,
                              items: BillingCycle.values.map((c) {
                                return DropdownMenuItem(
                                  value: c,
                                  child: Text(c.displayName, overflow: TextOverflow.ellipsis),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _cycle = val);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Next Billing Due Date', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _nextDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) setState(() => _nextDate = picked);
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
                              Text(DateFormatter.format(_nextDate), style: const TextStyle(fontSize: 13.5)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Category', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: _category,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(value: 'Entertainment', child: Text('Entertainment & Streaming', overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'Bills & Utilities', child: Text('Bills & Utilities', overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'Tech', child: Text('Software & Cloud Storage', overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'Health', child: Text('Fitness & Health', overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'Shopping', child: Text('Shopping Membership', overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'Education', child: Text('Learning & Courses', overflow: TextOverflow.ellipsis)),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _category = val);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Payment Account / Card', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedAccountId,
                        isExpanded: true,
                        items: finance.accounts.map((a) {
                          return DropdownMenuItem(
                            value: a.id,
                            child: Text('${a.name} (•••• ${a.lastFourDigits})', overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            final acc = finance.accounts.firstWhere((a) => a.id == val);
                            setState(() {
                              _selectedAccountId = acc.id;
                              _selectedAccountName = acc.name;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),

                  AppButton(
                    label: widget.editSubscriptionId != null ? 'Update Subscription' : 'Save Subscription',
                    onPressed: _saveSubscription,
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

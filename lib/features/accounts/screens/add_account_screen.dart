import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/account.dart';
import '../../../core/providers/finance_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';

class AddAccountScreen extends ConsumerStatefulWidget {
  final String? editAccountId;

  const AddAccountScreen({
    super.key,
    this.editAccountId,
  });

  @override
  ConsumerState<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends ConsumerState<AddAccountScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _balanceController;
  late TextEditingController _institutionController;
  late TextEditingController _lastFourController;
  late TextEditingController _descController;

  AccountType _selectedType = AccountType.savings;
  String _currency = 'INR';
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _balanceController = TextEditingController();
    _institutionController = TextEditingController();
    _lastFourController = TextEditingController();
    _descController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      if (widget.editAccountId != null) {
        final finance = ref.read(financeProvider);
        final acc = finance.accounts.where((a) => a.id == widget.editAccountId).firstOrNull;
        if (acc != null) {
          _nameController.text = acc.name;
          _balanceController.text = acc.balance.toString();
          _institutionController.text = acc.institution;
          _lastFourController.text = acc.lastFourDigits;
          _descController.text = acc.description ?? '';
          _selectedType = acc.type;
          _currency = acc.currency;
        }
      }
      _isInit = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _institutionController.dispose();
    _lastFourController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _saveAccount() {
    if (!_formKey.currentState!.validate()) return;

    final balance = double.tryParse(_balanceController.text) ?? 0.0;
    final financeNotifier = ref.read(financeProvider.notifier);

    final acc = Account(
      id: widget.editAccountId ?? 'acc_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      type: _selectedType,
      balance: balance,
      institution: _institutionController.text.trim().isNotEmpty
          ? _institutionController.text.trim()
          : 'Self Managed',
      lastFourDigits: _lastFourController.text.trim().isNotEmpty
          ? _lastFourController.text.trim()
          : '0000',
      currency: _currency,
      description: _descController.text.trim().isNotEmpty ? _descController.text.trim() : null,
    );

    if (widget.editAccountId != null) {
      financeNotifier.updateAccount(acc);
    } else {
      financeNotifier.addAccount(acc);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.editAccountId != null ? 'Account updated' : 'Account "${acc.name}" added',
        ),
        backgroundColor: AppColors.deepForest,
      ),
    );

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppConstants.tabletBreakpoint;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(widget.editAccountId != null ? 'Edit Account' : 'Add Financial Account'),
        actions: [
          TextButton(
            onPressed: _saveAccount,
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
                    label: 'Account Name',
                    hintText: 'e.g. HDFC Salary, ICICI Wealth, Petty Cash',
                    prefixIcon: const Icon(LucideIcons.wallet, size: 18),
                    validator: (v) => v == null || v.isEmpty ? 'Account name is required' : null,
                  ),
                  const SizedBox(height: 16),

                  // Account Type
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account Type',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<AccountType>(
                        initialValue: _selectedType,
                        isExpanded: true,
                        items: AccountType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type.displayName, overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedType = val);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Balance & Currency Row
                  Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: AppTextField(
                          controller: _balanceController,
                          label: 'Current Balance / Limit',
                          hintText: '0.00',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          prefixIcon: const Icon(LucideIcons.coins, size: 18),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Enter balance';
                            if (double.tryParse(v) == null) return 'Enter valid number';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Currency',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              initialValue: _currency,
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem(value: 'INR', child: Text('INR (₹)', overflow: TextOverflow.ellipsis)),
                                DropdownMenuItem(value: 'USD', child: Text('USD (\$)', overflow: TextOverflow.ellipsis)),
                                DropdownMenuItem(value: 'EUR', child: Text('EUR (€)', overflow: TextOverflow.ellipsis)),
                                DropdownMenuItem(value: 'GBP', child: Text('GBP (£)', overflow: TextOverflow.ellipsis)),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _currency = val);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  AppTextField(
                    controller: _institutionController,
                    label: 'Financial Institution / Bank',
                    hintText: 'e.g. HDFC Bank, SBI, ICICI, Zerodha, Paytm',
                    prefixIcon: const Icon(LucideIcons.landmark, size: 18),
                  ),
                  const SizedBox(height: 16),

                  AppTextField(
                    controller: _lastFourController,
                    label: 'Last 4 Digits / Reference',
                    hintText: 'e.g. 4821 or CASH',
                    prefixIcon: const Icon(LucideIcons.hash, size: 18),
                  ),
                  const SizedBox(height: 16),

                  AppTextField(
                    controller: _descController,
                    label: 'Description / Purpose (Optional)',
                    hintText: 'e.g. Primary salary account or travel rewards line',
                    maxLines: 2,
                    prefixIcon: const Icon(LucideIcons.fileText, size: 18),
                  ),
                  const SizedBox(height: 24),

                  AppButton(
                    label: widget.editAccountId != null ? 'Update Account' : 'Save Account',
                    onPressed: _saveAccount,
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/transaction.dart';
import '../../../core/providers/finance_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/fin_animated_icon.dart';
import '../../../shared/widgets/fin_section.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final String? editTransactionId;
  final String? initialType; // expense, income, transfer

  const AddTransactionScreen({
    super.key,
    this.editTransactionId,
    this.initialType,
  });

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  late TransactionType _type;
  late final TextEditingController _amountController;
  late final TextEditingController _titleController;
  late final TextEditingController _notesController;
  late final TextEditingController _merchantController;

  String? _selectedCategoryId;
  String? _selectedCategoryName;
  String? _selectedAccountId;
  String? _selectedAccountName;
  String? _destinationAccountId;
  String? _destinationAccountName;

  DateTime _selectedDate = DateTime.now();
  String _paymentMethod = 'UPI / NetBanking';
  String? _receiptPath;

  bool _isInit = false;

  final List<String> _paymentMethods = [
    'UPI / NetBanking',
    'Credit Card',
    'Debit Card',
    'Cash',
    'Bank Wire',
    'Digital Wallet',
  ];

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _titleController = TextEditingController();
    _notesController = TextEditingController();
    _merchantController = TextEditingController();

    if (widget.initialType == 'income') {
      _type = TransactionType.income;
    } else if (widget.initialType == 'transfer') {
      _type = TransactionType.transfer;
    } else {
      _type = TransactionType.expense;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final finance = ref.read(financeProvider);

      if (widget.editTransactionId != null) {
        final existing = finance.transactions
            .where((t) => t.id == widget.editTransactionId)
            .firstOrNull;
        if (existing != null) {
          _type = existing.type;
          _amountController.text = existing.amount.toString();
          _titleController.text = existing.title;
          _merchantController.text = existing.merchant;
          _notesController.text = existing.notes ?? '';
          _selectedCategoryId = existing.categoryId;
          _selectedCategoryName = existing.categoryName;
          _selectedAccountId = existing.accountId;
          _selectedAccountName = existing.accountName;
          _destinationAccountId = existing.destinationAccountId;
          _destinationAccountName = existing.destinationAccountName;
          _selectedDate = existing.date;
          _paymentMethod = existing.paymentMethod;
          _receiptPath = existing.receiptPath;
        }
      } else {
        // Defaults
        if (finance.accounts.isNotEmpty) {
          _selectedAccountId = finance.accounts.first.id;
          _selectedAccountName = finance.accounts.first.name;
          if (finance.accounts.length > 1) {
            _destinationAccountId = finance.accounts[1].id;
            _destinationAccountName = finance.accounts[1].name;
          }
        }
        if (finance.categories.isNotEmpty) {
          final cat = finance.categories.firstWhere(
            (c) => c.type == _type,
            orElse: () => finance.categories.first,
          );
          _selectedCategoryId = cat.id;
          _selectedCategoryName = cat.name;
        }
      }
      _isInit = true;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _notesController.dispose();
    _merchantController.dispose();
    super.dispose();
  }

  Color _getTypeAccentColor() {
    switch (_type) {
      case TransactionType.income:
        return AppColors.success;
      case TransactionType.expense:
        return AppColors.warmBronze;
      case TransactionType.transfer:
        return AppColors.deepForest;
    }
  }

  Future<void> _pickReceiptImage() async {
    final picker = ImagePicker();
    try {
      final photo = await picker.pickImage(source: ImageSource.gallery);
      if (photo != null) {
        setState(() => _receiptPath = photo.name);
      }
    } catch (_) {
      setState(() => _receiptPath = 'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg');
    }
  }

  void _saveTransaction() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid transaction amount')),
      );
      return;
    }

    if (_type == TransactionType.transfer && _selectedAccountId == _destinationAccountId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Source and Destination accounts must be different for transfer')),
      );
      return;
    }

    final id = widget.editTransactionId ?? 'tx_${DateTime.now().millisecondsSinceEpoch}';

    final tx = TransactionModel(
      id: id,
      title: _titleController.text.trim(),
      amount: amount,
      type: _type,
      categoryId: _type == TransactionType.transfer ? 'cat_transfer' : (_selectedCategoryId ?? 'cat_uncategorized'),
      categoryName: _type == TransactionType.transfer ? 'Transfer' : (_selectedCategoryName ?? 'General'),
      accountId: _selectedAccountId ?? 'acc_cash',
      accountName: _selectedAccountName ?? 'Cash Account',
      destinationAccountId: _type == TransactionType.transfer ? _destinationAccountId : null,
      destinationAccountName: _type == TransactionType.transfer ? _destinationAccountName : null,
      date: _selectedDate,
      paymentMethod: _paymentMethod,
      notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      merchant: _merchantController.text.trim().isNotEmpty ? _merchantController.text.trim() : 'Direct Transaction',
      receiptPath: _receiptPath,
    );

    if (widget.editTransactionId != null) {
      ref.read(financeProvider.notifier).updateTransaction(tx);
    } else {
      ref.read(financeProvider.notifier).addTransaction(tx);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.editTransactionId != null
              ? 'Transaction updated successfully'
              : '${_type.displayName} of ${CurrencyFormatter.format(amount)} recorded',
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
    final accentColor = _getTypeAccentColor();

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          widget.editTransactionId != null ? 'Edit Transaction' : 'New Transaction',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton(
            onPressed: _saveTransaction,
            child: const Text(
              'Save',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 24 : 18,
                  vertical: 16,
                ),
                children: [
                  // Segmented Type Selector
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceSecondaryLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        _buildTypeSegment('Expense', TransactionType.expense, isDark),
                        _buildTypeSegment('Income', TransactionType.income, isDark),
                        _buildTypeSegment('Transfer', TransactionType.transfer, isDark),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Amount Box with Visual Accent
                  FinSection(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                    children: [
                      Text(
                        'AMOUNT (${finance.profile.currency})',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: accentColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            CurrencyFormatter.getSymbol(finance.profile.currency),
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: accentColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _amountController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ),
                              decoration: const InputDecoration(
                                hintText: '0.00',
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                fillColor: Colors.transparent,
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Please enter amount';
                                }
                                if (double.tryParse(val) == null) {
                                  return 'Enter a valid number';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Title & Merchant
                  AppTextField(
                    controller: _titleController,
                    label: 'Transaction Title',
                    hintText: 'e.g. Organic Groceries, Coffee, Salary',
                    prefixIcon: const Icon(LucideIcons.tag, size: 18),
                    validator: (val) => val == null || val.isEmpty ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 14),

                  AppTextField(
                    controller: _merchantController,
                    label: 'Merchant / Entity (Optional)',
                    hintText: 'e.g. Nature Basket, Uber, Netflix',
                    prefixIcon: const Icon(LucideIcons.store, size: 18),
                  ),
                  const SizedBox(height: 14),

                  // Category Selection
                  if (_type != TransactionType.transfer) ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Category',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () => _openCategoryPicker(context, finance),
                          borderRadius: BorderRadius.circular(13),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(
                                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                              ),
                            ),
                            child: Row(
                              children: [
                                const FinAnimatedIcon(icon: LucideIcons.shapes, size: 18, color: AppColors.sage),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _selectedCategoryName ?? 'Select Category',
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.textSecondaryLight),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Account Selection
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _type == TransactionType.transfer ? 'From Account' : 'Account',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedAccountId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(LucideIcons.wallet, size: 18),
                          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        items: finance.accounts.map((acc) {
                          return DropdownMenuItem(
                            value: acc.id,
                            child: Text(
                              '${acc.name} (${CurrencyFormatter.format(acc.balance, compact: true)})',
                              overflow: TextOverflow.ellipsis,
                            ),
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
                  const SizedBox(height: 14),

                  // If Transfer: Destination Account
                  if (_type == TransactionType.transfer) ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'To Destination Account',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _destinationAccountId,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(LucideIcons.arrowRightLeft, size: 18),
                            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          items: finance.accounts.map((acc) {
                            return DropdownMenuItem(
                              value: acc.id,
                              child: Text(
                                '${acc.name} (${CurrencyFormatter.format(acc.balance, compact: true)})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              final acc = finance.accounts.firstWhere((a) => a.id == val);
                              setState(() {
                                _destinationAccountId = acc.id;
                                _destinationAccountName = acc.name;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Date Picker Row & Payment Method
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedDate,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                );
                                if (picked != null) {
                                  setState(() => _selectedDate = picked);
                                }
                              },
                              borderRadius: BorderRadius.circular(13),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceLight,
                                  borderRadius: BorderRadius.circular(13),
                                  border: Border.all(
                                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const FinAnimatedIcon(icon: LucideIcons.calendar, size: 17, color: AppColors.sage),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        DateFormatter.formatShort(_selectedDate),
                                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
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
                            Text(
                              'Payment Method',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              initialValue: _paymentMethod,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                              ),
                              items: _paymentMethods.map((m) {
                                return DropdownMenuItem(
                                  value: m,
                                  child: Text(
                                    m,
                                    style: const TextStyle(fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _paymentMethod = val);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Notes
                  AppTextField(
                    controller: _notesController,
                    label: 'Notes / Memo (Optional)',
                    hintText: 'Add extra details or reminders...',
                    maxLines: 2,
                    prefixIcon: const Icon(LucideIcons.fileText, size: 18),
                  ),
                  const SizedBox(height: 16),

                  // Receipt Attachment Section
                  FinSection(
                    padding: const EdgeInsets.all(16),
                    children: [
                      InkWell(
                        onTap: _pickReceiptImage,
                        child: Row(
                          children: [
                            FinAnimatedIcon(
                              icon: _receiptPath != null ? LucideIcons.fileCheck : LucideIcons.camera,
                              color: accentColor,
                              backgroundColor: accentColor.withValues(alpha: 0.12),
                              size: 19,
                              backgroundSize: 38,
                              borderRadius: 10,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _receiptPath != null ? 'Receipt Attached' : 'Attach Receipt Image',
                                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _receiptPath != null ? _receiptPath! : 'Take a photo or choose from gallery',
                                    style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondaryLight),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            if (_receiptPath != null)
                              IconButton(
                                icon: const Icon(LucideIcons.x, size: 16),
                                onPressed: () => setState(() => _receiptPath = null),
                              )
                            else
                              const Icon(LucideIcons.plus, size: 18, color: AppColors.textSecondaryLight),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Save & Cancel Actions
                  AppButton(
                    label: widget.editTransactionId != null ? 'Update Transaction' : 'Save Transaction',
                    onPressed: _saveTransaction,
                    height: 50,
                  ),
                  const SizedBox(height: 10),
                  AppButton(
                    label: 'Cancel',
                    variant: AppButtonVariant.outlined,
                    onPressed: () => context.pop(),
                    height: 48,
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

  Widget _buildTypeSegment(String label, TransactionType type, bool isDark) {
    final isSelected = _type == type;
    final color = type == TransactionType.income
        ? AppColors.success
        : (type == TransactionType.transfer ? AppColors.sage : AppColors.warmBronze);

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _type = type;
            final finance = ref.read(financeProvider);
            final matching = finance.categories.where((c) => c.type == type).firstOrNull;
            if (matching != null) {
              _selectedCategoryId = matching.id;
              _selectedCategoryName = matching.name;
            }
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppColors.surfaceDark : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? color : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  void _openCategoryPicker(BuildContext context, FinanceState finance) {
    final availableCategories = finance.categories.where((c) => c.type == _type).toList();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Category',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: availableCategories.length,
                  itemBuilder: (context, i) {
                    final cat = availableCategories[i];
                    final isSelected = cat.id == _selectedCategoryId;

                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedCategoryId = cat.id;
                          _selectedCategoryName = cat.name;
                        });
                        Navigator.pop(ctx);
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.deepForest.withValues(alpha: 0.1)
                              : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? AppColors.deepForest : AppColors.borderLight,
                            width: isSelected ? 1.8 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FinAnimatedIcon(icon: cat.icon, size: 22, color: cat.color),
                            const SizedBox(height: 6),
                            Text(
                              cat.name,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

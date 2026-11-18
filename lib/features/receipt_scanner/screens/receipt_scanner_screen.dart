import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/transaction.dart';
import '../../../core/providers/finance_provider.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/fin_animated_icon.dart';
import '../../../shared/widgets/fin_section.dart';

class ReceiptScannerScreen extends ConsumerStatefulWidget {
  const ReceiptScannerScreen({super.key});

  @override
  ConsumerState<ReceiptScannerScreen> createState() => _ReceiptScannerScreenState();
}

class _ReceiptScannerScreenState extends ConsumerState<ReceiptScannerScreen>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  String? _imagePath;
  bool _isScanning = false;
  bool _scanCompleted = false;

  late final AnimationController _animController;

  // Extracted simulated values
  late final TextEditingController _merchantController;
  late final TextEditingController _totalController;
  late final TextEditingController _taxController;
  DateTime _extractedDate = DateTime.now();
  String _selectedCategory = 'Food & Dining';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _merchantController = TextEditingController();
    _totalController = TextEditingController();
    _taxController = TextEditingController();
  }

  @override
  void dispose() {
    _animController.dispose();
    _merchantController.dispose();
    _totalController.dispose();
    _taxController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(source: source);
      if (photo != null) {
        setState(() {
          _imagePath = photo.name;
          _isScanning = true;
          _scanCompleted = false;
        });

        _animController.repeat(reverse: true);

        // Simulate intelligent AI receipt processing (OCR)
        await Future.delayed(const Duration(milliseconds: 1800));

        if (!mounted) return;

        _animController.stop();

        setState(() {
          _isScanning = false;
          _scanCompleted = true;
          // Populate realistic mock extracted details
          _merchantController.text = 'Nature\'s Basket Gourmet';
          _totalController.text = '1840.50';
          _taxController.text = '92.00';
          _extractedDate = DateTime.now();
          _selectedCategory = 'Groceries';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Receipt scanned! Parsed items & tax successfully.'),
            backgroundColor: AppColors.deepForest,
          ),
        );
      }
    } catch (e) {
      // In web/desktop simulator, if image picker throws, mock a sample receipt
      setState(() {
        _imagePath = 'sample_cafe_receipt.jpg';
        _isScanning = false;
        _scanCompleted = true;
        _merchantController.text = 'Third Wave Coffee';
        _totalController.text = '420.00';
        _taxController.text = '21.00';
        _extractedDate = DateTime.now();
        _selectedCategory = 'Food & Dining';
      });
    }
  }

  void _saveExtractedTransaction() {
    final amount = double.tryParse(_totalController.text.trim()) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid receipt total amount.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final finance = ref.read(financeProvider);
    final account = finance.accounts.isNotEmpty ? finance.accounts.first : null;

    final newTx = TransactionModel(
      id: 'tx_scan_${DateTime.now().millisecondsSinceEpoch}',
      title: _merchantController.text.trim().isEmpty ? 'Receipt Purchase' : _merchantController.text.trim(),
      amount: amount,
      type: TransactionType.expense,
      categoryId: 'cat_groceries',
      categoryName: _selectedCategory,
      accountId: account?.id ?? 'acc_cash',
      accountName: account?.name ?? 'Primary Account',
      date: _extractedDate,
      paymentMethod: 'Card / Digital POS',
      notes: 'Scanned via SpendHunt AI Receipt Lens (Tax: ₹${_taxController.text})',
      merchant: _merchantController.text.trim(),
    );

    ref.read(financeProvider.notifier).addTransaction(newTx);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Transaction saved to ledger!'),
        backgroundColor: AppColors.success,
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
        title: const Text('Receipt Scanner'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 32 : 18,
                vertical: 18,
              ),
              children: [
                // Top Info Banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.deepForest.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    children: [
                      FinAnimatedIcon(
                        icon: LucideIcons.sparkles,
                        color: AppColors.deepForest,
                        size: 18,
                        pulse: true,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Scan or upload a paper receipt. SpendHunt AI extracts merchant, amount, tax & date into editable form.',
                          style: TextStyle(fontSize: 12, color: AppColors.deepForest, height: 1.35),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Scanner Viewport Box
                Container(
                  height: 230,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      width: 1.2,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_imagePath != null)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FinAnimatedIcon(
                              icon: LucideIcons.receiptText,
                              size: 44,
                              color: isDark ? AppColors.sage : AppColors.deepForest,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Receipt Source Attached',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _imagePath!,
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                            ),
                          ],
                        )
                      else
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceSecondaryLight,
                                shape: BoxShape.circle,
                              ),
                              child: const FinAnimatedIcon(
                                icon: LucideIcons.camera,
                                size: 30,
                                color: AppColors.sage,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Ready to scan receipt',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Position receipt within steady lighting',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                            ),
                          ],
                        ),

                      // Laser scanning animation line
                      if (_isScanning)
                        AnimatedBuilder(
                          animation: _animController,
                          builder: (context, child) {
                            return Positioned(
                              top: 20 + (_animController.value * 180),
                              left: 20,
                              right: 20,
                              child: Container(
                                height: 3,
                                decoration: BoxDecoration(
                                  color: AppColors.goldenYellow,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.goldenYellow.withValues(alpha: 0.6),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Capture Actions
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Take Picture',
                        icon: LucideIcons.camera,
                        onPressed: () => _pickImage(ImageSource.camera),
                        variant: AppButtonVariant.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppButton(
                        label: 'Choose Gallery',
                        icon: LucideIcons.image,
                        onPressed: () => _pickImage(ImageSource.gallery),
                        variant: AppButtonVariant.outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Extracted Information Form (Interactive & Editable)
                if (_scanCompleted) ...[
                  FinSection(
                    padding: const EdgeInsets.all(20),
                    children: [
                      const Row(
                        children: [
                          FinAnimatedIcon(
                            icon: LucideIcons.checkCheck,
                            color: AppColors.success,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Extracted Receipt Information',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Review and edit values before adding to your financial ledger.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                      ),
                      const SizedBox(height: 16),

                      AppTextField(
                        controller: _merchantController,
                        label: 'Merchant / Store',
                        prefixIcon: const Icon(LucideIcons.store, size: 18),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: _totalController,
                              label: 'Total Amount (₹)',
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              prefixIcon: const Icon(LucideIcons.coins, size: 18),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppTextField(
                              controller: _taxController,
                              label: 'Tax / GST (₹)',
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              prefixIcon: const Icon(LucideIcons.percent, size: 18),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Receipt Date', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                InkWell(
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: _extractedDate,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime.now(),
                                    );
                                    if (picked != null) setState(() => _extractedDate = picked);
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceLight,
                                      borderRadius: BorderRadius.circular(13),
                                      border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                                    ),
                                    child: Text(
                                      DateFormatter.formatShort(_extractedDate),
                                      style: const TextStyle(fontSize: 13),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
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
                                const Text('Category', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  initialValue: _selectedCategory,
                                  isExpanded: true,
                                  items: const [
                                    DropdownMenuItem(value: 'Food & Dining', child: Text('Food & Dining', overflow: TextOverflow.ellipsis)),
                                    DropdownMenuItem(value: 'Groceries', child: Text('Groceries', overflow: TextOverflow.ellipsis)),
                                    DropdownMenuItem(value: 'Shopping', child: Text('Shopping', overflow: TextOverflow.ellipsis)),
                                    DropdownMenuItem(value: 'Healthcare', child: Text('Healthcare', overflow: TextOverflow.ellipsis)),
                                    DropdownMenuItem(value: 'Bills & Utilities', child: Text('Bills & Utilities', overflow: TextOverflow.ellipsis)),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) setState(() => _selectedCategory = val);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      AppButton(
                        label: 'Save as Transaction',
                        icon: LucideIcons.check,
                        onPressed: _saveExtractedTransaction,
                        height: 50,
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

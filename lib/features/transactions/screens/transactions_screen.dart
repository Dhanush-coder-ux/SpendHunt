import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/transaction.dart';
import '../../../core/providers/finance_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/fin_animated_icon.dart';
import '../../../shared/widgets/fin_list_tile.dart';
import '../../../shared/widgets/fin_section.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  String _searchQuery = '';
  int _selectedTypeIndex = 0; // 0: All, 1: Income, 2: Expense, 3: Transfer
  String? _selectedCategory;
  String? _selectedAccount;
  String _sortBy = 'newest'; // newest, oldest, amount_high, amount_low

  @override
  Widget build(BuildContext context) {
    final finance = ref.watch(financeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppConstants.tabletBreakpoint;

    // Filter transactions
    var filtered = finance.transactions.where((tx) {
      // Type filter
      if (_selectedTypeIndex == 1 && tx.type != TransactionType.income) return false;
      if (_selectedTypeIndex == 2 && tx.type != TransactionType.expense) return false;
      if (_selectedTypeIndex == 3 && tx.type != TransactionType.transfer) return false;

      // Category filter
      if (_selectedCategory != null && tx.categoryId != _selectedCategory) return false;

      // Account filter
      if (_selectedAccount != null && tx.accountId != _selectedAccount) return false;

      // Search query
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesTitle = tx.title.toLowerCase().contains(q);
        final matchesMerchant = tx.merchant.toLowerCase().contains(q);
        final matchesCat = tx.categoryName.toLowerCase().contains(q);
        final matchesAcc = tx.accountName.toLowerCase().contains(q);
        if (!matchesTitle && !matchesMerchant && !matchesCat && !matchesAcc) return false;
      }

      return true;
    }).toList();

    // Sort transactions
    if (_sortBy == 'newest') {
      filtered.sort((a, b) => b.date.compareTo(a.date));
    } else if (_sortBy == 'oldest') {
      filtered.sort((a, b) => a.date.compareTo(b.date));
    } else if (_sortBy == 'amount_high') {
      filtered.sort((a, b) => b.amount.compareTo(a.amount));
    } else if (_sortBy == 'amount_low') {
      filtered.sort((a, b) => a.amount.compareTo(b.amount));
    }

    // Group transactions by date header
    final Map<String, List<TransactionModel>> grouped = {};
    for (var tx in filtered) {
      final dateKey = DateFormatter.formatRelative(tx.date);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(tx);
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Transactions',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: () => context.push('/categories'),
            icon: const Icon(LucideIcons.shapes, size: 20),
            tooltip: 'Categories',
          ),
          IconButton(
            onPressed: () => _showFilterSheet(context, finance),
            icon: Icon(
              LucideIcons.slidersHorizontal,
              size: 20,
              color: (_selectedCategory != null || _selectedAccount != null || _sortBy != 'newest')
                  ? AppColors.warmBronze
                  : null,
            ),
            tooltip: 'Filter & Sort',
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/transactions/add'),
        backgroundColor: AppColors.deepForest,
        foregroundColor: Colors.white,
        icon: const Icon(LucideIcons.plus, size: 18),
        label: const Text('Add Transaction', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search & Filter Header Section
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 32 : 18,
                vertical: 10,
              ),
              child: Column(
                children: [
                  // Search Bar
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                    child: TextField(
                      onChanged: (val) => setState(() => _searchQuery = val),
                      style: const TextStyle(fontSize: 13.5),
                      decoration: InputDecoration(
                        hintText: 'Search merchant, title or category...',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                        prefixIcon: Icon(
                          LucideIcons.search,
                          size: 18,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(LucideIcons.x, size: 16),
                                onPressed: () => setState(() => _searchQuery = ''),
                              )
                            : null,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Segmented Filter Tabs
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceSecondaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        _buildFilterTab('All', 0, isDark),
                        _buildFilterTab('Income', 1, isDark),
                        _buildFilterTab('Expense', 2, isDark),
                        _buildFilterTab('Transfer', 3, isDark),
                      ],
                    ),
                  ),

                  // Active filter chip indicators
                  if (_selectedCategory != null || _selectedAccount != null || _sortBy != 'newest') ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          'Filtered by: ',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        if (_selectedCategory != null)
                          _buildActiveChip(
                            finance.categories.firstWhere((c) => c.id == _selectedCategory).name,
                            () => setState(() => _selectedCategory = null),
                          ),
                        if (_selectedAccount != null)
                          _buildActiveChip(
                            finance.accounts.firstWhere((a) => a.id == _selectedAccount).name,
                            () => setState(() => _selectedAccount = null),
                          ),
                        if (_sortBy != 'newest')
                          _buildActiveChip(
                            'Sort: ${_sortBy.replaceAll('_', ' ')}',
                            () => setState(() => _sortBy = 'newest'),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Transactions Grouped Flat List
            Expanded(
              child: filtered.isEmpty
                  ? EmptyState(
                      title: 'No transactions found',
                      description: 'Try adjusting your search terms or filters.',
                      icon: LucideIcons.searchX,
                      actionLabel: 'Reset Filters',
                      onAction: () {
                        setState(() {
                          _searchQuery = '';
                          _selectedTypeIndex = 0;
                          _selectedCategory = null;
                          _selectedAccount = null;
                          _sortBy = 'newest';
                        });
                      },
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 32 : 18,
                        vertical: 4,
                      ),
                      itemCount: grouped.keys.length,
                      itemBuilder: (context, index) {
                        final header = grouped.keys.elementAt(index);
                        final txList = grouped[header]!;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                                child: Text(
                                  header,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.4,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ),
                              FinSection(
                                children: List.generate(txList.length, (i) {
                                  final tx = txList[i];
                                  final isLast = i == txList.length - 1;
                                  final isIncome = tx.type == TransactionType.income;
                                  final isTransfer = tx.type == TransactionType.transfer;

                                  final iconData = isIncome
                                      ? LucideIcons.arrowDownLeft
                                      : (isTransfer
                                          ? LucideIcons.arrowLeftRight
                                          : LucideIcons.shoppingBag);

                                  final iconColor = isIncome
                                      ? AppColors.success
                                      : (isTransfer
                                          ? AppColors.sage
                                          : (isDark ? AppColors.textPrimaryDark : AppColors.deepForest));

                                  final iconBg = isIncome
                                      ? AppColors.success.withValues(alpha: 0.12)
                                      : (isTransfer
                                          ? AppColors.sage.withValues(alpha: 0.12)
                                          : (isDark
                                              ? AppColors.surfaceSecondaryDark
                                              : AppColors.surfaceSecondaryLight));

                                  return FinListTile(
                                    onTap: () => context.push('/transactions/details/${tx.id}'),
                                    leading: FinAnimatedIcon(
                                      icon: iconData,
                                      size: 18,
                                      color: iconColor,
                                      backgroundColor: iconBg,
                                      backgroundSize: 40,
                                      borderRadius: 12,
                                    ),
                                    title: tx.title,
                                    subtitle: '${tx.categoryName} • ${tx.accountName}',
                                    trailingTitle:
                                        '${isIncome ? "+" : (isTransfer ? "" : "-")}${CurrencyFormatter.format(tx.amount, currencyCode: finance.profile.currency)}',
                                    trailingSubtitle: DateFormatter.formatTime(tx.date),
                                    trailingTitleColor: isIncome
                                        ? AppColors.success
                                        : (isTransfer
                                            ? (isDark ? AppColors.textPrimaryDark : AppColors.deepForest)
                                            : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                                    showDivider: !isLast,
                                  );
                                }),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(String label, int index, bool isDark) {
    final isSelected = _selectedTypeIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTypeIndex = index),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppColors.deepForest : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? (isDark ? Colors.white : AppColors.deepForest)
                    : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveChip(String label, VoidCallback onRemove) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Chip(
        label: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
        deleteIcon: const Icon(LucideIcons.x, size: 12),
        onDeleted: onRemove,
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  void _showFilterSheet(BuildContext context, FinanceState finance) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter & Sort',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedCategory = null;
                            _selectedAccount = null;
                            _sortBy = 'newest';
                          });
                          Navigator.pop(ctx);
                        },
                        child: const Text('Reset All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  const Text('Sort By', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Newest First'),
                        selected: _sortBy == 'newest',
                        onSelected: (val) {
                          setState(() => _sortBy = 'newest');
                          setSheetState(() {});
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Oldest First'),
                        selected: _sortBy == 'oldest',
                        onSelected: (val) {
                          setState(() => _sortBy = 'oldest');
                          setSheetState(() {});
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Highest Amount'),
                        selected: _sortBy == 'amount_high',
                        onSelected: (val) {
                          setState(() => _sortBy = 'amount_high');
                          setSheetState(() {});
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Lowest Amount'),
                        selected: _sortBy == 'amount_low',
                        onSelected: (val) {
                          setState(() => _sortBy = 'amount_low');
                          setSheetState(() {});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  const Text('Category', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    isExpanded: true,
                    decoration: const InputDecoration(hintText: 'All Categories'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All Categories')),
                      ...finance.categories.map(
                        (c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(c.name, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      setState(() => _selectedCategory = val);
                      setSheetState(() {});
                    },
                  ),
                  const SizedBox(height: 16),

                  const Text('Account', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedAccount,
                    isExpanded: true,
                    decoration: const InputDecoration(hintText: 'All Accounts'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All Accounts')),
                      ...finance.accounts.map(
                        (a) => DropdownMenuItem(
                          value: a.id,
                          child: Text(a.name, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      setState(() => _selectedAccount = val);
                      setSheetState(() {});
                    },
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Apply Filters'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/investment.dart';
import '../../../core/providers/finance_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/fin_animated_icon.dart';
import '../../../shared/widgets/fin_list_tile.dart';
import '../../../shared/widgets/fin_section.dart';
import '../../../shared/widgets/section_header.dart';

class InvestmentsScreen extends ConsumerStatefulWidget {
  const InvestmentsScreen({super.key});

  @override
  ConsumerState<InvestmentsScreen> createState() => _InvestmentsScreenState();
}

class _InvestmentsScreenState extends ConsumerState<InvestmentsScreen> {
  int _selectedFilter = 0; // 0: All, 1: Stocks, 2: Mutual Funds, 3: Gold, 4: Fixed Deposits

  @override
  Widget build(BuildContext context) {
    final finance = ref.watch(financeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppConstants.tabletBreakpoint;

    final totalValue = finance.totalInvestmentValue;
    final totalInvested = finance.totalInvestedCapital;
    final totalReturns = finance.totalInvestmentReturns;
    final returnRate = totalInvested > 0 ? (totalReturns / totalInvested) * 100 : 0.0;

    final investments = finance.investments.where((inv) {
      if (_selectedFilter == 1) return inv.type == InvestmentType.stocks;
      if (_selectedFilter == 2) return inv.type == InvestmentType.mutualFunds;
      if (_selectedFilter == 3) return inv.type == InvestmentType.gold;
      if (_selectedFilter == 4) return inv.type == InvestmentType.fixedDeposit;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Investment Portfolio', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            onPressed: () => context.push('/investments/add'),
            icon: const Icon(LucideIcons.plus, size: 20),
            tooltip: 'Add Investment',
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/investments/add'),
        backgroundColor: AppColors.deepForest,
        foregroundColor: Colors.white,
        icon: const Icon(LucideIcons.plus, size: 18),
        label: const Text('Add Asset', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 32 : 18,
            vertical: 18,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Portfolio Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.deepForest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'CURRENT PORTFOLIO VALUATION',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${finance.investments.length} Assets',
                            style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      CurrencyFormatter.format(totalValue, currencyCode: finance.profile.currency),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.8,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          totalReturns >= 0 ? LucideIcons.trendingUp : LucideIcons.trendingDown,
                          size: 14,
                          color: totalReturns >= 0 ? AppColors.goldenYellow : AppColors.error,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${totalReturns >= 0 ? "+" : ""}${CurrencyFormatter.format(totalReturns, currencyCode: finance.profile.currency)} (${returnRate >= 0 ? "+" : ""}${returnRate.toStringAsFixed(1)}%) overall returns',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: totalReturns >= 0 ? AppColors.goldenYellow : AppColors.error,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Container(height: 1, color: Colors.white.withValues(alpha: 0.12)),
                    const SizedBox(height: 14),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Invested Capital',
                                style: TextStyle(fontSize: 11.5, color: Colors.white.withValues(alpha: 0.7)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                CurrencyFormatter.format(totalInvested, currencyCode: finance.profile.currency),
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Unrealized P&L',
                              style: TextStyle(fontSize: 11.5, color: Colors.white.withValues(alpha: 0.7)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${totalReturns >= 0 ? "+" : ""}${returnRate.toStringAsFixed(2)}%',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: totalReturns >= 0 ? AppColors.goldenYellow : AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildChip('All Assets', 0),
                    _buildChip('Stocks & Equities', 1),
                    _buildChip('Mutual Funds', 2),
                    _buildChip('Digital Gold', 3),
                    _buildChip('Fixed Deposits', 4),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Holdings Flat List
              SectionHeader(
                title: 'Portfolio Holdings',
                subtitle: '${investments.length} assets',
              ),
              const SizedBox(height: 10),

              if (investments.isEmpty)
                EmptyState(
                  title: 'No investments in this category',
                  description: 'Add stocks, mutual funds, gold, or FDs to track your net worth.',
                  icon: LucideIcons.trendingUp,
                  actionLabel: 'Add Holding',
                  onAction: () => context.push('/investments/add'),
                )
              else
                FinSection(
                  children: List.generate(investments.length, (index) {
                    final inv = investments[index];
                    final isLast = index == investments.length - 1;
                    final isProfit = inv.isProfitable;

                    final iconData = inv.type == InvestmentType.gold
                        ? LucideIcons.coins
                        : (inv.type == InvestmentType.stocks ? LucideIcons.lineChart : LucideIcons.trendingUp);

                    final iconColor = isProfit ? AppColors.success : AppColors.warmBronze;

                    return FinListTile(
                      onTap: () => context.push('/investments/details/${inv.id}'),
                      leading: FinAnimatedIcon(
                        icon: iconData,
                        size: 19,
                        color: iconColor,
                        backgroundColor: iconColor.withValues(alpha: 0.12),
                        backgroundSize: 40,
                        borderRadius: 12,
                      ),
                      title: inv.name,
                      subtitle: '${inv.type.name.toUpperCase()} • ${inv.units.toStringAsFixed(inv.units.truncateToDouble() == inv.units ? 0 : 2)} units',
                      trailingTitle: CurrencyFormatter.format(inv.currentValue, currencyCode: finance.profile.currency),
                      trailingSubtitle: '${isProfit ? "+" : ""}${inv.returnPercentage.toStringAsFixed(1)}%',
                      trailingTitleColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      showDivider: !isLast,
                    );
                  }),
                ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, int index) {
    final isSelected = _selectedFilter == index;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: isSelected,
        onSelected: (_) => setState(() => _selectedFilter = index),
        selectedColor: AppColors.deepForest.withValues(alpha: 0.15),
        checkmarkColor: AppColors.deepForest,
      ),
    );
  }
}

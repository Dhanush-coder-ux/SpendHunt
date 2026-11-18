import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/finance_provider.dart';
import '../../../shared/widgets/fin_animated_icon.dart';
import '../../../shared/widgets/fin_list_tile.dart';
import '../../../shared/widgets/fin_section.dart';
import '../../../shared/widgets/section_header.dart';

class FinancialHealthScreen extends ConsumerWidget {
  const FinancialHealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final finance = ref.watch(financeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppConstants.tabletBreakpoint;

    final savingsRate = finance.savingsRateThisMonth;
    final dti = (finance.totalMonthlyEmi / (finance.totalIncomeThisMonth <= 0 ? 1 : finance.totalIncomeThisMonth)) * 100;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Financial Health Score'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 32 : 18,
                vertical: 18,
              ),
              children: [
                // Score Gauge Hero Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.deepForest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'OVERALL FINANCIAL HEALTH',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: AppColors.goldenYellow,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'STRONG TIER',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.goldenYellow,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Circular Score Metric
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 130,
                            height: 130,
                            child: CircularProgressIndicator(
                              value: 0.84,
                              strokeWidth: 10,
                              backgroundColor: Colors.white.withValues(alpha: 0.15),
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.goldenYellow),
                            ),
                          ),
                          const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '84',
                                style: TextStyle(
                                  fontSize: 38,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '/ 100',
                                style: TextStyle(fontSize: 12, color: Colors.white70),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      Text(
                        'Your finances are in excellent standing.',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'High savings rate and low debt service ratio keep you resilient.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Core Health Pillars
                const SectionHeader(
                  title: 'Core Diagnostic Pillars',
                  subtitle: 'Key ratios assessed against fintech industry benchmarks',
                ),
                const SizedBox(height: 10),

                FinSection(
                  children: [
                    FinListTile(
                      leading: const FinAnimatedIcon(
                        icon: LucideIcons.piggyBank,
                        size: 18,
                        color: AppColors.success,
                        backgroundColor: Color(0x1F548B68),
                        backgroundSize: 38,
                        borderRadius: 10,
                      ),
                      title: 'Monthly Savings Rate',
                      subtitle: 'Optimal (Target > 20%)',
                      trailingTitle: '${savingsRate.toStringAsFixed(1)}%',
                      trailingSubtitle: 'Score: 92/100',
                      trailingTitleColor: AppColors.success,
                      showDivider: true,
                    ),
                    FinListTile(
                      leading: const FinAnimatedIcon(
                        icon: LucideIcons.scale,
                        size: 18,
                        color: AppColors.deepForest,
                        backgroundColor: Color(0x1F0C3B2E),
                        backgroundSize: 38,
                        borderRadius: 10,
                      ),
                      title: 'Debt-to-Income (DTI) Ratio',
                      subtitle: 'Conservative Debt (< 35%)',
                      trailingTitle: '${dti.toStringAsFixed(1)}%',
                      trailingSubtitle: 'Score: 88/100',
                      trailingTitleColor: AppColors.success,
                      showDivider: true,
                    ),
                    FinListTile(
                      leading: const FinAnimatedIcon(
                        icon: LucideIcons.shieldCheck,
                        size: 18,
                        color: AppColors.goldenYellow,
                        backgroundColor: Color(0x1FFFBA00),
                        backgroundSize: 38,
                        borderRadius: 10,
                      ),
                      title: 'Emergency Fund Coverage',
                      subtitle: 'Adequate (Target 6 Months)',
                      trailingTitle: '4.2 Months',
                      trailingSubtitle: 'Score: 78/100',
                      trailingTitleColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      showDivider: true,
                    ),
                    FinListTile(
                      leading: const FinAnimatedIcon(
                        icon: LucideIcons.pieChart,
                        size: 18,
                        color: AppColors.warmBronze,
                        backgroundColor: Color(0x1FBB8A52),
                        backgroundSize: 38,
                        borderRadius: 10,
                      ),
                      title: 'Budget Discipline Index',
                      subtitle: 'Moderate (1 over-budget category)',
                      trailingTitle: '82%',
                      trailingSubtitle: 'Score: 75/100',
                      trailingTitleColor: AppColors.warmBronze,
                      showDivider: false,
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // Strengths & Improvement Areas
                const SectionHeader(title: 'Qualitative Assessment'),
                const SizedBox(height: 10),

                FinSection(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Row(
                      children: [
                        FinAnimatedIcon(
                          icon: LucideIcons.circleCheck,
                          color: AppColors.success,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text('Key Strengths', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildBullet('Strong positive net monthly cash flow surplus exceeding ₹60,000.'),
                    _buildBullet('Diversified equity investments in both index & active funds.'),
                    _buildBullet('Safe Debt-to-Income ratio well beneath lending limits.'),
                    Divider(
                      height: 24,
                      color: (isDark ? AppColors.borderDark : AppColors.borderLight).withValues(alpha: 0.65),
                    ),
                    const Row(
                      children: [
                        FinAnimatedIcon(
                          icon: LucideIcons.alertCircle,
                          color: AppColors.warmBronze,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text('Areas for Improvement', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildBullet('Food & dining category frequently approaches upper threshold limit.'),
                    _buildBullet('Reach 6 full months of emergency reserves for peak resilience.'),
                  ],
                ),
                const SizedBox(height: 18),

                // Regulated disclaimer
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'Disclaimer: FinPilot AI Health Score is an illustrative algorithmic personal management estimate, not an official credit bureau score (CIBIL/Experian).',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, right: 8),
            width: 5,
            height: 5,
            decoration: const BoxDecoration(color: AppColors.sage, shape: BoxShape.circle),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12.5, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

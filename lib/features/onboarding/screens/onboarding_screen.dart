import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/app_button.dart';
import '../widgets/onboarding_illustration.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingSlide> _slides = const [
    _OnboardingSlide(
      title: 'Let AI help you make smarter decisions',
      description:
          'SpendHunt AI analyses your cash flow run-rate, highlights anomalous expenses, and provides predictive end-of-month forecasts.',
      animationAsset: 'assets/animations/ai_insights.json',
    ),
    _OnboardingSlide(
      title: 'Manage your financial goals',
      description:
          'Set category spending budgets, track upcoming loans, monitor subscriptions, and watch your emergency fund grow progressively.',
      animationAsset: 'assets/animations/financial_goals.json',
    ),
    _OnboardingSlide(
      title: 'Understand your money',
      description:
          'Consolidate every savings account, digital wallet, credit card and cash balance into one unified, calm, and private command center.',
      animationAsset: 'assets/animations/unified_finances.json',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/sign-in');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppConstants.tabletBreakpoint;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => context.go('/sign-in'),
            child: Text(
              'Skip',
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _slides.length,
                    onPageChanged: (idx) => setState(() => _currentPage = idx),
                    itemBuilder: (context, index) {
                      final slide = _slides[index];
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          // Adaptively compute illustration size targeting 260–300 logical px
                          // on standard/large displays, scaling smoothly on smaller screens.
                          final availableHeight = constraints.maxHeight;
                          final illustrationSize =
                              (availableHeight * 0.48).clamp(200.0, 300.0);
                          final spacingAfterIllustration =
                              availableHeight > 520 ? 28.0 : 16.0;
                          final spacingBetweenTexts =
                              availableHeight > 520 ? 12.0 : 8.0;

                          return SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 28),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Center(
                                      child: OnboardingIllustration(
                                        assetPath: slide.animationAsset,
                                        isActive: _currentPage == index,
                                        size: illustrationSize,
                                      ),
                                    ),
                                    SizedBox(height: spacingAfterIllustration),
                                    Text(
                                      slide.title,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.4,
                                        color: isDark
                                            ? AppColors.textPrimaryDark
                                            : AppColors.textPrimaryLight,
                                      ),
                                    ),
                                    SizedBox(height: spacingBetweenTexts),
                                    Text(
                                      slide.description,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        color: isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondaryLight,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                // Indicator & Actions
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 32 : 24,
                    vertical: 24,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_slides.length, (i) {
                          final isSelected = _currentPage == i;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: isSelected ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.deepForest
                                  : (isDark ? AppColors.borderDark : AppColors.borderLight),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 28),

                      AppButton(
                        label: _currentPage == _slides.length - 1 ? 'Get Started' : 'Continue',
                        onPressed: _onNext,
                        height: 50,
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingSlide {
  final String title;
  final String description;
  final String animationAsset;

  const _OnboardingSlide({
    required this.title,
    required this.description,
    required this.animationAsset,
  });
}

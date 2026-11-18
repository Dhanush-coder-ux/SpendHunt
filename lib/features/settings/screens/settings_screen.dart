import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/finance_provider.dart';
import '../../../shared/widgets/confirmation_dialog.dart';
import '../../../shared/widgets/fin_animated_icon.dart';
import '../../../shared/widgets/fin_section.dart';
import '../../../shared/widgets/section_header.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final finance = ref.watch(financeProvider);
    final profile = finance.profile;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppConstants.tabletBreakpoint;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 32 : 18,
                vertical: 18,
              ),
              children: [
                // Appearance Section
                const SectionHeader(title: 'Appearance & Theme'),
                const SizedBox(height: 10),

                FinSection(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  children: [
                    Row(
                      children: [
                        FinAnimatedIcon(
                          icon: profile.isDarkMode ? LucideIcons.moon : LucideIcons.sun,
                          size: 19,
                          color: AppColors.warmBronze,
                          backgroundColor: AppColors.warmBronze.withValues(alpha: 0.12),
                          backgroundSize: 38,
                          borderRadius: 10,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Dark Forest Mode',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                profile.isDarkMode ? 'Dark Forest Palette' : 'Warm Off-White Earthy Palette',
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Switch.adaptive(
                          value: profile.isDarkMode,
                          activeTrackColor: AppColors.deepForest,
                          onChanged: (val) {
                            ref.read(financeProvider.notifier).toggleTheme();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // Currency & Localization
                const SectionHeader(title: 'Currency & Regional Units'),
                const SizedBox(height: 10),

                FinSection(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text(
                      'Primary Display Currency',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: profile.currency,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(LucideIcons.coins, size: 18),
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
                        DropdownMenuItem(
                          value: 'AED',
                          child: Text(
                            'AED — UAE Dirham',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          ref.read(financeProvider.notifier).updateProfile(
                                profile.copyWith(currency: val),
                              );
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // Security & Privacy
                const SectionHeader(title: 'Security & Privacy Controls'),
                const SizedBox(height: 10),

                FinSection(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  children: [
                    Row(
                      children: [
                        const FinAnimatedIcon(
                          icon: LucideIcons.fingerprint,
                          size: 19,
                          color: AppColors.sage,
                          backgroundColor: Color(0x1F8D9773),
                          backgroundSize: 38,
                          borderRadius: 10,
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Biometric Authentication',
                                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Require FaceID / Fingerprint on launch',
                                style: TextStyle(fontSize: 11.5, color: AppColors.textSecondaryLight),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Switch.adaptive(
                          value: profile.biometricEnabled,
                          activeTrackColor: AppColors.deepForest,
                          onChanged: (val) {
                            ref.read(financeProvider.notifier).updateProfile(
                                  profile.copyWith(biometricEnabled: val),
                                );
                          },
                        ),
                      ],
                    ),
                    Divider(
                      height: 20,
                      thickness: 0.8,
                      indent: 52,
                      color: (isDark ? AppColors.borderDark : AppColors.borderLight).withValues(alpha: 0.65),
                    ),
                    Row(
                      children: [
                        const FinAnimatedIcon(
                          icon: LucideIcons.bell,
                          size: 19,
                          color: AppColors.sage,
                          backgroundColor: Color(0x1F8D9773),
                          backgroundSize: 38,
                          borderRadius: 10,
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Financial Push Alerts',
                                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Budget threshold and bill due notices',
                                style: TextStyle(fontSize: 11.5, color: AppColors.textSecondaryLight),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Switch.adaptive(
                          value: profile.notificationsEnabled,
                          activeTrackColor: AppColors.deepForest,
                          onChanged: (val) {
                            ref.read(financeProvider.notifier).updateProfile(
                                  profile.copyWith(notificationsEnabled: val),
                                );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // Session / Logout
                const SectionHeader(title: 'Account Session'),
                const SizedBox(height: 10),

                FinSection(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Signed in as ${profile.name}',
                                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                profile.email,
                                style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondaryLight),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          icon: const Icon(LucideIcons.logOut, size: 16, color: AppColors.error),
                          label: const Text('Sign Out', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
                          onPressed: () async {
                            final confirmed = await ConfirmationDialog.show(
                              context,
                              title: 'Sign Out',
                              message: 'Are you sure you want to sign out of SpendHunt?',
                              confirmLabel: 'Sign Out',
                              isDestructive: true,
                            );
                            if (confirmed == true && context.mounted) {
                              context.go('/sign-in');
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

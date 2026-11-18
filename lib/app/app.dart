import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../core/providers/finance_provider.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class SpendHuntApp extends ConsumerWidget {
  const SpendHuntApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(financeProvider.select((s) => s.profile.isDarkMode));

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: appRouter,
    );
  }
}

typedef FinPilotApp = SpendHuntApp;

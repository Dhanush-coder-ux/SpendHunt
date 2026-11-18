import 'package:flutter/material.dart';
import '../../../shared/widgets/responsive_scaffold.dart';
import 'dashboard_screen.dart';

/// The main Home screen of SpendHunt, embedding [DashboardScreen]
/// inside the responsive shell (bottom navigation for mobile, sidebar for desktop).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveScaffold(
      currentIndex: 0,
      child: DashboardScreen(),
    );
  }
}

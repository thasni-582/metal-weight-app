import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:metal_weight/core/constants/app_colors.dart';
import 'package:metal_weight/core/providers/app_settings_provider.dart';
import 'package:metal_weight/screens/calculator/calculation_screen.dart';
import 'package:metal_weight/screens/history/history_screen.dart';
import 'package:metal_weight/screens/home/home_screen.dart';
import 'package:metal_weight/screens/settings/settings_screen.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _currentIndex = 0;
  int _historyRefreshTrigger = 0;
  DateTime? _lastPressedAt;

  void _navigateToCalculator() {
    setState(() {
      _currentIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettingsProvider>(context);

    final List<Widget> pages = [
      const HomeScreen(),
      const CalculationScreen(),
      HistoryScreen(
        key: ValueKey('history_$_historyRefreshTrigger'),
        onNavigateToCalculator: _navigateToCalculator,
      ),
      const SettingsScreen(),
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color activeColor = isDark ? const Color(0xFF38BDF8) : AppColors.blueprintBlue;
    final Color inactiveColor = isDark ? Colors.white60 : Colors.blueGrey.shade400;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_currentIndex != 0) {
          // Instead of exiting, go back to the Home tab!
          setState(() {
            _currentIndex = 0;
          });
          return;
        }

        final now = DateTime.now();
        if (_lastPressedAt == null ||
            now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
          _lastPressedAt = now;
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Press back again to exit'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          SystemNavigator.pop();
        }
      },
      child: Directionality(
        textDirection: settings.textDirection,
        child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: pages,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
            border: Border(
              top: BorderSide(
                color: isDark ? Colors.white12 : AppColors.borderLight.withValues(alpha: 0.8),
                width: 1.0,
              ),
            ),
          ),
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
                if (index == 2) {
                  _historyRefreshTrigger++;
                }
              });
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            height: 70,
            indicatorColor: activeColor.withValues(alpha: isDark ? 0.20 : 0.12),
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.home_outlined, color: inactiveColor, size: 25),
                selectedIcon: Icon(Icons.home_rounded, color: activeColor, size: 25),
                label: settings.strings.get('home'),
              ),
              NavigationDestination(
                icon: Icon(Icons.calculate_outlined, color: inactiveColor, size: 25),
                selectedIcon: Icon(Icons.calculate_rounded, color: activeColor, size: 25),
                label: settings.strings.get('calculator'),
              ),
              NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined, color: inactiveColor, size: 25),
                selectedIcon: Icon(Icons.receipt_long_rounded, color: activeColor, size: 25),
                label: settings.strings.get('history'),
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined, color: inactiveColor, size: 25),
                selectedIcon: Icon(Icons.settings_rounded, color: activeColor, size: 25),
                label: settings.strings.get('settings'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}

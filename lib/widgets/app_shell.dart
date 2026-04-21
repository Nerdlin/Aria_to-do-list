import 'package:flutter/material.dart';

import '../screens/analytics_screen.dart';
import '../screens/home_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/tasks_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    this.initialIndex = 0,
  });

  final int initialIndex;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _currentIndex;

  late final List<Widget> _pages = const [
    HomeScreen(),
    TasksScreen(),
    AnalyticsScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const activeColor = Color(0xFF7C3AED);
    final inactiveColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF9CA3AF);

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      floatingActionButton: Container(
        height: 66,
        width: 66,
        margin: const EdgeInsets.only(top: 24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => Navigator.pushNamed(context, '/add-task'),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: const Icon(Icons.add_rounded, size: 34, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 24,
        height: 78,
        shadowColor: Colors.black.withValues(alpha: 0.12),
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              activeIcon: Icons.home_rounded,
              inactiveIcon: Icons.home_outlined,
              label: 'Home',
              index: 0,
              activeColor: activeColor,
              inactiveColor: inactiveColor,
            ),
            _buildNavItem(
              activeIcon: Icons.check_box_rounded,
              inactiveIcon: Icons.check_box_outlined,
              label: 'Tasks',
              index: 1,
              activeColor: activeColor,
              inactiveColor: inactiveColor,
            ),
            const SizedBox(width: 48),
            _buildNavItem(
              activeIcon: Icons.bar_chart_rounded,
              inactiveIcon: Icons.bar_chart_outlined,
              label: 'Analytics',
              index: 2,
              activeColor: activeColor,
              inactiveColor: inactiveColor,
            ),
            _buildNavItem(
              activeIcon: Icons.settings_rounded,
              inactiveIcon: Icons.settings_outlined,
              label: 'Settings',
              index: 3,
              activeColor: activeColor,
              inactiveColor: inactiveColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData activeIcon,
    required IconData inactiveIcon,
    required String label,
    required int index,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    final isActive = _currentIndex == index;
    final color = isActive ? activeColor : inactiveColor;

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isActive ? activeIcon : inactiveIcon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


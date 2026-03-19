import 'package:flutter/material.dart';

import '../screens/analytics_screen.dart';
import '../screens/home_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/tasks_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    TasksScreen(),
    AnalyticsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      floatingActionButton: Container(
        height: 64,
        width: 64,
        margin: const EdgeInsets.only(top: 30),
        decoration: BoxDecoration(
          color: const Color(0xFF7B61FF),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7B61FF).withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => Navigator.pushNamed(context, '/add-task'),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: const Icon(Icons.add_rounded, size: 32, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Theme(
        data: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomAppBar(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          height: 75,
          color: Colors.white,
          elevation: 20,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_rounded, Icons.home_outlined, 'Home', 0),
              _buildNavItem(Icons.check_box_rounded, Icons.check_box_outlined, 'Tasks', 1),
              const SizedBox(width: 48), // Space for FAB
              _buildNavItem(Icons.bar_chart_rounded, Icons.bar_chart_outlined, 'Analytics', 2),
              _buildNavItem(Icons.settings_rounded, Icons.settings_outlined, 'Settings', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData activeIcon, IconData inactiveIcon, String label, int index) {
    final bool isActive = _currentIndex == index;
    final Color color = isActive ? const Color(0xFF7B61FF) : const Color(0xFF9CA3AF);

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
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

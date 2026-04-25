import 'package:flutter/material.dart';

/// Centralised colour palette for Aria.
///
/// Every colour that previously lived as a magic hex literal in individual
/// screens now has a single canonical definition here. Widget files should
/// import this class instead of duplicating values.
class AppColors {
  AppColors._();

  // ── Brand ───────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF7C3AED);
  static const Color secondary = Color(0xFF6366F1);
  static const Color accent = Color(0xFF8B5CF6);

  // ── Semantic ────────────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  static const Color pink = Color(0xFFEC4899);
  static const Color lightBlue = Color(0xFF60A5FA);

  // ── Surface (Dark) ─────────────────────────────────────────────────
  static const Color darkSurface = Color(0xFF111827);
  static const Color darkBackground = Color(0xFF0B1120);
  static const Color darkCard = Color(0xFF172033);
  static const Color darkBorder = Color(0xFF1E293B);
  static const Color darkDeepPurple = Color(0xFF1E1B4B);

  // ── Surface (Light) ────────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF8F7FF);
  static const Color lightSubdued = Color(0xFFF5F3FF);
  static const Color lightSubduedDeep = Color(0xFFEDE9FE);

  // ── Text ────────────────────────────────────────────────────────────
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color textMutedDark = Color(0xFF94A3B8);
  static const Color textBody = Color(0xFF6B7280);

  // ── Gradients ───────────────────────────────────────────────────────
  static const List<Color> primaryGradient = [accent, secondary];
  static const List<Color> headerGradientLight = [Color(0xFF6F32FF), accent];
  static const List<Color> headerGradientDark = [darkDeepPurple, Color(0xFF312E81)];
  static const List<Color> splashGradient = [
    Color(0xFF4C1D95),
    primary,
    secondary,
  ];

  // ── Helpers ─────────────────────────────────────────────────────────

  /// Returns the canonical colour for a task category.
  static Color categoryColor(String category) {
    switch (category) {
      case 'Personal':
        return info;
      case 'Health':
        return success;
      case 'Learning':
        return warning;
      case 'Finance':
        return error;
      case 'Creative':
        return pink;
      case 'Work':
      default:
        return primary;
    }
  }

  /// Returns the canonical colour for a task priority level.
  static Color priorityColor(String priority) {
    switch (priority) {
      case 'High':
        return error;
      case 'Low':
        return success;
      case 'Medium':
      default:
        return warning;
    }
  }
}

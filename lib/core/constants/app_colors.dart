import 'package:flutter/material.dart';

/// Application color palette — kept minimal and professional (banking style).
class AppColors {
  AppColors._();

  // Primary brand color: deep navy
  static const Color primary = Color(0xFF0D2137);
  static const Color primaryLight = Color(0xFF1A3A5C);
  static const Color primaryAccent = Color(0xFF1565C0);

  // Backgrounds
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F2F5);

  // Text
  static const Color textPrimary = Color(0xFF0D2137);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);

  // Status
  static const Color success = Color(0xFF0F7B55);
  static const Color error = Color(0xFFB91C1C);
  static const Color warning = Color(0xFFB45309);
  static const Color info = Color(0xFF1565C0);

  // Border / divider
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);

  // Sidebar
  static const Color sidebarBackground = Color(0xFF0D2137);
  static const Color sidebarActive = Color(0xFF1565C0);
  static const Color sidebarText = Color(0xFFCBD5E1);
  static const Color sidebarActiveText = Color(0xFFFFFFFF);
}

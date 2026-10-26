import 'package:flutter/material.dart';

/// Token warna (ios-bg, primary, dst).
class AppColors {
  AppColors._();
  static const primary = Color(0xFF8D4B00);
  static const primaryContainer = Color(0xFFB15F00);
  static const amberSoft = Color(0xFFFAF0E6);
  static const bg = Color(0xFFF2F2F7);
  static const fill = Color(0xFFE3E3E8);
  static const subtle = Color(0xFF8E8E93);
  static const separator = Color(0xFFE5E5EA);
  static const tertiary = Color(0xFFC7C7CC);
  static const green = Color(0xFF34C759);
  static const greenLight = Color(0xFFE8F8EE);
  static const greenDark = Color(0xFF1E7E34);
  static const red = Color(0xFFFF3B30);
  static const redLight = Color(0xFFFEECEC);
  static const dark = Color(0xFF1C1917);
  static const neutral900 = Color(0xFF171717);
  static const neutral800 = Color(0xFF262626);
  static const neutral600 = Color(0xFF525252);
  static const neutral100 = Color(0xFFF5F5F5);
  static const neutral50 = Color(0xFFFAFAFA);
  static const emerald = Color(0xFF10B981);
}

BoxDecoration cardBox({Color color = Colors.white, double radius = 16}) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: AppColors.separator),
    boxShadow: const [
      BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
    ],
  );
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: AppColors.primary).copyWith(
    primary: AppColors.primary,
    onPrimary: Colors.white,
  );
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.bg,
  );
  return base.copyWith(
    textTheme: base.textTheme,
    primaryTextTheme: base.primaryTextTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      foregroundColor: Colors.black,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.dark,
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),
  );
}

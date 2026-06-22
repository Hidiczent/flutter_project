import 'package:flutter/material.dart';
import 'package:laoepic_thesis_app/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

/// ພາສາລາວ → Noto Sans Lao · ອັງກິດ/ໄທ (UI) → Poppins
class AppTheme {
  /// Returns whether is lao locale based on the provided state.
  static bool isLaoLocale(String code) =>
      code.toLowerCase().trim() == 'lo';

  static TextTheme _compactTextTheme(TextTheme base) {
    TextStyle? down(TextStyle? s, double factor) {
      if (s == null) return null;
      final size = s.fontSize;
      return s.copyWith(
        fontSize: size != null ? size * factor : null,
      );
    }

    const factor = 0.92;
    return base.copyWith(
      displayLarge: down(base.displayLarge, factor),
      displayMedium: down(base.displayMedium, factor),
      displaySmall: down(base.displaySmall, factor),
      headlineLarge: down(base.headlineLarge, factor),
      headlineMedium: down(base.headlineMedium, factor),
      headlineSmall: down(base.headlineSmall, factor),
      titleLarge: down(base.titleLarge, 0.9),
      titleMedium: down(base.titleMedium, 0.9),
      titleSmall: down(base.titleSmall, 0.9),
      bodyLarge: down(base.bodyLarge, factor),
      bodyMedium: down(base.bodyMedium, factor),
      bodySmall: down(base.bodySmall, factor),
      labelLarge: down(base.labelLarge, factor),
      labelMedium: down(base.labelMedium, factor),
      labelSmall: down(base.labelSmall, factor),
    );
  }

  static ThemeData light(String localeCode) {
    final lao = isLaoLocale(localeCode);
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.accent,
      ),
      useMaterial3: true,
    );

    final rawTextTheme = lao
        ? GoogleFonts.notoSansLaoTextTheme(base.textTheme)
        : GoogleFonts.poppinsTextTheme(base.textTheme);
    final textTheme = _compactTextTheme(rawTextTheme);

    final titleStyle = lao
        ? GoogleFonts.notoSans(
            fontWeight: FontWeight.w600,
            fontSize: 17,
            color: Colors.white,
          )
        : GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 17,
            color: Colors.white,
          );

    return base.copyWith(
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      iconTheme: const IconThemeData(size: 22),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        toolbarHeight: 48,
        iconTheme: const IconThemeData(color: Colors.white, size: 22),
        backgroundColor: AppColors.primary,
        titleTextStyle: titleStyle,
      ),
      tabBarTheme: const TabBarThemeData(
        labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        isDense: true,
      ),
    );
  }
}

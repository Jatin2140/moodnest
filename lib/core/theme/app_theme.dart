import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => _buildTheme(isDark: false);
  static ThemeData get dark => _buildTheme(isDark: true);

  static ThemeData _buildTheme({required bool isDark}) {
    final colorScheme = isDark
        ? ColorScheme.dark(
            primary: const Color(0xFFF5A65B),
            secondary: const Color(0xFF8C7BB5),
            surface: AppColors.surfaceDark,
            onSurface: AppColors.textPrimaryDark,
            outline: AppColors.outlineDark,
          )
        : ColorScheme.light(
            primary: const Color(0xFFF5A65B),
            secondary: const Color(0xFF8C7BB5),
            surface: AppColors.surface,
            onSurface: AppColors.textPrimary,
            outline: AppColors.outline,
          );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.manropeTextTheme().copyWith(
        displayLarge: AppTypography.displayLg,
        displayMedium: AppTypography.displayMd,
        titleLarge: AppTypography.titleLg,
        bodyLarge: AppTypography.bodyLg,
        bodyMedium: AppTypography.bodyMd,
        labelSmall: AppTypography.caption,
      ),
      scaffoldBackgroundColor:
          isDark ? AppColors.surfaceDark : AppColors.surfaceMuted,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: AppTypography.titleLg.copyWith(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        ),
        iconTheme: IconThemeData(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? AppColors.surfaceMutedDark : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isDark ? AppColors.outlineDark : AppColors.outline,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? AppColors.surfaceMutedDark
            : AppColors.surfaceMuted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? AppColors.outlineDark : AppColors.outline,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? AppColors.outlineDark : AppColors.outline,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFF5A65B), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.danger, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: AppTypography.bodyMd
            .copyWith(color: isDark ? AppColors.textMutedDark : AppColors.textMuted),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0,
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        selectedItemColor: const Color(0xFFF5A65B),
        unselectedItemColor:
            isDark ? AppColors.textMutedDark : AppColors.textMuted,
        selectedLabelStyle: AppTypography.caption,
        unselectedLabelStyle: AppTypography.caption,
        type: BottomNavigationBarType.fixed,
      ),
      chipTheme: ChipThemeData(
        backgroundColor:
            isDark ? AppColors.surfaceMutedDark : AppColors.surfaceMuted,
        selectedColor: const Color(0xFFF5A65B).withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        labelStyle: AppTypography.caption,
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? AppColors.outlineDark : AppColors.outline,
        space: 1,
        thickness: 1,
      ),
    );
  }
}

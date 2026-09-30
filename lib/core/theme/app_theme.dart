import 'package:flutter/material.dart';

import 'app_colors.dart';

export 'app_colors.dart';

/// Boşluk ölçeği. Widget'lar kendi padding değerlerini uydurmaz.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

/// Köşe yarıçapı ölçeği. Yumuşak ama abartısız köşeler için tek kaynak.
class AppRadius {
  AppRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 22;
  static const double pill = 999;
}

/// Uygulama teması ve tipografi.
class AppTheme {
  AppTheme._();

  /// Hedef platform Windows olduğu için sistem yazı tipi kullanılır.
  /// İleride paketlenmiş bir yazı tipine geçmek istenirse yalnızca burası
  /// değişir.
  static const String fontFamily = 'Segoe UI';

  static const TextStyle _base = TextStyle(
    fontFamily: fontFamily,
    color: AppColors.textPrimary,
    height: 1.45,
  );

  /// Uygulamadaki tüm metin biçimleri buradan gelir.
  static final TextTheme textTheme = TextTheme(
    headlineMedium: _base.copyWith(
      fontSize: 26,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.4,
    ),
    headlineSmall: _base.copyWith(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
    ),
    titleLarge: _base.copyWith(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
    ),
    titleMedium: _base.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
    titleSmall: _base.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
    bodyLarge: _base.copyWith(fontSize: 15),
    bodyMedium: _base.copyWith(fontSize: 14, color: AppColors.textSecondary),
    bodySmall: _base.copyWith(fontSize: 13, color: AppColors.textSecondary),
    labelLarge: _base.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
    labelMedium: _base.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppColors.textSecondary,
      letterSpacing: 0.3,
    ),
  );

  static ThemeData get light {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    );
    final colorScheme = baseScheme.copyWith(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primarySoft,
      onPrimaryContainer: AppColors.primaryHover,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.danger,
      onError: AppColors.onPrimary,
      outline: AppColors.borderStrong,
      outlineVariant: AppColors.border,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.surface,
      splashFactory: InkRipple.splashFactory,
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(color: AppColors.textSecondary, size: 20),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        hintStyle: textTheme.bodyLarge?.copyWith(color: AppColors.textMuted),
        border: _inputBorder(AppColors.border),
        enabledBorder: _inputBorder(AppColors.border),
        focusedBorder: _inputBorder(AppColors.primary, width: 1.4),
        errorBorder: _inputBorder(AppColors.danger),
        focusedErrorBorder: _inputBorder(AppColors.danger, width: 1.4),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: textTheme.labelLarge,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.sm)),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.sm)),
          ),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        waitDuration: const Duration(milliseconds: 450),
        textStyle: textTheme.bodySmall?.copyWith(color: AppColors.onPrimary),
        decoration: const BoxDecoration(
          color: AppColors.textPrimary,
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.sm)),
        ),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thickness: const WidgetStatePropertyAll(8),
        radius: const Radius.circular(AppRadius.pill),
        thumbColor: const WidgetStatePropertyAll(AppColors.borderStrong),
        thumbVisibility: const WidgetStatePropertyAll(false),
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(AppRadius.md)),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

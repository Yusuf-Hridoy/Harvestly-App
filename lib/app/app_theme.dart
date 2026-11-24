import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';

/// Font families bundled in assets/fonts.
class AppFonts {
  const AppFonts._();

  /// Screen titles, the greeting, big numbers, the app name on login.
  static const String display = 'SpaceGrotesk';

  /// Everything else.
  static const String body = 'Inter';
}

/// Shared sizes so every screen looks the same.
class AppSizes {
  const AppSizes._();

  static const double cardRadius = 16;
  static const double controlRadius = 14;
  static const double borderWidth = 1;
  static const double minTapTarget = 44;
  static const double screenPadding = 16;
  static const double gap = 12;
}

/// Makes the Harvestly color set reachable from any widget.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette(this.colors);

  final AppColorSet colors;

  @override
  AppPalette copyWith({AppColorSet? colors}) =>
      AppPalette(colors ?? this.colors);

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return t < 0.5 ? this : other;
  }
}

/// Short way to read the Harvestly colors from a widget.
extension AppPaletteContext on BuildContext {
  AppColorSet get colors => Theme.of(this).extension<AppPalette>()!.colors;
}

/// Light and dark themes, both built from [AppColors].
class AppTheme {
  const AppTheme._();

  static ThemeData light() => _build(AppColors.light, Brightness.light);

  static ThemeData dark() => _build(AppColors.dark, Brightness.dark);

  /// Status bar and navigation bar icon colors for a theme.
  static SystemUiOverlayStyle overlayStyle(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final AppColorSet set = isDark ? AppColors.dark : AppColors.light;
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: set.surface,
      systemNavigationBarIconBrightness: isDark
          ? Brightness.light
          : Brightness.dark,
    );
  }

  static ThemeData _build(AppColorSet c, Brightness brightness) {
    final ColorScheme scheme = ColorScheme(
      brightness: brightness,
      primary: c.primary,
      onPrimary: c.onPrimary,
      secondary: c.secondary,
      onSecondary: c.onPrimary,
      secondaryContainer: c.secondarySoft,
      onSecondaryContainer: c.onSecondarySoft,
      tertiary: c.tertiary,
      onTertiary: c.onTertiary,
      error: c.error,
      onError: c.onPrimary,
      surface: c.surface,
      onSurface: c.text,
      onSurfaceVariant: c.textMuted,
      outline: c.border,
      outlineVariant: c.border,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.background,
      canvasColor: c.background,
      fontFamily: AppFonts.body,
      textTheme: _textTheme(c),
      extensions: <ThemeExtension<dynamic>>[AppPalette(c)],
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        foregroundColor: c.text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: overlayStyle(brightness),
        titleTextStyle: TextStyle(
          fontFamily: AppFonts.display,
          fontWeight: FontWeight.w600,
          fontSize: 20,
          color: c.text,
        ),
      ),
      cardTheme: CardThemeData(
        color: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          side: BorderSide(color: c.border, width: AppSizes.borderWidth),
        ),
      ),
      dividerTheme: DividerThemeData(color: c.border, thickness: 1, space: 1),
      iconTheme: IconThemeData(color: c.text),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: c.onPrimary,
          disabledBackgroundColor: c.primary.withValues(alpha: 0.5),
          disabledForegroundColor: c.onPrimary,
          minimumSize: const Size.fromHeight(52),
          elevation: 0,
          textStyle: const TextStyle(
            fontFamily: AppFonts.body,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.controlRadius),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.link,
          minimumSize: const Size(AppSizes.minTapTarget, AppSizes.minTapTarget),
          textStyle: const TextStyle(
            fontFamily: AppFonts.body,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.text,
          side: BorderSide(color: c.border, width: AppSizes.borderWidth),
          minimumSize: const Size(AppSizes.minTapTarget, AppSizes.minTapTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.controlRadius),
          ),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
          return states.contains(WidgetState.selected)
              ? c.primary
              : Colors.transparent;
        }),
        checkColor: WidgetStatePropertyAll<Color>(c.onPrimary),
        side: BorderSide(color: c.border, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
          return states.contains(WidgetState.selected) ? c.link : c.border;
        }),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.secondary,
        linearTrackColor: c.secondarySoft,
        circularTrackColor: c.secondarySoft,
        refreshBackgroundColor: c.surface,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.primary,
        contentTextStyle: TextStyle(
          fontFamily: AppFonts.body,
          fontSize: 14,
          color: c.onPrimary,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.controlRadius),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          side: BorderSide(color: c.border, width: AppSizes.borderWidth),
        ),
        titleTextStyle: TextStyle(
          fontFamily: AppFonts.display,
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: c.text,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        hintStyle: TextStyle(fontFamily: AppFonts.body, color: c.textMuted),
        labelStyle: TextStyle(fontFamily: AppFonts.body, color: c.textMuted),
        floatingLabelStyle: TextStyle(fontFamily: AppFonts.body, color: c.text),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        border: _inputBorder(c.border),
        enabledBorder: _inputBorder(c.border),
        focusedBorder: _inputBorder(c.link),
        errorBorder: _inputBorder(c.error),
        focusedErrorBorder: _inputBorder(c.error),
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppSizes.controlRadius),
    borderSide: BorderSide(color: color, width: AppSizes.borderWidth),
  );

  static TextTheme _textTheme(AppColorSet c) {
    TextStyle display(double size, FontWeight weight) => TextStyle(
      fontFamily: AppFonts.display,
      fontSize: size,
      fontWeight: weight,
      color: c.text,
    );
    TextStyle body(double size, FontWeight weight, {Color? color}) => TextStyle(
      fontFamily: AppFonts.body,
      fontSize: size,
      fontWeight: weight,
      color: color ?? c.text,
    );

    return TextTheme(
      displaySmall: display(32, FontWeight.w700),
      headlineMedium: display(26, FontWeight.w700),
      headlineSmall: display(22, FontWeight.w600),
      titleLarge: display(20, FontWeight.w600),
      titleMedium: body(16, FontWeight.w600),
      titleSmall: body(14, FontWeight.w600),
      bodyLarge: body(16, FontWeight.w400),
      bodyMedium: body(14, FontWeight.w400),
      bodySmall: body(13, FontWeight.w400, color: c.textMuted),
      labelLarge: body(14, FontWeight.w600),
      labelMedium: body(13, FontWeight.w500, color: c.textMuted),
      labelSmall: body(12, FontWeight.w500, color: c.textMuted),
    );
  }
}

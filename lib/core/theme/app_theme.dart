import 'package:flutter/material.dart';

class AppTheme {
  // Office-inspired color palette
  static const Color _primaryBlue = Color(0xFF2B579A);      // Word Blue
  static const Color _accentGreen = Color(0xFF217346);       // Excel Green
  static const Color _accentOrange = Color(0xFFD24726);      // PowerPoint Orange
  static const Color _accentPurple = Color(0xFF7B57A0);      // OneNote Purple
  static const Color _accentTeal = Color(0xFF008B8B);        // Design Teal

  static const Color _surfaceWhite = Color(0xFFFAFAFA);
  static const Color _canvasGray = Color(0xFFF0F0F0);
  static const Color _ribbonGray = Color(0xFFF5F6F7);
  static const Color _borderGray = Color(0xFFE0E0E0);
  static const Color _textPrimary = Color(0xFF333333);
  static const Color _textSecondary = Color(0xFF666666);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Segoe UI',
      colorScheme: const ColorScheme.light(
        primary: _primaryBlue,
        onPrimary: Colors.white,
        secondary: _accentGreen,
        onSecondary: Colors.white,
        tertiary: _accentOrange,
        surface: Colors.white,
        onSurface: _textPrimary,
        onSurfaceVariant: _textSecondary,
        surfaceContainerHighest: _ribbonGray,
        surfaceContainerHigh: Color(0xFFEEEFF0),
        surfaceContainer: _canvasGray,
        surfaceContainerLow: Color(0xFFF7F7F7),
        surfaceContainerLowest: _surfaceWhite,
        outline: _borderGray,
        outlineVariant: Color(0xFFE8E8E8),
      ),

      // AppBar — clean Office ribbon style
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0.5,
        backgroundColor: Colors.white,
        foregroundColor: _textPrimary,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: _textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: 'Segoe UI',
        ),
        iconTheme: IconThemeData(color: _textSecondary, size: 20),
        actionsIconTheme: IconThemeData(color: _textSecondary, size: 20),
      ),

      // Cards — subtle, clean borders
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: _borderGray, width: 1),
        ),
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),

      // Dividers
      dividerTheme: const DividerThemeData(
        color: _borderGray,
        thickness: 1,
        space: 1,
      ),

      // ListTile — clean flat style
      listTileTheme: const ListTileThemeData(
        dense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        titleTextStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: _textPrimary,
          fontFamily: 'Segoe UI',
        ),
        subtitleTextStyle: TextStyle(
          fontSize: 11,
          color: _textSecondary,
          fontFamily: 'Segoe UI',
        ),
        iconColor: _textSecondary,
        selectedTileColor: Color(0xFFE8F0FE),
        selectedColor: _primaryBlue,
      ),

      // IconButton — subtle hover
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: _textSecondary,
          padding: const EdgeInsets.all(8),
          minimumSize: const Size(36, 36),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),

      // FAB — Office blue
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _primaryBlue,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: StadiumBorder(),
      ),

      // Elevated buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, fontFamily: 'Segoe UI'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),

      // Chips — clean tags
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF0F4FF),
        selectedColor: _primaryBlue.withValues(alpha: 0.15),
        labelStyle: const TextStyle(fontSize: 12, color: _primaryBlue, fontFamily: 'Segoe UI'),
        side: BorderSide(color: _primaryBlue.withValues(alpha: 0.2)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      ),

      // Input fields — subtle borders
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: _borderGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: _borderGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: _primaryBlue, width: 1.5),
        ),
        hintStyle: const TextStyle(color: Color(0xFF999999), fontSize: 13),
      ),

      // Popup menu — clean
      popupMenuTheme: PopupMenuThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: _borderGray),
        ),
        textStyle: const TextStyle(fontSize: 13, color: _textPrimary, fontFamily: 'Segoe UI'),
      ),

      // SnackBar — clean blue
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF323232),
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'Segoe UI'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),

      // Bottom sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
      ),

      // Scrollbar
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(const Color(0xFFBBBBBB)),
        radius: const Radius.circular(10),
        thickness: WidgetStateProperty.all(6),
      ),

      // Tooltip
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: const Color(0xFF3B3B3B),
          borderRadius: BorderRadius.circular(4),
        ),
        textStyle: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Segoe UI'),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        waitDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  // Utility: get module accent color based on file extension
  static Color getModuleColor(String ext) {
    switch (ext) {
      case 'ordw':
        return _primaryBlue;
      case 'ords':
        return _accentGreen;
      case 'ordp':
        return _accentOrange;
      case 'ordd':
        return _accentTeal;
      case 'ordn':
        return _accentPurple;
      case 'pdf':
        return const Color(0xFFD42A2A);
      default:
        return _textSecondary;
    }
  }

  static String getModuleLabel(String ext) {
    switch (ext) {
      case 'ordw':
        return 'Writer';
      case 'ords':
        return 'Sheet';
      case 'ordp':
        return 'Slides';
      case 'ordd':
        return 'Design';
      case 'ordn':
        return 'Notes';
      case 'pdf':
        return 'PDF';
      default:
        return 'File';
    }
  }
}

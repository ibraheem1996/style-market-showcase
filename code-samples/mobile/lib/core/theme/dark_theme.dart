// Flutter imports:
import 'package:flutter/material.dart';

import '../utils/responsive/app_design_tokens.dart';
import '../utils/responsive/app_radius.dart';
import 'app_bottom_sheet_theme.dart';
import 'app_semantic_colors.dart';

Color _scaffoldColor = const Color(0xFF121212);
//!Dark theme configuration
ThemeData darkTheme(BuildContext context) => ThemeData(
  useMaterial3: true,
  fontFamily: 'Poppins',
  fontFamilyFallback: const ['Tajawal'],
  colorScheme: ColorScheme.dark(
    //!primary color
    primary: const Color(0xff12A4F4),
    onPrimary: Colors.white,

    //!secondary color
    secondary: const Color(0xFF333333),
    onSecondary: Colors.white,
    // secondary: const Color(0xFF1E1E1E),
    // onSecondary: const Color(0xFF333333),

    //!tertiary color
    tertiary: const Color(0xFF242424),
    onTertiary: const Color(0xFF2C2C2C),

    //!surface color
    surface: const Color(0xFF333333),
    onSurface: Colors.white70,

    //!error color
    error: Colors.red,
    onError: Colors.white,

    //!secondary container color
    secondaryContainer: Color.lerp(_scaffoldColor, Colors.white, 0.1),
    onSecondaryContainer: const Color.fromARGB(255, 177, 175, 175),

    //!outline color
    outline: const Color(0xFF8A8A8A),

    //!shadow color
    shadow: Colors.black.withValues(alpha: 0.6),
  ),
  extensions: const [AppSemanticColors(warning: Color(0xFFF59E0B))],

  //!scaffold background color
  scaffoldBackgroundColor: const Color(0xFF121212),

  //!bottom sheet theme
  bottomSheetTheme: appBottomSheetTheme(context),

  //!app bar theme
  appBarTheme: AppBarTheme(
    toolbarHeight: AppControlSizes.appBarToolbarHeight(context),

    backgroundColor: Color.lerp(_scaffoldColor, Colors.white, 0.06),
    centerTitle: true,
    elevation: 0,
    leadingWidth: AppControlSizes.appBarActionLane,
    iconTheme: IconThemeData(size: AppIconSizes.appBarAction(context)),
    actionsIconTheme: IconThemeData(size: AppIconSizes.appBarAction(context)),
  ),

  //!divider theme
  dividerTheme: const DividerThemeData(color: Color(0xFF121212)),

  //!bottom navigation bar theme
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Color.lerp(_scaffoldColor, Colors.white, 0.06),
  ),

  //!card theme
  cardTheme: CardThemeData(
    color: const Color(0xFF242424),
    margin: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.sm,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md(context)),
    ),
    elevation: 2.5,
  ),
  switchTheme: SwitchThemeData(
    thumbColor: const WidgetStatePropertyAll(Color(0xFF1E1E1E)),
    trackColor: WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.selected)) {
        return const Color(0xff12A4F4);
      }
      return const Color(0xff4A4A4A);
    }),
    trackOutlineColor: WidgetStateProperty.all(const Color(0xff4A4A4A)),
  ),

  //!elevated button theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xff12A4F4),
      foregroundColor: Colors.white,

      elevation: 5,
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      alignment: Alignment.center,
      foregroundColor: Colors.white.withValues(alpha: 0.8),
    ),
  ),

  actionIconTheme: ActionIconThemeData(
    backButtonIconBuilder: (context) {
      return Icon(Icons.arrow_back, size: AppIconSizes.appBarAction(context));
    },
  ),

  iconButtonTheme: IconButtonThemeData(
    style: IconButton.styleFrom(
      minimumSize: const Size.square(AppControlSizes.minimumTapTarget),
      iconSize: AppIconSizes.standardAction(context),
      tapTargetSize: MaterialTapTargetSize.padded,
    ),
  ),
);

//! Backward compatibility alias
ThemeData myDarkTheme(BuildContext context) => darkTheme(context);

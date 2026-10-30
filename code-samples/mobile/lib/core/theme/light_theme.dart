// Flutter imports:
import 'package:flutter/material.dart';

import '../utils/responsive/app_design_tokens.dart';
import '../utils/responsive/app_radius.dart';
import 'app_bottom_sheet_theme.dart';
import 'app_semantic_colors.dart';

Color _scaffoldColor = const Color.fromARGB(255, 202, 197, 215);
//! Light theme configuration
ThemeData lightTheme(BuildContext context) => ThemeData(
  useMaterial3: true,
  fontFamily: 'Poppins',
  fontFamilyFallback: const ['Tajawal'],

  colorScheme: ColorScheme.light(
    //!primary color
    primary: const Color(0xff12A4F4),
    onPrimary: Colors.white,

    //!secondary color
    secondary: const Color.fromARGB(255, 198, 206, 206),
    onSecondary: Colors.black,

    //!tertiary color
    tertiary: const Color(0xFFE0E0E0),
    onTertiary: const Color(0xFFEEEEEE),

    //!surface color
    surface: Colors.white,
    onSurface: Colors.black87,

    //!error color
    error: Colors.red,
    onError: Colors.white,

    //!secondary container color
    secondaryContainer: Color.lerp(_scaffoldColor, Colors.white, 0.4)!,
    onSecondaryContainer: const Color.fromARGB(255, 123, 119, 119),

    //!outline color
    outline: const Color(0xffD6D8D9),

    //!shadow color
    shadow: Colors.black26,
  ),
  extensions: const [AppSemanticColors(warning: Color(0xFFD97706))],

  //!scaffold background color
  scaffoldBackgroundColor: _scaffoldColor,

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
  dividerTheme: const DividerThemeData(color: Colors.grey),

  //!bottom navigation bar theme
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Color.lerp(_scaffoldColor, Colors.white, 0.15)!,
  ),

  //!elevated button theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xff12A4F4),
      foregroundColor: Colors.white,
      elevation: 5,
      shadowColor: Colors.black54,
    ),
  ),

  //!card theme
  cardTheme: CardThemeData(
    color: Color.lerp(_scaffoldColor, Colors.white, 0.4),
    margin: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.sm,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md(context)),
    ),
    elevation: 2.5,
  ),

  radioTheme: RadioThemeData(
    fillColor: WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.selected)) {
        return const Color(0xff12A4F4);
      }
      return Colors.black;
    }),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: const WidgetStatePropertyAll(Colors.white),
    trackColor: WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.selected)) {
        return const Color(0xff12A4F4);
      }
      return const Color(0xffD6D8D9);
    }),
    trackOutlineColor: WidgetStateProperty.all(const Color(0xffD6D8D9)),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      alignment: Alignment.center,
      foregroundColor: Colors.black87,
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
ThemeData myLightTheme(BuildContext context) => lightTheme(context);

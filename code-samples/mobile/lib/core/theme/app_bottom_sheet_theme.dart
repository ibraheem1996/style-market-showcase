import 'package:flutter/material.dart';

import '../utils/responsive/app_responsive_value.dart';
import '../utils/responsive/responsive_content_profile.dart';

/// Keeps application bottom sheets edge-to-edge on every window class.
BottomSheetThemeData appBottomSheetTheme(BuildContext context) {
  return BottomSheetThemeData(
    constraints: BoxConstraints(
      maxWidth: AppResponsiveValue.resolve(
        context,
        compact: double.infinity,
        medium: double.infinity,
        expanded: ResponsiveContentProfile.standard.maxWidth,
      ),
    ),
  );
}

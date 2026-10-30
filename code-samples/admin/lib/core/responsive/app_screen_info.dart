import 'package:flutter/widgets.dart';

import 'app_breakpoints.dart';

class AppScreenInfo {
  const AppScreenInfo({
    required this.width,
    required this.height,
    required this.screenClass,
    required this.orientation,
  });

  factory AppScreenInfo.fromSize(Size size) {
    return AppScreenInfo(
      width: size.width,
      height: size.height,
      screenClass: AppBreakpoints.classify(size.width),
      orientation: size.width >= size.height
          ? Orientation.landscape
          : Orientation.portrait,
    );
  }

  final double width;
  final double height;
  final AppScreenClass screenClass;
  final Orientation orientation;

  bool get isCompact => screenClass == AppScreenClass.compact;
  bool get isMedium => screenClass == AppScreenClass.medium;
  bool get isExpanded => screenClass == AppScreenClass.expanded;
  bool get isWide => screenClass == AppScreenClass.wide;
  bool get isDesktop => isExpanded || isWide;
}

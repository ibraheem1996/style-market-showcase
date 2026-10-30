import 'package:flutter/widgets.dart';

import 'app_screen_info.dart';

class AppResponsive extends StatelessWidget {
  const AppResponsive({required this.child, super.key});

  final Widget child;

  static AppScreenInfo of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<_AppResponsiveScope>();
    assert(scope != null, 'AppResponsive was not found in the widget tree.');
    return scope!.screen;
  }

  static Widget builder({
    required Widget Function(BuildContext context, AppScreenInfo screen)
    builder,
  }) {
    return Builder(builder: (context) => builder(context, of(context)));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaSize = MediaQuery.sizeOf(context);
        final width = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : mediaSize.width;
        final height = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : mediaSize.height;

        return _AppResponsiveScope(
          screen: AppScreenInfo.fromSize(Size(width, height)),
          child: child,
        );
      },
    );
  }
}

class _AppResponsiveScope extends InheritedWidget {
  const _AppResponsiveScope({required this.screen, required super.child});

  final AppScreenInfo screen;

  @override
  bool updateShouldNotify(_AppResponsiveScope oldWidget) {
    return screen.width != oldWidget.screen.width ||
        screen.height != oldWidget.screen.height ||
        screen.screenClass != oldWidget.screen.screenClass ||
        screen.orientation != oldWidget.screen.orientation;
  }
}

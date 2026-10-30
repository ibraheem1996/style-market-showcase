import 'package:flutter/widgets.dart';

import '../utils/responsive/app_window_class.dart';
import '../utils/responsive/responsive_content_profile.dart';

/// Centers content within a semantic maximum width and adaptive gutters.
///
/// The widget only constrains and pads its child. It does not replace
/// `MediaQuery`, apply safe-area padding, or own scrolling and state.
class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({
    required this.profile,
    required this.child,
    this.includeTopPadding = true,
    this.includeBottomPadding = true,
    this.alignment = Alignment.center,
    super.key,
  });

  const ResponsiveContent.form({
    required this.child,
    super.key,
    this.includeTopPadding = true,
    this.includeBottomPadding = true,
    this.alignment = Alignment.center,
  }) : profile = ResponsiveContentProfile.form;

  const ResponsiveContent.standard({
    required this.child,
    super.key,
    this.includeTopPadding = true,
    this.includeBottomPadding = true,
    this.alignment = Alignment.center,
  }) : profile = ResponsiveContentProfile.standard;

  const ResponsiveContent.catalog({
    required this.child,
    super.key,
    this.includeTopPadding = true,
    this.includeBottomPadding = true,
    this.alignment = Alignment.center,
  }) : profile = ResponsiveContentProfile.catalog;

  final ResponsiveContentProfile profile;
  final Widget child;
  final bool includeTopPadding;
  final bool includeBottomPadding;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final windowClass = AppWindowClass.fromWidth(constraints.maxWidth);
        final padding = ResponsiveContentGutters.forWindowClass(windowClass);
        return Align(
          alignment: alignment,
          heightFactor: 1,
          child: Padding(
            padding: EdgeInsets.only(
              top: includeTopPadding ? padding : 0,
              bottom: includeBottomPadding ? padding : 0,
              left: padding,
              right: padding,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: profile.maxWidth),
              child: SizedBox(width: double.infinity, child: child),
            ),
          ),
        );
      },
    );
  }
}

/// Centers a group of slivers within the same profiles as [ResponsiveContent].
///
/// This keeps surrounding slivers, such as a full-width app bar, outside the
/// constrained content region while preserving one scroll view.
class ResponsiveSliverContent extends StatelessWidget {
  const ResponsiveSliverContent({
    required this.profile,
    required this.slivers,
    super.key,
  });

  const ResponsiveSliverContent.form({required this.slivers, super.key})
    : profile = ResponsiveContentProfile.form;

  const ResponsiveSliverContent.standard({required this.slivers, super.key})
    : profile = ResponsiveContentProfile.standard;

  const ResponsiveSliverContent.catalog({required this.slivers, super.key})
    : profile = ResponsiveContentProfile.catalog;

  final ResponsiveContentProfile profile;
  final List<Widget> slivers;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final horizontalInset = ResponsiveContentInsets.horizontal(
          availableWidth: constraints.crossAxisExtent,
          profile: profile,
        );

        return SliverPadding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalInset,
            vertical: ResponsiveContentGutters.forWindowClass(
              AppWindowClass.fromWidth(constraints.crossAxisExtent),
            ),
          ),
          sliver: SliverMainAxisGroup(slivers: slivers),
        );
      },
    );
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/core/utils/responsive/app_window_class.dart';
import 'package:my_project/core/utils/responsive/responsive_content_profile.dart';

void main() {
  test('profiles own their semantic maximum widths centrally', () {
    expect(ResponsiveContentProfile.form.maxWidth, 560);
    expect(ResponsiveContentProfile.standard.maxWidth, 760);
    expect(ResponsiveContentProfile.catalog.maxWidth, 900);
  });

  test('gutters change at the compact boundary', () {
    expect(ResponsiveContentGutters.forWindowClass(AppWindowClass.compact), 12);
    expect(ResponsiveContentGutters.forWindowClass(AppWindowClass.medium), 24);
    expect(
      ResponsiveContentGutters.forWindowClass(AppWindowClass.expanded),
      24,
    );
  });

  test('standard sliver and chrome share the expanded centered inset', () {
    expect(
      ResponsiveContentInsets.horizontal(
        availableWidth: 1200,
        profile: ResponsiveContentProfile.standard,
      ),
      220,
    );
  });
}

abstract final class AppTextScaleLimits {
  /// Immersive onboarding foreground preserves its bounded visual composition.
  static const double onboarding = 1.5;

  /// Bounded horizontal product rails keep card metadata and actions usable.
  static const double productCard = 2.0;

  /// Compact navigation and AppBar metadata preserve fixed chrome geometry.
  static const double compactNavigation = 2.0;

  /// The fixed-height Home audience switcher keeps one-line tabs legible.
  static const double audienceSwitcher = 2.0;

  /// Home and Listing category controls preserve their compact geometry.
  static const double categories = 1.8;

  /// Home-only visual ceiling retained for extreme accessibility scaling.
  ///
  /// This is an explicit Home composition policy, not a default for other
  /// Features or the application root.
  static const double maxHomeBody = 2.8;

  /// Fixed checkout bars keep totals and their primary action reachable.
  static const double checkoutBottomBar = 1.8;

  /// Fixed Product Details actions keep quantity and CTA controls aligned.
  static const double bottomActionBar = 2.0;

  /// Product Details size choices retain usable fixed control geometry.
  static const double itemDetailsSizeSelector = 2.0;

  /// App-owned dialogs keep their complete presentation usable on short windows.
  static const double dialog = 2.0;

  /// App-owned snackbars preserve their compact transient presentation.
  static const double snackbar = 2.0;

  /// Bottom sheets with fixed headers or actions retain usable vertical space.
  static const double bottomSheet = 2.0;

  /// Form fields inside constrained sheets preserve decoration geometry.
  static const double appFormTextField = 1.8;

  /// Supplementary media labels stay inside small image overlays.
  static const double mediaBadge = 1.3;
}

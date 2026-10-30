import 'package:flutter/material.dart';

import '../utils/responsive/app_window_class.dart';

extension AppTypographyContextX on BuildContext {
  /// Resolves the app's semantic typography from this widget context.
  AppTypography get appTypography => AppTypography._(this);
}

/// Semantic text styles resolved from the active theme, locale, and width.
final class AppTypography {
  AppTypography._(BuildContext context)
    : _colors = Theme.of(context).colorScheme,
      _windowClass = AppWindowClass.fromWidth(MediaQuery.sizeOf(context).width),
      _isEnglish = Localizations.localeOf(context).languageCode == 'en';

  final ColorScheme _colors;
  final AppWindowClass _windowClass;
  final bool _isEnglish;

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  double _size({
    required double compact,
    required double medium,
    required double expanded,
  }) {
    return switch (_windowClass) {
      AppWindowClass.compact => compact,
      AppWindowClass.medium => medium,
      AppWindowClass.expanded => expanded,
    };
  }

  TextStyle _style({
    required double compact,
    required double medium,
    required double expanded,
    required FontWeight weight,
    required double height,
    bool display = false,
    bool italicInEnglish = false,
    Color? color,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      // Italic assets use their own family so Arabic fallback stays upright.
      fontFamily: display
          ? italicInEnglish && _isEnglish
                ? 'PlayfairItalic'
                : 'Playfair'
          : null,
      fontFamilyFallback: display ? const ['Tajawal'] : null,
      fontSize: _size(compact: compact, medium: medium, expanded: expanded),
      fontWeight: weight,
      height: height,
      letterSpacing: 0,
      color: color,
      decoration: decoration,
      decorationColor: decoration == null ? null : color,
    );
  }

  // ---------------------------------------------------------------------------
  // App bar
  // ---------------------------------------------------------------------------

  /// Titles and compact supporting metadata in shared AppBar chrome.
  ///
  /// Content titles below the AppBar use [page] or [sectionHeader].
  ({TextStyle title, TextStyle subtitle}) get appBar => (
    title: _style(
      compact: 19,
      medium: 20,
      expanded: 21,
      weight: FontWeight.w700,
      height: 1.25,
      display: true,
      italicInEnglish: true,
      color: _colors.onSurface,
    ),
    subtitle: _style(
      compact: 13,
      medium: 14,
      expanded: 15,
      weight: FontWeight.w400,
      height: 1.40,
      display: true,
      color: _colors.onSurfaceVariant,
    ),
  );

  // ---------------------------------------------------------------------------
  // Page
  // ---------------------------------------------------------------------------

  /// A page's in-content title, subtitle, and introductory description.
  ///
  /// It does not style AppBar titles or repeated section headers.
  ({TextStyle title, TextStyle subtitle, TextStyle description}) get page => (
    title: _style(
      compact: 22,
      medium: 23,
      expanded: 24,
      weight: FontWeight.w800,
      height: 1.30,
      display: true,
      italicInEnglish: true,
      color: _colors.onSurface,
    ),
    subtitle: _style(
      compact: 18,
      medium: 19,
      expanded: 20,
      weight: FontWeight.w400,
      height: 1.35,
      display: true,
      italicInEnglish: true,
      color: _colors.onSurfaceVariant,
    ),
    description: _style(
      compact: 16,
      medium: 16,
      expanded: 17,
      weight: FontWeight.w400,
      height: 1.50,
      color: _colors.onSurfaceVariant,
    ),
  );

  // ---------------------------------------------------------------------------
  // Section header
  // ---------------------------------------------------------------------------

  /// Repeated section headers such as New Arrivals and Recommended.
  ///
  /// Product Details subheadings keep their feature-owned hierarchy.
  ({
    TextStyle smallLabelAboveTitle,
    TextStyle title,
    TextStyle description,
    TextStyle viewAllAction,
  })
  get sectionHeader => (
    smallLabelAboveTitle: _style(
      compact: 14,
      medium: 14,
      expanded: 15,
      weight: FontWeight.w700,
      height: 1.35,
      color: _colors.primary,
    ),
    title: _style(
      compact: 20,
      medium: 21,
      expanded: 22,
      weight: FontWeight.w800,
      height: 1.30,
      display: true,
      italicInEnglish: true,
      color: _colors.onSecondary.withValues(alpha: 0.9),
    ),
    description: _style(
      compact: 14,
      medium: 14,
      expanded: 15,
      weight: FontWeight.w400,
      height: 1.45,
      color: _colors.onSurfaceVariant,
    ),
    viewAllAction: _style(
      compact: 14,
      medium: 14,
      expanded: 15,
      weight: FontWeight.w700,
      height: 1.35,
      color: _colors.primary,
    ),
  );

  // ---------------------------------------------------------------------------
  // Content text
  // ---------------------------------------------------------------------------

  /// Generic readable content when no more specific semantic owner exists.
  ///
  /// Do not use it in place of product, form, summary, or state-message roles.
  ({TextStyle primary, TextStyle supporting, TextStyle caption})
  get contentText => (
    primary: _style(
      compact: 16,
      medium: 17,
      expanded: 18,
      weight: FontWeight.w400,
      height: 1.50,
      color: _colors.onSecondary.withValues(alpha: 0.8),
    ),
    supporting: _style(
      compact: 14,
      medium: 15,
      expanded: 16,
      weight: FontWeight.w400,
      height: 1.45,
      color: _colors.onSurfaceVariant,
    ),
    caption: _style(
      compact: 13,
      medium: 14,
      expanded: 15,
      weight: FontWeight.w400,
      height: 1.40,
      color: _colors.onSurfaceVariant,
    ),
  );

  // ---------------------------------------------------------------------------
  // Store identity
  // ---------------------------------------------------------------------------

  /// The store name and identity description in Home chrome only.
  ///
  /// Page and section titles must use their own semantic roles.
  ({TextStyle name, TextStyle description}) get storeIdentity => (
    name: _style(
      compact: 19,
      medium: 20,
      expanded: 21,
      weight: FontWeight.w700,
      height: 1.25,
      display: true,
      italicInEnglish: true,
      color: _colors.onSurface,
    ),
    description: _style(
      compact: 14,
      medium: 14,
      expanded: 15,
      weight: FontWeight.w400,
      height: 1.35,
      color: _colors.onSurfaceVariant,
    ),
  );

  // ---------------------------------------------------------------------------
  // Onboarding
  // ---------------------------------------------------------------------------

  /// Large onboarding copy displayed over the onboarding artwork.
  ///
  /// Other media overlays use [mediaOverlay].
  ({TextStyle title, TextStyle description}) get onboarding => (
    title: _style(
      compact: 44,
      medium: 46,
      expanded: 48,
      weight: FontWeight.w800,
      height: 1.25,
      display: true,
      italicInEnglish: true,
      color: _colors.onPrimary,
    ),
    description: _style(
      compact: 20,
      medium: 20,
      expanded: 22,
      weight: FontWeight.w500,
      height: 1.50,
      color: _colors.onPrimary,
      display: true,
    ),
  );

  // ---------------------------------------------------------------------------
  // Product card
  // ---------------------------------------------------------------------------

  /// Product identity, price, and attributes inside reusable catalog cards.
  ///
  /// Full Product Details content uses [productDetails].
  ({
    TextStyle name,
    TextStyle currentPrice,
    TextStyle oldPrice,
    TextStyle attribute,
  })
  get productCard => (
    name: _style(
      compact: 15,
      medium: 15,
      expanded: 16,
      weight: FontWeight.w500,
      height: 1.35,
      color: _colors.onSecondary.withValues(alpha: 0.87),
    ),
    currentPrice: _style(
      compact: 17,
      medium: 17,
      expanded: 18,
      weight: FontWeight.w800,
      height: 1.25,
      color: _colors.primary,
    ),
    oldPrice: _style(
      compact: 14,
      medium: 14,
      expanded: 16,
      weight: FontWeight.w400,
      height: 1.25,
      color: _colors.onSurfaceVariant,
      // decoration: TextDecoration.lineThrough,
    ),
    attribute: _style(
      compact: 13,
      medium: 14,
      expanded: 15,
      weight: FontWeight.w500,
      height: 1.35,
      color: _colors.onSurfaceVariant,
    ),
  );

  // ---------------------------------------------------------------------------
  // Product details
  // ---------------------------------------------------------------------------

  /// The Product Details hierarchy, including its local section subheadings.
  ///
  /// Repeated catalog cards and cross-page headers keep separate owners.
  ({
    TextStyle name,
    TextStyle currentPrice,
    TextStyle oldPrice,
    TextStyle sectionTitle,
    TextStyle description,
    TextStyle optionValue,
  })
  get productDetails => (
    name: _style(
      compact: 19,
      medium: 20,
      expanded: 22,
      weight: FontWeight.w700,
      height: 1.30,
      display: true,
      color: _colors.onSurface,
    ),
    currentPrice: _style(
      compact: 19,
      medium: 20,
      expanded: 22,
      weight: FontWeight.w800,
      height: 1.25,
      color: _colors.primary,
    ),
    oldPrice: _style(
      compact: 16,
      medium: 16,
      expanded: 17,
      weight: FontWeight.w400,
      height: 1.25,
      color: _colors.onSurfaceVariant,
      decoration: TextDecoration.lineThrough,
    ),
    sectionTitle: _style(
      compact: 16,
      medium: 16,
      expanded: 17,
      weight: FontWeight.w500,
      height: 1.35,
      display: true,
      color: _colors.primary,
    ),
    description: _style(
      compact: 14,
      medium: 14,
      expanded: 15,
      weight: FontWeight.w400,
      height: 1.50,
      color: _colors.onSurface,
    ),
    optionValue: _style(
      compact: 14,
      medium: 14,
      expanded: 15,
      weight: FontWeight.w500,
      height: 1.35,
      color: _colors.onSurface,
    ),
  );

  // ---------------------------------------------------------------------------
  // Form field
  // ---------------------------------------------------------------------------

  /// Text owned by form fields and their InputDecoration.
  ///
  /// Submission feedback belongs to [stateMessage] or [snackbar].
  ({
    TextStyle enteredText,
    TextStyle label,
    TextStyle hint,
    TextStyle helperMessage,
    TextStyle errorMessage,
  })
  get formField => (
    enteredText: _style(
      compact: 16,
      medium: 16,
      expanded: 17,
      weight: FontWeight.w400,
      height: 1.40,
      color: _colors.onSurface,
    ),
    label: _style(
      compact: 14,
      medium: 14,
      expanded: 15,
      weight: FontWeight.w500,
      height: 1.35,
      color: _colors.onSurface,
    ),
    hint: _style(
      compact: 14,
      medium: 14,
      expanded: 15,
      weight: FontWeight.w400,
      height: 1.40,
      color: _colors.onSurfaceVariant,
    ),
    helperMessage: _style(
      compact: 12,
      medium: 12,
      expanded: 13,
      weight: FontWeight.w400,
      height: 1.40,
      color: _colors.onSurfaceVariant,
    ),
    errorMessage: _style(
      compact: 12,
      medium: 12,
      expanded: 13,
      weight: FontWeight.w400,
      height: 1.40,
      color: _colors.error,
    ),
  );

  // ---------------------------------------------------------------------------
  // Button
  // ---------------------------------------------------------------------------

  /// Labels inside stateful buttons, such as Continue or Add to Cart.
  ///
  /// The button component remains responsible for enabled/disabled colors.
  ({TextStyle label, TextStyle checkout, TextStyle secondary}) get button => (
    label: _style(
      compact: 16,
      medium: 17,
      expanded: 19,
      weight: FontWeight.w700,
      height: 1.25,
    ),
    checkout: _style(
      compact: 17,
      medium: 17,
      expanded: 18,
      weight: FontWeight.w700,
      height: 1.25,
    ),
    secondary: _style(
      compact: 14,
      medium: 14,
      expanded: 15,
      weight: FontWeight.w500,
      height: 1.10,
    ),
  );

  // ---------------------------------------------------------------------------
  // Text actions
  // ---------------------------------------------------------------------------

  /// Standalone links, inline expand/link text, and destructive text actions.
  ///
  /// Button children and section-owned View All actions use their own roles.
  ({
    TextStyle link,
    TextStyle inlineLink,
    TextStyle destructive,
    TextStyle secondary,
  })
  get textAction => (
    link: _style(
      compact: 14,
      medium: 15,
      expanded: 16,
      weight: FontWeight.w700,
      height: 1.35,
      color: _colors.primary,
    ),
    inlineLink: _style(
      compact: 14,
      medium: 14,
      expanded: 14,
      weight: FontWeight.w500,
      height: 1.35,
      color: _colors.primary,
    ),
    destructive: _style(
      compact: 14,
      medium: 14,
      expanded: 15,
      weight: FontWeight.w700,
      height: 1.35,
      color: _colors.error,
    ),
    secondary: _style(
      compact: 14,
      medium: 14,
      expanded: 15,
      weight: FontWeight.w500,
      height: 1.35,
      color: _colors.onSecondary,
    ),
  );

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------

  /// Tabs, bottom-navigation labels, categories, and search-entry prompts.
  ///
  /// Category labels remain separate because their layout evolves independently.
  ({
    TextStyle label,
    TextStyle selectedLabel,
    TextStyle categoryLabel,
    TextStyle searchPrompt,
  })
  get navigation => (
    label: _style(
      compact: 13,
      medium: 14,
      expanded: 14,
      weight: FontWeight.w500,
      height: 1.25,
      color: _colors.onSurfaceVariant,
    ),
    selectedLabel: _style(
      compact: 14,
      medium: 15,
      expanded: 15,
      weight: FontWeight.w700,
      height: 1.25,
      color: _colors.primary,
    ),
    categoryLabel: _style(
      compact: 14,
      medium: 15,
      expanded: 15,
      weight: FontWeight.w500,
      height: 1.30,
      color: _colors.onSurface,
    ),
    searchPrompt: _style(
      compact: 14,
      medium: 15,
      expanded: 16,
      weight: FontWeight.w400,
      height: 1.45,
      color: _colors.onSurfaceVariant,
    ),
  );

  // ---------------------------------------------------------------------------
  // Filter chip
  // ---------------------------------------------------------------------------

  /// Labels in removable or selectable filtering controls.
  ///
  /// Product attributes and supplementary badges keep their own roles.
  ({TextStyle label}) get filterChip => (
    label: _style(
      compact: 14,
      medium: 14,
      expanded: 15,
      weight: FontWeight.w500,
      height: 1.35,
      color: _colors.onSurfaceVariant,
    ),
  );

  // ---------------------------------------------------------------------------
  // List item
  // ---------------------------------------------------------------------------

  /// Titles and secondary details in rows such as Settings and Addresses.
  ///
  /// It does not own summary key-value rows or product-card content.
  ({TextStyle title, TextStyle detail}) get listItem => (
    title: _style(
      compact: 16,
      medium: 16,
      expanded: 17,
      weight: FontWeight.w500,
      height: 1.35,
      color: _colors.onSecondary.withValues(alpha: 0.90),
    ),
    detail: _style(
      compact: 14,
      medium: 14,
      expanded: 15,
      weight: FontWeight.w400,
      height: 1.40,
      color: _colors.onSurfaceVariant,
    ),
  );

  // ---------------------------------------------------------------------------
  // State messages
  // ---------------------------------------------------------------------------

  /// Empty, error, login-required, and loading-result state copy.
  ///
  /// Transient snackbar copy and generic supporting content are separate.
  ({TextStyle title, TextStyle message, TextStyle inlineMessage})
  get stateMessage => (
    title: _style(
      compact: 18,
      medium: 19,
      expanded: 20,
      weight: FontWeight.w700,
      height: 1.35,
      color: _colors.onSecondary.withValues(alpha: 0.9),
    ),
    message: _style(
      compact: 16,
      medium: 16,
      expanded: 17,
      weight: FontWeight.w400,
      height: 1.50,
      color: _colors.onSurface,
    ),
    inlineMessage: _style(
      compact: 14,
      medium: 14,
      expanded: 15,
      weight: FontWeight.w400,
      height: 1.40,
      color: _colors.onSurfaceVariant,
    ),
  );

  // ---------------------------------------------------------------------------
  // Sheet
  // ---------------------------------------------------------------------------

  /// Titles at the top of bottom sheets, such as Sort or Select Address.
  ///
  /// Sheet option rows use their semantic row or control owner.
  ({TextStyle title}) get sheet => (
    title: _style(
      compact: 19,
      medium: 20,
      expanded: 21,
      weight: FontWeight.w700,
      height: 1.35,
      display: true,
      color: _colors.onSecondary.withValues(alpha: 0.9),
    ),
  );

  // ---------------------------------------------------------------------------
  // Dialog
  // ---------------------------------------------------------------------------

  /// Dialog titles and explanatory messages.
  ///
  /// Dialog actions use [button] or [textAction].
  ({TextStyle title, TextStyle message}) get dialog => (
    title: _style(
      compact: 18,
      medium: 19,
      expanded: 20,
      weight: FontWeight.w700,
      height: 1.35,
      display: true,
      color: _colors.onSurface,
    ),
    message: _style(
      compact: 16,
      medium: 16,
      expanded: 17,
      weight: FontWeight.w400,
      height: 1.50,
      color: _colors.onSurfaceVariant,
    ),
  );

  // ---------------------------------------------------------------------------
  // Tooltip
  // ---------------------------------------------------------------------------

  /// Short descriptions for icon and compact controls, such as Back or Clear.
  ///
  /// Visible helper copy beside a control uses its form or content owner.
  ({TextStyle message}) get tooltip => (
    message: _style(
      compact: 12,
      medium: 12,
      expanded: 13,
      weight: FontWeight.w500,
      height: 1.35,
      color: _colors.onInverseSurface,
    ),
  );

  // ---------------------------------------------------------------------------
  // Snackbar
  // ---------------------------------------------------------------------------

  /// Transient snackbar title and message copy for operation outcomes.
  ///
  /// Persistent empty/error states use [stateMessage].
  ({TextStyle title, TextStyle message}) get snackbar => (
    title: _style(
      compact: 16,
      medium: 16,
      expanded: 17,
      weight: FontWeight.w400,
      height: 1.40,
      color: _colors.onSurface,
    ),
    message: _style(
      compact: 14,
      medium: 14,
      expanded: 15,
      weight: FontWeight.w400,
      height: 1.40,
      color: _colors.onSurface,
    ),
  );

  // ---------------------------------------------------------------------------
  // Badge
  // ---------------------------------------------------------------------------

  /// Supplementary micro-labels and compact counts, such as media badges.
  ///
  /// Domain statuses and filter controls must not use badge typography.
  ({TextStyle label, TextStyle count, TextStyle price}) get badge => (
    label: _style(
      compact: 11,
      medium: 11,
      expanded: 12,
      weight: FontWeight.w700,
      height: 1.20,
    ),
    count: _style(
      compact: 10,
      medium: 10,
      expanded: 10,
      weight: FontWeight.w700,
      height: 1.15,
    ),

    price: _style(
      compact: 14,
      medium: 14,
      expanded: 15,
      weight: FontWeight.w500,
      height: 1.15,
    ),
  );

  // ---------------------------------------------------------------------------
  // Status
  // ---------------------------------------------------------------------------

  /// Domain status headings, labels, and supporting lifecycle details.
  ///
  /// The status presentation owner supplies the paired data-driven foreground.
  ({TextStyle title, TextStyle label, TextStyle detail}) get status => (
    title: _style(
      compact: 18,
      medium: 19,
      expanded: 20,
      weight: FontWeight.w700,
      height: 1.35,
    ),
    label: _style(
      compact: 14,
      medium: 14,
      expanded: 15,
      weight: FontWeight.w700,
      height: 1.30,
    ),
    detail: _style(
      compact: 13,
      medium: 13,
      expanded: 14,
      weight: FontWeight.w400,
      height: 1.40,
    ),
  );

  // ---------------------------------------------------------------------------
  // Summary
  // ---------------------------------------------------------------------------

  /// Key-value and final-total hierarchy in Cart, Checkout, and Orders.
  ///
  /// General paragraphs and status labels use their own owners.
  ({
    TextStyle label,
    TextStyle value,
    TextStyle finalValue,
    TextStyle checkoutTitle,
  })
  get summary => (
    label: _style(
      compact: 15,
      medium: 15,
      expanded: 16,
      weight: FontWeight.w500,
      height: 1.35,
      color: _colors.onSecondary.withValues(alpha: 0.9),
    ),
    value: _style(
      compact: 14,
      medium: 14,
      expanded: 15,
      weight: FontWeight.w500,
      height: 1.35,
      color: _colors.onSurface,
    ),
    finalValue: _style(
      compact: 18,
      medium: 19,
      expanded: 20,
      weight: FontWeight.w800,
      height: 1.25,
      color: _colors.primary,
    ),

    checkoutTitle: _style(
      compact: 18,
      medium: 19,
      expanded: 20,
      weight: FontWeight.w700,
      height: 1.35,
      color: _colors.onSecondary.withValues(alpha: 0.9),
    ),
  );

  // ---------------------------------------------------------------------------
  // Media overlay
  // ---------------------------------------------------------------------------

  /// Readable messages over immersive media scrims, such as Media Viewer.
  ///
  /// It is not a replacement for page or state-message text.
  ({TextStyle message}) get mediaOverlay => (
    message: _style(
      compact: 16,
      medium: 16,
      expanded: 17,
      weight: FontWeight.w500,
      height: 1.45,
      color: _colors.onInverseSurface,
    ),
  );
}

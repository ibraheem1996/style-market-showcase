import 'package:flutter/material.dart';

/// Represents an active filter in a format directly usable by the UI.
/// This prevents the UI from having to cross-reference filter states
/// with filter options to determine names and colors.
class ActiveFilterUiModel {
  final ActiveFilterType type;
  final dynamic id;
  final String label;
  final Color? color;

  ActiveFilterUiModel({
    required this.type,
    required this.id,
    required this.label,
    this.color,
  });
}

enum ActiveFilterType { size, color, price }

/// Represents a subcategory in a format directly usable by the UI.
/// The name is already localized by the Controller.
class SubcategoryUiModel {
  final int id;
  final String name;
  final String imageUrl;

  SubcategoryUiModel({
    required this.id,
    required this.name,
    required this.imageUrl,
  });
}

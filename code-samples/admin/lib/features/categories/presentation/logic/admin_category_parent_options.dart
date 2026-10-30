import '../../domain/entities/admin_category_entities.dart';

/// Returns only roots accepted by the current root/direct-child write policy.
///
/// A category that already owns children cannot be moved under another root,
/// because that would create a third level under the current Backend policy.
List<AdminCategoryEntity> eligibleAdminCategoryParents({
  required List<AdminCategoryEntity> tree,
  AdminCategoryEntity? currentCategory,
}) {
  if (currentCategory != null && currentCategory.directChildrenCount > 0) {
    return const [];
  }
  return tree
      .where((category) => category.id != currentCategory?.id)
      .toList(growable: false);
}

AdminCategoryEntity? findAdminCategory(
  List<AdminCategoryEntity> tree,
  int categoryId,
) {
  for (final category in tree) {
    if (category.id == categoryId) return category;
    final child = findAdminCategory(category.children, categoryId);
    if (child != null) return child;
  }
  return null;
}

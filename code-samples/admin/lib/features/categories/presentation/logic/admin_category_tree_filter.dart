import '../../domain/entities/admin_category_entities.dart';
import '../cubit/categories_list/admin_categories_state.dart';

/// Filters a Backend-owned tree without changing sibling order.
///
/// Ancestors remain visible when a descendant matches so the result keeps its
/// hierarchy context instead of becoming a disconnected flat list.
List<AdminCategoryEntity> filterAdminCategoryTree({
  required List<AdminCategoryEntity> tree,
  required String query,
  required AdminCategoryStatusFilter status,
}) {
  final normalizedQuery = query.trim().toLowerCase();

  AdminCategoryEntity? visit(AdminCategoryEntity node) {
    final filteredChildren = node.children
        .map(visit)
        .whereType<AdminCategoryEntity>()
        .toList(growable: false);
    final matchesText =
        normalizedQuery.isEmpty ||
        node.arabicName.toLowerCase().contains(normalizedQuery) ||
        node.englishName.toLowerCase().contains(normalizedQuery);
    final matchesStatus = switch (status) {
      AdminCategoryStatusFilter.all => true,
      AdminCategoryStatusFilter.active => node.active,
      AdminCategoryStatusFilter.inactive => !node.active,
    };
    if (!(matchesText && matchesStatus) && filteredChildren.isEmpty) {
      return null;
    }
    return node.copyWith(children: filteredChildren);
  }

  return tree
      .map((t) => visit(t))
      .whereType<AdminCategoryEntity>()
      .toList(growable: false);
}

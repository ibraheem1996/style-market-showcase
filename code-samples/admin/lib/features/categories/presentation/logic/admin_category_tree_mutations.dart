import '../../domain/entities/admin_category_entities.dart';

List<AdminCategoryEntity> replaceAdminCategoryNode(
  List<AdminCategoryEntity> tree,
  AdminCategoryEntity replacement,
) {
  ({List<AdminCategoryEntity> tree, bool replaced}) replace(
    List<AdminCategoryEntity> nodes,
  ) {
    for (var i = 0; i < nodes.length; i++) {
      final node = nodes[i];

      if (node.id == replacement.id) {
        final updatedNodes = [...nodes];
        updatedNodes[i] = replacement;

        return (tree: updatedNodes, replaced: true);
      }

      final childResult = replace(node.children);

      if (childResult.replaced) {
        final updatedNodes = [...nodes];
        updatedNodes[i] = node.copyWith(children: childResult.tree);

        return (tree: updatedNodes, replaced: true);
      }
    }

    return (tree: nodes, replaced: false);
  }

  return replace(tree).tree;
}

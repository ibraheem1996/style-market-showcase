import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/responsive/app_radius.dart';
import '../../../../core/responsive/app_spacing.dart';
import '../../../../core/utils/image_url_resolver.dart';
import '../../../../shared/design_system/app_text_styles.dart';
import '../../domain/entities/admin_category_entities.dart';
import '../cubit/categories_list/admin_categories_state.dart';

class AdminCategoryTree extends StatelessWidget {
  const AdminCategoryTree({
    required this.categories,
    required this.imageUrlResolver,
    required this.operationCategoryId,
    required this.operation,
    required this.onEdit,
    required this.onVisibility,
    required this.onDelete,
    super.key,
  });

  final List<AdminCategoryEntity> categories;
  final ImageUrlResolver imageUrlResolver;
  final int? operationCategoryId;
  final AdminCategoryListOperation? operation;
  final ValueChanged<int> onEdit;
  final ValueChanged<AdminCategoryEntity> onVisibility;
  final ValueChanged<int> onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final category in categories)
          _CategoryBranch(category: category, isRoot: true, host: this),
      ],
    );
  }
}

class _CategoryBranch extends StatelessWidget {
  const _CategoryBranch({
    required this.category,
    required this.isRoot,
    required this.host,
  });

  final AdminCategoryEntity category;
  final bool isRoot;
  final AdminCategoryTree host;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isRoot
        ? Theme.of(context).colorScheme.surface
        : Theme.of(context).colorScheme.surface.withValues(alpha: 0.5);

    return Column(
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(
            start: isRoot ? 0 : AppSpacing.xl,
          ),
          child: _CategoryRow(
            isRoot: isRoot,
            category: category,
            host: host,
            backgroundColor: backgroundColor,
          ),
        ),
        for (final child in category.children)
          _CategoryBranch(category: child, isRoot: false, host: host),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.host,
    required this.backgroundColor,
    required this.isRoot,
  });

  final AdminCategoryEntity category;
  final AdminCategoryTree host;
  final Color backgroundColor;
  final bool isRoot;

  @override
  Widget build(BuildContext context) {
    final isBusy = host.operationCategoryId == category.id;
    final imageUrl = host.imageUrlResolver.resolve(category.image);
    return Card(
      color: backgroundColor,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: SizedBox.square(
                dimension: 52,
                child: imageUrl == null
                    ? const Icon(Icons.image_not_supported_outlined)
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            const Icon(Icons.broken_image_outlined),
                      ),
              ),
            ),
            SizedBox(
              width: 220,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.arabicName,
                    style: AppTextStyles.body(
                      context,
                    ).copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    category.englishName,
                    style: AppTextStyles.label(context),
                  ),
                ],
              ),
            ),
            if (isRoot) Chip(label: Text("رئيسي")),
            Chip(label: Text(category.active ? 'نشط' : 'غير نشط')),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'الرقم التعريفي: '),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(text: category.id.toString()),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(text: "تم نسخ"),
                                  TextSpan(
                                    text: " ${category.id.toString()} ",
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  ),
                                  TextSpan(text: "الا الحافضة"),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      child: Text(
                        category.id.toString(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text('الترتيب: ${category.sortOrder}'),
            Text('المنتجات: ${category.directProductCount}'),
            Text('الفروع: ${category.directChildrenCount}'),
            if (isBusy)
              const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator.adaptive(strokeWidth: 2),
              )
            else ...[
              IconButton(
                tooltip: 'تعديل',
                onPressed: host.operation == null
                    ? () => host.onEdit(category.id)
                    : null,
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: category.active ? 'إيقاف' : 'تفعيل',
                onPressed: host.operation == null
                    ? () => host.onVisibility(category)
                    : null,
                icon: Icon(
                  category.active
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              ),
              IconButton(
                tooltip: 'فحص الحذف',
                color: Theme.of(context).colorScheme.error,
                onPressed: host.operation == null
                    ? () => host.onDelete(category.id)
                    : null,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

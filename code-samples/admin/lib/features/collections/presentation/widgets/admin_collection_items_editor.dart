import 'package:flutter/material.dart';
import 'package:multi_product_store_admin_web/shared/design_system/app_text_styles.dart';

import '../../../../core/responsive/app_spacing.dart';
import '../../../../shared/presentation/widgets/app_error_view.dart';
import '../../domain/entities/admin_collection_entities.dart';
import '../cubit/collection_items/admin_collection_items_cubit.dart';
import '../cubit/collection_items/admin_collection_items_state.dart';

class AdminCollectionItemsEditor extends StatelessWidget {
  const AdminCollectionItemsEditor({
    required this.collectionId,
    required this.state,
    required this.cubit,
    super.key,
  });

  final int collectionId;
  final AdminCollectionItemsState state;
  final AdminCollectionItemsCubit cubit;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Card(child: LinearProgressIndicator()),
        ),
      );
    }
    if (state.loadError != null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: AppErrorView(
            message: state.loadError!,
            onRetry: () => cubit.load(collectionId),
          ),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'منتجات المجموعة',
                    style: AppTextStyles.title(context),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: state.isSubmitting ? null : cubit.addRow,
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة منتج'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'أدخل أرقام المنتجات يدويًا. سيستبدل الحفظ القائمة كاملة.',
            ),
            const SizedBox(height: AppSpacing.md),
            if (state.items.isNotEmpty) ...[
              _CurrentItems(items: state.items),
              const SizedBox(height: AppSpacing.md),
            ],

            _ItemsRows(state: state, cubit: cubit),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                FilledButton.icon(
                  onPressed: state.isSubmitting
                      ? null
                      : () => cubit.submit(collectionId),
                  icon: state.isSubmitting
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator.adaptive(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: const Text('استبدال قائمة المنتجات'),
                ),
                OutlinedButton.icon(
                  onPressed: state.isSubmitting
                      ? null
                      : cubit.assignSequentialSortOrder,
                  icon: const Icon(Icons.format_list_numbered),
                  label: const Text('ترتيب تلقائي'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrentItems extends StatelessWidget {
  const _CurrentItems({required this.items});

  final List<AdminCollectionItem> items;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('رقم المنتج')),
          DataColumn(label: Text('الاسم العربي')),
          DataColumn(label: Text('الاسم الإنجليزي')),
          DataColumn(label: Text('الحالة')),
          DataColumn(label: Text('الترتيب')),
        ],
        rows: [
          for (final item in items)
            DataRow(
              cells: [
                DataCell(Text('${item.productId}')),
                DataCell(Text(item.arabicName)),
                DataCell(Text(item.englishName ?? '-')),
                DataCell(Text(item.active ? 'نشط' : 'غير نشط')),
                DataCell(Text('${item.sortOrder}')),
              ],
            ),
        ],
      ),
    );
  }
}

class _ItemsRows extends StatelessWidget {
  const _ItemsRows({required this.state, required this.cubit});

  final AdminCollectionItemsState state;
  final AdminCollectionItemsCubit cubit;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 640),
        child: Column(
          children: [
            for (var index = 0; index < state.drafts.length; index++)
              _ItemRow(
                index: index,
                productId: state.drafts[index].productId,
                sortOrder: state.drafts[index].sortOrder,
                errors: state.showValidationErrors
                    ? state.rowErrors[index] ?? const <String, String>{}
                    : const <String, String>{},
                enabled: !state.isSubmitting,
                onProductChanged: (value) =>
                    cubit.productIdChanged(index, value),
                onSortChanged: (value) => cubit.sortOrderChanged(index, value),
                onRemove: () => cubit.removeRow(index),
              ),
          ],
        ),
      ),
    );
  }
}

class _ItemRow extends StatefulWidget {
  const _ItemRow({
    required this.index,
    required this.productId,
    required this.sortOrder,
    required this.errors,
    required this.enabled,
    required this.onProductChanged,
    required this.onSortChanged,
    required this.onRemove,
  });

  final int index;
  final String productId;
  final String sortOrder;
  final Map<String, String> errors;
  final bool enabled;
  final ValueChanged<String> onProductChanged;
  final ValueChanged<String> onSortChanged;
  final VoidCallback onRemove;

  @override
  State<_ItemRow> createState() => _ItemRowState();
}

class _ItemRowState extends State<_ItemRow> {
  late final TextEditingController _productController;
  late final TextEditingController _sortController;

  @override
  void initState() {
    super.initState();
    _productController = TextEditingController(text: widget.productId);
    _sortController = TextEditingController(text: widget.sortOrder);
  }

  @override
  void didUpdateWidget(covariant _ItemRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync(_productController, widget.productId);
    _sync(_sortController, widget.sortOrder);
  }

  @override
  void dispose() {
    _productController.dispose();
    _sortController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 220,
            child: TextField(
              controller: _productController,
              enabled: widget.enabled,
              keyboardType: TextInputType.number,
              onChanged: widget.onProductChanged,
              decoration: InputDecoration(
                labelText: 'رقم المنتج ${widget.index + 1}',
                errorText: widget.errors['productId'],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          SizedBox(
            width: 180,
            child: TextField(
              controller: _sortController,
              enabled: widget.enabled,
              keyboardType: TextInputType.number,
              onChanged: widget.onSortChanged,
              decoration: InputDecoration(
                labelText: 'الترتيب',
                errorText: widget.errors['sortOrder'],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            tooltip: 'حذف الصف',
            onPressed: widget.enabled ? widget.onRemove : null,
            icon: const Icon(Icons.remove_circle_outline),
          ),
        ],
      ),
    );
  }

  void _sync(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }
}

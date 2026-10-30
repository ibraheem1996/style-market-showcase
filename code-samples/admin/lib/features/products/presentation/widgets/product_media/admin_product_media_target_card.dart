import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:multi_product_store_admin_web/core/responsive/app_icon_sizes.dart';
import 'package:multi_product_store_admin_web/core/responsive/app_responsive.dart';

import '../../../../../core/responsive/app_layout_values.dart';
import '../../../../../core/responsive/app_radius.dart';
import '../../../../../core/responsive/app_spacing.dart';
import '../../../../../core/utils/image_url_resolver.dart';
import '../../../../../shared/design_system/app_palette.dart';
import '../../../../../shared/design_system/app_text_styles.dart';
import '../../../../../shared/presentation/dialogs/confirm_dialog.dart';
import '../../../domain/entities/admin_product_media_entities.dart';
import '../../cubit/product_media/admin_product_media_state.dart';
import '../admin_product_image.dart';
import '../admin_product_image_wrap.dart';
import 'admin_product_media_labels.dart';

class AdminProductMediaTargetCard extends StatelessWidget {
  const AdminProductMediaTargetCard({
    required this.target,
    required this.limits,
    required this.imageUrlResolver,
    required this.operation,
    required this.pageHasActiveMutation,
    required this.onUpload,
    required this.onDelete,
    required this.onReorder,
    required this.onSetPrimary,
    required this.onValidationError,
    super.key,
  });

  final AdminProductMediaTargetEntity target;
  final AdminProductMediaLimitsEntity limits;
  final ImageUrlResolver imageUrlResolver;
  final AdminProductMediaTargetOperationState? operation;
  final bool pageHasActiveMutation;
  final ValueChanged<List<AdminProductMediaUploadFileEntity>> onUpload;
  final ValueChanged<int> onDelete;
  final ValueChanged<List<int>> onReorder;
  final ValueChanged<int?> onSetPrimary;
  final ValueChanged<String> onValidationError;

  @override
  Widget build(BuildContext context) {
    final screen = AppResponsive.of(context);
    final colors = Theme.of(context).semanticColors;
    final isTargetBusy = operation?.operation != null;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TargetHeader(target: target),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Chip(label: Text(target.scope.label)),
                Chip(label: Text('الصور: ${target.ownedImages.length}')),
                if (target.owner.active == false)
                  const Chip(label: Text('غير نشط')),
                if (isTargetBusy)
                  const Chip(label: Text('جار تنفيذ العملية...')),
              ],
            ),
            if (operation?.errorMessage != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                operation!.errorMessage!,
                style: AppTextStyles.label(
                  context,
                ).copyWith(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Center(
              child: SizedBox(
                height: AppLayoutValues.buttonHeight(screen),
                child: ElevatedButton.icon(
                  onPressed: pageHasActiveMutation
                      ? null
                      : () => _pickFiles(context),
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: const Text('إضافة صور'),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _OwnedImagesList(
              images: target.ownedImages,
              imageUrlResolver: imageUrlResolver,
              disabled: pageHasActiveMutation,
              onDelete: (imageId) async {
                final confirmed = await showAppConfirmDialog(
                  context: context,
                  title: 'حذف الصورة',
                  message: 'سيتم حذف هذه الصورة من هذا المنتج.',
                  confirmLabel: 'حذف',
                );
                if (confirmed) onDelete(imageId);
              },
              onSetPrimary: onSetPrimary,
              onReorder: onReorder,
            ),
            const SizedBox(height: AppSpacing.md),
            _EffectiveImagesPanel(
              target: target,
              imageUrlResolver: imageUrlResolver,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFiles(BuildContext context) async {
    final extensions = limits.allowedExtensions
        .map((item) => item.replaceFirst('.', '').toLowerCase())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
    final files = await openFiles(
      acceptedTypeGroups: [
        XTypeGroup(
          label: 'Images',
          extensions: extensions,
          mimeTypes: limits.allowedMimeTypes,
        ),
      ],
    );
    if (files.isEmpty) return;
    if (files.length > limits.maxFilesPerRequest) {
      onValidationError(
        'يمكن رفع ${limits.maxFilesPerRequest} صور كحد أقصى في كل عملية.',
      );
      return;
    }

    final allowedExtensions = limits.allowedExtensions
        .map((item) => item.toLowerCase())
        .toSet();
    final uploadFiles = <AdminProductMediaUploadFileEntity>[];
    for (final file in files) {
      final extension = _extensionOf(file.name);
      if (!allowedExtensions.contains(extension)) {
        onValidationError('امتداد الملف ${file.name} غير مسموح.');
        return;
      }
      final length = await file.length();
      if (length > limits.maxFileBytes) {
        onValidationError('الملف ${file.name} يتجاوز الحجم المسموح.');
        return;
      }
      final bytes = await file.readAsBytes();
      uploadFiles.add(
        AdminProductMediaUploadFileEntity(
          name: file.name,
          bytes: bytes,
          size: length,
          mimeType: file.mimeType,
        ),
      );
    }

    onUpload(uploadFiles);
  }

  String _extensionOf(String name) {
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex == -1) return '';
    return name.substring(dotIndex).toLowerCase();
  }
}

class _TargetHeader extends StatelessWidget {
  const _TargetHeader({required this.target});

  final AdminProductMediaTargetEntity target;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (target.owner.color?.hex != null) ...[
          AdminProductColorSwatch(hex: target.owner.color?.hex),
          const SizedBox(width: AppSpacing.sm),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                target.headerName,
                style: AppTextStyles.sectionTitle(context),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Target #${target.targetId} - ${target.targetKey}',
                style: AppTextStyles.label(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OwnedImagesList extends StatelessWidget {
  const _OwnedImagesList({
    required this.images,
    required this.imageUrlResolver,
    required this.disabled,
    required this.onDelete,
    required this.onSetPrimary,
    required this.onReorder,
  });

  final List<AdminProductMediaImageEntity> images;
  final ImageUrlResolver imageUrlResolver;
  final bool disabled;
  final ValueChanged<int> onDelete;
  final ValueChanged<int?> onSetPrimary;
  final ValueChanged<List<int>> onReorder;

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return Text(
        'لا توجد صور مملوكة لهذا الهدف.',
        style: AppTextStyles.label(context),
      );
    }

    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),

      buildDefaultDragHandles: false,

      itemCount: images.length,

      onReorder: disabled || images.length < 2
          ? (_, _) {}
          : (oldIndex, newIndex) {
              final ordered = [...images];

              final item = ordered.removeAt(oldIndex);

              final insertIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;

              ordered.insert(insertIndex, item);

              onReorder(ordered.map((e) => e.imageId).toList());
            },

      itemBuilder: (context, index) {
        final image = images[index];

        return ReorderableDragStartListener(
          key: ValueKey(image.imageId),
          index: index,

          child: _ImageRow(
            key: ValueKey(image.imageId),
            image: image,
            imageUrlResolver: imageUrlResolver,
            disabled: disabled,
            onDelete: onDelete,
            onSetPrimary: onSetPrimary,
          ),
        );
      },
    );
  }
}

class _ImageRow extends StatelessWidget {
  const _ImageRow({
    required super.key,
    required this.image,
    required this.imageUrlResolver,
    required this.disabled,
    required this.onDelete,
    required this.onSetPrimary,
  });

  final AdminProductMediaImageEntity image;
  final ImageUrlResolver imageUrlResolver;
  final bool disabled;
  final ValueChanged<int> onDelete;
  final ValueChanged<int?> onSetPrimary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: Theme.of(context).semanticColors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: [
              AdminProductImage(
                image: image.url,
                resolver: imageUrlResolver,
                size: 72,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    Chip(label: Text('#${image.imageId}')),
                    if (image.isPrimary) const Chip(label: Text('أساسية')),
                  ],
                ),
              ),
              IconButton(
                onPressed: disabled
                    ? null
                    : () =>
                          onSetPrimary(image.isPrimary ? null : image.imageId),
                icon: Icon(
                  image.isPrimary
                      ? Icons.star
                      : Icons.star_border_purple500_outlined,
                  size: AppIconSizes.xlarge,
                ),
              ),
              IconButton(
                onPressed: disabled ? null : () => onDelete(image.imageId),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EffectiveImagesPanel extends StatelessWidget {
  const _EffectiveImagesPanel({
    required this.target,
    required this.imageUrlResolver,
  });

  final AdminProductMediaTargetEntity target;
  final ImageUrlResolver imageUrlResolver;

  @override
  Widget build(BuildContext context) {
    final effective = target.effectiveImages;
    final initiallyExpanded =
        !effective.inherited && effective.images.isNotEmpty;
    return ExpansionTile(
      initiallyExpanded: initiallyExpanded,
      tilePadding: EdgeInsets.all(AppSpacing.sm),
      childrenPadding: const EdgeInsets.only(bottom: AppSpacing.md),
      title: Text(
        'الصور الفعلية المعروضة',
        style: AppTextStyles.sectionTitle(context),
      ),
      subtitle: Text(
        effective.inherited
            ? 'موروثة من ${effective.source.label}'
            : 'المصدر: ${effective.source.label}',
        style: AppTextStyles.label(context),
      ),
      children: [
        if (effective.images.isEmpty)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              'لا توجد صور فعلية.',
              style: AppTextStyles.label(context),
            ),
          )
        else
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final image in effective.images)
                  AdminProductImage(
                    image: image.url,
                    resolver: imageUrlResolver,
                    size: 72,
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

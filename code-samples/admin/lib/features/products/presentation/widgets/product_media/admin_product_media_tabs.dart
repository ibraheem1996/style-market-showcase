import 'package:flutter/material.dart';

import '../../../../../core/responsive/app_spacing.dart';
import '../../../../../core/utils/image_url_resolver.dart';
import '../../../domain/entities/admin_product_enums.dart';
import '../../../domain/entities/admin_product_media_entities.dart';
import '../../cubit/product_media/admin_product_media_state.dart';
import 'admin_product_media_labels.dart';
import 'admin_product_media_target_card.dart';

class AdminProductMediaTabs extends StatelessWidget {
  const AdminProductMediaTabs({
    required this.imageUrlResolver,
    required this.state,
    required this.onUpload,
    required this.onDelete,
    required this.onReorder,
    required this.onSetPrimary,
    required this.onValidationError,
    super.key,
  });

  final ImageUrlResolver imageUrlResolver;
  final AdminProductMediaState state;
  final void Function(
    AdminProductMediaTargetEntity target,
    List<AdminProductMediaUploadFileEntity> files,
  )
  onUpload;
  final void Function(AdminProductMediaTargetEntity target, int imageId)
  onDelete;
  final void Function(AdminProductMediaTargetEntity target, List<int> imageIds)
  onReorder;
  final void Function(AdminProductMediaTargetEntity target, int? imageId)
  onSetPrimary;
  final ValueChanged<String> onValidationError;

  @override
  Widget build(BuildContext context) {
    final groups = _visibleGroups(state.media!.targets);
    return DefaultTabController(
      length: groups.length,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TabBar(
            isScrollable: true,
            tabs: [for (final group in groups) Tab(text: group.scope.tabLabel)],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 720,
            child: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              children: [
                for (final group in groups)
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        for (final target in group.targets) ...[
                          AdminProductMediaTargetCard(
                            target: target,
                            limits: state.media!.limits,
                            imageUrlResolver: imageUrlResolver,
                            operation: state.operationFor(target.targetKey),
                            pageHasActiveMutation: state.hasActiveMutation,
                            onUpload: (files) => onUpload(target, files),
                            onDelete: (imageId) => onDelete(target, imageId),
                            onReorder: (imageIds) =>
                                onReorder(target, imageIds),
                            onSetPrimary: (imageId) =>
                                onSetPrimary(target, imageId),
                            onValidationError: onValidationError,
                          ),
                          const SizedBox(height: AppSpacing.xxxl),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<_MediaTargetGroup> _visibleGroups(
    List<AdminProductMediaTargetEntity> targets,
  ) {
    return [
      for (final scope in AdminProductMediaScope.values)
        if (targets.any((target) => target.scope == scope))
          _MediaTargetGroup(
            scope: scope,
            targets: targets
                .where((target) => target.scope == scope)
                .toList(growable: false),
          ),
    ];
  }
}

class _MediaTargetGroup {
  const _MediaTargetGroup({required this.scope, required this.targets});

  final AdminProductMediaScope scope;
  final List<AdminProductMediaTargetEntity> targets;
}

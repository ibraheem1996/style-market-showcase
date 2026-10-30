import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/injection.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/responsive/app_spacing.dart';
import '../../../../core/utils/image_url_resolver.dart';
import '../../../../shared/presentation/widgets/app_error_view.dart';
import '../../../../shared/presentation/widgets/app_loading_view.dart';
import '../../../../shared/presentation/widgets/page_header.dart';
import '../cubit/product_media/admin_product_media_cubit.dart';
import '../cubit/product_media/admin_product_media_state.dart';
import '../widgets/product_media/admin_product_media_summary_bar.dart';
import '../widgets/product_media/admin_product_media_tabs.dart';

class AdminProductMediaReturnMarker {
  bool changed = false;
}

sealed class AdminProductMediaRouteResult {
  const AdminProductMediaRouteResult();
}

class AdminProductMediaChangedResult extends AdminProductMediaRouteResult {
  const AdminProductMediaChangedResult();
}

class AdminProductMediaPage extends StatelessWidget {
  const AdminProductMediaPage({
    required this.productId,
    this.returnMarker,
    super.key,
  });

  final int productId;
  final AdminProductMediaReturnMarker? returnMarker;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<AdminProductMediaCubit>();
        if (returnMarker != null) {
          cubit.attachChangedCallback(() => returnMarker!.changed = true);
        }
        return cubit..load(productId);
      },
      child: _AdminProductMediaView(
        productId: productId,
        returnMarker: returnMarker,
      ),
    );
  }
}

class _AdminProductMediaView extends StatelessWidget {
  const _AdminProductMediaView({
    required this.productId,
    required this.returnMarker,
  });

  final int productId;
  final AdminProductMediaReturnMarker? returnMarker;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminProductMediaCubit, AdminProductMediaState>(
      listenWhen: (previous, current) =>
          previous.effectId != current.effectId && current.effect != null,
      listener: (context, state) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.effect!.message)));
      },
      child: BlocBuilder<AdminProductMediaCubit, AdminProductMediaState>(
        builder: (context, state) {
          final cubit = context.read<AdminProductMediaCubit>();
          final media = state.media;

          if (state.isLoading && media == null) {
            return const AppLoadingView(message: 'جار تحميل صور المنتج...');
          }

          if (state.loadErrorMessage != null && media == null) {
            return AppErrorView(
              title: 'تعذر تحميل صور المنتج',
              message: state.loadErrorMessage!,
              onRetry: () => cubit.load(productId),
            );
          }

          if (media == null) {
            return const AppErrorView(message: 'تعذر تحميل صور المنتج.');
          }

          final imageUrlResolver = getIt<ImageUrlResolver>();
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PageHeader(
                  title: 'إدارة صور المنتج',
                  subtitle:
                      '${media.product.arabicName} - منتج #${media.product.id}',
                  actions: [
                    OutlinedButton.icon(
                      onPressed: !cubit.canRefresh() ? null : cubit.refresh,
                      icon: const Icon(Icons.refresh),
                      label: const Text('تحديث'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _leave(context, state),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('العودة للتفاصيل'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                AdminProductMediaSummaryBar(media: media),
                if (state.isRefreshing) ...[
                  const SizedBox(height: AppSpacing.md),
                  const LinearProgressIndicator(),
                ],
                const SizedBox(height: AppSpacing.lg),
                AdminProductMediaTabs(
                  imageUrlResolver: imageUrlResolver,
                  state: state,
                  onUpload: (target, files) =>
                      cubit.upload(target: target, files: files),
                  onDelete: (target, imageId) =>
                      cubit.deleteImage(target: target, imageId: imageId),
                  onReorder: (target, imageIds) =>
                      cubit.reorder(target: target, imageIds: imageIds),
                  onSetPrimary: (target, imageId) =>
                      cubit.setPrimary(target: target, imageId: imageId),
                  onValidationError: (message) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(message)));
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _leave(BuildContext context, AdminProductMediaState state) {
    if (context.canPop()) {
      context.pop<AdminProductMediaRouteResult>(
        state.hasSuccessfulMutation
            ? const AdminProductMediaChangedResult()
            : null,
      );
      return;
    }
    context.go(AppRoutes.productDetailPath(productId));
  }
}

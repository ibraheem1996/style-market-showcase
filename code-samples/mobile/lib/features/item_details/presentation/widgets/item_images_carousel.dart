import 'package:flutter/material.dart';
import 'package:my_project/core/utils/responsive/app_design_tokens.dart';
import 'package:my_project/core/widgets/app_remote_image.dart';

import '../../../../core/media/image_url_normalizer.dart';
import '../../../../core/widgets/app_product_image_viewer.dart';

class ItemImagesCarousel extends StatelessWidget {
  const ItemImagesCarousel({
    super.key,
    required this.images,
    required this.controller,
    required this.onPageChanged,
    required this.imageFrameSize,
    required this.semanticLabel,
  });
  final List<String> images;
  final PageController controller;
  final void Function(int) onPageChanged;
  final Size imageFrameSize;
  final String semanticLabel;

  static const double _loadingIndicatorExtent = 24;

  @override
  Widget build(BuildContext context) {
    final normalizedImages = images.map(normalizeProductImageUrl).toList();
    final count = normalizedImages.isNotEmpty ? normalizedImages.length : 1;

    return PageView.builder(
      onPageChanged: onPageChanged,
      controller: controller,
      physics: const BouncingScrollPhysics(),
      itemCount: count,
      itemBuilder: (context, index) {
        final url = normalizedImages.isEmpty ? null : normalizedImages[index];

        return Align(
          alignment: Alignment.center,
          child: SizedBox.fromSize(
            size: imageFrameSize,
            child: AppProductImageViewer(
              displayImage: url,
              images: normalizedImages,

              child: ColoredBox(
                color: Theme.of(context).colorScheme.surface,
                child: url == null
                    ? Icon(
                        Icons.broken_image,
                        size: AppIconSizes.prominentMediaStatus(context),
                      )
                    : AppRemoteImage.productDetails(
                        source: url,
                        semanticLabel: semanticLabel,
                        placeholderBuilder: (_) => const Center(
                          child: SizedBox.square(
                            dimension: _loadingIndicatorExtent,
                            child: CircularProgressIndicator.adaptive(),
                          ),
                        ),
                        errorBuilder: (_) => Icon(
                          Icons.broken_image,
                          size: AppIconSizes.prominentMediaStatus(context),
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

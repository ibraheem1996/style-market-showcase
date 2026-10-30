import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../media/app_media_profile.dart';
import '../media/image_url_normalizer.dart';
import '../utils/responsive/app_design_tokens.dart';

typedef AppRemoteImageStateBuilder = Widget Function(BuildContext context);

/// Renders remote Backend artwork with semantic geometry-specific policies.
///
/// The surrounding Feature remains responsible for frames, Hero transitions,
/// overlays, gestures, navigation, and retry orchestration. The default cache
/// manager is intentionally retained; memory decode dimensions are not a disk
/// cache retention policy.
class AppRemoteImage extends StatelessWidget {
  const AppRemoteImage.productCard({
    super.key,
    required this.source,
    this.semanticLabel,
    this.placeholderBuilder,
    this.errorBuilder,
  }) : profile = AppMediaProfile.productCard;

  const AppRemoteImage.banner({
    super.key,
    required this.source,
    this.semanticLabel,
    this.placeholderBuilder,
    this.errorBuilder,
  }) : profile = AppMediaProfile.homeBanner;

  const AppRemoteImage.collection({
    super.key,
    required this.source,
    this.semanticLabel,
    this.placeholderBuilder,
    this.errorBuilder,
  }) : profile = AppMediaProfile.homeCollection;

  const AppRemoteImage.category({
    super.key,
    required this.source,
    this.semanticLabel,
    this.placeholderBuilder,
    this.errorBuilder,
  }) : profile = AppMediaProfile.homeCategory;

  const AppRemoteImage.categoryThumbnail({
    super.key,
    required this.source,
    this.semanticLabel,
    this.placeholderBuilder,
    this.errorBuilder,
  }) : profile = AppMediaProfile.categoryThumbnail;

  const AppRemoteImage.orderThumbnail({
    super.key,
    required this.source,
    this.semanticLabel,
    this.placeholderBuilder,
    this.errorBuilder,
  }) : profile = AppMediaProfile.orderThumbnail;

  const AppRemoteImage.productDetails({
    super.key,
    required this.source,
    this.semanticLabel,
    this.placeholderBuilder,
    this.errorBuilder,
  }) : profile = AppMediaProfile.productDetails;

  const AppRemoteImage.favoriteCard({
    super.key,
    required this.source,
    this.semanticLabel,
    this.placeholderBuilder,
    this.errorBuilder,
  }) : profile = AppMediaProfile.favoriteCard;

  final String source;
  final String? semanticLabel;
  final AppMediaProfile profile;
  final AppRemoteImageStateBuilder? placeholderBuilder;
  final AppRemoteImageStateBuilder? errorBuilder;

  @override
  Widget build(BuildContext context) {
    final image = LayoutBuilder(
      builder: (context, constraints) {
        final laidOutSize = constraints.biggest;
        final decodeSize = profile.resolveDecodeSize(
          laidOutSize: laidOutSize,
          context: context,
        );

        return CachedNetworkImage(
          fadeInDuration: Duration.zero,
          fadeOutDuration: Duration.zero,
          imageUrl: normalizeBackendImageUrl(source),
          fit: profile.fit,
          width: constraints.hasBoundedWidth ? constraints.maxWidth : null,
          height: constraints.hasBoundedHeight ? constraints.maxHeight : null,
          memCacheWidth: decodeSize?.width,
          memCacheHeight: decodeSize?.height,
          placeholder: (context, _) =>
              placeholderBuilder?.call(context) ??
              Center(
                child: profile == AppMediaProfile.productDetails
                    ? const SizedBox.square(
                        dimension:
                            AppControlSizes.defaultProgressIndicatorImageSize,
                        child: CircularProgressIndicator.adaptive(),
                      )
                    : CircularProgressIndicator.adaptive(),
              ),
          errorWidget: (context, _, _) =>
              errorBuilder?.call(context) ??
              Center(
                child: Icon(
                  Icons.error_outline,
                  size: AppIconSizes.mediaStatus(context),
                ),
              ),
        );
      },
    );

    final label = semanticLabel?.trim();
    if (label == null || label.isEmpty) {
      return ExcludeSemantics(child: image);
    }
    return Semantics(image: true, label: label, child: image);
  }
}

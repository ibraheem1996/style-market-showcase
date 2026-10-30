import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/media/app_media_profile.dart';
import '../../../../core/utils/responsive/app_window_class.dart';

class ItemDetailsImageLayout {
  const ItemDetailsImageLayout({
    required this.mediaViewportSize,
    required this.imageFrameSize,
    required this.alignment,
  });

  final Size mediaViewportSize;
  final Size imageFrameSize;
  final Alignment alignment;
}

/// Keeps the product frame large on phones without letting wider windows
/// produce an excessively tall details image.
///
/// Short windows may use a wider media viewport, while the centered product
/// frame retains the shared 3:4 Product Details ratio.
ItemDetailsImageLayout resolveItemDetailsImageLayout({
  required Size windowSize,
  required double availableWidth,
}) {
  assert(availableWidth.isFinite && availableWidth > 0);
  assert(windowSize.height.isFinite && windowSize.height > 0);

  const regularHeightFraction = 0.72;
  const shortHeightFraction = 0.60;
  const maximumRegularHeight = 640.0;
  const maximumShortHeight = 320.0;

  final shortWindow = isShortWindow(windowSize);

  final heightBudget = math.min(
    windowSize.height *
        (shortWindow ? shortHeightFraction : regularHeightFraction),
    shortWindow ? maximumShortHeight : maximumRegularHeight,
  );

  final imageWidth = math.min(
    availableWidth,
    heightBudget * AppMediaProfile.productDetails.aspectRatio,
  );

  final imageHeight = imageWidth / AppMediaProfile.productDetails.aspectRatio;

  return ItemDetailsImageLayout(
    mediaViewportSize: Size(
      shortWindow ? availableWidth : imageWidth,
      imageHeight,
    ),
    imageFrameSize: Size(imageWidth, imageHeight),

    alignment: Alignment.center,
  );
}

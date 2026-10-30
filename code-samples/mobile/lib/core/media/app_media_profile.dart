import 'package:flutter/material.dart';

import 'image_url_normalizer.dart';

/// Semantic rendering and memory policy for remote Backend artwork.
enum AppMediaProfile {
  productCard,
  homeBanner,
  homeCollection,
  homeCategory,
  categoryThumbnail,
  orderThumbnail,
  productDetails,
  favoriteCard;

  double get aspectRatio => switch (this) {
    productCard || productDetails || favoriteCard => 3 / 4,
    homeBanner => 2 / 1,
    homeCollection => 3 / 2,
    homeCategory || categoryThumbnail || orderThumbnail => 1,
  };

  BoxFit get fit => switch (this) {
    productCard ||
    homeBanner ||
    homeCollection ||
    homeCategory ||
    favoriteCard ||
    categoryThumbnail ||
    orderThumbnail => BoxFit.cover,
    productDetails => BoxFit.contain,
  };
  int get maximumDecodeWidth => switch (this) {
    productCard => 960,
    homeBanner => 1440,
    homeCollection => 1440,
    homeCategory => 512,
    categoryThumbnail => 256,
    orderThumbnail => 512,
    productDetails => 1440,
    favoriteCard => 768,
  };

  int get maximumDecodeHeight => switch (this) {
    productCard => 1280,
    homeBanner => 720,
    homeCollection => 960,
    homeCategory => 512,
    categoryThumbnail => 256,
    orderThumbnail => 512,
    productDetails => 1680,
    favoriteCard => 1024,
  };

  ImageCacheSize? resolveDecodeSize({
    required Size laidOutSize,
    required BuildContext context,
    double qualityFactor = 1,
  }) {
    if (!laidOutSize.width.isFinite ||
        !laidOutSize.height.isFinite ||
        laidOutSize.width <= 0 ||
        laidOutSize.height <= 0 ||
        !qualityFactor.isFinite ||
        qualityFactor <= 0) {
      return null;
    }

    return calculateImageCacheSize(
      maxWidth: maximumDecodeWidth,
      maxHeight: maximumDecodeHeight,
      qualityFactor: qualityFactor,
      width: laidOutSize.width,
      height: laidOutSize.height,
      context: context,
    );
  }
}

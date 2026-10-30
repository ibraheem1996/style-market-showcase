import 'package:flutter/material.dart';

import '../config/api_config.dart';

/// Resolves a remote backend image source into an idempotent absolute URL.
String normalizeBackendImageUrl(String value) {
  final raw = value.trim();
  final fallbackUrl = ApiConfig.placeholder;

  if (raw.isEmpty) return fallbackUrl;
  if (_isAbsoluteUrl(raw)) return raw;
  if (raw == ApiConfig.placeholder) return raw;

  final embeddedAbsolute = _firstAbsoluteUrlInside(raw);
  if (embeddedAbsolute != null) return embeddedAbsolute;

  final imagesBase = ApiConfig.images.replaceFirst(RegExp(r'/+$'), '');
  final normalizedPath = raw.replaceFirst(RegExp(r'^/+'), '');
  final imagesPath = Uri.tryParse(
    imagesBase,
  )?.path.replaceFirst(RegExp(r'^/+'), '');

  if (imagesPath != null && normalizedPath.startsWith('$imagesPath/')) {
    return '${ApiConfig.serverBaseUrl}/$normalizedPath';
  }

  return '$imagesBase/$normalizedPath';
}

/// Normalizes product media paths without assuming which caller did the first
/// pass. Some existing mappers already return full URLs while direct viewers
/// can still receive raw relative paths.
String normalizeProductImageUrl(String value) {
  return normalizeBackendImageUrl(value);
}

bool isUsableProductImageUrl(String value) {
  final raw = value.trim();
  return raw.isNotEmpty && raw != ApiConfig.placeholder;
}

bool _isAbsoluteUrl(String value) {
  final uri = Uri.tryParse(value);
  return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
}

String? _firstAbsoluteUrlInside(String value) {
  final httpIndex = value.indexOf('http://');
  final httpsIndex = value.indexOf('https://');

  final indexes = [
    if (httpIndex > 0) httpIndex,
    if (httpsIndex > 0) httpsIndex,
  ];

  if (indexes.isEmpty) return null;

  indexes.sort();
  return value.substring(indexes.first);
}

class ImageCacheSize {
  const ImageCacheSize({
    required this.width,
    required this.height,
  });

  final int width;
  final int height;
}

/// Calculates the image decode size in physical pixels from its laid-out
/// logical size.
ImageCacheSize calculateImageCacheSize({
  required double width,
  required double height,
  required BuildContext context,
  double qualityFactor = 1,
  int? maxWidth,
  int? maxHeight,
}) {
  final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);

  assert(
    width.isFinite &&
        height.isFinite &&
        width > 0 &&
        height > 0 &&
        devicePixelRatio.isFinite &&
        devicePixelRatio > 0 &&
        qualityFactor.isFinite &&
        qualityFactor > 0 &&
        (maxWidth == null || maxWidth > 0) &&
        (maxHeight == null || maxHeight > 0),
  );

  var decodeWidth = (width * devicePixelRatio * qualityFactor).round();
  var decodeHeight = (height * devicePixelRatio * qualityFactor).round();

  if (maxWidth != null) {
    decodeWidth = decodeWidth.clamp(1, maxWidth);
  }

  if (maxHeight != null) {
    decodeHeight = decodeHeight.clamp(1, maxHeight);
  }

  return ImageCacheSize(
    width: decodeWidth,
    height: decodeHeight,
  );
}
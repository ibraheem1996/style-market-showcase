import 'package:injectable/injectable.dart';

import '../config/api_config.dart';

@lazySingleton
class ImageUrlResolver {
  const ImageUrlResolver();

  /// Accepts backend filenames and already-normalized URLs.
  String? resolve(String? value) {
    final imageValue = value?.trim();
    if (imageValue == null || imageValue.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(imageValue);
    if (uri != null && uri.hasScheme && uri.host.isNotEmpty) {
      return imageValue;
    }

    // Category responses include the static mount, unlike legacy filenames.
    if (imageValue.startsWith('/images/')) {
      return '${ApiConfig.serverBaseUrl}$imageValue';
    }

    final filename = imageValue.startsWith('/')
        ? imageValue.substring(1)
        : imageValue;
    return '${ApiConfig.imagesBaseUrl}/$filename';
  }
}

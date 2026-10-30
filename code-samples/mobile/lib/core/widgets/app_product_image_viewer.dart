import 'package:flutter/material.dart';

import '../navigation/full_image_route_args.dart';

/// Opens product media while leaving the surrounding card tap behavior intact.
class AppProductImageViewer extends StatelessWidget {
  const AppProductImageViewer({
    super.key,
    this.displayImage,
    required this.images,
    required this.child,
  });

  final String? displayImage;
  final List<String> images;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final gallery = FullImageNavigation.productGallery(
      displayImage: displayImage,
      images: images,
    );

    if (gallery.images.isEmpty) return child;

    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FullImageNavigation.openImageViewer(
          images: gallery.images,
          initialIndex: gallery.initialIndex,
        ),
        child: child,
      ),
    );
  }
}

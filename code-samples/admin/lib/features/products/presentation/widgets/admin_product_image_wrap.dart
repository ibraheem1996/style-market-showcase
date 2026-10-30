import 'package:flutter/material.dart';

import '../../../../core/responsive/app_radius.dart';
import '../../../../core/responsive/app_spacing.dart';
import '../../../../core/utils/image_url_resolver.dart';
import '../../../../shared/design_system/app_palette.dart';
import 'admin_product_image.dart';

class AdminProductImageWrap extends StatelessWidget {
  const AdminProductImageWrap({
    required this.images,
    required this.imageUrlResolver,
    this.imageSize = 88,
    super.key,
  });

  final List<String> images;
  final ImageUrlResolver imageUrlResolver;
  final double imageSize;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final image in images)
          AdminProductImage(
            image: image,
            resolver: imageUrlResolver,
            size: imageSize,
          ),
      ],
    );
  }
}

class AdminProductColorSwatch extends StatelessWidget {
  const AdminProductColorSwatch({required this.hex, super.key});

  final String? hex;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _parseHex(hex),
        borderRadius: BorderRadius.circular(AppRadius.xs),
        border: Border.all(color: Theme.of(context).semanticColors.border),
      ),
      child: const SizedBox(width: 18, height: 18),
    );
  }

  Color _parseHex(String? value) {
    if (value == null) {
      return Colors.transparent;
    }
    final normalized = value.replaceFirst('#', '');
    final parsed = int.tryParse(normalized, radix: 16);
    if (parsed == null || normalized.length != 6) {
      return Colors.transparent;
    }
    return Color(0xFF000000 | parsed);
  }
}

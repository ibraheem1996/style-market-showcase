import 'package:flutter/material.dart';

import '../../../../core/responsive/app_radius.dart';
import '../../../../core/responsive/app_spacing.dart';
import '../../../../core/utils/image_url_resolver.dart';
import '../../../../shared/design_system/app_palette.dart';

class AdminProductImage extends StatelessWidget {
  const AdminProductImage({
    required this.image,
    required this.resolver,
    this.size = 56,
    super.key,
  });

  final String? image;
  final ImageUrlResolver resolver;
  final double size;

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).semanticColors;
    final resolved = resolver.resolve(image);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          border: Border.all(color: semanticColors.border),
        ),
        child: SizedBox.square(
          dimension: size,
          child: resolved == null
              ? const Icon(Icons.image_not_supported_outlined)
              : Image.network(
                  resolved,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Padding(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    child: Icon(Icons.broken_image_outlined),
                  ),
                ),
        ),
      ),
    );
  }
}

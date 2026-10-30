import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/features/item_details/presentation/logic/item_details_image_layout.dart';

void main() {
  test('keeps product media within the intended 3:4 layout bounds', () {
    final compact = resolveItemDetailsImageLayout(
      windowSize: const Size(360, 690),
      availableWidth: 336,
    );
    final tall = resolveItemDetailsImageLayout(
      windowSize: const Size(1200, 1400),
      availableWidth: 760,
    );

    expect(compact.imageFrameSize.width, 336);
    expect(compact.imageFrameSize.aspectRatio, closeTo(3 / 4, 0.0001));
    expect(tall.imageFrameSize.height, 640);
  });
}

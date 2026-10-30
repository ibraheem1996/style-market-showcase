import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_project/core/widgets/app_expandable_text.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../core/translations/locale_keys.dart';
import '../../../../core/utils/responsive/app_design_tokens.dart';
import '../logic/item_details_selector.dart';
import 'section_title_underline.dart';

class ProductDescription extends StatelessWidget {
  final ItemDetailsDescriptionSection section;

  const ProductDescription({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    final text = section.text;
    if (text.trim().isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _titleKey.tr,
          style: context.appTypography.productDetails.sectionTitle,
        ),
        SizedBox(height: AppSpacing.xs),
        const SectionTitleUnderline(),
        SizedBox(height: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: AppExpandableText(
            text,
            collapsedMaxLines: 2,
            expandedMaxLines: null,
            style: context.appTypography.productDetails.description,
            expandText: LocaleKeys.showMore.tr,
            collapseText: LocaleKeys.showLess.tr,
            linkStyle: context.appTypography.textAction.inlineLink,
          ),
        ),
      ],
    );
  }

  String get _titleKey {
    return switch (section.type) {
      ItemDetailsDescriptionType.product =>
        LocaleKeys.itemDetailsProductDescription,
      ItemDetailsDescriptionType.selectedVariant =>
        LocaleKeys.itemDetailsSelectedVariantDetails,
    };
  }
}

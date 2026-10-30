import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_project/core/utils/responsive/app_responsive_value.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../core/translations/locale_keys.dart';
import '../../../../core/utils/responsive/app_design_tokens.dart';
import '../../../../core/utils/responsive/app_radius.dart';
import '../../../../core/widgets/helper.dart';
import '../../../products/domain/entities/item_entity.dart';
import '../../../products/domain/entities/item_entity_extensions.dart';
import '../logic/item_details_selector.dart';
import 'section_title_underline.dart';

class ColorSelector extends StatelessWidget {
  const ColorSelector({
    super.key,
    required this.variants,
    required this.selectedColorLabel,
    required this.selectedColorCode,
    required this.colorDescription,
    required this.selectColor,
  });
  final List<VariantEntity> variants;
  final String selectedColorLabel;
  final String selectedColorCode;
  final String? colorDescription;

  final void Function(String) selectColor;

  static const double _selectionBorderWidth = 2;
  @override
  Widget build(BuildContext context) {
    final isLargText = context.isLargeText;
    final isExpanded = context.isExpanded;
    final theme = Theme.of(context);
    //unique colors
    final colors = uniqueColors(variants);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.lg,
          runSpacing: AppSpacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              LocaleKeys.itemDetailsChooseColor.tr,
              style: context.appTypography.productDetails.sectionTitle,
            ),
            if (selectedColorLabel.isNotEmpty)
              Text(
                selectedColorLabel,
                style: context.appTypography.productDetails.optionValue,
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        const SectionTitleUnderline(),
        const SizedBox(height: AppSpacing.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...colors.map((v) {
                final code = v.colorHex;

                final isSelected = selectedColorCode == code;
                final isOutOfStock = !isColorAvailable(variants, code);

                return Semantics(
                  button: true,
                  selected: isSelected,
                  label: v.displayColor,
                  child: InkWell(
                    onTap: () => selectColor(code),
                    borderRadius: BorderRadius.circular(AppRadius.sm(context)),
                    child: Row(
                      children: [
                        AnimatedOpacity(
                          opacity: isOutOfStock && !isSelected ? 0.45 : 1,
                          duration: const Duration(milliseconds: 200),
                          child: AnimatedContainer(
                            height: isLargText || isExpanded
                                ? AppControlSizes.minimumTapTarget
                                : AppControlSizes.medium,
                            width: isLargText || isExpanded
                                ? AppControlSizes.minimumTapTarget
                                : AppControlSizes.medium,
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: parseProductColor(code),
                              borderRadius: BorderRadius.all(
                                Radius.circular(AppRadius.sm(context)),
                              ),
                              border: Border.all(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : isOutOfStock
                                    ? theme.colorScheme.error
                                    : theme.colorScheme.outline.withValues(
                                        alpha: 0.35,
                                      ),
                                width: isSelected ? _selectionBorderWidth : 1,
                              ),
                            ),
                            child: isSelected
                                ? Center(
                                    child: Icon(
                                      Icons.check,
                                      color:
                                          parseProductColor(
                                                code,
                                              ).computeLuminance() <
                                              0.5
                                          ? Colors.white
                                          : Colors.black,
                                      size:
                                          AppIconSizes.swatchSelectionIndicator(
                                            context,
                                          ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ),
                        if (v != colors.last) SizedBox(width: AppSpacing.sm),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        if (colorDescription != null && colorDescription!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Text(
              colorDescription!,
              style: context.appTypography.productDetails.description,
            ),
          ),
        ],
      ],
    );
  }
}

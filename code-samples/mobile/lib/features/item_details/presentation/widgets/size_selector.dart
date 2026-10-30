import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../core/translations/locale_keys.dart';
import '../../../../core/utils/responsive/app_design_tokens.dart';
import '../../../../core/utils/responsive/app_radius.dart';
import '../../../../core/utils/responsive/app_responsive_value.dart';
import '../../../../core/utils/responsive/app_text_scale_limits.dart';
import '../../../products/domain/entities/item_entity.dart';
import '../../../products/domain/entities/item_entity_extensions.dart';
import '../logic/item_details_selector.dart';
import 'section_title_underline.dart';

class SizeSelector extends StatelessWidget {
  const SizeSelector({
    super.key,
    required this.variants,
    required this.selectedColorCode,
    required this.selectSize,
    required this.selectedSize,
  });
  final List<VariantEntity> variants;
  final String selectedColorCode;
  final String selectedSize;
  final void Function(String) selectSize;

  static const double _selectionBorderWidth = 2;
  @override
  Widget build(BuildContext context) {
    bool isExpanded = context.isExpanded;
    bool isLargeText = context.isLargeText;
    final isLarger = isExpanded || isLargeText;
    final theme = Theme.of(context);
    final sizes = sizesForColor(variants, selectedColorCode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.itemDetailsChooseSize.tr,
          style: context.appTypography.productDetails.sectionTitle,
        ),
        const SizedBox(height: AppSpacing.xs),
        const SectionTitleUnderline(),
        const SizedBox(height: AppSpacing.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: sizes.map((v) {
              final label = (v.displaySize).trim();
              final isSelected =
                  selectedSize.trim().toLowerCase() == label.toLowerCase();
              final isOutOfStock = v.variantStock <= 0;

              return Row(
                children: [
                  Semantics(
                    button: true,
                    selected: isSelected,
                    label: label,
                    child: InkWell(
                      onTap: () => selectSize(label),
                      borderRadius: BorderRadius.circular(
                        AppRadius.sm(context),
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: isLarger
                              ? AppControlSizes.minimumTapTarget
                              : AppControlSizes.medium,
                          minWidth: isLarger
                              ? AppControlSizes.minimumTapTarget
                              : AppControlSizes.medium,
                        ),
                        child: AnimatedOpacity(
                          opacity: isOutOfStock && !isSelected ? 0.45 : 1,
                          duration: const Duration(milliseconds: 200),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primary.withValues(
                                      alpha: 0.12,
                                    )
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : isOutOfStock
                                    ? theme.colorScheme.error.withValues(
                                        alpha: 0.5,
                                      )
                                    : theme.colorScheme.outline.withValues(
                                        alpha: 0.35,
                                      ),
                                width: isSelected ? _selectionBorderWidth : 1,
                              ),
                              borderRadius: BorderRadius.circular(
                                AppRadius.sm(context),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 0,
                                vertical: 0,
                              ),
                              child: Text(
                                label,
                                textScaler: MediaQuery.textScalerOf(context)
                                    .clamp(
                                      maxScaleFactor: AppTextScaleLimits
                                          .itemDetailsSizeSelector,
                                    ),
                                style: context
                                    .appTypography
                                    .productDetails
                                    .optionValue
                                    .copyWith(
                                      color: isSelected
                                          ? theme.colorScheme.primary
                                          : null,
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (v != sizes.last) SizedBox(width: AppSpacing.md),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/translations/locale_keys.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/responsive/app_design_tokens.dart';
import '../../../../core/utils/responsive/app_radius.dart';
import '../../../../core/utils/responsive/app_text_scale_limits.dart';

class ProductSearchField extends StatelessWidget {
  const ProductSearchField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmitted;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: AppTextScaleLimits.appFormTextField,
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) {
          return TextField(
            style: context.appTypography.formField.enteredText,
            controller: controller,
            focusNode: focusNode,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onChanged: onChanged,
            onSubmitted: (_) => onSubmitted(),
            decoration: InputDecoration(
              hintText: LocaleKeys.productSearchHint.tr,
              hintStyle: context.appTypography.formField.hint,
              prefixIcon: Icon(
                Icons.search_rounded,
                size: AppIconSizes.fieldIcon(context),
              ),
              suffixIcon: value.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: LocaleKeys.productSearchClear.tr,
                      onPressed: onClear,
                      icon: Icon(
                        Icons.close_rounded,
                        size: AppIconSizes.fieldIcon(context),
                      ),
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg(context)),
              ),
            ),
          );
        },
      ),
    );
  }
}

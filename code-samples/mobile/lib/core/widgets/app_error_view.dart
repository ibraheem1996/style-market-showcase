import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_project/core/theme/app_typography.dart';
import 'package:my_project/core/utils/responsive/app_design_tokens.dart';
import 'package:my_project/core/widgets/responsive_content.dart';

import '../../constants/image_patch.dart';
import 'failure_ui_model.dart';

class AppErrorView extends StatelessWidget {
  const AppErrorView({super.key, required this.model});

  final FailureUIModel model;

  static const double _imageExtent = 125;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typography = context.appTypography;

    return SafeArea(
      child: ResponsiveContent.form(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                model.imagePath ?? ImagePatch.error,
                height: _imageExtent,
                width: _imageExtent,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                model.messageKey.tr,
                textAlign: TextAlign.center,
                style: typography.stateMessage.title,
              ),
              const SizedBox(height: AppSpacing.md),
              if (model.descriptionKey != null)
                Text(
                  model.descriptionKey!.tr,
                  textAlign: TextAlign.center,
                  style: typography.stateMessage.message,
                ),
              const SizedBox(height: AppSpacing.lg),
              if (model.onButtonPressed != null)
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.sm,
                  children: [
                    ElevatedButton(
                      onPressed: model.onButtonPressed,
                      child: Text(
                        model.buttonTextKey.tr,
                        style: typography.button.label,
                      ),
                    ),
                    if (model.secondButtonTextKey != null)
                      ElevatedButton(
                        onPressed: model.onSecondButtonPressed,
                        child: Text(
                          model.secondButtonTextKey!.tr,
                          style: typography.button.label,
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/utils/responsive/app_radius.dart';
import '../../../../core/utils/responsive/app_design_tokens.dart';

class BackToTopButton extends StatelessWidget {
  const BackToTopButton({
    super.key,
    required this.showListenable,
    required this.onPressed,
  });

  final ValueListenable<bool> showListenable;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ValueListenableBuilder<bool>(
      valueListenable: showListenable,
      builder: (context, show, _) {
        return AnimatedSlide(
          offset: show ? Offset.zero : const Offset(0, 0.35),
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          child: AnimatedOpacity(
            opacity: show ? 1 : 0,
            duration: const Duration(milliseconds: 220),
            child: IgnorePointer(
              ignoring: !show,
              child: Material(
                color: theme.colorScheme.primary,
                elevation: 4,
                borderRadius: BorderRadius.circular(
                  AppRadius.circular(context),
                ),
                child: InkWell(
                  onTap: onPressed,
                  borderRadius: BorderRadius.circular(
                    AppRadius.circular(context),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Icon(
                      Icons.keyboard_arrow_up,
                      color: theme.colorScheme.onPrimary,
                      size: AppIconSizes.standardAction(context),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

import '../../design_system/app_text_styles.dart';
import '../../../core/responsive/app_spacing.dart';

class AppLoadingView extends StatelessWidget {
  const AppLoadingView({this.message = 'جار التحميل...', super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,

      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator.adaptive(),
            const SizedBox(height: AppSpacing.md),
            Text(message, style: AppTextStyles.body(context)),
          ],
        ),
      ),
    );
  }
}

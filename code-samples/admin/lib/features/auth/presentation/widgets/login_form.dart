import 'package:flutter/material.dart';

import '../../../../shared/design_system/app_text_styles.dart';
import '../../../../core/responsive/app_layout_values.dart';
import '../../../../core/responsive/app_radius.dart';
import '../../../../core/responsive/app_responsive.dart';
import '../../../../core/responsive/app_spacing.dart';
import '../../../../core/responsive/app_widths.dart';
import '../cubit/login_state.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({
    required this.state,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onSubmit,
    super.key,
  });

  final LoginState state;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPasswordChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final screen = AppResponsive.of(context);
    final errorColor = Theme.of(context).colorScheme.error;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: AppWidths.loginFormMax),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.cardPadding(screen)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'تسجيل الدخول',
              style: AppTextStyles.title(context),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.section(screen)),
            TextField(
              enabled: !state.isSubmitting,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onChanged: onEmailChanged,
              decoration: InputDecoration(
                labelText: 'الاسم او البريد الالكتروني',
                errorText: state.emailError,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              enabled: !state.isSubmitting,
              obscureText: true,
              textInputAction: TextInputAction.done,
              onChanged: onPasswordChanged,
              onSubmitted: (_) {
                if (!state.isSubmitting) {
                  onSubmit();
                }
              },
              decoration: InputDecoration(
                labelText: 'كلمة المرور',
                errorText: state.passwordError,
              ),
            ),
            if (state.errorMessage != null) ...[
              const SizedBox(height: AppSpacing.lg),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: errorColor.withValues(alpha: 0.12),
                  border: Border.all(color: errorColor),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    state.errorMessage!,
                    style: AppTextStyles.body(
                      context,
                    ).copyWith(color: errorColor),
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              height: AppLayoutValues.buttonHeight(screen),
              child: ElevatedButton(
                onPressed: state.isSubmitting ? null : onSubmit,
                child: state.isSubmitting
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator.adaptive(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('تسجيل الدخول'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

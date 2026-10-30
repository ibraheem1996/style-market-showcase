import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:get/get.dart';

import '../../../../../core/errors/failure_i18n.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/translations/locale_keys.dart';
import '../../../../../core/utils/responsive/app_design_tokens.dart';
import '../../../../../core/utils/responsive/app_text_scale_limits.dart';
import '../../state/address_verification_state.dart';

class AddressPhoneVerificationView extends StatelessWidget {
  const AddressPhoneVerificationView({
    super.key,
    required this.state,
    required this.onCodeChanged,
    required this.onSubmitCode,
    required this.onConfirm,
    required this.onResend,
    required this.isBusy,
    required this.isTerminal,
    required this.onClose,
  });

  final AddressVerificationState state;
  final ValueChanged<String> onCodeChanged;
  final ValueChanged<String> onSubmitCode;
  final VoidCallback onConfirm;
  final VoidCallback onResend;
  final bool isBusy;
  final bool isTerminal;
  final VoidCallback onClose;

  static const double _progressStrokeWidth = 2;

  /// Builds error or informational feedback text based on the verification state.
  Widget? _buildFeedbackMessage(BuildContext context) {
    if (state.actionFailure != null) {
      return Text(
        state.actionFailure!.message,
        textAlign: TextAlign.center,
        style: context.appTypography.stateMessage.inlineMessage.copyWith(
          color: context.theme.colorScheme.error,
        ),
      );
    }
    if (state.messageKey != null) {
      return Text(
        state.messageKey!.tr,
        textAlign: TextAlign.center,
        style: context.appTypography.stateMessage.inlineMessage,
      );
    }
    return null;
  }

  /// Builds status-specific notice text (expired or rate-limited).
  Widget? _buildStatusText(BuildContext context) {
    if (state.actionFailure != null) return null;
    switch (state.status) {
      case AddressVerificationStatus.expired:
        return Text(
          LocaleKeys.phoneVerificationExpired.tr,
          textAlign: TextAlign.center,
          style: context.appTypography.stateMessage.message,
        );

      case AddressVerificationStatus.limited:
        return Text(
          LocaleKeys.phoneVerificationLimited.tr,
          textAlign: TextAlign.center,
          style: context.appTypography.stateMessage.message,
        );

      case AddressVerificationStatus.invalid:
        return Text(
          LocaleKeys.phoneVerificationInvalidSession.tr,
          textAlign: TextAlign.center,
          style: context.appTypography.stateMessage.message.copyWith(
            color: Theme.of(context).colorScheme.error,
          ),
        );

      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedbackMessage = _buildFeedbackMessage(context);
    final statusText = _buildStatusText(context);
    final resendTimerParts = LocaleKeys.phoneVerificationResendTimer.tr.split(
      '@seconds',
    );

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        if (statusText == null)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                LocaleKeys.phoneVerificationSubtitle.tr,
                textAlign: TextAlign.center,
                style: context.appTypography.page.description,
              ),
              const SizedBox(height: AppSpacing.xs),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  state.challenge?.maskedPhone ?? '',
                  textAlign: TextAlign.center,
                  style: context.appTypography.listItem.title.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                LocaleKeys.phoneVerificationContinueWithoutVerification.tr,
                textAlign: TextAlign.center,
                style: context.appTypography.stateMessage.inlineMessage,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                LocaleKeys.phoneVerificationSavingNotice.tr,
                textAlign: TextAlign.center,
                style: context.appTypography.stateMessage.inlineMessage,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),

        if (!isTerminal) ...[
          Directionality(
            textDirection: TextDirection.ltr,
            child: MediaQuery.withClampedTextScaling(
              maxScaleFactor: AppTextScaleLimits.appFormTextField,
              child: KeyedSubtree(
                key: ValueKey(state.otpInputVersion),
                child: OtpTextField(
                  numberOfFields: 6,
                  clearText: true,
                  autoFocus: true,
                  enabled: !isBusy,
                  showFieldAsBox: true,
                  contentPadding: EdgeInsets.zero,
                  onCodeChanged: onCodeChanged,
                  onSubmit: onSubmitCode,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        if (feedbackMessage != null) ...[
          feedbackMessage,
          const SizedBox(height: AppSpacing.sm),
        ],
        if (statusText != null) statusText,
        if (statusText != null && isTerminal) ...[
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            onPressed: onClose,
            child: Text(
              LocaleKeys.phoneVerificationClose.tr,
              style: context.appTypography.button.label,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        if (!isTerminal) ...[
          ElevatedButton(
            onPressed: isBusy ? null : onConfirm,
            child: state.status == AddressVerificationStatus.confirming
                ? const CircularProgressIndicator.adaptive(
                    strokeWidth: _progressStrokeWidth,
                  )
                : Text(
                    LocaleKeys.phoneVerificationVerifyButton.tr,
                    style: context.appTypography.button.label,
                  ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (state.resendSecondsLeft > 0)
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                Text(
                  resendTimerParts.first.trim(),
                  style: context.appTypography.stateMessage.inlineMessage,
                ),
                Text(
                  state.resendSecondsLeft.toString(),
                  style: context.appTypography.stateMessage.inlineMessage
                      .copyWith(color: Theme.of(context).colorScheme.primary),
                ),
                Text(
                  resendTimerParts.last.trim(),
                  style: context.appTypography.stateMessage.inlineMessage,
                ),
              ],
            )
          else
            TextButton(
              onPressed: isBusy ? null : onResend,
              child: state.status == AddressVerificationStatus.resending
                  ? const SizedBox.square(
                      dimension:
                          AppControlSizes.defaultProgressIndicatorImageSize,
                      child: CircularProgressIndicator.adaptive(
                        strokeWidth: _progressStrokeWidth,
                      ),
                    )
                  : Text(
                      LocaleKeys.resend.tr,
                      style: context.appTypography.textAction.link,
                    ),
            ),
        ],
      ],
    );
  }
}

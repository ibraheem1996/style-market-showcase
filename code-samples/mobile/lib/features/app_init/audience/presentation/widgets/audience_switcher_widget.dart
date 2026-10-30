import 'package:flutter/material.dart';

import '../../../../core/utils/responsive/app_design_tokens.dart';
import '../../../../core/utils/responsive/app_home_layout_tokens.dart';
import '../../../../core/utils/responsive/app_radius.dart';
import '../../../../core/utils/responsive/app_text_scale_limits.dart';
import '../../domain/entities/audience_entity.dart';
import '../../domain/entities/extension_audince_entity.dart';

class AudienceSwitcherWidget extends StatelessWidget {
  const AudienceSwitcherWidget({
    super.key,
    required this.onSelect,
    required this.audiences,
    required this.selected,
  });

  final void Function(AudienceEntity) onSelect;
  final List<AudienceEntity> audiences;
  final AudienceEntity? selected;

  @override
  Widget build(BuildContext context) {
    if (audiences.isEmpty || selected == null) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                for (final audience in audiences)
                  _AudienceTab(
                    audience: audience,
                    isSelected: selected!.audienceId == audience.audienceId,
                    onTap: () => onSelect(audience),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AudienceTab extends StatelessWidget {
  const _AudienceTab({
    required this.audience,
    required this.isSelected,
    required this.onTap,
  });

  final AudienceEntity audience;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      selected: isSelected,
      label: audience.displayName,
      child: MediaQuery.withClampedTextScaling(
        maxScaleFactor: AppTextScaleLimits.audienceSwitcher,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            key: ValueKey('home-audience-tab-${audience.audienceId}'),
            onTap: onTap,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: AppControlSizes.minimumTapTarget,
                minWidth: AppControlSizes.minimumTapTarget,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppHomeAudienceLayout.horizontalPadding,
                  vertical: AppHomeAudienceLayout.verticalPadding,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      audience.displayName,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: AppHomeAudienceLayout.textStyle(context).copyWith(
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppHomeAudienceLayout.indicatorGap),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      width: isSelected ? AppSpacing.xxl : 0,
                      height: AppHomeAudienceLayout.indicatorHeight(context),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(
                          AppRadius.sm(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/translations/locale_keys.dart';
import '../../../../../core/utils/responsive/app_design_tokens.dart';
import '../../../domain/entities/area_entity.dart';
import '../../../domain/entities/city_entity.dart';

import 'custom_drop_down.dart';
import 'street_one_field.dart';
import 'street_two_field.dart';
import 'phone_field.dart';
import 'save_address_button.dart';

class AddressForm extends StatelessWidget {
  const AddressForm({
    super.key,
    required this.formKey,

    required this.streetOneController,
    required this.streetTwoController,
    required this.phoneController,

    required this.onCityChanged,
    required this.onAreaChanged,
    required this.onSaveOrEditAddress,

    required this.selectedAreaId,
    required this.selectedCityId,

    required this.cities,
    required this.areas,

    required this.isEdit,
    required this.isLoadingCities,
    required this.isLoadingAreas,
    required this.isSaving,
    this.areaErrorMessage,
    this.onRetryAreas,
  });
  final GlobalKey<FormState> formKey;

  final TextEditingController streetOneController;
  final TextEditingController streetTwoController;
  final TextEditingController phoneController;

  final Future<void> Function(int?) onCityChanged;
  final void Function(int?) onAreaChanged;
  final VoidCallback onSaveOrEditAddress;

  final bool isLoadingAreas;
  final bool isEdit;
  final bool isLoadingCities;
  final bool isSaving;
  final String? areaErrorMessage;
  final VoidCallback? onRetryAreas;

  final List<CityEntity> cities;
  final List<AreaEntity> areas;
  final int? selectedCityId;
  final int? selectedAreaId;

  @override
  Widget build(BuildContext context) {
    final isArabic = Get.locale?.languageCode == 'ar';
    final mediaQuery = MediaQuery.of(context);
    final double menuMaxHeight = mediaQuery.size.height * 0.5;
    return Form(
      key: formKey,
      child: Column(
        children: [
          CustomDropdownButtonFormField<int>(
            menuMaxHeight: menuMaxHeight,
            hint: Text(
              isLoadingCities
                  ? LocaleKeys.addressesLoadingCities.tr
                  : LocaleKeys.addressesSelectCity.tr,
              style: context.appTypography.formField.hint,
            ),
            value: cities
                .firstWhereOrNull((city) => city.cityId == selectedCityId)
                ?.cityId,
            validator: (value) =>
                value == null ? LocaleKeys.addressesSelectCity.tr : null,
            items: cities
                .map(
                  (city) => DropdownMenuItem<int>(
                    value: city.cityId,
                    child: Text(
                      city.displayName(isArabic: isArabic),
                      style: context.appTypography.formField.enteredText,
                    ),
                  ),
                )
                .toList(),
            onChanged: isLoadingCities ? null : (value) => onCityChanged(value),
          ),

          const SizedBox(height: AppSpacing.md),

          CustomDropdownButtonFormField<int>(
            menuMaxHeight: menuMaxHeight,
            hint: Text(
              isLoadingAreas
                  ? LocaleKeys.addressesLoadingAreas.tr
                  : LocaleKeys.addressesSelectArea.tr,
              style: context.appTypography.formField.hint,
            ),
            value: areas
                .firstWhereOrNull((area) => area.areaId == selectedAreaId)
                ?.areaId,
            validator: (value) =>
                value == null ? LocaleKeys.addressesSelectArea.tr : null,
            items: areas
                .map(
                  (area) => DropdownMenuItem<int>(
                    value: area.areaId,
                    child: Text(
                      area.displayName(isArabic: isArabic),
                      style: context.appTypography.formField.enteredText,
                    ),
                  ),
                )
                .toList(),
            onChanged: isLoadingAreas ? null : onAreaChanged,
          ),
          if (areaErrorMessage != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                areaErrorMessage!,
                style: context.appTypography.stateMessage.inlineMessage
                    .copyWith(color: Theme.of(context).colorScheme.error),
              ),
            ),
            if (onRetryAreas != null)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  onPressed: onRetryAreas,
                  label: Text(
                    LocaleKeys.retry.tr,
                    style: context.appTypography.textAction.link,
                  ),
                  icon: Icon(
                    Icons.refresh,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
          ],
          const SizedBox(height: AppSpacing.md),

          StreetOneField(controller: streetOneController),
          const SizedBox(height: AppSpacing.sm),

          StreetTwoField(controller: streetTwoController),
          const SizedBox(height: AppSpacing.sm),

          PhoneField(controller: phoneController),
          const SizedBox(height: AppSpacing.sm),

          SaveAddressButton(
            isSaving: isSaving,
            isEdit: isEdit,
            onPressed: onSaveOrEditAddress,
          ),
        ],
      ),
    );
  }
}

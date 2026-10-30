import 'package:freezed_annotation/freezed_annotation.dart';
part 'filter_options_entity.freezed.dart';

// FilterOptionsEntity holds the available filter choices returned by the API.
// ColorOption, SizeOption, and PriceRange are defined here as the single source
// of truth — they represent filter value objects used across both filter options
// and listing item data.

@freezed
abstract class FilterOptionsEntity with _$FilterOptionsEntity {
  const factory FilterOptionsEntity({
    required List<ColorOption> colors,
    required List<SizeOption> sizes,
    required PriceRange priceRange,
  }) = _FilterOptionsEntity;
}

@freezed
abstract class ColorOption with _$ColorOption {
  const factory ColorOption({
    required int valueId,
    required String hex,
    required String nameAr,
    required String nameEn,
  }) = _ColorOption;
}

@freezed
abstract class SizeOption with _$SizeOption {
  const factory SizeOption({
    required int sizeValueId,
    required String nameAr,
    required String nameEn,
  }) = _SizeOption;
}

@freezed
abstract class PriceRange with _$PriceRange {
  const factory PriceRange({required double min, required double max}) =
      _PriceRange;
}

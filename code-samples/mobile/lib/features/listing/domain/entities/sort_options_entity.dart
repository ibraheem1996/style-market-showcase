import 'package:freezed_annotation/freezed_annotation.dart';
part 'sort_options_entity.freezed.dart';

// SortOptionsEntity holds the available sort choices returned by the API.
// It is separate from FilterOptionsEntity because sort selection and filter
// selection are independent user actions with different UI flows.

@freezed
abstract class SortOptionsEntity with _$SortOptionsEntity {
  const factory SortOptionsEntity({
    required List<String> availableSorts,
    required String defaultSort,
  }) = _SortOptionsEntity;
}

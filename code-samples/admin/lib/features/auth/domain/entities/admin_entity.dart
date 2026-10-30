import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_entity.freezed.dart';

@freezed
abstract class AdminEntity with _$AdminEntity {
  const factory AdminEntity({
    required int id,
    required String name,
    required String email,
    required String? phone,
    required bool isApproved,
    required String userType,
  }) = _AdminEntity;
}

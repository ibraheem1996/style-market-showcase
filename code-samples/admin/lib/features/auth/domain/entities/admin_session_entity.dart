import 'package:freezed_annotation/freezed_annotation.dart';

import 'admin_entity.dart';
import 'auth_tokens_entity.dart';

part 'admin_session_entity.freezed.dart';

@freezed
abstract class AdminSessionEntity with _$AdminSessionEntity {
  const factory AdminSessionEntity({
    required AdminEntity admin,
    required AuthTokensEntity tokens,
  }) = _AdminSessionEntity;
}

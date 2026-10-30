import '../../../../core/errors/mapping_exception.dart';
import '../../domain/entities/audience_entity.dart';
import '../models/audience_model.dart';

extension AudienceMapper on AudienceModel {
  AudienceEntity toEntity() {
    String fallbackName(String? primary, String? fallback) {
      if (primary != null && primary.trim().isNotEmpty) {
        return primary;
      }

      if (fallback != null && fallback.trim().isNotEmpty) {
        return fallback;
      }

      throw MappingException("Audience name is null");
    }

    return AudienceEntity(
      audienceId: audienceId,
      nameAr: fallbackName(nameAr, nameEn),
      nameEn: fallbackName(nameEn, nameAr),
      sortOrder: sortOrder,
    );
  }
}

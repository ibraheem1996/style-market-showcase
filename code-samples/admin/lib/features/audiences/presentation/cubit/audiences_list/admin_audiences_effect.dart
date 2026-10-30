import '../../../domain/entities/admin_audience_entities.dart';

sealed class AdminAudiencesEffect {
  const AdminAudiencesEffect();
}

class AdminAudiencesMessageEffect extends AdminAudiencesEffect {
  const AdminAudiencesMessageEffect(this.message);

  final String message;
}

class AdminAudiencesDeletionImpactEffect extends AdminAudiencesEffect {
  const AdminAudiencesDeletionImpactEffect(this.impact);

  final AdminAudienceDeletionImpact impact;
}

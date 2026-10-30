enum AdminAudienceSavedAction { created, updated }

sealed class AdminAudienceFormEffect {
  const AdminAudienceFormEffect();
}

class AdminAudienceFormSuccessEffect extends AdminAudienceFormEffect {
  const AdminAudienceFormSuccessEffect(this.action);

  final AdminAudienceSavedAction action;
}

class AdminAudienceFormFailureEffect extends AdminAudienceFormEffect {
  const AdminAudienceFormFailureEffect(this.message);

  final String message;
}

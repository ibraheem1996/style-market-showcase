enum ApiStatus { success, error }

enum ActionType { none, created, alreadyExists }

extension ApiStatusX on ApiStatus {
  bool get isSuccess => this == ApiStatus.success;
}

extension ActionTypeX on ActionType {
  bool get isCreated => this == ActionType.created;
  bool get isAlreadyExists => this == ActionType.alreadyExists;
  bool get isOk => isCreated || isAlreadyExists;
}

ApiStatus parseApiStatus(dynamic value) {
  final v = (value ?? "").toString().toLowerCase();
  switch (v) {
    case "success":
    case "ok":
    case "true":
      return ApiStatus.success;
    case "error":
      return ApiStatus.error;
    default:
      return ApiStatus.error;
  }
}

ActionType parseActionType(dynamic value) {
  final v = (value ?? "").toString().toLowerCase();
  switch (v) {
    case "created":
      return ActionType.created;
    case "already_exists":
    case "alreadyexists":
      return ActionType.alreadyExists;
    default:
      return ActionType.none;
  }
}

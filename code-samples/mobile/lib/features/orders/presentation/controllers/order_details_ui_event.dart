import '../../../../core/errors/failure.dart';

sealed class OrderDetailsUiEvent {
  const OrderDetailsUiEvent();
}

class OrderDetailsMessageEvent extends OrderDetailsUiEvent {
  const OrderDetailsMessageEvent(this.messageKey);

  final String messageKey;
}

class OrderDetailsActionFailedEvent extends OrderDetailsUiEvent {
  const OrderDetailsActionFailedEvent(this.failure);

  final Failure failure;
}

class OrderDetailsActionUnavailableEvent extends OrderDetailsUiEvent {
  const OrderDetailsActionUnavailableEvent(this.failure);

  final Failure failure;
}

class OrderDetailsCancelSucceededEvent extends OrderDetailsUiEvent {
  const OrderDetailsCancelSucceededEvent();
}

class OrderDetailsNoteSucceededEvent extends OrderDetailsUiEvent {
  const OrderDetailsNoteSucceededEvent();
}

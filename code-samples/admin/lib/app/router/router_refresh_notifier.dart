import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../features/auth/presentation/cubit/admin_session_cubit.dart';
import '../../features/auth/presentation/cubit/admin_session_state.dart';

@lazySingleton
class RouterRefreshNotifier extends ChangeNotifier {
  RouterRefreshNotifier(AdminSessionCubit sessionCubit) {
    _subscription = sessionCubit.stream.listen((state) {
      notifyListeners();
    });
  }

  late final StreamSubscription<AdminSessionState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

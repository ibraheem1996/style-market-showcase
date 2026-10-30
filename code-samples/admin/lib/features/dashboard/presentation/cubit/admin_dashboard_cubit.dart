import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/result/app_result.dart';
import '../../domain/entities/admin_dashboard_entities.dart';
import '../../domain/usecases/get_admin_dashboard_overview_use_case.dart';
import 'admin_dashboard_state.dart';

@injectable
class AdminDashboardCubit extends Cubit<AdminDashboardState> {
  AdminDashboardCubit(this._getOverview) : super(const AdminDashboardState());

  final GetAdminDashboardOverviewUseCase _getOverview;
  int _requestSequence = 0;
  AdminDashboardFilter? _inFlightFilter;

  Future<void> loadInitial() {
    return _load(AdminDashboardFilter.today());
  }

  Future<void> selectPreset(AdminDashboardPreset preset) {
    return _load(AdminDashboardFilter.preset(preset));
  }

  Future<void> selectCustomRange({
    required DateTime dateFrom,
    required DateTime dateTo,
  }) {
    return _load(
      AdminDashboardFilter.customValidated(dateFrom: dateFrom, dateTo: dateTo),
    );
  }

  Future<void> retry() {
    return _load(state.filter, force: true);
  }

  Future<void> _load(AdminDashboardFilter filter, {bool force = false}) async {
    if (_inFlightFilter == filter) {
      return;
    }
    if (!force &&
        !state.isLoading &&
        state.overview != null &&
        state.filter == filter) {
      return;
    }

    final sequence = ++_requestSequence;
    _inFlightFilter = filter;
    emit(
      state.copyWith(
        filter: filter,
        overview: null,
        isLoading: true,
        errorMessage: null,
      ),
    );

    final result = await _getOverview(filter);
    if (isClosed || sequence != _requestSequence) {
      return;
    }
    if (_inFlightFilter == filter) {
      _inFlightFilter = null;
    }

    switch (result) {
      case AppResultSuccess(:final data):
        emit(
          state.copyWith(overview: data, isLoading: false, errorMessage: null),
        );
      case AppResultFailure(:final failure):
        emit(state.copyWith(isLoading: false, errorMessage: failure.message));
    }
  }
}

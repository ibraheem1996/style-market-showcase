import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/admin_dashboard_entities.dart';

part 'admin_dashboard_state.freezed.dart';

@freezed
abstract class AdminDashboardState with _$AdminDashboardState {
  const factory AdminDashboardState({
    @Default(AdminDashboardFilter.preset(AdminDashboardPreset.today))
    AdminDashboardFilter filter,
    AdminDashboardOverview? overview,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _AdminDashboardState;
}

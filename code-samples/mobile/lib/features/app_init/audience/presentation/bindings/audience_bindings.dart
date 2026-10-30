import 'package:dio/dio.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/crashlytics_service.dart';
import '../../../../core/services/performance_service.dart';
import '../../../../core/storage/prefs_storage.dart';
import '../../data/datasources/local/audience_local_datasource.dart';
import '../../data/datasources/local/audience_local_datasource_impl.dart';
import '../../data/datasources/remote/audience_remote_datasource.dart';
import '../../data/repositories/audience_repository_impl.dart';
import '../../domain/repositories/audience_repository.dart';
import '../../domain/usecases/get_audiences_usecase.dart';
import '../../domain/usecases/get_selected_audience_usecase.dart';
import '../../domain/usecases/set_selected_audience_usecase.dart';

class AudienceBindings {
  static void setup() {
    final sl = getIt;

    sl.registerLazySingleton<AudienceRemoteDataSource>(
      () => AudienceRemoteDataSource(sl<Dio>()),
    );

    sl.registerLazySingleton<AudienceLocalDataSource>(
      () => AudienceLocalDataSourceImpl(sl<PrefsStorage>()),
    );

    sl.registerLazySingleton<AudienceRepository>(
      () => AudienceRepositoryImpl(
        remoteDataSource: sl<AudienceRemoteDataSource>(),
        localDataSource: sl<AudienceLocalDataSource>(),
        analytics: sl<AnalyticsService>(),
        crash: sl<CrashlyticsService>(),
        performance: sl<PerformanceService>(),
      ),
    );

    sl.registerLazySingleton(
      () => GetAudiencesUseCase(sl<AudienceRepository>()),
    );
    sl.registerLazySingleton(
      () => GetSelectedAudienceUseCase(sl<AudienceRepository>()),
    );
    sl.registerLazySingleton(
      () => SetSelectedAudienceUseCase(sl<AudienceRepository>()),
    );
  }
}

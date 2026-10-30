import 'package:dartz/dartz.dart';
import 'package:get/get.dart';

import '../../../../core/errors/api_result.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/failure_key.dart';
import '../../domain/entities/audience_entity.dart';
import '../../domain/usecases/get_audiences_usecase.dart';
import '../../domain/usecases/get_selected_audience_usecase.dart';
import '../../domain/usecases/set_selected_audience_usecase.dart';
import '../store/audience_store.dart';

class AudienceManager extends GetxService {
  AudienceManager({
    required this.store,
    required this.getAudiencesUseCase,
    required this.getSelectedAudienceUseCase,
    required this.setSelectedAudienceUseCase,
  });

  final AudienceStore store;
  final GetAudiencesUseCase getAudiencesUseCase;
  final GetSelectedAudienceUseCase getSelectedAudienceUseCase;
  final SetSelectedAudienceUseCase setSelectedAudienceUseCase;

  Future<ApiResult<void>> initAudiences() async {
    final result = await getAudiencesUseCase();
    return result.fold((failure) => Left(failure), (list) {
      if (list.isEmpty) {
        return Left(Failure.http(key: FailureKey.missingServerData));
      }
      store.audiences.assignAll(list);
      final savedId = getSelectedAudienceUseCase();

      AudienceEntity? match;
      if (savedId != null) {
        match = list.firstWhereOrNull((a) => a.audienceId == savedId);
      }

      // If a saved audience exists and matches, use it. Otherwise, default to the first audience.
      if (match != null) {
        store.selectedAudience.value = match;
      } else {
        store.selectedAudience.value = list.first;
        setSelectedAudienceUseCase(list.first.audienceId);
      }
      return Right(null);
    });
  }

  Future<void> selectAudience(AudienceEntity audience) async {
    store.selectedAudience.value = audience;
    await setSelectedAudienceUseCase(audience.audienceId);
  }

  int? get selectedAudienceId => store.selectedAudience.value?.audienceId;
}

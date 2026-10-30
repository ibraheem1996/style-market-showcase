// Project imports:
import '../../../../core/errors/api_result.dart';
import '../entities/area_entity.dart';
import '../repositories/addresses_repository.dart';

//! Use case for getting areas for a city
class GetAreasUseCase {
  final AddressesRepository repository;

  GetAreasUseCase(this.repository);

  Future<ApiResult<List<AreaEntity>>> call(GetAreasParams params) async {
    return await repository.getAreas(params.cityId);
  }
}

class GetAreasParams {
  final int cityId;

  GetAreasParams({required this.cityId});
}

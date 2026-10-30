// Project imports:
import '../../../../core/errors/api_result.dart';
import '../entities/city_entity.dart';
import '../repositories/addresses_repository.dart';

//! Use case for getting all cities
class GetCitiesUseCase {
  final AddressesRepository repository;

  GetCitiesUseCase(this.repository);

  Future<ApiResult<List<CityEntity>>> call() async {
    return await repository.getCities();
  }
}

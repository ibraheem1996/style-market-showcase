import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/network/api_response.dart';
import '../models/admin_category_request_models.dart';
import '../models/admin_category_response_models.dart';

part 'admin_categories_remote_data_source.g.dart';

@RestApi()
@lazySingleton
abstract class AdminCategoriesRemoteDataSource {
  @factoryMethod
  factory AdminCategoriesRemoteDataSource(@Named('protectedDio') Dio dio) =
      _AdminCategoriesRemoteDataSource;

  @GET('/admin/categories')
  Future<ApiResponse<AdminCategoriesListDataModel>> getCategories();

  @GET('/admin/categories/{categoryId}')
  Future<ApiResponse<AdminCategoryMutationDataModel>> getCategory(
    @Path('categoryId') int categoryId,
  );

  @MultiPart()
  @POST('/admin/categories')
  Future<ApiResponse<AdminCategoryMutationDataModel>> createCategory(
    @Part(name: 'arabic_name') String arabicName,
    @Part(name: 'english_name') String englishName,
    @Part(name: 'parent_id') int? parentId,
    @Part(name: 'sort_order') int sortOrder,
    @Part(name: 'image') MultipartFile image,
  );

  @MultiPart()
  @PUT('/admin/categories/{categoryId}')
  Future<ApiResponse<AdminCategoryMutationDataModel>> updateCategory(
    @Path('categoryId') int categoryId,
    @Part(name: 'arabic_name') String arabicName,
    @Part(name: 'english_name') String englishName,
    @Part(name: 'parent_id') int? parentId,
    @Part(name: 'sort_order') int sortOrder,
    @Part(name: 'image') MultipartFile? image,
  );

  @PATCH('/admin/categories/{categoryId}/visibility')
  Future<ApiResponse<AdminCategoryMutationDataModel>> updateVisibility(
    @Path('categoryId') int categoryId,
    @Body() AdminCategoryVisibilityRequestModel body,
  );

  @GET('/admin/categories/{categoryId}/deletion-impact')
  Future<ApiResponse<AdminCategoryDeletionImpactModel>> getDeletionImpact(
    @Path('categoryId') int categoryId,
  );

  @DELETE('/admin/categories/{categoryId}')
  Future<ApiResponse<AdminCategoryDeleteDataModel>> deleteCategory(
    @Path('categoryId') int categoryId,
  );
}

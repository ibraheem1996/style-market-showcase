import '../../../../core/errors/app_failure.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/network_error_mapper.dart';
import '../../../../core/result/app_result.dart';
import '../../domain/entities/admin_category_entities.dart';
import '../models/admin_category_response_models.dart';

extension AdminCategoryNodeMapper on AdminCategoryNodeModel {
  AdminCategoryEntity toEntity() {
    if (id <= 0 || directProductCount < 0 || directChildrenCount < 0) {
      throw const FormatException('Invalid Admin Category numeric fields.');
    }
    if (arabicName.trim().isEmpty || englishName.trim().isEmpty) {
      throw const FormatException('Missing Admin Category name.');
    }
    return AdminCategoryEntity(
      id: id,
      arabicName: arabicName,
      englishName: englishName,
      image: image,
      parentId: parentId,
      sortOrder: sortOrder,
      active: active,
      directProductCount: directProductCount,
      directChildrenCount: directChildrenCount,
      canDelete: canDelete,
      children: children.map((node) => node.toEntity()).toList(growable: false),
    );
  }
}

extension AdminCategoryMutationMapper on AdminCategoryMutationDataModel {
  AdminCategoryMutationResult toEntity() => AdminCategoryMutationResult(
    category: category.toEntity(),
    warnings: List.unmodifiable(warnings),
  );
}

extension AdminCategoryDeletionImpactMapper
    on AdminCategoryDeletionImpactModel {
  AdminCategoryDeletionImpact toEntity() {
    if (categoryId <= 0 || directProductCount < 0 || directChildrenCount < 0) {
      throw const FormatException('Invalid category deletion impact.');
    }
    return AdminCategoryDeletionImpact(
      categoryId: categoryId,
      active: active,
      directProductCount: directProductCount,
      directChildrenCount: directChildrenCount,
      canDelete: canDelete,
      blockers: List.unmodifiable(blockers),
    );
  }
}

extension AdminCategoryDeleteMapper on AdminCategoryDeleteDataModel {
  AdminCategoryDeleteResult toEntity() {
    if (deletedCategoryId <= 0) {
      throw const FormatException('Invalid deleted category id.');
    }
    return AdminCategoryDeleteResult(
      deletedCategoryId: deletedCategoryId,
      warnings: List.unmodifiable(warnings),
    );
  }
}

AppResult<T> mapAdminCategoryResponse<T, M>({
  required ApiResponse<M> response,
  required T Function(M model) mapper,
  required NetworkErrorMapper errorMapper,
}) {
  if (!response.isSuccess || response.data == null) {
    return AppResult.failure(
      errorMapper.mapResponse(
        statusCode: null,
        data: {
          'status': response.status,
          'message': response.message,
          'error_code': response.errorCode,
        },
      ),
    );
  }
  try {
    return AppResult.success(mapper(response.data as M));
  } on FormatException catch (error) {
    return AppResult.failure(AppFailure.parsing(rawMessage: error.message));
  }
}

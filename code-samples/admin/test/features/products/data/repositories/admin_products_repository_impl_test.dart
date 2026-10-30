import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multi_product_store_admin_web/core/errors/app_failure.dart';
import 'package:multi_product_store_admin_web/core/network/api_response.dart';
import 'package:multi_product_store_admin_web/core/network/network_error_mapper.dart';
import 'package:multi_product_store_admin_web/core/result/app_result.dart';
import 'package:multi_product_store_admin_web/features/products/data/datasources/admin_products_remote_data_source.dart';
import 'package:multi_product_store_admin_web/features/products/data/models/admin_product_media_request_models.dart';
import 'package:multi_product_store_admin_web/features/products/data/models/admin_product_media_response_models.dart';
import 'package:multi_product_store_admin_web/features/products/data/models/admin_product_lifecycle_response_models.dart';
import 'package:multi_product_store_admin_web/features/products/data/models/admin_product_request_models.dart';
import 'package:multi_product_store_admin_web/features/products/data/models/admin_product_response_models.dart';
import 'package:multi_product_store_admin_web/features/products/data/repositories/admin_products_repository_impl.dart';
import 'package:multi_product_store_admin_web/features/products/domain/entities/admin_product_create_entities.dart';
import 'package:multi_product_store_admin_web/features/products/domain/entities/admin_product_edit_entities.dart';
import 'package:multi_product_store_admin_web/features/products/domain/entities/admin_product_enums.dart';
import 'package:multi_product_store_admin_web/features/products/domain/entities/admin_product_filters.dart';
import 'package:multi_product_store_admin_web/features/products/domain/entities/admin_product_media_entities.dart';
import 'package:multi_product_store_admin_web/features/products/domain/entities/admin_variant_create_entities.dart';

void main() {
  group('AdminProductsRepositoryImpl', () {
    late _FakeAdminProductsRemoteDataSource remote;
    late AdminProductsRepositoryImpl repository;

    setUp(() {
      remote = _FakeAdminProductsRemoteDataSource();
      repository = AdminProductsRepositoryImpl(
        remote,
        const NetworkErrorMapper(),
      );
    });

    test('maps list success response to domain page', () async {
      remote.productsResponse = ApiResponse(
        status: 'success',
        data: AdminProductsListDataModel.fromJson(_listJson()),
      );

      final result = await repository.getProducts(
        page: 1,
        pageSize: 20,
        filters: const AdminProductFilters(),
      );

      expect(result, isA<AppResultSuccess>());
      expect(remote.lastQueries?['sort'], 'newest');
    });

    test('maps backend error response to failure', () async {
      remote.productsResponse = const ApiResponse(
        status: 'error',
        message: 'Product not found',
        errorCode: 'PRODUCT_NOT_FOUND',
      );

      final result = await repository.getProducts(
        page: 1,
        pageSize: 20,
        filters: const AdminProductFilters(),
      );

      expect(result, isA<AppResultFailure>());
      expect((result as AppResultFailure).failure.message, 'Product not found');
    });

    test('maps network errors through NetworkErrorMapper', () async {
      remote.error = DioException(
        requestOptions: RequestOptions(path: '/admin/products'),
        type: DioExceptionType.connectionError,
        error: 'offline',
      );

      final result = await repository.getProducts(
        page: 1,
        pageSize: 20,
        filters: const AdminProductFilters(),
      );

      expect(result, isA<AppResultFailure>());
      expect((result as AppResultFailure).failure, isA<NetworkFailure>());
    });

    test('maps edit bootstrap success response', () async {
      remote.editBootstrapResponse = ApiResponse(
        status: 'success',
        data: AdminProductDetailsEditBootstrapModel.fromJson(
          _editBootstrapJson(),
        ),
      );

      final result = await repository.getProductDetailsEditBootstrap(10);

      expect(result, isA<AppResultSuccess>());
      final data =
          (result as AppResultSuccess<AdminProductDetailsEditBootstrapEntity>)
              .data;
      expect(data.current.itemPrice, '19.90');
      expect(data.categories.first.parentId, isNull);
      expect(data.sizeGroupCorrection.currentSizeGroupId, 3);
      expect(data.sizeGroupCorrection.canUpdate, isTrue);
      expect(data.sizeGroupCorrection.sizeGroups.single.values, hasLength(2));
    });

    test('maps product create options success response', () async {
      remote.createOptionsResponse = ApiResponse(
        status: 'success',
        data: AdminProductCreateOptionsModel.fromJson(_createOptionsJson()),
      );

      final result = await repository.getProductCreateOptions();

      expect(result, isA<AppResultSuccess>());
      final data =
          (result as AppResultSuccess<AdminProductCreateOptionsEntity>).data;
      expect(data.defaults.active, isFalse);
      expect(data.defaults.featured, isTrue);
      expect(data.sizeGroups.single.values, hasLength(2));
    });

    test('creates product with item-only request body', () async {
      remote.createProductResponse = ApiResponse(
        status: 'success',
        data: AdminProductCreateResultModel.fromJson({
          'created_product_id': 77,
          'product': _detailJson(id: 77),
        }),
      );

      final result = await repository.createProduct(
        const AdminProductCreateInputEntity(
          arabicName: 'منتج جديد',
          englishName: 'New Product',
          descriptionAr: null,
          descriptionEn: null,
          categoryId: 2,
          audienceId: 1,
          sizeGroupId: 3,
          itemPrice: '20.00',
          itemDiscount: '0.00',
          active: true,
          featured: false,
          simpleStock: 0,
        ),
      );

      final body = remote.lastCreateProductBody?.toJson();
      expect(result, isA<AppResultSuccess>());
      expect(body, {
        'arabic_name': 'منتج جديد',
        'english_name': 'New Product',
        'category_id': 2,
        'audience_id': 1,
        'size_group_id': 3,
        'item_price': '20.00',
        'item_discount': '0.00',
        'active': true,
        'featured': false,
        'simple_stock': 0,
      });
      expect(body?.containsKey('media'), false);
      expect(body?.containsKey('color_id'), false);
      expect(body?.containsKey('initial_variant'), false);
    });

    test('updates product details with partial patch body', () async {
      remote.detailResponse = ApiResponse(
        status: 'success',
        data: AdminProductDetailModel.fromJson(_detailJson()),
      );

      final result = await repository.updateProductDetails(
        productId: 10,
        patch: const AdminProductDetailsPatchEntity(
          englishName: null,
          clearEnglishName: true,
          itemPrice: '24.99',
        ),
      );

      expect(result, isA<AppResultSuccess>());
      expect(remote.lastPatchBody, {
        'english_name': null,
        'item_price': '24.99',
      });
      expect(remote.lastPatchBody?.containsKey('size_group_id'), isFalse);
    });

    test(
      'updates only product size group and preserves explicit null',
      () async {
        remote.detailResponse = ApiResponse(
          status: 'success',
          data: AdminProductDetailModel.fromJson({
            ..._detailJson(),
            'size_group': null,
          }),
        );

        final result = await repository.updateProductSizeGroup(
          productId: 10,
          sizeGroupId: null,
        );

        expect(result, isA<AppResultSuccess>());
        expect(remote.lastSizeGroupBody?.toJson(), {'size_group_id': null});
      },
    );

    test('maps variant create options success response', () async {
      remote.variantCreateOptionsResponse = ApiResponse(
        status: 'success',
        data: AdminVariantCreateOptionsModel.fromJson(
          _variantCreateOptionsJson(),
        ),
      );

      final result = await repository.getVariantCreateOptions(10);

      expect(result, isA<AppResultSuccess>());
      final data =
          (result as AppResultSuccess<AdminVariantCreateOptionsEntity>).data;
      expect(data.allowedShapes.colorOnly, isTrue);
      expect(data.colors.single.selectable, isTrue);
      expect(data.existingCombinations.single.variantId, 101);
    });

    test(
      'creates variant with explicit inherited nulls and zero override',
      () async {
        remote.variantCreateResultResponse = ApiResponse(
          status: 'success',
          data: AdminVariantCreateResultModel.fromJson({
            'created_variant_id': 501,
            'product': _detailJson(),
          }),
        );

        final result = await repository.createVariant(
          productId: 10,
          input: const AdminVariantCreateInputEntity(
            colorId: 7,
            sizeId: null,
            descriptionAr: null,
            descriptionEn: null,
            stock: 0,
            active: true,
            variantPrice: null,
            variantDiscount: '0.00',
          ),
        );

        expect(result, isA<AppResultSuccess>());
        expect(remote.lastCreateBody, {
          'color_id': 7,
          'description_ar': null,
          'description_en': null,
          'stock': 0,
          'active': true,
          'variant_price': null,
          'variant_discount': '0.00',
        });
      },
    );

    test('maps product media bootstrap success response', () async {
      remote.mediaResponse = ApiResponse(
        status: 'success',
        data: AdminProductMediaBootstrapModel.fromJson(_mediaBootstrapJson()),
      );

      final result = await repository.getProductMedia(10);

      expect(result, isA<AppResultSuccess>());
      expect(remote.getMediaProductId, 10);
    });

    test('uploads media as multipart files with content types', () async {
      remote.mediaMutationResponse = ApiResponse(
        status: 'success',
        data: AdminProductMediaMutationDataModel.fromJson({
          'operation': 'upload',
          'created_image_ids': [701],
          'deleted_image_id': null,
          'storage_deleted': null,
          'media': _mediaBootstrapJson(),
        }),
      );

      final result = await repository.uploadProductMediaImages(
        productId: 10,
        scope: AdminProductMediaScope.item,
        targetId: 10,
        files: const [
          AdminProductMediaUploadFileEntity(
            name: 'photo.png',
            bytes: [1, 2, 3],
            size: 3,
            mimeType: null,
          ),
        ],
      );

      expect(result, isA<AppResultSuccess>());
      expect(remote.lastMediaScope, 'item');
      expect(remote.lastMultipartFiles.single.filename, 'photo.png');
      expect(
        remote.lastMultipartFiles.single.contentType?.mimeType,
        'image/png',
      );
    });

    test('reorders media target with exact image id list', () async {
      remote.mediaMutationResponse = ApiResponse(
        status: 'success',
        data: AdminProductMediaMutationDataModel.fromJson({
          'operation': 'reorder',
          'created_image_ids': null,
          'deleted_image_id': null,
          'storage_deleted': null,
          'media': _mediaBootstrapJson(),
        }),
      );

      final result = await repository.reorderProductMediaTarget(
        productId: 10,
        scope: AdminProductMediaScope.item,
        targetId: 10,
        imageIds: [502, 501],
      );

      expect(result, isA<AppResultSuccess>());
      expect(remote.lastReorderBody?.imageIds, [502, 501]);
    });

    test('clears primary with explicit null image id', () async {
      remote.mediaMutationResponse = ApiResponse(
        status: 'success',
        data: AdminProductMediaMutationDataModel.fromJson({
          'operation': 'primary',
          'created_image_ids': null,
          'deleted_image_id': null,
          'storage_deleted': null,
          'media': _mediaBootstrapJson(),
        }),
      );

      await repository.setProductMediaPrimary(
        productId: 10,
        scope: AdminProductMediaScope.item,
        targetId: 10,
        imageId: null,
      );

      expect(remote.lastPrimaryBody?.toJson(), {'image_id': null});
    });

    test('visibility preserves returned full product detail', () async {
      remote.visibilityResponse = ApiResponse(
        status: 'success',
        data: AdminProductVisibilityDataModel.fromJson({
          'product_id': 10,
          'active': false,
          'featured': true,
          'product': {..._detailJson(), 'active': false, 'featured': true},
        }),
      );

      final result = await repository.updateProductVisibility(
        productId: 10,
        active: false,
      );

      expect(result, isA<AppResultSuccess>());
      final data = (result as AppResultSuccess).data;
      expect(data.product.id, 10);
      expect(data.product.active, isFalse);
    });

    test('maps product deletion impact and storage cleanup result', () async {
      remote.productImpactResponse = ApiResponse(
        status: 'success',
        data: AdminProductDeletionImpactModel.fromJson(_productImpactJson()),
      );
      remote.deleteProductResponse = ApiResponse(
        status: 'success',
        data: AdminProductDeleteResultModel.fromJson({
          'deleted_product_id': 10,
          'delete_effects': _productImpactJson()['delete_effects'],
          'storage': {'deleted': 2, 'retained_shared': 1, 'failed': 0},
        }),
      );

      final impact = await repository.getProductDeletionImpact(10);
      final deleted = await repository.deleteProduct(10);

      expect((impact as AppResultSuccess).data.deleteEffects.mediaFileCount, 2);
      expect((deleted as AppResultSuccess).data.storage.retainedShared, 1);
    });

    test('maps variant delete updated parent product', () async {
      remote.deleteVariantResponse = ApiResponse(
        status: 'success',
        data: AdminVariantDeleteResultModel.fromJson({
          'deleted_variant_id': 101,
          'product_id': 10,
          'delete_effects': {
            'favorite_row_count': 1,
            'variant_attribute_count': 2,
            'variant_media_row_count': 1,
            'orphan_color_media_row_count': 0,
            'orphan_size_media_row_count': 0,
            'orphan_item_attribute_meta_count': 0,
            'media_file_count': 1,
            'remaining_variant_count': 1,
          },
          'storage': {'deleted': 1, 'retained_shared': 0, 'failed': 0},
          'product': _detailJson(),
        }),
      );

      final result = await repository.deleteVariant(101);

      expect((result as AppResultSuccess).data.product.id, 10);
    });
  });
}

Map<String, Object?> _productImpactJson() => {
  'product_id': 10,
  'arabic_name': 'منتج',
  'english_name': null,
  'active': false,
  'sell_mode': 'simple',
  'can_delete': true,
  'blockers': {'active': false, 'order_item_count': 0, 'cart_row_count': 0},
  'delete_effects': {
    'favorite_row_count': 3,
    'variant_count': 0,
    'variant_attribute_count': 0,
    'media_row_count': 2,
    'media_file_count': 2,
    'collection_item_count': 1,
    'item_attribute_meta_count': 0,
    'recently_viewed_count': 4,
  },
};

class _FakeAdminProductsRemoteDataSource
    implements AdminProductsRemoteDataSource {
  ApiResponse<AdminProductsListDataModel>? productsResponse;
  ApiResponse<AdminProductDetailModel>? detailResponse;
  ApiResponse<AdminProductDeletionImpactModel>? productImpactResponse;
  ApiResponse<AdminProductDeleteResultModel>? deleteProductResponse;
  ApiResponse<AdminVariantDeletionImpactModel>? variantImpactResponse;
  ApiResponse<AdminVariantDeleteResultModel>? deleteVariantResponse;
  ApiResponse<AdminProductMediaBootstrapModel>? mediaResponse;
  ApiResponse<AdminProductMediaMutationDataModel>? mediaMutationResponse;
  ApiResponse<AdminProductDetailsEditBootstrapModel>? editBootstrapResponse;
  ApiResponse<AdminProductCreateOptionsModel>? createOptionsResponse;
  ApiResponse<AdminProductCreateResultModel>? createProductResponse;
  ApiResponse<AdminProductVisibilityDataModel>? visibilityResponse;
  ApiResponse<AdminProductStockDataModel>? productStockResponse;
  ApiResponse<AdminVariantStockDataModel>? variantStockResponse;
  ApiResponse<AdminVariantVisibilityDataModel>? variantVisibilityResponse;
  ApiResponse<AdminVariantDetailsEditBootstrapModel>?
  variantEditBootstrapResponse;
  ApiResponse<AdminProductDetailModel>? updateVariantDetailsResponse;
  ApiResponse<AdminVariantCreateOptionsModel>? variantCreateOptionsResponse;
  ApiResponse<AdminVariantCreateResultModel>? variantCreateResultResponse;
  Object? error;
  Map<String, dynamic>? lastQueries;
  Map<String, dynamic>? lastPatchBody;
  Map<String, dynamic>? lastCreateBody;
  AdminProductCreateRequestModel? lastCreateProductBody;
  AdminProductSizeGroupUpdateRequestModel? lastSizeGroupBody;
  int? getMediaProductId;
  String? lastMediaScope;
  int? lastMediaTargetId;
  List<MultipartFile> lastMultipartFiles = const [];
  AdminProductMediaReorderRequestModel? lastReorderBody;
  AdminProductMediaPrimaryRequestModel? lastPrimaryBody;

  @override
  Future<ApiResponse<AdminProductsListDataModel>> getProducts(
    Map<String, dynamic> queries,
  ) async {
    lastQueries = queries;
    final thrown = error;
    if (thrown != null) throw thrown;
    return productsResponse!;
  }

  @override
  Future<ApiResponse<AdminProductDetailModel>> getProductDetail(
    int productId,
  ) async {
    return detailResponse!;
  }

  @override
  Future<ApiResponse<AdminProductDeletionImpactModel>> getProductDeletionImpact(
    int productId,
  ) async {
    return productImpactResponse!;
  }

  @override
  Future<ApiResponse<AdminProductDeleteResultModel>> deleteProduct(
    int productId,
  ) async {
    return deleteProductResponse!;
  }

  @override
  Future<ApiResponse<AdminVariantDeletionImpactModel>> getVariantDeletionImpact(
    int variantId,
  ) async {
    return variantImpactResponse!;
  }

  @override
  Future<ApiResponse<AdminVariantDeleteResultModel>> deleteVariant(
    int variantId,
  ) async {
    return deleteVariantResponse!;
  }

  @override
  Future<ApiResponse<AdminProductMediaBootstrapModel>> getProductMedia(
    int productId,
  ) async {
    getMediaProductId = productId;
    return mediaResponse!;
  }

  @override
  Future<ApiResponse<AdminProductMediaMutationDataModel>>
  uploadProductMediaImages(
    int productId,
    String scope,
    int targetId,
    List<MultipartFile> files,
  ) async {
    lastMediaScope = scope;
    lastMediaTargetId = targetId;
    lastMultipartFiles = files;
    return mediaMutationResponse!;
  }

  @override
  Future<ApiResponse<AdminProductMediaMutationDataModel>>
  deleteProductMediaImage(int productId, int imageId) async {
    return mediaMutationResponse!;
  }

  @override
  Future<ApiResponse<AdminProductMediaMutationDataModel>>
  reorderProductMediaTarget(
    int productId,
    String scope,
    int targetId,
    AdminProductMediaReorderRequestModel body,
  ) async {
    lastMediaScope = scope;
    lastMediaTargetId = targetId;
    lastReorderBody = body;
    return mediaMutationResponse!;
  }

  @override
  Future<ApiResponse<AdminProductMediaMutationDataModel>>
  setProductMediaPrimary(
    int productId,
    String scope,
    int targetId,
    AdminProductMediaPrimaryRequestModel body,
  ) async {
    lastMediaScope = scope;
    lastMediaTargetId = targetId;
    lastPrimaryBody = body;
    return mediaMutationResponse!;
  }

  @override
  Future<ApiResponse<AdminProductDetailsEditBootstrapModel>>
  getProductDetailsEditBootstrap(int productId) async {
    return editBootstrapResponse!;
  }

  @override
  Future<ApiResponse<AdminProductCreateOptionsModel>>
  getProductCreateOptions() async {
    return createOptionsResponse!;
  }

  @override
  Future<ApiResponse<AdminProductCreateResultModel>> createProduct(
    AdminProductCreateRequestModel body,
  ) async {
    lastCreateProductBody = body;
    return createProductResponse!;
  }

  @override
  Future<ApiResponse<AdminVariantCreateOptionsModel>> getVariantCreateOptions(
    int productId,
  ) async {
    return variantCreateOptionsResponse!;
  }

  @override
  Future<ApiResponse<AdminVariantCreateResultModel>> createVariant(
    int productId,
    Map<String, dynamic> body,
  ) async {
    lastCreateBody = body;
    return variantCreateResultResponse!;
  }

  @override
  Future<ApiResponse<AdminProductDetailModel>> updateProductDetails(
    int productId,
    Map<String, dynamic> body,
  ) async {
    lastPatchBody = body;
    return detailResponse!;
  }

  @override
  Future<ApiResponse<AdminProductDetailModel>> updateProductSizeGroup(
    int productId,
    AdminProductSizeGroupUpdateRequestModel body,
  ) async {
    lastSizeGroupBody = body;
    return detailResponse!;
  }

  @override
  Future<ApiResponse<AdminProductVisibilityDataModel>> updateProductVisibility(
    int productId,
    AdminProductVisibilityRequestModel body,
  ) async {
    return visibilityResponse!;
  }

  @override
  Future<ApiResponse<AdminProductStockDataModel>> updateProductStock(
    int productId,
    AdminProductStockRequestModel body,
  ) async {
    return productStockResponse!;
  }

  @override
  Future<ApiResponse<AdminVariantStockDataModel>> updateVariantStock(
    int variantId,
    AdminVariantStockRequestModel body,
  ) async {
    return variantStockResponse!;
  }

  @override
  Future<ApiResponse<AdminVariantVisibilityDataModel>> updateVariantVisibility(
    int variantId,
    AdminVariantVisibilityRequestModel body,
  ) async {
    return variantVisibilityResponse!;
  }

  @override
  Future<ApiResponse<AdminVariantDetailsEditBootstrapModel>>
  getVariantDetailsEditBootstrap(int variantId) async {
    return variantEditBootstrapResponse!;
  }

  @override
  Future<ApiResponse<AdminProductDetailModel>> updateVariantDetails(
    int variantId,
    Map<String, dynamic> body,
  ) async {
    lastPatchBody = body;
    return updateVariantDetailsResponse!;
  }
}

Map<String, Object?> _editBootstrapJson() {
  return {
    'product_id': 10,
    'current': {
      'arabic_name': 'منتج',
      'english_name': 'Product',
      'description_ar': null,
      'description_en': null,
      'category_id': 2,
      'audience_id': 1,
      'item_price': '19.90',
      'item_discount': '5.00',
      'sell_mode': 'simple',
    },
    'categories': [
      {
        'id': 1,
        'arabic_name': 'الملابس',
        'english_name': 'Clothes',
        'parent_id': null,
        'sort_order': 1,
        'active': true,
        'selectable': true,
      },
      {
        'id': 2,
        'arabic_name': 'قمصان',
        'english_name': 'Shirts',
        'parent_id': 1,
        'sort_order': 1,
        'active': true,
        'selectable': true,
      },
    ],
    'audiences': [
      {
        'id': 1,
        'arabic_name': 'رجال',
        'english_name': 'Men',
        'sort_order': 1,
        'active': true,
        'selectable': true,
      },
    ],
    'size_group_correction': {
      'current': {'size_group_id': 3},
      'editable': {
        'can_update': true,
        'locked_reason': null,
        'variant_count': 0,
        'size_variant_count': 0,
      },
      'size_groups': [
        {
          'id': 3,
          'arabic_name': 'مقاسات',
          'english_name': 'Sizes',
          'values': [
            {'id': 4, 'arabic_name': 'M', 'english_name': 'M', 'sort_order': 1},
            {'id': 5, 'arabic_name': 'L', 'english_name': 'L', 'sort_order': 2},
          ],
        },
      ],
      'allowed_null': true,
    },
  };
}

Map<String, Object?> _variantCreateOptionsJson() {
  return {
    'product_id': 10,
    'product': {
      'id': 10,
      'arabic_name': 'منتج',
      'english_name': 'Product',
      'sell_mode': 'simple',
      'item_price': '19.90',
      'item_discount': '5.00',
      'size_group': {'id': 3, 'arabic_name': 'مقاسات', 'english_name': 'Sizes'},
    },
    'current_variant_shape': null,
    'detected_variant_shapes': <String>[],
    'shape_locked': false,
    'shape_lock_reason': null,
    'shape_inconsistency': null,
    'inferred_size_group_id': null,
    'allowed_shapes': {
      'color_size': true,
      'color_only': true,
      'size_only': true,
      'none': false,
    },
    'colors': [
      {
        'id': 7,
        'arabic_name': 'أسود',
        'english_name': 'Black',
        'hex': '#000000',
        'sort_order': 1,
        'selectable': true,
      },
    ],
    'sizes': [
      {
        'id': 4,
        'arabic_name': 'M',
        'english_name': 'M',
        'sort_order': 1,
        'selectable': true,
      },
    ],
    'existing_combinations': [
      {
        'variant_id': 101,
        'color_id': 7,
        'size_id': 4,
        'variant_key': 'c7-s4',
        'label': 'أسود / M',
        'shape': 'color_size',
        'active': true,
      },
    ],
    'conversion_impact': {
      'will_convert_simple_product': true,
      'simple_cart_row_count': 2,
      'simple_favorite_row_count': 1,
    },
  };
}

Map<String, Object?> _listJson() {
  return {
    'items': [
      {
        'id': 10,
        'arabic_name': 'منتج بسيط',
        'english_name': 'Simple',
        'category': null,
        'audience': null,
        'sell_mode': 'simple',
        'active': true,
        'featured': false,
        'variant_count': 0,
        'total_stock': 4,
        'stock_state': 'low_stock',
        'stock_source': 'item_stock',
        'price': {
          'item_price': 100,
          'item_discount': 10,
          'effective_price': 100,
          'effective_discount': 10,
          'final_price': 90,
        },
        'thumbnail_image': null,
        'resolved_images': [],
        'created_at': null,
        'updated_at': null,
      },
    ],
    'pagination': {
      'page': 1,
      'page_size': 20,
      'total_items': 1,
      'total_pages': 1,
      'has_next': false,
      'has_previous': false,
    },
  };
}

Map<String, Object?> _createOptionsJson() {
  return {
    'defaults': {
      'active': false,
      'featured': true,
      'item_discount': '0.00',
      'simple_stock': 0,
    },
    'limits': {
      'arabic_name_max_length': 150,
      'english_name_max_length': 255,
      'price_min': '0.00',
      'price_max': '99999999.99',
      'discount_min': '0.00',
      'discount_max': '100.00',
    },
    'categories': [
      {
        'id': 2,
        'arabic_name': 'قمصان',
        'english_name': 'Shirts',
        'parent_id': null,
        'sort_order': 1,
        'active': true,
        'selectable': true,
      },
    ],
    'audiences': [
      {
        'id': 1,
        'arabic_name': 'رجال',
        'english_name': 'Men',
        'sort_order': 1,
        'active': true,
        'selectable': true,
      },
    ],
    'size_groups': [
      {
        'id': 3,
        'arabic_name': 'مقاسات',
        'english_name': 'Sizes',
        'values': [
          {'id': 4, 'arabic_name': 'M', 'english_name': 'M', 'sort_order': 1},
          {'id': 5, 'arabic_name': 'L', 'english_name': 'L', 'sort_order': 2},
        ],
      },
    ],
  };
}

Map<String, Object?> _detailJson({int id = 10}) {
  return {
    'id': id,
    'arabic_name': 'منتج بسيط',
    'english_name': 'Simple',
    'description_ar': 'وصف',
    'description_en': 'Description',
    'category': {'id': 2, 'arabic_name': 'قمصان', 'english_name': 'Shirts'},
    'audience': {'id': 1, 'arabic_name': 'رجال', 'english_name': 'Men'},
    'size_group': {'id': 3, 'arabic_name': 'مقاسات', 'english_name': 'Sizes'},
    'sell_mode': 'simple',
    'active': true,
    'featured': false,
    'simple_stock': {
      'stock': 4,
      'stock_state': 'low_stock',
      'stock_source': 'item_stock',
    },
    'inventory_summary': {
      'stock_source': 'item_stock',
      'stock': 4,
      'stock_state': 'low_stock',
      'variant_count': 0,
      'active_variant_count': 0,
      'inactive_variant_count': 0,
      'total_stock': 4,
      'lowest_stock': 4,
    },
    'price': {
      'item_price': 100,
      'item_discount': 10,
      'effective_price': 100,
      'effective_discount': 10,
      'final_price': 90,
    },
    'media': {
      'thumbnail': null,
      'preview': {'source': 'none', 'source_id': null, 'images': []},
      'summary': {
        'strategy': 'none',
        'total_image_count': 0,
        'unique_image_count': 0,
        'item_image_count': 0,
        'color_group_count': 0,
        'color_image_count': 0,
        'size_group_count': 0,
        'size_image_count': 0,
        'variant_group_count': 0,
        'variant_image_count': 0,
      },
      'item_images': {'source': 'item', 'images': []},
      'color_image_groups': [],
      'size_image_groups': [],
      'variant_image_groups': [],
    },
    'variant_view': null,
    'order_linked': false,
    'created_at': null,
    'updated_at': null,
  };
}

Map<String, Object?> _mediaBootstrapJson() {
  return {
    'product': {
      'id': 10,
      'arabic_name': 'منتج بسيط',
      'english_name': 'Simple',
      'sell_mode': 'simple',
      'active': true,
    },
    'fallback': {
      'card_order': ['color', 'item'],
      'entity_order': ['variant', 'color', 'size', 'item'],
    },
    'limits': {
      'max_files_per_request': 10,
      'max_file_bytes': 5242880,
      'allowed_extensions': ['.jpg', '.jpeg', '.png', '.webp', '.avif'],
      'allowed_mime_types': [
        'image/jpeg',
        'image/png',
        'image/webp',
        'image/avif',
      ],
    },
    'summary': {
      'target_count': 1,
      'owned_image_count': 1,
      'item_image_count': 1,
      'color_image_count': 0,
      'size_image_count': 0,
      'variant_image_count': 0,
    },
    'preview': {
      'source': 'item',
      'source_id': 10,
      'images': [_mediaImageJson()],
    },
    'targets': [
      {
        'scope': 'item',
        'target_id': 10,
        'target_key': 'item:10',
        'label': 'صور المنتج العامة',
        'owner': {
          'product_id': 10,
          'color': null,
          'size': null,
          'variant_id': null,
          'active': true,
        },
        'owned_images': [_mediaImageJson()],
        'effective_images': {
          'source': 'item',
          'source_id': 10,
          'inherited': false,
          'images': [_mediaImageJson()],
        },
      },
    ],
  };
}

Map<String, Object?> _mediaImageJson() {
  return {
    'image_id': 501,
    'url': 'item-a.jpg',
    'sort_order': 0,
    'is_primary': false,
    'created_at': null,
  };
}

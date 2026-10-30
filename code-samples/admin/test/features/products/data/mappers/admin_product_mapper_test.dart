import 'package:flutter_test/flutter_test.dart';
import 'package:multi_product_store_admin_web/features/products/data/mappers/admin_product_media_mapper.dart';
import 'package:multi_product_store_admin_web/features/products/data/mappers/admin_product_mapper.dart';
import 'package:multi_product_store_admin_web/features/products/data/models/admin_product_media_response_models.dart';
import 'package:multi_product_store_admin_web/features/products/data/models/admin_product_request_models.dart';
import 'package:multi_product_store_admin_web/features/products/data/models/admin_product_response_models.dart';
import 'package:multi_product_store_admin_web/features/products/domain/entities/admin_product_create_entities.dart';
import 'package:multi_product_store_admin_web/features/products/domain/entities/admin_product_enums.dart';
import 'package:multi_product_store_admin_web/features/products/domain/entities/admin_variant_create_entities.dart';

void main() {
  group('AdminProductMapper', () {
    test('parses products list with pagination and simple product', () {
      final model = AdminProductsListDataModel.fromJson({
        'items': [_summaryJson()],
        'pagination': _paginationJson(),
      });

      final entity = model.toEntity();

      expect(entity.items, hasLength(1));
      expect(entity.pagination.totalItems, 1);
      expect(entity.items.single.sellMode, AdminProductSellMode.simple);
      expect(entity.items.single.stockState, AdminProductStockState.lowStock);
      expect(entity.items.single.updatedAt, isNull);
    });

    test('parses variant product detail from backend detail contract', () {
      final model = AdminProductDetailModel.fromJson(_variantDetailJson());

      final entity = model.toEntity();

      expect(entity.sellMode, AdminProductSellMode.variant);
      expect(
        entity.inventorySummary.stockSource,
        AdminProductStockSource.variantStock,
      );
      expect(entity.inventorySummary.totalStock, 2);
      expect(entity.media.itemImages.images.single.url, 'item.jpg');
      expect(entity.media.colorImageGroups.single.color.id, 7);
      expect(
        entity.media.colorImageGroups.single.images.single.url,
        'black.jpg',
      );
      expect(entity.media.preview.images.single.url, 'black.jpg');
      expect(
        entity.variantView?.noteCode,
        AdminProductVariantNoteCode.variantsUseColorImages,
      );
      expect(entity.variantView?.groups, hasLength(1));
      expect(
        entity.variantView?.groups.single.variants.single.color?.arabicName,
        'أسود',
      );
      expect(
        entity.variantView?.groups.single.variants.single.size?.arabicName,
        'M',
      );
      expect(entity.orderLinked, isTrue);
      expect(entity.sizeGroup?.id, 3);
    });

    test('maps null product size group without inference', () {
      final model = AdminProductDetailModel.fromJson({
        ..._simpleDetailJson(),
        'size_group': null,
      });

      expect(model.toEntity().sizeGroup, isNull);
    });

    test('maps product edit size group correction contract', () {
      final model = AdminProductDetailsEditBootstrapModel.fromJson({
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
        'categories': <Object?>[],
        'audiences': <Object?>[],
        'size_group_correction': {
          'current': {'size_group_id': 3},
          'editable': {
            'can_update': false,
            'locked_reason': 'Product has size-bearing variants',
            'variant_count': 2,
            'size_variant_count': 1,
          },
          'size_groups': [
            {
              'id': 3,
              'arabic_name': 'مقاسات',
              'english_name': 'Sizes',
              'values': [
                {
                  'id': 4,
                  'arabic_name': 'M',
                  'english_name': 'M',
                  'sort_order': 1,
                },
              ],
            },
          ],
          'allowed_null': true,
        },
      });

      final correction = model.toEntity().sizeGroupCorrection;
      expect(correction.currentSizeGroupId, 3);
      expect(correction.canUpdate, isFalse);
      expect(correction.sizeVariantCount, 1);
      expect(correction.sizeGroups.single.values.single.arabicName, 'M');
    });

    test('size group request preserves set and explicit null values', () {
      const setRequest = AdminProductSizeGroupUpdateRequestModel(
        sizeGroupId: 6,
      );
      const clearRequest = AdminProductSizeGroupUpdateRequestModel(
        sizeGroupId: null,
      );

      expect(setRequest.toJson(), {'size_group_id': 6});
      expect(clearRequest.toJson(), {'size_group_id': null});
    });

    test(
      'preserves media ownership separately from variant view ownership',
      () {
        final model = AdminProductDetailModel.fromJson({
          ..._variantDetailJson(),
          'media': {
            'thumbnail': {
              'url': 'owned-item.jpg',
              'source': 'item',
              'source_id': 11,
            },
            'preview': {
              'source': 'item',
              'source_id': 11,
              'images': [
                {'url': 'preview-only.jpg'},
              ],
            },
            'summary': {
              'strategy': 'mixed',
              'total_image_count': 4,
              'unique_image_count': 4,
              'item_image_count': 1,
              'color_group_count': 1,
              'color_image_count': 1,
              'size_group_count': 1,
              'size_image_count': 1,
              'variant_group_count': 1,
              'variant_image_count': 1,
            },
            'item_images': {
              'source': 'item',
              'images': [
                {'url': 'owned-item.jpg'},
              ],
            },
            'color_image_groups': [
              {
                'source': 'color',
                'color': _colorJson(),
                'images': [
                  {'url': 'owned-color.jpg'},
                ],
              },
            ],
            'size_image_groups': [
              {
                'source': 'size',
                'size': _sizeJson(),
                'images': [
                  {'url': 'owned-size.jpg'},
                ],
              },
            ],
            'variant_image_groups': [
              {
                'source': 'variant',
                'variant': {
                  'id': 101,
                  'label': 'أسود / M',
                  'color': _colorJson(),
                  'size': _sizeJson(),
                },
                'images': [
                  {'url': 'owned-variant.jpg'},
                ],
              },
            ],
          },
          'variant_view': {
            ..._variantViewJson(),
            'groups': [
              {
                ..._variantGroupJson(),
                'images': [
                  {'url': 'owned-color.jpg'},
                ],
                'image_ownership': {
                  'source': 'color',
                  'source_id': 7,
                  'inherited': false,
                },
                'variants': [
                  {
                    ..._variantJson(),
                    'variant_images': [
                      {'url': 'owned-variant.jpg'},
                    ],
                    'image_ownership': {
                      'source': 'variant',
                      'source_id': 101,
                      'inherited': false,
                    },
                  },
                ],
              },
            ],
          },
        });

        final entity = model.toEntity();

        expect(entity.media.itemImages.images.single.url, 'owned-item.jpg');
        expect(
          entity.media.colorImageGroups.single.images.single.url,
          'owned-color.jpg',
        );
        expect(
          entity.media.sizeImageGroups.single.images.single.url,
          'owned-size.jpg',
        );
        expect(
          entity.media.variantImageGroups.single.images.single.url,
          'owned-variant.jpg',
        );
        expect(entity.media.preview.images.single.url, 'preview-only.jpg');
        final group = entity.variantView!.groups.single;
        expect(group.imageOwnership.source, AdminProductImageSource.color);
        expect(group.images.single.url, 'owned-color.jpg');
        expect(
          group.variants.single.imageOwnership.source,
          AdminProductImageSource.variant,
        );
        expect(
          group.variants.single.variantImages.single.url,
          'owned-variant.jpg',
        );
      },
    );

    test('rejects malformed response with missing required id', () {
      final model = AdminProductSummaryModel.fromJson({
        ..._summaryJson(),
        'id': null,
      });

      expect(
        model.toEntity,
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('Missing required admin product field: id'),
          ),
        ),
      );
    });

    test('rejects unknown enum values clearly', () {
      final model = AdminProductSummaryModel.fromJson({
        ..._summaryJson(),
        'sell_mode': 'bundle',
      });

      expect(
        model.toEntity,
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('Unknown admin product sell mode: bundle'),
          ),
        ),
      );
    });

    test('parses variant create options contract', () {
      final model = AdminVariantCreateOptionsModel.fromJson(
        _variantCreateOptionsJson(),
      );

      final entity = model.toEntity();

      expect(entity.productId, 10);
      expect(entity.product.sellMode, AdminProductSellMode.simple);
      expect(entity.product.sizeGroup?.id, 3);
      expect(entity.currentVariantShape, isNull);
      expect(entity.detectedVariantShapes, isEmpty);
      expect(entity.shapeLocked, isFalse);
      expect(entity.allowedShapes.colorSize, isTrue);
      expect(entity.colors.single.sortOrder, 1);
      expect(entity.sizes.single.selectable, isTrue);
      expect(entity.existingCombinations.single.label, 'أسود / M');
      expect(
        entity.existingCombinations.single.shape,
        AdminVariantShape.colorSize,
      );
      expect(entity.existingCombinations.single.active, isTrue);
      expect(entity.conversionImpact.simpleCartRowCount, 2);
    });

    test(
      'parses variant shape lock diagnostics and rejects unknown values',
      () {
        final locked = AdminVariantCreateOptionsModel.fromJson({
          ..._variantCreateOptionsJson(),
          'current_variant_shape': 'size_only',
          'detected_variant_shapes': ['size_only'],
          'shape_locked': true,
          'shape_lock_reason': 'existing_variants',
          'shape_inconsistency': 'size_group_missing',
          'inferred_size_group_id': 4,
        }).toEntity();

        expect(locked.currentVariantShape, AdminVariantShape.sizeOnly);
        expect(
          locked.shapeLockReason,
          AdminVariantShapeLockReason.existingVariants,
        );
        expect(
          locked.shapeInconsistency,
          AdminVariantShapeInconsistency.sizeGroupMissing,
        );
        expect(locked.inferredSizeGroupId, 4);

        final unknown = AdminVariantCreateOptionsModel.fromJson({
          ..._variantCreateOptionsJson(),
          'current_variant_shape': 'bundle',
        });
        expect(unknown.toEntity, throwsA(isA<FormatException>()));
      },
    );

    test('parses product create options contract', () {
      final model = AdminProductCreateOptionsModel.fromJson(
        _productCreateOptionsJson(),
      );

      final entity = model.toEntity();

      expect(entity.defaults.active, isFalse);
      expect(entity.defaults.featured, isTrue);
      expect(entity.limits.arabicNameMaxLength, 150);
      expect(entity.categories.single.id, 2);
      expect(entity.audiences.single.id, 1);
      expect(entity.sizeGroups.single.values.last.arabicName, 'L');
    });

    test('rejects malformed product create options required fields', () {
      final model = AdminProductCreateOptionsModel.fromJson({
        ..._productCreateOptionsJson(),
        'size_groups': [
          {
            'id': null,
            'arabic_name': 'مقاسات',
            'english_name': 'Sizes',
            'values': [],
          },
        ],
      });

      expect(
        model.toEntity,
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('Missing required admin product field: size_groups.id'),
          ),
        ),
      );
    });

    test('parses product create result with returned product detail', () {
      final model = AdminProductCreateResultModel.fromJson({
        'created_product_id': 77,
        'product': _simpleDetailJson(id: 77),
      });

      final entity = model.toEntity();

      expect(entity.createdProductId, 77);
      expect(entity.product.id, 77);
      expect(entity.product.sellMode, AdminProductSellMode.simple);
    });

    test('product create request omits null item-only optional fields', () {
      final body = const AdminProductCreateInputEntity(
        arabicName: 'منتج جديد',
        englishName: 'New Product',
        descriptionAr: null,
        descriptionEn: null,
        categoryId: 2,
        audienceId: 1,
        sizeGroupId: null,
        itemPrice: '20.00',
        itemDiscount: '0.00',
        active: true,
        featured: false,
        simpleStock: 0,
      ).toRequestModel().toJson();

      expect(body, {
        'arabic_name': 'منتج جديد',
        'english_name': 'New Product',
        'category_id': 2,
        'audience_id': 1,
        'item_price': '20.00',
        'item_discount': '0.00',
        'active': true,
        'featured': false,
        'simple_stock': 0,
      });
      expect(body.containsKey('description_ar'), false);
      expect(body.containsKey('size_group_id'), false);
      expect(body.containsKey('variant_price'), false);
      expect(body.containsKey('media'), false);
    });

    test('rejects malformed variant create options required fields', () {
      final model = AdminVariantCreateOptionsModel.fromJson({
        ..._variantCreateOptionsJson(),
        'product_id': null,
      });

      expect(
        model.toEntity,
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('Missing required admin product field: product_id'),
          ),
        ),
      );
    });

    test(
      'variant create request preserves inheritance nulls and zero override',
      () {
        final body = const AdminVariantCreateInputEntity(
          colorId: null,
          sizeId: 4,
          descriptionAr: null,
          descriptionEn: 'Size only',
          stock: 0,
          active: false,
          variantPrice: '0.00',
          variantDiscount: null,
        ).toRequestBody();

        expect(body, {
          'size_id': 4,
          'description_ar': null,
          'description_en': 'Size only',
          'stock': 0,
          'active': false,
          'variant_price': '0.00',
          'variant_discount': null,
        });
      },
    );

    test('parses editable product media bootstrap contract', () {
      final model = AdminProductMediaBootstrapModel.fromJson(
        _mediaBootstrapJson(),
      );

      final entity = model.toEntity();

      expect(entity.product.id, 10);
      expect(entity.fallback.cardOrder, [
        AdminProductMediaScope.color,
        AdminProductMediaScope.item,
      ]);
      expect(entity.targets, hasLength(2));
      expect(entity.targets.first.scope, AdminProductMediaScope.item);
      expect(entity.targets.first.ownedImages.single.imageId, 501);
      expect(entity.targets.last.effectiveImages.inherited, isTrue);
      expect(entity.targets.last.effectiveImages.sourceId, 10);
    });

    test('parses media mutation response and replacement bootstrap', () {
      final model = AdminProductMediaMutationDataModel.fromJson({
        'operation': 'delete',
        'created_image_ids': null,
        'deleted_image_id': 501,
        'storage_deleted': false,
        'media': _mediaBootstrapJson(),
      });

      final entity = model.toEntity();

      expect(entity.operation, AdminProductMediaOperation.delete);
      expect(entity.deletedImageId, 501);
      expect(entity.storageDeleted, isFalse);
      expect(entity.media.targets.first.targetKey, 'item:10');
    });

    test('rejects unknown media scope clearly', () {
      final model = AdminProductMediaBootstrapModel.fromJson({
        ..._mediaBootstrapJson(),
        'targets': [
          {
            ...Map<String, Object?>.from(
              (_mediaBootstrapJson()['targets'] as List).first as Map,
            ),
            'scope': 'gallery',
          },
        ],
      });

      expect(
        model.toEntity,
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('Unknown admin product media scope: gallery'),
          ),
        ),
      );
    });
  });
}

Map<String, Object?> _paginationJson() {
  return {
    'page': 1,
    'page_size': 20,
    'total_items': 1,
    'total_pages': 1,
    'has_next': false,
    'has_previous': false,
  };
}

Map<String, Object?> _summaryJson() {
  return {
    'id': 10,
    'arabic_name': 'منتج بسيط',
    'english_name': 'Simple',
    'category': {'id': 2, 'arabic_name': 'ملابس', 'english_name': 'Clothes'},
    'audience': {'id': 1, 'arabic_name': 'رجال', 'english_name': 'Men'},
    'sell_mode': 'simple',
    'active': true,
    'featured': false,
    'variant_count': 0,
    'total_stock': 4,
    'stock_state': 'low_stock',
    'stock_source': 'item_stock',
    'price': _priceJson(finalPrice: 90),
    'thumbnail_image': 'simple.jpg',
    'resolved_images': ['simple.jpg'],
    'created_at': '2026-06-15T10:00:00',
    'updated_at': null,
  };
}

Map<String, Object?> _variantDetailJson() {
  return {
    ..._summaryJson(),
    'id': 11,
    'arabic_name': 'منتج بخيارات',
    'sell_mode': 'variant',
    'description_ar': 'وصف',
    'description_en': 'Description',
    'size_group': {'id': 3, 'arabic_name': 'مقاسات', 'english_name': 'Sizes'},
    'simple_stock': null,
    'order_linked': true,
    'inventory_summary': _inventorySummaryJson(),
    'price': _priceJson(minFinalPrice: 57, maxFinalPrice: 70),
    'media': _mediaJson(),
    'variant_view': _variantViewJson(),
  };
}

Map<String, Object?> _variantCreateOptionsJson() {
  return {
    'product_id': 10,
    'product': {
      'id': 10,
      'arabic_name': 'منتج بسيط',
      'english_name': 'Simple',
      'sell_mode': 'simple',
      'item_price': '100.00',
      'item_discount': '10.00',
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

Map<String, Object?> _productCreateOptionsJson() {
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

Map<String, Object?> _simpleDetailJson({int id = 10}) {
  return {
    ..._summaryJson(),
    'id': id,
    'description_ar': null,
    'description_en': null,
    'size_group': {'id': 3, 'arabic_name': 'مقاسات', 'english_name': 'Sizes'},
    'simple_stock': {
      'stock': 0,
      'stock_state': 'out_of_stock',
      'stock_source': 'item_stock',
    },
    'order_linked': false,
    'inventory_summary': {
      'stock_source': 'item_stock',
      'stock': 0,
      'stock_state': 'out_of_stock',
      'variant_count': 0,
      'active_variant_count': 0,
      'inactive_variant_count': 0,
      'total_stock': 0,
      'lowest_stock': 0,
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
  };
}

Map<String, Object?> _inventorySummaryJson() {
  return {
    'stock_source': 'variant_stock',
    'stock': null,
    'stock_state': 'low_stock',
    'variant_count': 1,
    'active_variant_count': 1,
    'inactive_variant_count': 0,
    'total_stock': 2,
    'lowest_stock': 2,
  };
}

Map<String, Object?> _mediaJson() {
  return {
    'thumbnail': {'url': 'black.jpg', 'source': 'color', 'source_id': 7},
    'preview': {
      'source': 'color',
      'source_id': 7,
      'images': [
        {'url': 'black.jpg'},
      ],
    },
    'summary': {
      'strategy': 'color_images',
      'total_image_count': 2,
      'unique_image_count': 2,
      'item_image_count': 1,
      'color_group_count': 1,
      'color_image_count': 1,
      'size_group_count': 0,
      'size_image_count': 0,
      'variant_group_count': 0,
      'variant_image_count': 0,
    },
    'item_images': {
      'source': 'item',
      'images': [
        {'url': 'item.jpg'},
      ],
    },
    'color_image_groups': [
      {
        'source': 'color',
        'color': _colorJson(),
        'images': [
          {'url': 'black.jpg'},
        ],
      },
    ],
    'size_image_groups': [],
    'variant_image_groups': [],
  };
}

Map<String, Object?> _variantViewJson() {
  return {
    'grouping': 'color',
    'image_strategy': 'color_images',
    'note_code': 'variants_use_color_images',
    'groups': [_variantGroupJson()],
  };
}

Map<String, Object?> _variantGroupJson() {
  return {
    'type': 'color',
    'label': 'أسود',
    'color': _colorJson(),
    'size': null,
    'images': [
      {'url': 'black.jpg'},
    ],
    'image_ownership': {'source': 'color', 'source_id': 7, 'inherited': false},
    'summary': {
      'variant_count': 1,
      'total_stock': 2,
      'lowest_stock': 2,
      'active_count': 1,
      'inactive_count': 0,
      'min_final_price': 57,
      'max_final_price': 57,
    },
    'variants': [_variantJson()],
  };
}

Map<String, Object?> _variantJson() {
  return {
    'id': 101,
    'active': true,
    'stock': 2,
    'stock_state': 'low_stock',
    'stock_source': 'variant_stock',
    'color': _colorJson(),
    'size': _sizeJson(),
    'description_ar': null,
    'description_en': null,
    'price': _priceJson(finalPrice: 57),
    'image_ownership': {'source': 'color', 'source_id': 7, 'inherited': true},
    'variant_images': [],
    'order_linked': true,
    'created_at': '2026-06-15T10:00:00',
  };
}

Map<String, Object?> _colorJson() {
  return {
    'id': 7,
    'arabic_name': 'أسود',
    'english_name': 'Black',
    'hex': '#000000',
  };
}

Map<String, Object?> _sizeJson() {
  return {'id': 4, 'arabic_name': 'M', 'english_name': 'M'};
}

Map<String, Object?> _priceJson({
  double? finalPrice,
  double? minFinalPrice,
  double? maxFinalPrice,
}) {
  return {
    'item_price': 100,
    'item_discount': 10,
    'effective_price': finalPrice,
    'effective_discount': 10,
    'final_price': finalPrice,
    'min_effective_price': minFinalPrice,
    'max_effective_price': maxFinalPrice,
    'min_final_price': minFinalPrice,
    'max_final_price': maxFinalPrice,
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
      'target_count': 2,
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
      {
        'scope': 'color',
        'target_id': 7,
        'target_key': 'color:7',
        'label': 'أسود',
        'owner': {
          'product_id': null,
          'color': _colorJson(),
          'size': null,
          'variant_id': null,
          'active': null,
        },
        'owned_images': [],
        'effective_images': {
          'source': 'item',
          'source_id': 10,
          'inherited': true,
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
    'created_at': '2026-06-25T10:00:00',
  };
}

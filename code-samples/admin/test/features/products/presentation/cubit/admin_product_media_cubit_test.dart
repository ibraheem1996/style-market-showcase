import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multi_product_store_admin_web/core/errors/app_failure.dart';
import 'package:multi_product_store_admin_web/core/errors/backend_error_code.dart';
import 'package:multi_product_store_admin_web/core/result/app_result.dart';
import 'package:multi_product_store_admin_web/features/products/domain/entities/admin_product_enums.dart';
import 'package:multi_product_store_admin_web/features/products/domain/entities/admin_product_media_entities.dart';
import 'package:multi_product_store_admin_web/features/products/domain/usecases/delete_admin_product_media_image_use_case.dart';
import 'package:multi_product_store_admin_web/features/products/domain/usecases/get_admin_product_media_use_case.dart';
import 'package:multi_product_store_admin_web/features/products/domain/usecases/reorder_admin_product_media_target_use_case.dart';
import 'package:multi_product_store_admin_web/features/products/domain/usecases/set_admin_product_media_primary_use_case.dart';
import 'package:multi_product_store_admin_web/features/products/domain/usecases/upload_admin_product_media_images_use_case.dart';
import 'package:multi_product_store_admin_web/features/products/presentation/cubit/product_media/admin_product_media_cubit.dart';
import 'package:multi_product_store_admin_web/features/products/presentation/cubit/product_media/admin_product_media_state.dart';

import '../../products_test_helpers.dart';

void main() {
  group('AdminProductMediaCubit', () {
    late FakeAdminProductsRepository repository;

    setUp(() {
      repository = FakeAdminProductsRepository();
    });

    AdminProductMediaCubit buildCubit() {
      return AdminProductMediaCubit(
        GetAdminProductMediaUseCase(repository),
        UploadAdminProductMediaImagesUseCase(repository),
        DeleteAdminProductMediaImageUseCase(repository),
        ReorderAdminProductMediaTargetUseCase(repository),
        SetAdminProductMediaPrimaryUseCase(repository),
      );
    }

    blocTest<AdminProductMediaCubit, AdminProductMediaState>(
      'loads bootstrap without storing effective image expansion state',
      build: buildCubit,
      act: (cubit) => cubit.load(10),
      expect: () => [
        isA<AdminProductMediaState>().having(
          (state) => state.isLoading,
          'isLoading',
          true,
        ),
        isA<AdminProductMediaState>()
            .having((state) => state.isLoading, 'isLoading', false)
            .having((state) => state.media?.targets, 'targets', hasLength(2)),
      ],
      verify: (_) => expect(repository.getMediaCalls, 1),
    );

    blocTest<AdminProductMediaCubit, AdminProductMediaState>(
      'upload success replaces media and marks route as changed',
      build: buildCubit,
      act: (cubit) async {
        var changed = false;
        cubit.attachChangedCallback(() => changed = true);
        await cubit.load(10);
        final target = cubit.state.media!.targets.first;
        await cubit.upload(
          target: target,
          files: const [
            AdminProductMediaUploadFileEntity(
              name: 'new.jpg',
              bytes: [1, 2],
              size: 2,
              mimeType: 'image/jpeg',
            ),
          ],
        );
        expect(changed, isTrue);
      },
      verify: (cubit) {
        expect(repository.uploadMediaCalls, 1);
        expect(repository.lastMediaScope, AdminProductMediaScope.item);
        expect(cubit.state.hasSuccessfulMutation, isTrue);
        expect(cubit.state.effect, isA<AdminProductMediaSuccessEffect>());
      },
    );

    blocTest<AdminProductMediaCubit, AdminProductMediaState>(
      'delete with storageDeleted false is still a successful mutation',
      build: () {
        repository.mediaMutationResult = AppResult.success(
          testProductMediaMutationResult(
            operation: AdminProductMediaOperation.delete,
            deletedImageId: 501,
            storageDeleted: false,
          ),
        );
        return buildCubit();
      },
      act: (cubit) async {
        await cubit.load(10);
        await cubit.deleteImage(
          target: cubit.state.media!.targets.first,
          imageId: 501,
        );
      },
      verify: (cubit) {
        expect(repository.deleteMediaCalls, 1);
        expect(cubit.state.hasSuccessfulMutation, isTrue);
        expect(cubit.state.effect?.message, contains('ما زال مستخدمًا'));
      },
    );

    blocTest<AdminProductMediaCubit, AdminProductMediaState>(
      'duplicate mutation is rejected while another mutation is active',
      build: () {
        repository.mediaMutationCompleter =
            Completer<AppResult<AdminProductMediaMutationResultEntity>>();
        return buildCubit();
      },
      act: (cubit) async {
        await cubit.load(10);
        final target = cubit.state.media!.targets.first;
        final first = cubit.setPrimary(target: target, imageId: 501);
        await Future<void>.delayed(Duration.zero);
        await cubit.deleteImage(target: target, imageId: 501);
        repository.mediaMutationCompleter!.complete(
          AppResult.success(
            testProductMediaMutationResult(
              operation: AdminProductMediaOperation.primary,
            ),
          ),
        );
        await first;
      },
      verify: (cubit) {
        expect(repository.primaryMediaCalls, 1);
        expect(repository.deleteMediaCalls, 0);
        expect(cubit.state.effect, isA<AdminProductMediaSuccessEffect>());
      },
    );

    blocTest<AdminProductMediaCubit, AdminProductMediaState>(
      'order conflict emits conflict effect and refreshes bootstrap',
      build: () {
        repository.mediaMutationResult = const AppResult.failure(
          AppFailure.conflict(
            message: 'Conflict',
            errorCode: BackendErrorCode.mediaOrderConflict,
          ),
        );
        return buildCubit();
      },
      act: (cubit) async {
        await cubit.load(10);
        await cubit.reorder(
          target: cubit.state.media!.targets.first,
          imageIds: [502, 501],
        );
      },
      verify: (cubit) {
        expect(repository.reorderMediaCalls, 1);
        expect(repository.getMediaCalls, 2);
        expect(
          cubit.state.operationFor('item:10')?.errorMessage,
          contains('تغير ترتيب الصور'),
        );
      },
    );
  });
}

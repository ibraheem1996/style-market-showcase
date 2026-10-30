import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:my_project/core/network/interceptors/audience_interceptor.dart';
import 'package:my_project/features/audience/domain/entities/audience_entity.dart';
import 'package:my_project/features/audience/presentation/store/audience_store.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    final store = Get.put(AudienceStore());
    store.selectedAudience.value = const AudienceEntity(
      audienceId: 5,
      nameAr: 'اختبار',
      nameEn: 'Test',
      sortOrder: 1,
    );
  });

  tearDown(Get.reset);

  test('adds the selected audience when the request has no override', () async {
    final options = RequestOptions(path: '/recommendations');

    final resolved = await _intercept(options);

    expect(resolved.headers['X-Audience-Id'], 5);
  });

  test('preserves an explicit audience override', () async {
    final options = RequestOptions(
      path: '/recommendations',
      headers: {'X-Audience-Id': 9},
    );

    final resolved = await _intercept(options);

    expect(resolved.headers['X-Audience-Id'], 9);
  });
}

Future<RequestOptions> _intercept(RequestOptions options) async {
  final handler = _TestRequestInterceptorHandler();
  AudienceInterceptor().onRequest(options, handler);
  return handler.result;
}

class _TestRequestInterceptorHandler extends RequestInterceptorHandler {
  Future<RequestOptions> get result async => (await future).data;
}

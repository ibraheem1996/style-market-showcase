import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../../features/audience/presentation/store/audience_store.dart';

class AudienceInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (Get.isRegistered<AudienceStore>()) {
      final id = Get.find<AudienceStore>().selectedAudience.value?.audienceId;
      if (id != null && options.headers['X-Audience-Id'] == null) {
        options.headers['X-Audience-Id'] = id;
      }
    }
    super.onRequest(options, handler);
  }
}

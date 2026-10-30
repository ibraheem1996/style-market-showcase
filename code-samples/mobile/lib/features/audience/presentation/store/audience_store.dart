import 'package:get/get.dart';

import '../../domain/entities/audience_entity.dart';

class AudienceStore extends GetxService {
  final RxList<AudienceEntity> audiences = <AudienceEntity>[].obs;
  final Rx<AudienceEntity?> selectedAudience = Rx<AudienceEntity?>(null);
}

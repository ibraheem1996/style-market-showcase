import '../../../../../core/constants/app_pref_key.dart';
import '../../../../../core/storage/prefs_storage.dart';
import 'audience_local_datasource.dart';

class AudienceLocalDataSourceImpl implements AudienceLocalDataSource {
  AudienceLocalDataSourceImpl(this._prefs);

  final PrefsStorage _prefs;

  @override
  int? getSelectedAudienceId() =>
      _prefs.getInt(AppStorageKey.selectedAudienceId);

  @override
  Future<bool> setSelectedAudienceId(int id) =>
      _prefs.setInt(AppStorageKey.selectedAudienceId, id);
}

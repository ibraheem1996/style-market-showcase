import 'dart:convert';

import 'package:my_project/core/storage/prefs_storage.dart';

import '../../recently_viewed_constants.dart';
import '../models/cards_by_keys_request_model.dart';

abstract class RecentlyViewedLocalDataSource {
  Future<List<RecentlyViewedKeyModel>> getKeys();
  Future<void> addKey(RecentlyViewedKeyModel key);
  Future<void> clearKeys();
}

class RecentlyViewedLocalDataSourceImpl
    implements RecentlyViewedLocalDataSource {
  final PrefsStorage _prefs;

  static const String _kKey = 'recently_viewed_keys_v2';

  RecentlyViewedLocalDataSourceImpl(this._prefs);

  @override
  Future<List<RecentlyViewedKeyModel>> getKeys() async {
    final raw = _prefs.getString(_kKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);

      if (decoded is! List<dynamic>) return [];

      final iterable = decoded
          .map((e) => _decodeEntry(e))
          .whereType<RecentlyViewedKeyModel>();

      final keys = _normalize(iterable);
      final normalizedRaw = _encode(keys);
      if (normalizedRaw != raw) {
        await _prefs.setString(_kKey, normalizedRaw);
      }
      return keys;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> addKey(RecentlyViewedKeyModel key) async {
    if (!_isValid(key)) return;

    final keys = _normalize([key, ...await getKeys()]);
    await _prefs.setString(_kKey, _encode(keys));
  }

  @override
  Future<void> clearKeys() async {
    await _prefs.setString(_kKey, '[]');
  }

  RecentlyViewedKeyModel? _decodeEntry(dynamic value) {
    if (value is! Map) return null;
    try {
      final key = RecentlyViewedKeyModel.fromJson(
        value as Map<String, dynamic>,
      );
      return _isValid(key) ? key : null;
    } catch (_) {
      return null;
    }
  }

  List<RecentlyViewedKeyModel> _normalize(
    Iterable<RecentlyViewedKeyModel> values,
  ) {
    final seen = <String>{};
    final normalized = <RecentlyViewedKeyModel>[];

    for (final key in values) {
      if (!_isValid(key)) continue;
      final identity = '${key.itemId}:${key.colorGroupId ?? 'null'}';
      if (seen.contains(identity)) continue;
      seen.add(identity);
      normalized.add(key);
      if (normalized.length == RecentlyViewedConstants.maxItems) break;
    }
    return normalized;
  }

  bool _isValid(RecentlyViewedKeyModel key) {
    return key.itemId > 0 &&
        (key.colorGroupId == null || key.colorGroupId! > 0);
  }

  String _encode(List<RecentlyViewedKeyModel> keys) {
    return jsonEncode(keys.map((key) => key.toJson()).toList());
  }
}

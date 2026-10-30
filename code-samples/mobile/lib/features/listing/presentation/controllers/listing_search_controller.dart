import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class ListingSearchController extends GetxController {
  static const debounceDuration = Duration(milliseconds: 500);

  final textController = TextEditingController();
  final focusNode = FocusNode();
  final query = ''.obs;
  final isSearchVisible = false.obs;

  Timer? _debounce;
  String _lastEmittedQuery = '';

  void showSearch() {
    isSearchVisible.value = true;
    focusNode.requestFocus();
  }

  void hideSearch({required ValueChanged<String> onQueryReady}) {
    clear(onQueryReady: onQueryReady);
    isSearchVisible.value = false;
    focusNode.unfocus();
  }

  void onQueryChanged(
    String value, {
    required ValueChanged<String> onQueryReady,
  }) {
    query.value = value;
    final normalized = normalizeQuery(value);

    _debounce?.cancel();
    if (normalized.isEmpty) {
      _emitIfChanged('', onQueryReady);
      return;
    }

    _debounce = Timer(debounceDuration, () {
      _emitIfChanged(normalized, onQueryReady);
    });
  }

  static String normalizeQuery(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  void clear({required ValueChanged<String> onQueryReady}) {
    _debounce?.cancel();
    textController.clear();
    query.value = '';
    _emitIfChanged('', onQueryReady);
  }

  void _emitIfChanged(String normalized, ValueChanged<String> onQueryReady) {
    if (normalized == _lastEmittedQuery) return;
    _lastEmittedQuery = normalized;
    onQueryReady(normalized);
  }

  @override
  void onClose() {
    _debounce?.cancel();
    textController.dispose();
    focusNode.dispose();
    super.onClose();
  }
}

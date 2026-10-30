// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

// Project imports:
import '../config/app_config.dart';
import 'logger_service.dart';

class CrashlyticsService {
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  static bool _globalHandlersConfigured = false;

  //! Check if crashlytics should be enabled (only in Production or Staging, not Debug)
  static bool get _isEnabled =>
      !AppConfig.isDebugMode && (AppConfig.isProduction || AppConfig.isStaging);

  /// Configures Crashlytics collection and the application's global handlers.
  static Future<void> configureGlobalErrorHandling() async {
    final crashlytics = FirebaseCrashlytics.instance;
    await crashlytics.setCrashlyticsCollectionEnabled(_isEnabled);

    if (!_isEnabled || _globalHandlersConfigured) return;

    FlutterError.onError = (details) {
      unawaited(_recordFlutterFatalError(details));
    };
    WidgetsBinding.instance.platformDispatcher.onError = (error, stackTrace) {
      unawaited(
        _recordFatalError(error, stackTrace, reason: 'Uncaught platform error'),
      );
      return true;
    };
    _globalHandlersConfigured = true;
  }

  /// Reports a caught startup failure without blocking the recovery UI.
  static Future<void> recordStartupFailure(
    Object error,
    StackTrace stackTrace,
  ) async {
    if (AppConfig.isDebugMode) {
      LoggerService.error('Application startup failed', error, stackTrace);
      return;
    }

    if (!_isEnabled) return;

    await _recordFatalError(
      error,
      stackTrace,
      reason: 'Application startup failed',
    );
  }

  static Future<void> _recordFlutterFatalError(
    FlutterErrorDetails details,
  ) async {
    try {
      await FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    } catch (_) {
      // Error reporting must not create another unhandled application error.
    }
  }

  static Future<void> _recordFatalError(
    Object error,
    StackTrace stackTrace, {
    required String reason,
  }) async {
    try {
      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        fatal: true,
        reason: reason,
      );
    } catch (_) {
      // Error reporting must not block startup recovery or recurse globally.
    }
  }

  Future<void> logError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
  }) async {
    final safeError = _safeError(error);

    if (AppConfig.isDebugMode) {
      LoggerService.error(
        "Crashlytics: Error logged${reason != null ? ' - $reason' : ''} (disabled in debug)",
        safeError,
        stackTrace,
      );
      return;
    }

    if (!_isEnabled) return;

    await _crashlytics.recordError(
      safeError,
      stackTrace,
      reason: reason,
      fatal: false,
    );
  }

  Object _safeError(dynamic error) {
    if (error is DioException) {
      return 'DioException(type: ${error.type.name}, method: ${error.requestOptions.method}, statusCode: ${error.response?.statusCode}, path: ${Uri.parse(error.requestOptions.path).path})';
    }

    return error;
  }

  Future<void> logMessage(String message) async {
    if (AppConfig.isDebugMode) {
      LoggerService.info("Crashlytics: $message (disabled in debug)");
      return;
    }

    if (!_isEnabled) return;

    await _crashlytics.log(message);
  }

  Future<void> setUserId(String userId) async {
    if (AppConfig.isDebugMode) {
      LoggerService.info(
        "Crashlytics: Set User ID - $userId (disabled in debug)",
      );
      return;
    }

    if (!_isEnabled) return;

    await _crashlytics.setUserIdentifier(userId);
  }

  Future<void> setCustomKey(String key, dynamic value) async {
    if (AppConfig.isDebugMode) {
      LoggerService.info(
        "Crashlytics: Set Custom Key - $key: $value (disabled in debug)",
      );
      return;
    }

    if (!_isEnabled) return;

    await _crashlytics.setCustomKey(key, value);
  }
}

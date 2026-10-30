import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../utils/responsive/android_orientation_display_info.dart';
import '../utils/responsive/app_orientation_policy.dart';


Size _logicalDisplaySizeFromView(FlutterView view) {
  final display = view.display;
  return Size(
    display.size.width / display.devicePixelRatio,
    display.size.height / display.devicePixelRatio,
  );
}

/// Applies the compact-display portrait policy on Android window changes.
///
/// Evaluations are serialized so rapid density, folding, or display changes
/// cannot let an older classification overwrite the latest platform request.
class AppOrientationScope extends StatefulWidget {
  const AppOrientationScope({
    required this.child,
    this.preferredOrientationsSetter = SystemChrome.setPreferredOrientations,
    this.logicalDisplaySizeReader = _logicalDisplaySizeFromView,
    this.androidDisplayInfoLoader,
    this.platform,
    super.key,
  });

  final Widget child;
  final Future<void> Function(List<DeviceOrientation> orientations)
  preferredOrientationsSetter;
  final  Size Function(FlutterView view) logicalDisplaySizeReader;
  final  Future<AndroidOrientationDisplayInfo?> Function()? androidDisplayInfoLoader;
  final TargetPlatform? platform;

  @override
  State<AppOrientationScope> createState() => _AppOrientationScopeState();
}

class _AppOrientationScopeState extends State<AppOrientationScope>
    with WidgetsBindingObserver {
  FlutterView? _view;
  AppOrientationDecision? _appliedDecision;
  bool _evaluationPending = false;
  bool _evaluationRunning = false;
  int _evaluationRevision = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _view = View.maybeOf(context);
    _requestEvaluation();
  }

  @override
  void didChangeMetrics() {
    _requestEvaluation();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _requestEvaluation();
    }
  }

  @override
  void dispose() {
    _evaluationRevision++;
    _evaluationPending = false;
    _view = null;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _requestEvaluation() {
    if (!mounted) return;

    _evaluationRevision++;
    _evaluationPending = true;
    if (_evaluationRunning) return;

    unawaited(_runEvaluationLoop());
  }

  Future<void> _runEvaluationLoop() async {
    _evaluationRunning = true;
    try {
      while (mounted && _evaluationPending) {
        _evaluationPending = false;
        final revision = _evaluationRevision;
        final view = _view;
        if (view == null) continue;

        final platform = widget.platform ?? defaultTargetPlatform;

        final logicalDisplaySize = widget.logicalDisplaySizeReader(view);
        AndroidOrientationDisplayInfo? androidDisplayInfo;

        if (platform == TargetPlatform.android) {
          try {
            final loader =
                widget.androidDisplayInfoLoader ??
                const AndroidOrientationDisplayInfoReader().read;
            androidDisplayInfo = await loader();
          } on Object {
            androidDisplayInfo = null;
          }
        }

        if (!mounted) return;
        if (revision != _evaluationRevision) {
          _evaluationPending = true;
          continue;
        }

        final decision = AppOrientationPolicy.decisionFor(
          platform: platform,
          logicalDisplaySize: logicalDisplaySize,
          androidDisplayInfo: androidDisplayInfo,
        );
        final orientations = decision.preferredOrientations;
        if (orientations == null || decision == _appliedDecision) continue;

        try {
          await widget.preferredOrientationsSetter(orientations);
        } on Object {
          continue;
        }

        if (!mounted) return;
        if (revision != _evaluationRevision) {
          _evaluationPending = true;
          continue;
        }

        _appliedDecision = decision;
      }
    } finally {
      _evaluationRunning = false;
      if (mounted && _evaluationPending) {
        unawaited(_runEvaluationLoop());
      }
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

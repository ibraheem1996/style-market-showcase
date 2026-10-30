import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class RxEventListener<T> extends StatefulWidget {
  const RxEventListener({
    super.key,
    required this.child,
    required this.rxnEvent,
    required this.clearEvent,
    required this.onEvent,
  });

  final Widget child;
  final RxInterface<T?> rxnEvent;
  final void Function() clearEvent;
  final Future<void> Function(T event) onEvent;

  @override
  State<RxEventListener<T>> createState() => _RxEventListenerState<T>();
}

class _RxEventListenerState<T> extends State<RxEventListener<T>> {
  Worker? worker;
  bool _isHandlingEvent = false;

  @override
  void initState() {
    super.initState();

    worker = ever<T?>(widget.rxnEvent, (event) {
      if (event == null) return;
      _handleEventSafely(event);
    });
  }

  Future<void> _handleEventSafely(T event) async {
    if (_isHandlingEvent) return;
    _isHandlingEvent = true;

    Future<void> run() async {
      if (!mounted) {
        _isHandlingEvent = false;
        return;
      }

      try {
        await widget.onEvent(event);
      } finally {
        if (mounted) {
          widget.clearEvent();
        }
        _isHandlingEvent = false;
      }
    }

    final phase = SchedulerBinding.instance.schedulerPhase;

    final isUnsafePhase =
        phase == SchedulerPhase.persistentCallbacks ||
        phase == SchedulerPhase.transientCallbacks ||
        phase == SchedulerPhase.midFrameMicrotasks;

    if (isUnsafePhase) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        run();
      });
    } else {
      Future.microtask(run);
    }
  }

  @override
  void dispose() {
    worker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:firebase_core/firebase_core.dart';

// Project imports:
import '../core/config/app_config.dart';
import '../core/services/crashlytics_service.dart';
import '../firebase_options.dart';
import 'app.dart';
import 'app_di.dart';
import 'startup_failure_view.dart';

void bootstrap() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(AppBootstrap(initialize: initializeApplication, app: const MyApp()));
}

Future<void> initializeApplication({required bool resetDependencies}) async {
  try {
    if (resetDependencies) {
      await resetAppDependenciesForRetry();
    }

    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    await CrashlyticsService.configureGlobalErrorHandling();
    AppConfig.validateRuntimeConfiguration();
    await setupAppDependencies();
  } catch (error, stackTrace) {
    await CrashlyticsService.recordStartupFailure(error, stackTrace);
    Error.throwWithStackTrace(error, stackTrace);
  }
}

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key, required this.initialize, required this.app});

  final Future<void> Function({required bool resetDependencies}) initialize;
  final Widget app;

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  late Future<void> _initialization;
  bool _retryInProgress = false;

  @override
  void initState() {
    super.initState();
    _initialization = _initialize(resetDependencies: false);
  }

  Future<void> _initialize({required bool resetDependencies}) async {
    await widget.initialize(resetDependencies: resetDependencies);
  }

  void _retry() {
    if (_retryInProgress) return;
    _retryInProgress = true;

    setState(() {
      _initialization = _initialize(
        resetDependencies: true,
      ).whenComplete(() => _retryInProgress = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _StartupLoadingView();
        }

        if (snapshot.hasError) {
          return StartupFailureView(onRetry: _retry);
        }

        return widget.app;
      },
    );
  }
}

class _StartupLoadingView extends StatelessWidget {
  const _StartupLoadingView();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: Center(child: CircularProgressIndicator.adaptive())),
    );
  }
}

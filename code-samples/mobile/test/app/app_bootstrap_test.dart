import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/app/bootstrap.dart';

void main() {
  testWidgets('startup failure retries once and shows the app after success', (
    tester,
  ) async {
    tester.platformDispatcher.localeTestValue = const Locale('en');
    addTearDown(tester.platformDispatcher.clearLocaleTestValue);

    final retryCompletion = Completer<void>();
    final resetRequests = <bool>[];

    Future<void> initialize({required bool resetDependencies}) async {
      resetRequests.add(resetDependencies);
      if (!resetDependencies) {
        throw StateError('startup failed');
      }
      await retryCompletion.future;
    }

    await tester.pumpWidget(
      AppBootstrap(
        initialize: initialize,
        app: const MaterialApp(home: Text('ready')),
      ),
    );
    await tester.pump();

    expect(find.text('فشل بدء التطبيق'), findsOneWidget);
    expect(find.text('حاول مرة أخرى'), findsOneWidget);
    expect(resetRequests, [false]);

    await tester.tap(find.text('حاول مرة أخرى'));
    await tester.tap(find.text('حاول مرة أخرى'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('حاول مرة أخرى'), findsNothing);
    expect(resetRequests, [false, true]);

    retryCompletion.complete();
    await tester.pump();
    await tester.pump();

    expect(find.text('ready'), findsOneWidget);
  });
}

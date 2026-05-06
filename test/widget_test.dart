import 'package:dspora/SplashScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('launch warm-up starts immediately before login flow', (
    WidgetTester tester,
  ) async {
    final callOrder = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        home: SplashScreen(
          enableVideo: false,
          navigationDelay: Duration.zero,
          warmUpOverride: () async {
            callOrder.add('warmup');
          },
          isLoggedInOverride: () async {
            callOrder.add('auth');
            return false;
          },
        ),
      ),
    );

    await tester.pump();
    await tester.pump();

    expect(callOrder, isNotEmpty);
    expect(callOrder.first, 'warmup');
    expect(callOrder.where((call) => call == 'warmup').length, 1);
  });
}

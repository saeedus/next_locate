import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:next_locate/app.dart';

void main() {
  testWidgets('Smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the welcome text is present.
    expect(find.text('Welcome to NextLocate!'), findsOneWidget);
  });
}

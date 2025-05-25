// This is a basic Flutter widget test.

import 'package:flutter_test/flutter_test.dart';
import 'package:r6box/main.dart';

void main() {
  testWidgets('App starts successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const R6BoxApp());

    // Wait for the app to settle
    await tester.pumpAndSettle();

    // The test passes if the app starts without errors
    expect(true, isTrue);
  });
}

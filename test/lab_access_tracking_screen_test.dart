import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:robolearn/screens/committee/lab_access_tracking_screen.dart';

void main() {
  testWidgets('Lab access tracker screen shows heading and controls', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LabAccessTrackingScreen()));

    expect(find.text('LAB ACCESS TRACKER'), findsOneWidget);
    expect(find.text('Log access activity'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
  });
}

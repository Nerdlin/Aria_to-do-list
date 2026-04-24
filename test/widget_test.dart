import 'package:aria_productivity_app/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Splash screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

    expect(find.text('Aria'), findsOneWidget);
    expect(find.text('AI-Powered Productivity'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}

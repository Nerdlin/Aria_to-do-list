import 'package:flutter_test/flutter_test.dart';

import 'package:aria_productivity_app/main.dart';

void main() {
  testWidgets('App starts with splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const AriaApp());
    expect(find.text('Aria'), findsOneWidget);
    expect(find.text('AI-Powered Productivity'), findsOneWidget);

    // Let splash timer finish and navigate to onboarding.
    await tester.pump(const Duration(milliseconds: 3000));
    await tester.pumpAndSettle();
    expect(find.text('Smart Daily Planning'), findsOneWidget);
  });
}

// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:kissan/main.dart';
import 'package:kissan/screens/splash_screen.dart';
import 'package:kissan/screens/language_initilalizer.dart';

void main() {
  testWidgets('App launches to SplashScreen', (WidgetTester tester) async {
    // Pump the actual app entry widget.
    await tester.pumpWidget(const BuyerStart());

    // Allow initial timers/animations to start.
    await tester.pump();

    // Verify that the splash screen is shown initially.
    expect(find.byType(SplashScreen), findsOneWidget);

    // Fast-forward the 3s splash timer and settle navigation.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // After splash, we should navigate to the language initializer.
    expect(find.byType(LanguageInitializerScreen), findsOneWidget);
  });
}

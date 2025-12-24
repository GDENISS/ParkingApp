import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zorem/main.dart';

void main() {
  testWidgets('SplashScreen displays logo and animates', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

    // Verify logo is displayed
    expect(find.byType(Image), findsOneWidget);
    
    // Verify app name is displayed
    expect(find.text('ZOREM'), findsOneWidget);

    // Wait for animation
    await tester.pump(const Duration(seconds: 1));
    
    // Verify animation completes
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('LoginPage displays all input fields', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    // Verify all text fields are present
    expect(find.byType(TextField), findsNWidgets(4));
    
    // Verify labels
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Car Model'), findsOneWidget);
    expect(find.text('License Plate'), findsOneWidget);
    
    // Verify confirm button
    expect(find.text('Confirm'), findsOneWidget);
  });

  testWidgets('RoundLabelButton displays icon and label', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RoundLabelButton(
            icon: Icons.add,
            label: 'Test',
            onPressed: () {},
          ),
        ),
      ),
    );

    // Verify icon is displayed
    expect(find.byIcon(Icons.add), findsOneWidget);
    
    // Verify label is displayed
    expect(find.text('Test'), findsOneWidget);
  });

  testWidgets('ElapsedTimeWidget displays formatted time', (WidgetTester tester) async {
    final testTime = DateTime.now().subtract(const Duration(minutes: 5, seconds: 30));
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ElapsedTimeWidget(createdAt: testTime),
        ),
      ),
    );

    // Verify time is displayed
    expect(find.textContaining('Released'), findsOneWidget);
    expect(find.textContaining(':'), findsOneWidget);
  });
}

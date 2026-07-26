import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:emi_calculator/core/services/notification_service.dart';

void main() {
  group('NotificationService', () {
    testWidgets('show displays a floating SnackBar with the message',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          scaffoldMessengerKey: NotificationService.scaffoldMessengerKey,
          home: const Scaffold(body: SizedBox.expand()),
        ),
      );

      NotificationService.show('Hello from tests');
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Hello from tests'), findsOneWidget);
    });

    testWidgets('consecutive identical messages are debounced',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          scaffoldMessengerKey: NotificationService.scaffoldMessengerKey,
          home: const Scaffold(body: SizedBox.expand()),
        ),
      );

      NotificationService.show('Only once');
      NotificationService.show('Only once');
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Only once'), findsOneWidget);
    });

    testWidgets('error messages bypass debounce and replace current SnackBar',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          scaffoldMessengerKey: NotificationService.scaffoldMessengerKey,
          home: const Scaffold(body: SizedBox.expand()),
        ),
      );

      NotificationService.show('Initial message');
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Initial message'), findsOneWidget);

      NotificationService.show('Error message', isError: true);
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Initial message'), findsNothing);
      expect(find.text('Error message'), findsOneWidget);
    });

    testWidgets('hide clears visible SnackBars', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          scaffoldMessengerKey: NotificationService.scaffoldMessengerKey,
          home: const Scaffold(body: SizedBox.expand()),
        ),
      );

      NotificationService.show('Will be hidden');
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Will be hidden'), findsOneWidget);

      NotificationService.hide();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Will be hidden'), findsNothing);
    });

    testWidgets('error SnackBar uses red background',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          scaffoldMessengerKey: NotificationService.scaffoldMessengerKey,
          home: const Scaffold(body: SizedBox.expand()),
        ),
      );

      NotificationService.show('Error', isError: true);
      await tester.pump(const Duration(milliseconds: 500));

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.backgroundColor, Colors.red.shade800);
    });
  });
}

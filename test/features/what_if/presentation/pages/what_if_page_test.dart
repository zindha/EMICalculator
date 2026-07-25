import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:emi_calculator/features/what_if/presentation/pages/what_if_page.dart';

void main() {
  group('WhatIfPage', () {
    testWidgets('renders all main sections', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: WhatIfPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('What If Simulator'), findsOneWidget);
      expect(find.text('Baseline Scenario'), findsOneWidget);
      expect(find.text('New Scenario'), findsOneWidget);
      expect(find.text('Difference'), findsOneWidget);
      expect(find.text('Adjust Scenario'), findsOneWidget);
      expect(find.text('Breakdown'), findsOneWidget);
    });

    testWidgets('reset button is tappable without errors', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: WhatIfPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.refresh_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Baseline Scenario'), findsOneWidget);
      expect(find.text('New Scenario'), findsOneWidget);
    });

    testWidgets('changing loan amount updates the diff card', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: WhatIfPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No Difference'), findsOneWidget);

      // Change the loan amount to a higher value.
      final loanAmountField = find.byType(TextField).first;
      await tester.tap(loanAmountField);
      await tester.pump();
      await tester.enterText(loanAmountField, '1000000');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.text('Extra Cost'), findsOneWidget);
      expect(
        find.text('The new scenario is more expensive overall.'),
        findsOneWidget,
      );
    });
  });
}

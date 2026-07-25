import 'package:emi_calculator/features/calculator/presentation/widgets/tenure_toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TenureToggle', () {
    testWidgets('toggles between months and years', (tester) async {
      bool? selectedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TenureToggle(
              inYears: false,
              onChanged: (value) => selectedValue = value,
            ),
          ),
        ),
      );

      expect(find.text('Months'), findsOneWidget);
      expect(find.text('Years'), findsOneWidget);

      await tester.tap(find.text('Years'));
      await tester.pump();

      expect(selectedValue, isTrue);
    });
  });
}

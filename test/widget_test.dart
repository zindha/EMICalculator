import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:emi_calculator/app.dart';

void main() {
  testWidgets('App should render', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(
      child: EmiCalculatorApp(),
    ));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

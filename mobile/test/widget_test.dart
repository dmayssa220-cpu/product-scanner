// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:product_scanner/main.dart';

void main() {
  testWidgets('Home screen opens the scanner', (WidgetTester tester) async {
    await tester.pumpWidget(const ProductScannerApp());

    expect(find.text('Product Scanner'), findsOneWidget);
    expect(find.text('Scannez ou recherchez un produit'), findsOneWidget);

    await tester.tap(find.text('Scanner un code-barres'));
    await tester.pumpAndSettle();

    expect(find.text('Le scanner sera intégré en Phase M2'), findsOneWidget);
  });
}

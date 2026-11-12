import 'package:flutter_test/flutter_test.dart';
import 'package:product_scanner/main.dart';

void main() {
  testWidgets('Home screen opens the scanner', (WidgetTester tester) async {
    await tester.pumpWidget(const ProductScannerApp());

    expect(find.text('Product Scanner'), findsOneWidget);
    expect(find.text('Scannez ou recherchez un produit'), findsOneWidget);

    await tester.tap(find.text('Scanner un code-barres'));
    await tester.pumpAndSettle();

    expect(find.text('Scanner un code-barres'), findsOneWidget);
  });
}

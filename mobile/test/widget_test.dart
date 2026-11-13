import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:product_scanner/main.dart';

void main() {
  testWidgets('Unauthenticated users are redirected to sign in',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const ProductScannerApp());
    await tester.pumpAndSettle();

    expect(find.text('Connexion'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);

    await tester.tap(find.text('Créer un compte'));
    await tester.pumpAndSettle();

    expect(find.text('Inscription'), findsOneWidget);
    expect(find.text("S'inscrire"), findsOneWidget);
  });
}

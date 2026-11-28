import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'core/router.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/favorites_repository.dart';
import 'data/repositories/history_repository.dart';
import 'data/repositories/identify_repository.dart';
import 'data/repositories/preferences_repository.dart';
import 'data/repositories/product_repository.dart';
import 'data/repositories/submissions_repository.dart';
import 'data/services/api_client.dart';
import 'data/services/token_storage.dart';
import 'data/ui/auth/auth_viewmodel.dart';
import 'ui/scan/scan_viewmodel.dart';
import 'core/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProductScannerApp());
}

class ProductScannerApp extends StatelessWidget {
  const ProductScannerApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<TokenStorage>(create: (_) => TokenStorage()),
        Provider<ApiClient>(
            create: (ctx) => ApiClient(storage: ctx.read<TokenStorage>())),
        ProxyProvider<ApiClient, AuthRepository>(
          update: (ctx, api, previous) =>
              AuthRepository(api, ctx.read<TokenStorage>()),
        ),
        ProxyProvider<ApiClient, ProductRepository>(
          update: (_, api, __) => ProductRepository(api),
        ),
        ProxyProvider<ApiClient, FavoritesRepository>(
          update: (_, api, __) => FavoritesRepository(api),
        ),
        ProxyProvider<ApiClient, HistoryRepository>(
          update: (_, api, __) => HistoryRepository(api),
        ),
        ProxyProvider<ApiClient, PreferencesRepository>(
          update: (_, api, __) => PreferencesRepository(api),
        ),
        ProxyProvider<ApiClient, SubmissionsRepository>(
          update: (_, api, __) => SubmissionsRepository(api),
        ),
        Provider<IdentifyRepository>(
          create: (ctx) =>
              IdentifyRepository(storage: ctx.read<TokenStorage>()),
        ),
        ChangeNotifierProvider<ScanViewModel>(
          create: (ctx) => ScanViewModel(ctx.read<ProductRepository>()),
        ),
        ChangeNotifierProvider<AuthViewModel>(
          create: (ctx) => AuthViewModel(ctx.read<AuthRepository>()),
        ),
      ],
      child: Builder(
        builder: (ctx) => MaterialApp.router(
          title: 'Product Scanner',
          theme: AppTheme.light(),
          routerConfig: buildRouter(ctx.read<AuthRepository>()),
        ),
      ),
    );
  }
}

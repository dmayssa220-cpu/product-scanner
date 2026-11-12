import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/router.dart';
import 'data/repositories/product_repository.dart';
import 'data/services/api_client.dart';
import 'ui/scan/scan_viewmodel.dart';

void main() {
  runApp(const ProductScannerApp());
}

class ProductScannerApp extends StatelessWidget {
  const ProductScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>(create: (_) => ApiClient()),
        ProxyProvider<ApiClient, ProductRepository>(
          update: (context, api, previous) => ProductRepository(api),
        ),
        ChangeNotifierProvider<ScanViewModel>(
          create: (context) => ScanViewModel(context.read<ProductRepository>()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Product Scanner',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        routerConfig: router,
      ),
    );
  }
}

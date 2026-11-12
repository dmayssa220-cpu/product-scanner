import 'package:go_router/go_router.dart';
import '../data/models/product.dart';
import '../data/ui/home/home_view.dart';
import '../ui/scan/scan_view.dart';
import '../ui/scan/product/product_view.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeView()),
    GoRoute(path: '/scan', builder: (context, state) => const ScanView()),
    GoRoute(
      path: '/product/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        final extra = state.extra;
        return ProductView(
          productId: id,
          initialProduct: extra is Product ? extra : null,
        );
      },
    ),
  ],
);

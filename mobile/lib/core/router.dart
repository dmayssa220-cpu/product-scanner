import 'package:go_router/go_router.dart';
import '../data/models/product.dart';
import '../data/repositories/auth_repository.dart';
import '../data/ui/auth/auth_view.dart';
import '../data/ui/home/home_view.dart';
import '../data/ui/scan/scan_view.dart';
import '../ui/home/history_view.dart';
import '../ui/scan/product/product_view.dart';

GoRouter buildRouter(AuthRepository authRepo) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final authenticated = await authRepo.isAuthenticated();
      final goingToAuth = state.matchedLocation == '/auth';
      if (!authenticated && !goingToAuth) return '/auth';
      if (authenticated && goingToAuth) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/auth', builder: (context, state) => const AuthView()),
      GoRoute(path: '/', builder: (context, state) => const HomeView()),
      GoRoute(path: '/scan', builder: (context, state) => const ScanView()),
      GoRoute(
          path: '/history', builder: (context, state) => const HistoryView()),
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
}

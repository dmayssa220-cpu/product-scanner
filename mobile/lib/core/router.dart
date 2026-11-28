import 'package:go_router/go_router.dart';
import '../data/models/product.dart';
import '../data/repositories/auth_repository.dart';
import '../data/ui/submissions/admin_view.dart';
import '../data/ui/auth/auth_view.dart';
import '../data/ui/favorites/favorites_view.dart';
import '../data/ui/home/home_view.dart';
import '../data/ui/preferences/preferences_view.dart';
import '../data/ui/scan/photo_scan_view.dart';
import '../ui/home/history_view.dart';
import '../ui/home/search_view.dart';
import '../ui/scan/product/product_view.dart';
import '../ui/scan/scan_view.dart';
import '../ui/compare/compare_view.dart';

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
      GoRoute(
        path: '/admin/submissions',
        builder: (_, __) => const SubmissionsAdminView(),
      ),
      GoRoute(path: '/scan', builder: (context, state) => const ScanView()),
      GoRoute(path: '/search', builder: (context, state) => const SearchView()),
      GoRoute(path: '/favorites', builder: (_, __) => const FavoritesView()),
      GoRoute(path: '/compare',builder: (context, state) {final list = state.extra as List<Product>;
    return CompareView(left: list[0], right: list[1]);
  },
),
      GoRoute(
        path: '/preferences',
        builder: (_, __) => const PreferencesView(),
      ),
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
      GoRoute(path: '/scan/photo', builder: (_, __) => const PhotoScanView()),
    ],
  );
}

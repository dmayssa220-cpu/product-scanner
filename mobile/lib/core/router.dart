import 'package:go_router/go_router.dart';
import '../data/ui/home/home_view.dart';
import '../data/ui/scan/scan_view.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeView()),
    GoRoute(path: '/scan', builder: (context, state) => const ScanView()),
  ],
);
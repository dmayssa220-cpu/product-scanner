import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../repositories/auth_repository.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final Future<bool> _isAdmin;

  @override
  void initState() {
    super.initState();
    _isAdmin = context.read<AuthRepository>().isAdmin();
  }

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthRepository>().logout();
    if (context.mounted) context.go('/auth');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Scanner'),
        actions: [
          IconButton(
            tooltip: 'Se déconnecter',
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border),
            tooltip: 'Favoris',
            onPressed: () => context.push('/favorites'),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.qr_code_scanner, size: 80),
                const SizedBox(height: 24),
                const Text(
                  'Scannez ou recherchez un produit',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: () => context.push('/scan'),
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Scanner un code-barres'),
                ),
                const SizedBox(height: 12),
                FilledButton.tonalIcon(
                  onPressed: () => context.push('/scan/photo'),
                  icon: const Icon(Icons.photo_camera),
                  label: const Text('Identifier par photo'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => context.push('/search'),
                  icon: const Icon(Icons.search),
                  label: const Text('Rechercher un produit'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => context.push('/history'),
                  icon: const Icon(Icons.history),
                  label: const Text('Historique des scans'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => context.push('/favorites'),
                  icon: const Icon(Icons.favorite),
                  label: const Text('Mes favoris'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => context.push('/preferences'),
                  icon: const Icon(Icons.tune),
                  label: const Text('Mes préférences'),
                ),
                const SizedBox(height: 12),
                FutureBuilder<bool>(
                  future: _isAdmin,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text(
                        'Impossible de vérifier le profil : ${snapshot.error}',
                        textAlign: TextAlign.center,
                      );
                    }
                    if (snapshot.data != true) return const SizedBox.shrink();
                    return OutlinedButton.icon(
                      onPressed: () => context.push('/admin/submissions'),
                      icon: const Icon(Icons.admin_panel_settings),
                      label: const Text('Modérer les soumissions'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

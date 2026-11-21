import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../repositories/favorites_repository.dart';
import '../../../ui/widgets/product_tile.dart';

class FavoritesView extends StatefulWidget {
  const FavoritesView({super.key});
  @override
  State<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> {
  late Future<List<Product>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<FavoritesRepository>().list();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes favoris')),
      body: FutureBuilder<List<Product>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Aucun favori.\nAppuyez sur le cœur d\'un produit pour l\'ajouter.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              setState(
                  () => _future = context.read<FavoritesRepository>().list());
              await _future;
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final product = items[i];
                return ProductTile(
                  product: product,
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () async {
                      await context
                          .read<FavoritesRepository>()
                          .remove(product.id);
                      setState(() =>
                          _future = context.read<FavoritesRepository>().list());
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

import 'package:material_ui/material_ui.dart';
import 'package:product_scanner/data/repositories/favorites_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../data/models/product.dart';
import '../../../data/repositories/product_repository.dart';
import 'product_viewmodel.dart';

class ProductView extends StatelessWidget {
  const ProductView({super.key, required this.productId, this.initialProduct});
  final String productId;
  final Product? initialProduct;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductViewModel(
        context.read<ProductRepository>(),
        initialProduct: initialProduct,
      )..load(productId),
      child: Consumer<ProductViewModel>(
        builder: (context, vm, _) {
          if (vm.loading) {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }
          if (vm.error != null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Produit')),
              body: Center(child: Text(vm.error!)),
            );
          }
          final p = vm.product!;
          return Scaffold(
            appBar: AppBar(
              title: Text(p.name),
              actions: [
                _FavoriteButton(productId: p.id),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _ScoreCard(score: p.score),
                const SizedBox(height: 16),
                _InfoRow(label: 'Marque', value: p.brand ?? '—'),
                _InfoRow(label: 'Catégorie', value: p.category ?? '—'),
                _InfoRow(label: 'Code-barres', value: p.barcode ?? '—'),
                if (p.processingLevel != null)
                  _InfoRow(
                      label: 'Niveau de transformation (NOVA)',
                      value: '${p.processingLevel}'),
                const SizedBox(height: 24),
                if (p.ingredients.isNotEmpty) ...[
                  const Text('Ingrédients',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...p.ingredients.map((i) => Text('• $i')),
                ],
                if (p.warnings.isNotEmpty)
                  Column(
                    children: p.warnings
                        .map((w) => Card(
                              color: Colors.red.shade50,
                              child: ListTile(
                                leading: const Icon(Icons.warning_amber_rounded,
                                    color: Colors.red),
                                title: Text(w.message,
                                    style: const TextStyle(color: Colors.red)),
                              ),
                            ))
                        .toList(),
                  ),
                if (p.warnings.isNotEmpty) const SizedBox(height: 16),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _openComparePicker(context, p),
              icon: const Icon(Icons.compare_arrows),
              label: const Text('Comparer'),
            ),
          );
        },
      ),
    );
  }
}

Future<void> _openComparePicker(
  BuildContext context,
  Product current,
) async {
  final favorites = await context.read<FavoritesRepository>().list();
  if (!context.mounted) return;
  final candidate = await showModalBottomSheet<Product>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: favorites.length <= 1
          ? const Padding(
              padding: EdgeInsets.all(24),
              child:
                  Text('Ajoutez un autre produit aux favoris pour comparer.'),
            )
          : ListView(
              shrinkWrap: true,
              children: favorites
                  .where((favorite) => favorite.id != current.id)
                  .map(
                    (favorite) => ListTile(
                      title: Text(favorite.name),
                      subtitle: Text(favorite.brand ?? ''),
                      onTap: () =>
                          Navigator.of(sheetContext).pop<Product>(favorite),
                    ),
                  )
                  .toList(),
            ),
    ),
  );
  if (candidate != null && context.mounted) {
    context.push('/compare', extra: [current, candidate]);
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.score});
  final ProductScore? score;

  @override
  Widget build(BuildContext context) {
    final productScore = score;
    if (productScore == null) return const SizedBox.shrink();
    final total = productScore.total;
    final color = total >= 75
        ? Colors.green
        : total >= 50
            ? Colors.orange
            : Colors.red;
    return Card(
      color: color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('${total.toStringAsFixed(0)}/100',
                style: TextStyle(
                    fontSize: 48, fontWeight: FontWeight.bold, color: color)),
            const Text('Score global'),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _SubScore(label: 'Nutrition', value: productScore.nutrition),
                _SubScore(label: 'Additifs', value: productScore.additives),
                _SubScore(
                    label: 'Transformation', value: productScore.processing),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SubScore extends StatelessWidget {
  const _SubScore({required this.label, required this.value});
  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value.toStringAsFixed(0),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _FavoriteButton extends StatefulWidget {
  const _FavoriteButton({required this.productId});
  final String productId;
  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton> {
  bool? _isFav;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = context.read<FavoritesRepository>();
    final v = await repo.isFavorite(widget.productId);
    if (mounted) setState(() => _isFav = v);
  }

  Future<void> _toggle() async {
    final repo = context.read<FavoritesRepository>();
    if (_isFav == true) {
      await repo.remove(widget.productId);
    } else {
      await repo.add(widget.productId);
    }
    setState(() => _isFav = !(_isFav ?? false));
  }

  @override
  Widget build(BuildContext context) {
    if (_isFav == null) return const SizedBox(width: 48, height: 48);
    return IconButton(
      icon: Icon(_isFav! ? Icons.favorite : Icons.favorite_border,
          color: _isFav! ? Colors.red : null),
      onPressed: _toggle,
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
              width: 140,
              child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

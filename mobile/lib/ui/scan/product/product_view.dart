import 'package:flutter/material.dart';
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
            appBar: AppBar(title: Text(p.name)),
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
              ],
            ),
          );
        },
      ),
    );
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

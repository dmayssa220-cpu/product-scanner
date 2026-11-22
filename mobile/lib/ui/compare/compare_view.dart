import 'package:material_ui/material_ui.dart';
import '../../core/theme.dart';
import '../../data/models/product.dart';

class CompareView extends StatefulWidget {
  const CompareView({super.key, required this.left, required this.right});
  final Product left;
  final Product right;

  @override
  State<CompareView> createState() => _CompareViewState();
}

class _CompareViewState extends State<CompareView> {
  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      appBar: AppBar(title: const Text('Comparaison')),
      body: isNarrow
          ? ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _ProductColumn(product: widget.left, other: widget.right),
                const SizedBox(height: 24),
                _ProductColumn(product: widget.right, other: widget.left),
              ],
            )
          : Row(
              children: [
                Expanded(
                    child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child:
                      _ProductColumn(product: widget.left, other: widget.right),
                )),
                const VerticalDivider(width: 1),
                Expanded(
                    child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child:
                      _ProductColumn(product: widget.right, other: widget.left),
                )),
              ],
            ),
    );
  }
}

class _ProductColumn extends StatelessWidget {
  const _ProductColumn({required this.product, required this.other});
  final Product product;
  final Product other;

  @override
  Widget build(BuildContext context) {
    final s = product.score;
    final os = other.score;
    if (s == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(product.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        if (product.brand != null)
          Text(product.brand!,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const SizedBox(height: 16),
        _ScoreRow(label: 'Score global', value: s.total, other: os?.total ?? 0),
        _ScoreRow(
            label: 'Nutrition', value: s.nutrition, other: os?.nutrition ?? 0),
        _ScoreRow(
            label: 'Additifs', value: s.additives, other: os?.additives ?? 0),
        _ScoreRow(
            label: 'Transformation',
            value: s.processing,
            other: os?.processing ?? 0),
        if (product.warnings.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text('Alertes', style: TextStyle(fontWeight: FontWeight.w600)),
          ...product.warnings.map((w) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text('⚠ ${w.message}',
                    style: const TextStyle(color: Colors.red)),
              )),
        ],
      ],
    );
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow(
      {required this.label, required this.value, required this.other});
  final String label;
  final double value;
  final double other;

  @override
  Widget build(BuildContext context) {
    final better = value > other;
    final color = AppTheme.scoreColor(value);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          if (better)
            const Icon(Icons.arrow_upward, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value.toStringAsFixed(0),
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/product.dart';
import 'score_badge.dart';

class ProductTile extends StatelessWidget {
  const ProductTile({super.key, required this.product, this.trailing});

  final Product product;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final score = product.score?.total ?? 0;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/product/${product.id}', extra: product),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ScoreBadge(score: score),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (product.brand != null)
                      Text(
                        product.brand!,
                        style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

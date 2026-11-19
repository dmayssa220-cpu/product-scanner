import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/models/product.dart';
import '../../data/repositories/product_repository.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final _queryController = TextEditingController();
  List<Product> _products = const [];
  bool _loading = false;
  bool _searched = false;
  String? _error;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _queryController.text.trim();
    if (query.length < 2) {
      setState(() {
        _error = 'Saisissez au moins 2 caractères.';
        _products = const [];
        _searched = false;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _searched = true;
    });
    try {
      final products = await context.read<ProductRepository>().search(query);
      if (mounted) setState(() => _products = products);
    } catch (error) {
      if (mounted) setState(() => _error = 'Recherche impossible : $error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rechercher un produit')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _queryController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _search(),
                    decoration: const InputDecoration(
                      labelText: 'Nom du produit ou marque',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  tooltip: 'Rechercher',
                  onPressed: _loading ? null : _search,
                  icon: const Icon(Icons.search),
                ),
              ],
            ),
          ),
          if (_loading) const LinearProgressIndicator(),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(_error!, textAlign: TextAlign.center),
            ),
          if (!_loading && _error == null && _searched && _products.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Aucun produit trouvé.'),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return ListTile(
                  leading: const Icon(Icons.inventory_2_outlined),
                  title: Text(product.name),
                  subtitle: Text(
                    [product.brand, product.category]
                        .whereType<String>()
                        .where((value) => value.isNotEmpty)
                        .join(' · '),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(
                    '/product/${product.id}',
                    extra: product,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

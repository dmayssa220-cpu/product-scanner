import 'package:flutter/foundation.dart';

import '../../../data/models/product.dart';
import '../../../data/repositories/product_repository.dart';

class ProductViewModel extends ChangeNotifier {
  ProductViewModel(this._repo, {this.initialProduct});

  final ProductRepository _repo;
  final Product? initialProduct;

  Product? product;
  bool loading = false;
  String? error;

  Future<void> load(String id) async {
    if (initialProduct != null) {
      product = initialProduct;
      notifyListeners();
      return;
    }
    loading = true;
    error = null;
    notifyListeners();
    try {
      product = await _repo.findById(id);
    } catch (exception) {
      error = exception.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}

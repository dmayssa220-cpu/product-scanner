import 'package:flutter/foundation.dart';

import '../../data/models/product.dart';
import '../../data/repositories/product_repository.dart';

class ScanViewModel extends ChangeNotifier {
  ScanViewModel(this._repository);

  final ProductRepository _repository;

  Product? product;
  bool loading = false;
  String? error;

  Future<void> onBarcodeDetected(String barcode) async {
    if (loading) return;

    loading = true;
    error = null;
    product = null;
    notifyListeners();

    try {
      product = await _repository.findByBarcode(barcode);
    } catch (exception) {
      error = exception.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void reset() {
    product = null;
    error = null;
    loading = false;
    notifyListeners();
  }
}

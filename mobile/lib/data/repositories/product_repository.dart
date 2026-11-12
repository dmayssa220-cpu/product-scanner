import '../models/product.dart';
import '../services/api_client.dart';

class ProductRepository {
  ProductRepository(this._api);
  final ApiClient _api;

  Future<Product> findByBarcode(String barcode) async {
    final data = await _api.get('/products/barcode/$barcode');
    return Product.fromJson(data);
  }

  Future<Product> findById(String id) async {
    final data = await _api.get('/products/$id');
    return Product.fromJson(data);
  }

  Future<List<Product>> search(String query) async {
    final data = await _api.getList('/products/search?q=$query');
    return data.map((e) => Product.fromJson(e)).toList();
  }
}
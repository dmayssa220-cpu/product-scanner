import '../models/product.dart';
import '../services/api_client.dart';

class FavoritesRepository {
  FavoritesRepository(this._api);
  final ApiClient _api;

  Future<List<Product>> list() async {
    final data = await _api.getList('/favorites', auth: true);
    return data.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> add(String productId) async {
    await _api.post('/favorites/$productId', {}, auth: true);
  }

  Future<void> remove(String productId) async {
    await _api.delete('/favorites/$productId', auth: true);
  }

  Future<bool> isFavorite(String productId) async {
    final data = await _api.get('/favorites/$productId/status', auth: true);
    return data['is_favorite'] as bool? ?? false;
  }
}
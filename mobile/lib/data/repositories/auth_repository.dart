import '../services/api_client.dart';
import '../services/token_storage.dart';

class AuthRepository {
  AuthRepository(this._api, this._storage);
  final ApiClient _api;
  final TokenStorage _storage;

  Future<void> register(String email, String password) async {
    final data = await _api.post('/auth/register', {'email': email, 'password': password});
    await _storage.save(data['access_token'] as String, email);
  }

  Future<void> login(String email, String password) async {
    final data = await _api.post('/auth/login', {'email': email, 'password': password});
    await _storage.save(data['access_token'] as String, email);
  }

  Future<void> logout() => _storage.clear();

  Future<bool> isAuthenticated() async => (await _storage.readToken()) != null;

  Future<String?> currentEmail() => _storage.readEmail();
}
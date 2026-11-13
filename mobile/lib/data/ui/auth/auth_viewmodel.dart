import 'package:flutter/foundation.dart';

import '../../repositories/auth_repository.dart';
import '../../services/api_client.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._repo);
  final AuthRepository _repo;

  bool loading = false;
  String? error;

  Future<bool> login(String email, String password) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      await _repo.login(email, password);
      return true;
    } on ApiException catch (e) {
      error = e.statusCode == 401 ? 'Identifiants invalides' : 'Erreur serveur';
      return false;
    } catch (_) {
      error = 'Erreur réseau';
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String email, String password) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      await _repo.register(email, password);
      return true;
    } on ApiException catch (e) {
      error = e.statusCode == 409 ? 'Email déjà utilisé' : 'Erreur serveur';
      return false;
    } catch (_) {
      error = 'Erreur réseau';
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}

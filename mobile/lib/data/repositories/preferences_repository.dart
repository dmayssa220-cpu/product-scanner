import '../services/api_client.dart';

class UserPreferences {
  UserPreferences({this.allergens = const [], this.diets = const []});
  final List<String> allergens;
  final List<String> diets;

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      UserPreferences(
        allergens: List<String>.from(json['allergens'] ?? []),
        diets: List<String>.from(json['diets'] ?? []),
      );

  Map<String, dynamic> toJson() => {'allergens': allergens, 'diets': diets};
}

class PreferencesRepository {
  PreferencesRepository(this._api);
  final ApiClient _api;

  Future<UserPreferences> get() async {
    final data = await _api.get('/users/me/preferences', auth: true);
    return UserPreferences.fromJson(data);
  }

  Future<void> save(UserPreferences prefs) async {
    await _api.put('/users/me/preferences', prefs.toJson(), auth: true);
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config.dart';
import 'token_storage.dart';

class ApiClient {
  ApiClient({http.Client? client, TokenStorage? storage})
      : _client = client ?? http.Client(),
        _storage = storage ?? TokenStorage();

  final http.Client _client;
  final TokenStorage _storage;

  Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await _storage.readToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<Map<String, dynamic>> get(String path, {bool auth = false}) async {
    final response = await _client.get(
      Uri.parse('${AppConfig.apiBaseUrl}$path'),
      headers: await _headers(auth: auth),
    );
    return _decodeMap(response);
  }

  Future<List<dynamic>> getList(String path, {bool auth = false}) async {
    final response = await _client.get(
      Uri.parse('${AppConfig.apiBaseUrl}$path'),
      headers: await _headers(auth: auth),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }
    throw ApiException(response.statusCode, response.body);
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body, {
    bool auth = false,
  }) async {
    final response = await _client.post(
      Uri.parse('${AppConfig.apiBaseUrl}$path'),
      headers: await _headers(auth: auth),
      body: jsonEncode(body),
    );
    return _decodeMap(response);
  }

  Future<void> delete(String path, {bool auth = false}) async {
    final response = await _client.delete(
      Uri.parse('${AppConfig.apiBaseUrl}$path'),
      headers: await _headers(auth: auth),
    );
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw ApiException(response.statusCode, response.body);
    }
  }

  Map<String, dynamic> _decodeMap(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw ApiException(response.statusCode, response.body);
  }
}

class ApiException implements Exception {
  ApiException(this.statusCode, this.body);
  final int statusCode;
  final String body;

  @override
  String toString() => 'ApiException($statusCode): $body';
}
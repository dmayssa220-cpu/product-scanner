import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../core/config.dart';
import '../services/token_storage.dart';

class IdentifyRepository {
  IdentifyRepository({TokenStorage? storage, http.Client? client})
      : _storage = storage ?? TokenStorage(),
        _client = client ?? http.Client();

  final TokenStorage _storage;
  final http.Client _client;

  Future<Map<String, dynamic>> identify(File image) async {
      final token = await _storage.readToken();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConfig.apiBaseUrl}/identify'),
      );
      if (token != null) request.headers['Authorization'] = 'Bearer $token';


      request.files.add(await http.MultipartFile.fromPath(
        'file',
        image.path,
        contentType: MediaType('image', 'jpeg'),
      ));

      final streamed = await _client.send(request);
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode != 200) {
        throw Exception('Erreur identification (${response.statusCode}) : ${response.body}');
      }
      return Map<String, dynamic>.from(
        (const JsonDecoder()).convert(response.body) as Map,
      );
    }
  }
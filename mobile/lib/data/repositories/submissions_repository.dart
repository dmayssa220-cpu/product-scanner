import '../services/api_client.dart';

class Submission {
  Submission({required this.id, required this.name, required this.status, this.rejectionReason, required this.createdAt});
  final String id;
  final String name;
  final String status;
  final String? rejectionReason;
  final DateTime createdAt;

  factory Submission.fromJson(Map<String, dynamic> json) => Submission(
        id: json['id'] as String,
        name: json['name'] as String,
        status: json['status'] as String,
        rejectionReason: json['rejection_reason'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

class SubmissionsRepository {
  SubmissionsRepository(this._api);
  final ApiClient _api;

  Future<String> submit({
    String? barcode,
    required String name,
    String? brand,
    String? category,
    List<Map<String, dynamic>> ingredients = const [],
    Map<String, dynamic> nutritionFacts = const {},
    int? processingLevel,
  }) async {
    final data = await _api.post('/submissions', {
      'barcode': barcode,
      'name': name,
      'brand': brand,
      'category': category,
      'ingredients': ingredients,
      'nutrition_facts': nutritionFacts,
      'processing_level': processingLevel,
    }, auth: true);
    return data['id'] as String;
  }

  Future<List<Submission>> mine() async {
    final data = await _api.getList('/submissions/mine', auth: true);
    return data.map((e) => Submission.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Map<String, dynamic>>> pendingAdmin() async {
    final data = await _api.getList('/submissions/admin/pending', auth: true);
    return data.cast<Map<String, dynamic>>();
  }

  Future<void> approve(String id) async {
    await _api.post('/submissions/admin/$id/approve', {}, auth: true);
  }

  Future<void> reject(String id, String reason) async {
    await _api.post('/submissions/admin/$id/reject?reason=$reason', {}, auth: true);
  }
}
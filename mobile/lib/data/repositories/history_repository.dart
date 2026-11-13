import '../models/history_entry.dart';
import '../services/api_client.dart';

class HistoryRepository {
  HistoryRepository(this._api);
  final ApiClient _api;

  Future<List<HistoryEntry>> list() async {
    final data = await _api.getList('/history', auth: true);
    return data.map((e) => HistoryEntry.fromJson(e as Map<String, dynamic>)).toList();
  }
}
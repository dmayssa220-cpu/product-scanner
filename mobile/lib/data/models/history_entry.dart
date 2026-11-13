class HistoryEntry {
  const HistoryEntry({
    required this.id,
    required this.scanType,
    required this.scannedAt,
    this.productId,
    this.productName,
    this.productBrand,
  });

  final String id;
  final String scanType;
  final DateTime scannedAt;
  final String? productId;
  final String? productName;
  final String? productBrand;

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>?;
    return HistoryEntry(
      id: json['id'] as String,
      scanType: json['scan_type'] as String,
      scannedAt: DateTime.parse(json['scanned_at'] as String),
      productId: product?['id'] as String?,
      productName: product?['name'] as String?,
      productBrand: product?['brand'] as String?,
    );
  }
}
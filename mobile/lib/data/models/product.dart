class ProductScore {
  const ProductScore({
    required this.total,
    required this.nutrition,
    required this.additives,
    required this.processing,
  });

  final double total;
  final double nutrition;
  final double additives;
  final double processing;

  factory ProductScore.fromJson(Map<String, dynamic> json) => ProductScore(
        total: (json['total'] as num).toDouble(),
        nutrition: (json['nutrition'] as num).toDouble(),
        additives: (json['additives'] as num).toDouble(),
        processing: (json['processing'] as num).toDouble(),
      );
}

class Product {
  const Product({
    required this.id,
    this.barcode,
    required this.name,
    this.brand,
    this.category,
    this.imageUrl,
    this.processingLevel,
    this.nutritionFacts = const {},
    this.ingredients = const [],
    this.score,
  });

  final String id;
  final String? barcode;
  final String name;
  final String? brand;
  final String? category;
  final String? imageUrl;
  final int? processingLevel;
  final Map<String, dynamic> nutritionFacts;
  final List<dynamic> ingredients;
  final ProductScore? score;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as String,
        barcode: json['barcode'] as String?,
        name: json['name'] as String,
        brand: json['brand'] as String?,
        category: json['category'] as String?,
        imageUrl: json['image_url'] as String?,
        processingLevel: json['processing_level'] as int?,
        nutritionFacts: (json['nutrition_facts'] as Map?)?.cast<String, dynamic>() ?? const {},
        ingredients: (json['ingredients'] as List?) ?? const [],
        score: json['score'] != null
            ? ProductScore.fromJson(json['score'] as Map<String, dynamic>)
            : null,
      );
}
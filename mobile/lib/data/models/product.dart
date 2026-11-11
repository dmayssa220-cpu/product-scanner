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
      );
}
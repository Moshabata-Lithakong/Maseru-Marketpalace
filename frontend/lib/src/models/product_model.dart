class ProductImage {
  final String url;

  const ProductImage({required this.url});

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(url: json['url'] as String? ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'url': url};
  }
}

class ProductName {
  final String en;
  final String st;

  const ProductName({required this.en, required this.st});

  factory ProductName.fromJson(Map<String, dynamic> json) {
    return ProductName(
      en: json['en'] as String? ?? '',
      st: json['st'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'en': en, 'st': st};
  }

  String getLocalized(String language) => language == 'en' ? en : st;
}

class ProductDescription {
  final String en;
  final String st;

  const ProductDescription({required this.en, required this.st});

  factory ProductDescription.fromJson(Map<String, dynamic> json) {
    return ProductDescription(
      en: json['en'] as String? ?? '',
      st: json['st'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'en': en, 'st': st};
  }

  String getLocalized(String language) => language == 'en' ? en : st;
}

class ProductRatings {
  final double average;
  final int count;

  const ProductRatings({required this.average, required this.count});

  factory ProductRatings.fromJson(Map<String, dynamic> json) {
    return ProductRatings(
      average: (json['average'] as num?)?.toDouble() ?? 0.0,
      count: json['count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'average': average, 'count': count};
  }
}

class Product {
  final String id;
  final ProductName name;
  final ProductDescription description;
  final String category;
  final double price;
  final int stockQuantity;
  final ProductRatings ratings;
  final List<ProductImage> images;
  final String vendorId;
  final bool isFavorite;
  final bool available;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.stockQuantity,
    required this.ratings,
    this.images = const [],
    required this.vendorId,
    this.isFavorite = false,
    this.available = true,
  });

  String get displayPrice => 'LSL ${price.toStringAsFixed(2)}';
  bool get inStock => stockQuantity > 0;

  factory Product.fromJson(Map<String, dynamic> json) {
    // FIXED: Handle vendorId when it's an object or string
    String parseVendorId(dynamic vendorIdData) {
      if (vendorIdData is String) {
        return vendorIdData;
      } else if (vendorIdData is Map<String, dynamic>) {
        // Extract vendor ID from the nested object
        return vendorIdData['_id'] as String? ?? '';
      }
      return '';
    }

    return Product(
      id: json['id'] as String? ?? json['_id'] ?? '',
      name: ProductName.fromJson(json['name'] as Map<String, dynamic>? ?? {}),
      description: ProductDescription.fromJson(json['description'] as Map<String, dynamic>? ?? {}),
      category: json['category'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      stockQuantity: json['stockQuantity'] as int? ?? 0,
      ratings: ProductRatings.fromJson(json['ratings'] as Map<String, dynamic>? ?? {}),
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => ProductImage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      vendorId: parseVendorId(json['vendorId']),
      isFavorite: json['isFavorite'] as bool? ?? false,
      available: json['available'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name.toJson(),
      'description': description.toJson(),
      'category': category,
      'price': price,
      'stockQuantity': stockQuantity,
      'ratings': ratings.toJson(),
      'images': images.map((e) => e.toJson()).toList(),
      'vendorId': vendorId,
      'isFavorite': isFavorite,
      'available': available,
    };
  }

  Product copyWith({
    String? id,
    ProductName? name,
    ProductDescription? description,
    String? category,
    double? price,
    int? stockQuantity,
    ProductRatings? ratings,
    List<ProductImage>? images,
    String? vendorId,
    bool? isFavorite,
    bool? available,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      ratings: ratings ?? this.ratings,
      images: images ?? this.images,
      vendorId: vendorId ?? this.vendorId,
      isFavorite: isFavorite ?? this.isFavorite,
      available: available ?? this.available,
    );
  }
}
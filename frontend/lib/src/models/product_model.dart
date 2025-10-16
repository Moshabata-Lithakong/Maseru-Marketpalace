import 'package:flutter/foundation.dart';

class ProductImage {
  final String url;
  final String publicId;

  const ProductImage({required this.url, required this.publicId});

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      url: json['url'] as String? ?? '',
      publicId: json['publicId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'url': url, 'publicId': publicId};
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
  final String currency;
  final int stockQuantity;
  final ProductRatings ratings;
  final List<ProductImage> images;
  final List<String> tags;
  final String vendorId;
  final int priority;
  final bool isFavorite;
  final bool available;
  final bool inStock;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.currency,
    required this.stockQuantity,
    required this.ratings,
    this.images = const [],
    this.tags = const [],
    required this.vendorId,
    required this.priority,
    this.isFavorite = false,
    this.available = true,
    this.inStock = true,
  });

  String get displayPrice => '$currency ${price.toStringAsFixed(2)}';

  factory Product.fromJson(Map<String, dynamic> json) {
    try {
      // Handle vendorId which can be String or Map in different responses
      String vendorId;
      if (json['vendorId'] is String) {
        vendorId = json['vendorId'] as String;
      } else if (json['vendorId'] is Map) {
        vendorId = (json['vendorId'] as Map)['_id']?.toString() ?? '';
      } else {
        vendorId = '';
      }

      // Handle name field - can be Map or String
      ProductName productName;
      if (json['name'] is Map) {
        productName = ProductName.fromJson(json['name'] as Map<String, dynamic>);
      } else if (json['name'] is String) {
        productName = ProductName(en: json['name'] as String, st: json['name'] as String);
      } else {
        productName = const ProductName(en: '', st: '');
      }

      // Handle description field - can be Map or String
      ProductDescription productDescription;
      if (json['description'] is Map) {
        productDescription = ProductDescription.fromJson(json['description'] as Map<String, dynamic>);
      } else if (json['description'] is String) {
        productDescription = ProductDescription(en: json['description'] as String, st: json['description'] as String);
      } else {
        productDescription = const ProductDescription(en: '', st: '');
      }

      // Handle price validation
      double price;
      if (json['price'] is int) {
        price = (json['price'] as int).toDouble();
      } else if (json['price'] is double) {
        price = json['price'] as double;
      } else {
        price = 0.0;
      }

      if (price < 0) {
        throw FormatException('Price cannot be negative');
      }

      // Handle stock quantity
      int stockQuantity = json['stockQuantity'] as int? ?? 0;
      if (stockQuantity < 0) {
        throw FormatException('Stock quantity cannot be negative');
      }

      return Product(
        id: json['id'] as String? ?? json['_id'] as String? ?? '',
        name: productName,
        description: productDescription,
        category: json['category'] as String? ?? '',
        price: price,
        currency: json['currency'] as String? ?? 'LSL',
        stockQuantity: stockQuantity,
        ratings: ProductRatings.fromJson(json['ratings'] as Map<String, dynamic>? ?? {}),
        images: (json['images'] as List<dynamic>?)
                ?.map((e) => ProductImage.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
        vendorId: vendorId,
        priority: json['priority'] as int? ?? 1,
        isFavorite: json['isFavorite'] as bool? ?? false,
        available: json['available'] as bool? ?? true,
        inStock: json['inStock'] as bool? ?? (stockQuantity > 0),
      );
    } catch (e) {
      print('❌ Error parsing product JSON: $e');
      print('❌ Problematic JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name.toJson(),
      'description': description.toJson(),
      'category': category,
      'price': price,
      'currency': currency,
      'stockQuantity': stockQuantity,
      'ratings': ratings.toJson(),
      'images': images.map((e) => e.toJson()).toList(),
      'tags': tags,
      'vendorId': vendorId,
      'priority': priority,
      'isFavorite': isFavorite,
      'available': available,
      'inStock': inStock,
    };
  }

  Product copyWith({
    String? id,
    ProductName? name,
    ProductDescription? description,
    String? category,
    double? price,
    String? currency,
    int? stockQuantity,
    ProductRatings? ratings,
    List<ProductImage>? images,
    List<String>? tags,
    String? vendorId,
    int? priority,
    bool? isFavorite,
    bool? available,
    bool? inStock,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      ratings: ratings ?? this.ratings,
      images: images ?? this.images,
      tags: tags ?? this.tags,
      vendorId: vendorId ?? this.vendorId,
      priority: priority ?? this.priority,
      isFavorite: isFavorite ?? this.isFavorite,
      available: available ?? this.available,
      inStock: inStock ?? this.inStock,
    );
  }

  @override
  String toString() {
    return 'Product(id: $id, name: ${name.en}, price: $price, category: $category)';
  }
}
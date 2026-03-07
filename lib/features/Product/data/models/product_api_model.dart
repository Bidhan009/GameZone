import 'package:gamezone_flutter/core/api/api_endpoints.dart';
import 'package:gamezone_flutter/features/Product/domain/entities/product_entity.dart';

class ProductApiModel {
  final String? id;
  final String name;
  final double price;
  final String category;
  final int stock;
  final String description;
  final String? imageUrl;

  ProductApiModel({
    this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.stock,
    required this.description,
    this.imageUrl,
  });

  String? get fullImageUrl {
    if (imageUrl == null || imageUrl!.isEmpty) return null;
    if (imageUrl!.startsWith('http')) return imageUrl;
    return '${ApiEndpoints.baseUrl.replaceAll('/api/', '')}$imageUrl';
  }

  factory ProductApiModel.fromJson(Map<String, dynamic> json) {
    return ProductApiModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] is String) 
          ? double.parse(json['price']) 
          : (json['price'] ?? 0).toDouble(),
      category: json['category'] ?? '',
      stock: (json['stock'] is String) 
          ? int.parse(json['stock']) 
          : (json['stock'] ?? 0).toInt(),
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'category': category,
      'stock': stock,
      'description': description,
      'imageUrl': imageUrl,
    };
  }
  ProductEntity toEntity() {
    return ProductEntity(
      id: id ?? '',
      name: name,
      price: price,
      category: category,
      stock: stock,
      description: description,
      imageUrl: fullImageUrl,
    );
  }
  factory ProductApiModel.fromEntity(ProductEntity entity) {
    return ProductApiModel(
      id: entity.id,
      name: entity.name,
      price: entity.price,
      category: entity.category,
      stock: entity.stock,
      description: entity.description,
      imageUrl: entity.imageUrl,
    );
  }
}
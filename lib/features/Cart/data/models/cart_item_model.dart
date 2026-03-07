import 'package:gamezone_flutter/core/api/api_endpoints.dart';
import 'package:gamezone_flutter/features/Product/domain/entities/product_entity.dart';

class CartItemModel {
  /// identifier for this item in the cart (returned by the server)
  final String id;
  final String productId;
  final int quantity;
  final ProductEntity? product;

  CartItemModel({
    required this.id,
    required this.productId,
    required this.quantity,
    this.product,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    // Since backend doesn't provide cart item _id, we use productId as the identifier
    // Backend may include a nested product object or just a productId field
    String prodId = '';
    Map<String, dynamic>? productData;

    if (json['product'] != null) {
      productData = json['product'] as Map<String, dynamic>;
      prodId = productData['_id']?.toString() ?? '';
    } else if (json['productId'] != null) {
      prodId = json['productId']?.toString() ?? '';
    }

    return CartItemModel(
      id: prodId, // Use productId as the id since cart items don't have their own _id
      productId: prodId,
      quantity: json['quantity'] ?? 1,
      product: productData != null ? _productFromJson(productData) : null,
    );
  }

  static String? _getFullImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return null;
    if (imageUrl.startsWith('http')) return imageUrl;
    return '${ApiEndpoints.baseUrl.replaceAll('/api/', '')}$imageUrl';
  }

  static ProductEntity _productFromJson(Map<String, dynamic> json) {
    return ProductEntity(
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
      imageUrl: _getFullImageUrl(json['imageUrl']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'productId': productId, 'quantity': quantity};
  }
}

class CartModel {
  final List<CartItemModel> items;
  final double totalPrice;

  CartModel({required this.items, required this.totalPrice});

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final items =
        (json['items'] as List<dynamic>?)
            ?.map((item) => CartItemModel.fromJson(item))
            .toList() ??
        [];
    final totalPrice = (json['totalPrice'] is String)
        ? double.parse(json['totalPrice'])
        : (json['totalPrice'] ?? 0).toDouble();
    return CartModel(items: items, totalPrice: totalPrice);
  }
}

import 'package:gamezone_flutter/features/Product/domain/entities/product_entity.dart';
class CartItemModel {
  final String productId;
  final int quantity;
  final ProductEntity? product;
  CartItemModel({
    required this.productId,
    required this.quantity,
    this.product,
  });
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      productId: json['productId'] ?? json['_id'] ?? '',
      quantity: json['quantity'] ?? 1,
      product: json['product'] != null
          ? _productFromJson(json['product'])
          : null,
    );
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
      imageUrl: json['imageUrl'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
    };
  }
}
class CartModel {
  final List<CartItemModel> items;
  final double totalPrice;
  CartModel({
    required this.items,
    required this.totalPrice,
  });
  factory CartModel.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>?)
            ?.map((item) => CartItemModel.fromJson(item))
            .toList() ??
        [];
    final totalPrice = (json['totalPrice'] is String)
        ? double.parse(json['totalPrice'])
        : (json['totalPrice'] ?? 0).toDouble();
    return CartModel(items: items, totalPrice: totalPrice);
  }
}
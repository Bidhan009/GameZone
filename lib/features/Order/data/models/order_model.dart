import 'package:gamezone_flutter/features/Product/domain/entities/product_entity.dart';

class OrderItemModel {
  final String productId;
  final int quantity;
  final double price;
  final ProductEntity? product;

  OrderItemModel({
    required this.productId,
    required this.quantity,
    required this.price,
    this.product,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    ProductEntity? productData;
    String product = '';

    if (json['product'] != null) {
      if (json['product'] is Map<String, dynamic>) {
        final productJson = json['product'] as Map<String, dynamic>;
        product = productJson['_id']?.toString() ?? '';
        productData = ProductEntity(
          id: product,
          name: productJson['name'] ?? '',
          price: (productJson['price'] is String)
              ? double.parse(productJson['price'])
              : (productJson['price'] ?? 0).toDouble(),
          category: '',
          stock: 0,
          description: '',
          imageUrl: productJson['imageUrl'],
        );
      } else {
        product = json['product']?.toString() ?? '';
      }
    } else {
      product = json['productId']?.toString() ?? '';
    }

    return OrderItemModel(
      productId: product,
      quantity: json['quantity'] ?? 1,
      price: (json['price'] is String)
          ? double.parse(json['price'])
          : (json['price'] ?? 0).toDouble(),
      product: productData,
    );
  }

  Map<String, dynamic> toJson() {
    return {'product': productId, 'quantity': quantity, 'price': price};
  }
}

class ShippingAddressModel {
  final String street;
  final String city;
  final String zipCode;

  ShippingAddressModel({
    required this.street,
    required this.city,
    required this.zipCode,
  });

  factory ShippingAddressModel.fromJson(Map<String, dynamic> json) {
    return ShippingAddressModel(
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      zipCode: json['zipCode'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'street': street, 'city': city, 'zipCode': zipCode};
  }
}

class ContactInfoModel {
  final String phone;
  final String email;

  ContactInfoModel({required this.phone, required this.email});

  factory ContactInfoModel.fromJson(Map<String, dynamic> json) {
    return ContactInfoModel(
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'phone': phone, 'email': email};
  }
}

class OrderModel {
  final String id;
  final List<OrderItemModel> items;
  final double totalAmount;
  final ShippingAddressModel shippingAddress;
  final ContactInfoModel? contactInfo;
  final String paymentMethod;
  final String paymentStatus;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.shippingAddress,
    this.contactInfo,
    this.paymentMethod = 'COD',
    this.paymentStatus = 'pending',
    this.status = 'pending',
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final items =
        (json['items'] as List<dynamic>?)
            ?.map((item) => OrderItemModel.fromJson(item))
            .toList() ??
        [];

    return OrderModel(
      id: json['_id']?.toString() ?? json['id'] ?? '',
      items: items,
      totalAmount: (json['totalAmount'] is String)
          ? double.parse(json['totalAmount'])
          : (json['totalAmount'] ?? 0).toDouble(),
      shippingAddress: ShippingAddressModel.fromJson(
        json['shippingAddress'] ?? {},
      ),
      contactInfo: json['contactInfo'] != null
          ? ContactInfoModel.fromJson(json['contactInfo'])
          : null,
      paymentMethod: json['paymentMethod'] ?? 'COD',
      paymentStatus: json['paymentStatus'] ?? 'pending',
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'shippingAddress': shippingAddress.toJson(),
      'contactInfo': contactInfo?.toJson(),
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'paid':
        return 'Paid';
      case 'shipped':
        return 'Shipped';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}

class CreateOrderRequestModel {
  final List<OrderItemModel> items;
  final double totalAmount;
  final ShippingAddressModel shippingAddress;
  final ContactInfoModel contactInfo;
  final String paymentMethod;

  CreateOrderRequestModel({
    required this.items,
    required this.totalAmount,
    required this.shippingAddress,
    required this.contactInfo,
    this.paymentMethod = 'COD',
  });

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'shippingAddress': shippingAddress.toJson(),
      'contactInfo': contactInfo.toJson(),
      'paymentMethod': paymentMethod,
      'paymentStatus': 'pending',
      'status': 'pending',
    };
  }
}

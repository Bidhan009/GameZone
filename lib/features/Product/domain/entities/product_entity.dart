import 'package:equatable/equatable.dart';
class ProductEntity extends Equatable {
  final String id;
  final String name;
  final double price;
  final String category;
  final int stock;
  final String description;
  final String? imageUrl;
  const ProductEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.stock,
    required this.description,
    this.imageUrl,
  });
  @override
  List<Object?> get props => [id, name, price, category, stock, description, imageUrl];
}
import 'package:dartz/dartz.dart';
import 'package:gamezone_flutter/core/error/failure.dart';
import 'package:gamezone_flutter/features/Product/domain/entities/product_entity.dart';
abstract interface class IProductRepository {
  Future<Either<Failure, List<ProductEntity>>> getAllProducts({int page = 1, int limit = 10});
  Future<Either<Failure, ProductEntity>> getProductById(String id);
}
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamezone_flutter/core/error/failure.dart';
import 'package:gamezone_flutter/core/usecase.dart';
import 'package:gamezone_flutter/features/Product/data/repositories/product_repository_impl.dart';
import 'package:gamezone_flutter/features/Product/domain/entities/product_entity.dart';
import 'package:gamezone_flutter/features/Product/domain/repository/product_repository.dart';
class GetProductsParams extends Equatable {
  final int page;
  final int limit;
  const GetProductsParams({this.page = 1, this.limit = 10});
  @override
  List<Object?> get props => [page, limit];
}
class GetProductsUseCase implements UsecaseWithParams<List<ProductEntity>, GetProductsParams> {
  final IProductRepository _productRepository;
  GetProductsUseCase(this._productRepository);
  @override
  Future<Either<Failure, List<ProductEntity>>> call(GetProductsParams params) async {
    return await _productRepository.getAllProducts(
      page: params.page,
      limit: params.limit,
    );
  }
}
final getProductsUseCaseProvider = Provider<GetProductsUseCase>((ref) {
  return GetProductsUseCase(ref.read(productRepositoryProvider));
});
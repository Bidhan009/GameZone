import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamezone_flutter/core/error/failure.dart';
import 'package:gamezone_flutter/core/service/connections/network_info.dart';
import 'package:gamezone_flutter/features/Product/data/datasources/product_remote_datasource.dart';
import 'package:gamezone_flutter/features/Product/domain/entities/product_entity.dart';
import 'package:gamezone_flutter/features/Product/domain/repository/product_repository.dart';
final productRepositoryProvider = Provider<IProductRepository>((ref) {
  final productRemote = ref.read(productRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  return ProductRepositoryImpl(
    productRemoteDataSource: productRemote,
    networkInfo: networkInfo,
  );
});
class ProductRepositoryImpl implements IProductRepository {
  final IProductRemoteDataSource _productRemoteDataSource;
  final NetworkInfo _networkInfo;
  ProductRepositoryImpl({
    required IProductRemoteDataSource productRemoteDataSource,
    required NetworkInfo networkInfo,
  })  : _productRemoteDataSource = productRemoteDataSource,
        _networkInfo = networkInfo;
  @override
  Future<Either<Failure, List<ProductEntity>>> getAllProducts({int page = 1, int limit = 10}) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModels = await _productRemoteDataSource.getAllProducts(page: page, limit: limit);
        final entities = apiModels.map((model) => model.toEntity()).toList();
        return Right(entities);
      } on DioException catch (e) {
        return Left(ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to fetch products',
          statusCode: e.response?.statusCode,
        ));
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }
  @override
  Future<Either<Failure, ProductEntity>> getProductById(String id) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = await _productRemoteDataSource.getProductById(id);
        return Right(apiModel.toEntity());
      } on DioException catch (e) {
        return Left(ApiFailure(
          message: e.response?.data['message'] ?? 'Failed to fetch product',
          statusCode: e.response?.statusCode,
        ));
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }
}
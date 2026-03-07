import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamezone_flutter/core/api/api_client.dart';
import 'package:gamezone_flutter/core/api/api_endpoints.dart';
import 'package:gamezone_flutter/features/Product/data/models/product_api_model.dart';
final productRemoteDatasourceProvider = Provider<IProductRemoteDataSource>((ref) {
  return ProductRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
  );
});
abstract interface class IProductRemoteDataSource {
  Future<List<ProductApiModel>> getAllProducts({int page = 1, int limit = 10});
  Future<ProductApiModel> getProductById(String id);
}
class ProductRemoteDatasource implements IProductRemoteDataSource {
  final ApiClient _apiClient;
  ProductRemoteDatasource({required ApiClient apiClient}) : _apiClient = apiClient;
  @override
  Future<List<ProductApiModel>> getAllProducts({int page = 1, int limit = 10}) async {
    final response = await _apiClient.get(
      ApiEndpoints.products,
      queryParameters: {'page': page, 'limit': limit},
    );
    if (response.data['success'] == true) {
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => ProductApiModel.fromJson(json)).toList();
    }
    throw Exception(response.data['message'] ?? "Failed to fetch products");
  }
  @override
  Future<ProductApiModel> getProductById(String id) async {
    final response = await _apiClient.get(ApiEndpoints.productById(id));
    if (response.data['success'] == true) {
      return ProductApiModel.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? "Failed to fetch product");
  }
}
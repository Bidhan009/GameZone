import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamezone_flutter/core/api/api_client.dart';
import 'package:gamezone_flutter/core/api/api_endpoints.dart';
import 'package:gamezone_flutter/features/Cart/data/models/cart_item_model.dart';
final cartRemoteDatasourceProvider = Provider<ICartRemoteDataSource>((ref) {
  return CartRemoteDatasource(apiClient: ref.read(apiClientProvider));
});
abstract interface class ICartRemoteDataSource {
  Future<CartModel> getCart();
  Future<CartModel> addToCart(String productId, int quantity);
  Future<CartModel> updateCartItem(String productId, int quantity);
  Future<CartModel> removeFromCart(String productId);
  Future<CartModel> clearCart();
}
class CartRemoteDatasource implements ICartRemoteDataSource {
  final ApiClient _apiClient;
  CartRemoteDatasource({required ApiClient apiClient}) : _apiClient = apiClient;
  @override
  Future<CartModel> getCart() async {
    final response = await _apiClient.get(ApiEndpoints.cart);
    if (response.data['success'] == true) {
      return CartModel.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? "Failed to get cart");
  }
  @override
  Future<CartModel> addToCart(String productId, int quantity) async {
    final response = await _apiClient.post(
      ApiEndpoints.cart,
      data: {'productId': productId, 'quantity': quantity},
    );
    if (response.data['success'] == true) {
      return CartModel.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? "Failed to add to cart");
  }
  @override
  Future<CartModel> updateCartItem(String productId, int quantity) async {
    final response = await _apiClient.patch(
      ApiEndpoints.cart,
      data: {'productId': productId, 'quantity': quantity},
    );
    if (response.data['success'] == true) {
      return CartModel.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? "Failed to update cart");
  }
  @override
  Future<CartModel> removeFromCart(String productId) async {
    final response = await _apiClient.delete(
      '${ApiEndpoints.cart}/$productId',
    );
    if (response.data['success'] == true) {
      return CartModel.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? "Failed to remove from cart");
  }
  @override
  Future<CartModel> clearCart() async {
    final response = await _apiClient.delete(ApiEndpoints.cart);
    if (response.data['success'] == true) {
      return CartModel.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? "Failed to clear cart");
  }
}
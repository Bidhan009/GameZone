import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:gamezone_flutter/features/Cart/data/datasources/cart_remote_datasource.dart';
import 'package:gamezone_flutter/features/Cart/data/models/cart_item_model.dart';
enum CartStatus { initial, loading, loaded, error }
class CartState {
  final CartStatus status;
  final List<CartItemModel> items;
  final double totalPrice;
  final String? errorMessage;
  CartState({
    this.status = CartStatus.initial,
    this.items = const [],
    this.totalPrice = 0.0,
    this.errorMessage,
  });
  CartState copyWith({
    CartStatus? status,
    List<CartItemModel>? items,
    double? totalPrice,
    String? errorMessage,
  }) {
    return CartState(
      status: status ?? this.status,
      items: items ?? this.items,
      totalPrice: totalPrice ?? this.totalPrice,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
class CartNotifier extends StateNotifier<CartState> {
  final ICartRemoteDataSource _cartRemoteDatasource;
  CartNotifier(this._cartRemoteDatasource) : super(CartState());
  Future<void> loadCart() async {
    state = state.copyWith(status: CartStatus.loading);
    try {
      final cart = await _cartRemoteDatasource.getCart();
      state = state.copyWith(
        status: CartStatus.loaded,
        items: cart.items,
        totalPrice: cart.totalPrice,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        status: CartStatus.error,
        errorMessage: e.response?.data['message'] ?? 'Failed to load cart',
      );
    } catch (e) {
      state = state.copyWith(
        status: CartStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
  Future<void> addToCart(String productId, {int quantity = 1}) async {
    try {
      final cart = await _cartRemoteDatasource.addToCart(productId, quantity);
      state = state.copyWith(
        items: cart.items,
        totalPrice: cart.totalPrice,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
  Future<void> updateQuantity(String productId, int quantity) async {
    try {
      final cart = await _cartRemoteDatasource.updateCartItem(productId, quantity);
      state = state.copyWith(
        items: cart.items,
        totalPrice: cart.totalPrice,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
  Future<void> removeFromCart(String productId) async {
    try {
      final cart = await _cartRemoteDatasource.removeFromCart(productId);
      state = state.copyWith(
        items: cart.items,
        totalPrice: cart.totalPrice,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
  Future<void> clearCart() async {
    try {
      await _cartRemoteDatasource.clearCart();
      state = state.copyWith(items: [], totalPrice: 0.0);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
}
final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier(ref.read(cartRemoteDatasourceProvider));
});
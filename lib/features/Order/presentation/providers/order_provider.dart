import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:gamezone_flutter/features/Order/data/datasources/order_remote_datasource.dart';
import 'package:gamezone_flutter/features/Order/data/models/order_model.dart';

enum OrderStatus { initial, loading, loaded, error }

class OrderState {
  final OrderStatus status;
  final List<OrderModel> orders;
  final String? errorMessage;
  final OrderModel? currentOrder;

  const OrderState({
    this.status = OrderStatus.initial,
    this.orders = const [],
    this.errorMessage,
    this.currentOrder,
  });

  OrderState copyWith({
    OrderStatus? status,
    List<OrderModel>? orders,
    String? errorMessage,
    OrderModel? currentOrder,
  }) {
    return OrderState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      errorMessage: errorMessage ?? this.errorMessage,
      currentOrder: currentOrder ?? this.currentOrder,
    );
  }
}

class OrderNotifier extends StateNotifier<OrderState> {
  final IOrderRemoteDataSource _orderRemoteDataSource;

  OrderNotifier(this._orderRemoteDataSource) : super(const OrderState());

  Future<void> loadOrders() async {
    state = const OrderState(status: OrderStatus.loading);
    try {
      final orders = await _orderRemoteDataSource.getUserOrders();
      state = OrderState(
        status: OrderStatus.loaded,
        orders: orders,
      );
    } catch (e) {
      state = OrderState(
        status: OrderStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<OrderModel> createOrder(CreateOrderRequestModel orderData) async {
    state = state.copyWith(status: OrderStatus.loading, errorMessage: null);
    try {
      final order = await _orderRemoteDataSource.createOrder(orderData);
      
      // Add to new order to list
      final updatedOrders = [order, ...state.orders];
      state = OrderState(
        status: OrderStatus.loaded,
        orders: updatedOrders,
        currentOrder: order,
      );
      
      return order;
    } catch (e) {
      state = OrderState(
        status: OrderStatus.error,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  void clearCurrentOrder() {
    state = state.copyWith(currentOrder: null);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

final orderProvider = StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  return OrderNotifier(ref.read(orderRemoteDatasourceProvider));
});

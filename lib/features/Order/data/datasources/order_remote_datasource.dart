import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamezone_flutter/core/api/api_client.dart';
import 'package:gamezone_flutter/core/api/api_endpoints.dart';
import 'package:gamezone_flutter/features/Order/data/models/order_model.dart';

final orderRemoteDatasourceProvider = Provider<IOrderRemoteDataSource>((ref) {
  return OrderRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

abstract interface class IOrderRemoteDataSource {
  Future<OrderModel> createOrder(CreateOrderRequestModel orderData);
  Future<List<OrderModel>> getUserOrders();
}

class OrderRemoteDatasource implements IOrderRemoteDataSource {
  final ApiClient _apiClient;
  
  OrderRemoteDatasource({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<OrderModel> createOrder(CreateOrderRequestModel orderData) async {
    final response = await _apiClient.post(
      ApiEndpoints.orders,
      data: orderData.toJson(),
    );
    print('Create order response: ${response.data}');
    print('Response data type: ${response.data.runtimeType}');
    if (response.data['success'] == true) {
      return OrderModel.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? "Failed to create order");
  }

  @override
  Future<List<OrderModel>> getUserOrders() async {
    final response = await _apiClient.get(ApiEndpoints.orders);
    if (response.data['success'] == true) {
      final ordersData = response.data['data'] as List<dynamic>;
      return ordersData
          .map((order) => OrderModel.fromJson(order))
          .toList();
    }
    throw Exception(response.data['message'] ?? "Failed to get orders");
  }
}

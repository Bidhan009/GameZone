import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamezone_flutter/features/Order/data/models/order_model.dart';
import 'package:gamezone_flutter/features/Order/presentation/providers/order_provider.dart';

class OrderHistoryScreen extends ConsumerStatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  ConsumerState<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends ConsumerState<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(orderProvider.notifier).loadOrders());
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Order History',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _buildBody(orderState),
    );
  }

  Widget _buildBody(OrderState orderState) {
    switch (orderState.status) {
      case OrderStatus.initial:
      case OrderStatus.loading:
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
        );

      case OrderStatus.loaded:
        if (orderState.orders.isEmpty) {
          return _buildEmptyOrders();
        }
        return _buildOrderList(orderState.orders);

      case OrderStatus.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                orderState.errorMessage ?? 'Something went wrong',
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(orderProvider.notifier).loadOrders(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildEmptyOrders() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long,
                size: 70,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "No Orders Yet",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Your order history will appear here\nonce you place your first order",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(List<OrderModel> orders) {
    return RefreshIndicator(
      onRefresh: () => ref.read(orderProvider.notifier).loadOrders(),
      color: const Color(0xFF6C63FF),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return GestureDetector(
      onTap: () => _showOrderDetails(order),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.receipt_long,
                        color: Color(0xFF6C63FF),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order.id.substring(0, 8)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${order.items.length} items',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                _buildStatusChip(order.status),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ship to',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${order.shippingAddress.city}, ${order.shippingAddress.zipCode}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${order.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(order.createdAt),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'View Details',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case 'pending':
        backgroundColor = Colors.orange.withValues(alpha: 0.2);
        textColor = Colors.orange;
        icon = Icons.access_time;
        break;
      case 'paid':
        backgroundColor = Colors.blue.withValues(alpha: 0.2);
        textColor = Colors.blue;
        icon = Icons.check_circle;
        break;
      case 'shipped':
        backgroundColor = Colors.purple.withValues(alpha: 0.2);
        textColor = Colors.purple;
        icon = Icons.local_shipping;
        break;
      case 'completed':
        backgroundColor = Colors.green.withValues(alpha: 0.2);
        textColor = Colors.green;
        icon = Icons.done_all;
        break;
      case 'cancelled':
        backgroundColor = Colors.red.withValues(alpha: 0.2);
        textColor = Colors.red;
        icon = Icons.cancel;
        break;
      default:
        backgroundColor = Colors.grey.withValues(alpha: 0.2);
        textColor = Colors.grey;
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showOrderDetails(OrderModel order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Color(0xFF1E293B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Order Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '#${order.id.substring(0, 8)}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  _buildStatusChip(order.status),
                ],
              ),
            ),
            const Divider(color: Colors.white24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildSectionTitle('Items'),
                    const SizedBox(height: 12),
                    ...order.items.map((item) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6C63FF).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.inventory_2,
                                  color: Color(0xFF6C63FF),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product?.name ?? 'Product',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      '${item.quantity}x @ \$${item.price.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.6),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Shipping Address'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Color(0xFF6C63FF),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                order.shippingAddress.street,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${order.shippingAddress.city}, ${order.shippingAddress.zipCode}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (order.contactInfo != null) ...[
                      const SizedBox(height: 24),
                      _buildSectionTitle('Contact Information'),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.phone,
                                  color: Color(0xFF10B981),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  order.contactInfo!.phone,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.email,
                                  color: Color(0xFF10B981),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    order.contactInfo!.email,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF6C63FF).withValues(alpha: 0.2),
                            const Color(0xFF9D4EDD).withValues(alpha: 0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Amount',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '\$${order.totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

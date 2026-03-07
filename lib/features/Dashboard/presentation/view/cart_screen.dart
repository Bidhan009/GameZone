import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamezone_flutter/features/Cart/presentation/providers/cart_provider.dart';
import 'package:gamezone_flutter/features/Order/presentation/views/checkout_screen.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(cartProvider.notifier).loadCart());
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'My Cart',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
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
      ),
      body: _buildBody(cartState),
      bottomNavigationBar: cartState.items.isNotEmpty
          ? _buildCheckoutBar(cartState)
          : null,
    );
  }

  Widget _buildBody(CartState state) {
    switch (state.status) {
      case CartStatus.initial:
      case CartStatus.loading:
        if (state.items.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
          );
        }
        return _buildCartList(state);

      case CartStatus.loaded:
        if (state.items.isEmpty) {
          return _buildEmptyCart();
        }
        return _buildCartList(state);

      case CartStatus.error:
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
                state.errorMessage ?? 'Something went wrong',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(cartProvider.notifier).loadCart(),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildEmptyCart() {
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
                Icons.shopping_cart_outlined,
                size: 70,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Your Cart is Empty",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Add items to your cart\nand start shopping",
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

  Widget _buildCartList(CartState state) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.items.length,
      itemBuilder: (context, index) {
        final item = state.items[index];
        final product = item.product;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (product?.imageUrl != null)
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: NetworkImage(product!.imageUrl!),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.image,
                    color: Colors.white54,
                    size: 40,
                  ),
                ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product?.name ?? 'Product',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${product?.price.toStringAsFixed(2) ?? '0.00'}',
                      style: const TextStyle(
                        color: Color(0xFF6C63FF),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  if (item.quantity > 1) {
                                    ref
                                        .read(cartProvider.notifier)
                                        .updateQuantity(item.productId, item.quantity - 1);
                                  } else {
                                    ref
                                        .read(cartProvider.notifier)
                                        .removeFromCart(item.productId);
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(
                                    item.quantity > 1 ? Icons.remove : Icons.delete_outline,
                                    color: item.quantity > 1 ? Colors.white : Colors.red,
                                    size: 20,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  '${item.quantity}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  ref
                                      .read(cartProvider.notifier)
                                      .updateQuantity(item.productId, item.quantity + 1);
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCheckoutBar(CartState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total (${state.items.length} items)',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${state.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CheckoutScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Checkout',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

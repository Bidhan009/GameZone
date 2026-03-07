import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamezone_flutter/features/Product/presentation/providers/product_provider.dart';
import 'package:gamezone_flutter/features/Cart/presentation/providers/cart_provider.dart';
import 'package:gamezone_flutter/features/Bookmark/presentation/providers/bookmark_provider.dart';

class ProductScreen extends ConsumerStatefulWidget {
  const ProductScreen({super.key});

  @override
  ConsumerState<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends ConsumerState<ProductScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(productProvider.notifier).loadProducts();
      ref.read(bookmarkProvider.notifier).loadBookmarks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productProvider);
    final bookmarkState = ref.watch(bookmarkProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Products',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () => ref.read(productProvider.notifier).refreshProducts(),
            ),
          ),
        ],
      ),
      body: _buildBody(productState, bookmarkState),
    );
  }

  Widget _buildBody(ProductState state, BookmarkState bookmarkState) {
    switch (state.status) {
      case ProductStatus.initial:
      case ProductStatus.loading:
        if (state.products.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
          );
        }
        return _buildProductList(state, bookmarkState);

      case ProductStatus.loaded:
        if (state.products.isEmpty) {
          return Center(
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
                    Icons.inventory_2_outlined,
                    size: 70,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "No Products Available",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }
        return _buildProductList(state, bookmarkState);

      case ProductStatus.error:
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
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(productProvider.notifier).refreshProducts(),
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

  Widget _buildProductList(ProductState state, BookmarkState bookmarkState) {
    return RefreshIndicator(
      onRefresh: () => ref.read(productProvider.notifier).refreshProducts(),
      color: const Color(0xFF6C63FF),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.products.length + (state.status == ProductStatus.loading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.products.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
              ),
            );
          }

          final product = state.products[index];
          final isBookmarked = bookmarkState.bookmarkedIds.contains(product.id);

          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    if (product.imageUrl != null)
                      Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                          image: DecorationImage(
                            image: NetworkImage(product.imageUrl!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    else
                      Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                        ),
                        child: Icon(
                          Icons.image,
                          size: 60,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: () {
                          ref.read(bookmarkProvider.notifier).toggleBookmark(product);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B).withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                            color: isBookmarked ? Colors.red : Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                    if (product.stock > 0)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'In Stock',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C63FF).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.category,
                          style: const TextStyle(
                            color: Color(0xFF6C63FF),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: product.stock > 0
                                  ? Colors.green.withValues(alpha: 0.2)
                                  : Colors.red.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Stock: ${product.stock}',
                              style: TextStyle(
                                color: product.stock > 0
                                    ? const Color(0xFF10B981)
                                    : Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: product.stock > 0
                                ? () {
                                    ref.read(cartProvider.notifier).addToCart(product.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${product.name} added to cart'),
                                        backgroundColor: const Color(0xFF6C63FF),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6C63FF),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add_shopping_cart, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Add to Cart',
                                  style: TextStyle(fontWeight: FontWeight.bold),
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
      ),
    );
  }
}

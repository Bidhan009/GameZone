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
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(productProvider.notifier).refreshProducts(),
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
          return const Center(child: CircularProgressIndicator());
        }
        return _buildProductList(state, bookmarkState);
      case ProductStatus.loaded:
        if (state.products.isEmpty) {
          return const Center(child: Text('No products available'));
        }
        return _buildProductList(state, bookmarkState);
      case ProductStatus.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(state.errorMessage ?? 'Something went wrong'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(productProvider.notifier).refreshProducts(),
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
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.products.length + (state.status == ProductStatus.loading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.products.length) {
            return const Center(child: CircularProgressIndicator());
          }
          final product = state.products[index];
          final isBookmarked = bookmarkState.bookmarkedIds.contains(product.id);
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    if (product.imageUrl != null)
                      Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          image: DecorationImage(
                            image: NetworkImage(product.imageUrl!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    else
                      Container(
                        height: 150,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, size: 50),
                      ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: Icon(
                            isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                            color: isBookmarked ? Colors.red : Colors.grey,
                          ),
                          onPressed: () {
                            ref.read(bookmarkProvider.notifier).toggleBookmark(product);
                          },
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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.category,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Stock: ${product.stock}',
                            style: TextStyle(
                              color: product.stock > 0 ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: product.stock > 0
                                ? () {
                                    ref.read(cartProvider.notifier).addToCart(product.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${product.name} added to cart'),
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  }
                                : null,
                            child: const Text('Add to Cart'),
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
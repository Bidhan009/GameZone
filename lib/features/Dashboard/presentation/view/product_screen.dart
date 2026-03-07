import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamezone_flutter/features/Product/presentation/providers/product_provider.dart';
class ProductScreen extends ConsumerStatefulWidget {
  const ProductScreen({super.key});
  @override
  ConsumerState<ProductScreen> createState() => _ProductScreenState();
}
class _ProductScreenState extends ConsumerState<ProductScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(productProvider.notifier).loadProducts());
  }
  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productProvider);
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
      body: _buildBody(productState),
    );
  }
  Widget _buildBody(ProductState state) {
    switch (state.status) {
      case ProductStatus.initial:
      case ProductStatus.loading:
        if (state.products.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return _buildProductList(state);
      case ProductStatus.loaded:
        if (state.products.isEmpty) {
          return const Center(child: Text('No products available'));
        }
        return _buildProductList(state);
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
  Widget _buildProductList(ProductState state) {
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
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                                    // Add to cart logic
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
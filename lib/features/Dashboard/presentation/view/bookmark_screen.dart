import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamezone_flutter/features/Bookmark/presentation/providers/bookmark_provider.dart';
import 'package:gamezone_flutter/features/Cart/presentation/providers/cart_provider.dart';
class BookmarkScreen extends ConsumerStatefulWidget {
  const BookmarkScreen({super.key});
  @override
  ConsumerState<BookmarkScreen> createState() => _BookmarkScreenState();
}
class _BookmarkScreenState extends ConsumerState<BookmarkScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(bookmarkProvider.notifier).loadBookmarks());
  }
  @override
  Widget build(BuildContext context) {
    final bookmarkState = ref.watch(bookmarkProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
      ),
      body: bookmarkState.bookmarks.isEmpty
          ? const Center(child: Text('No bookmarks yet'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookmarkState.bookmarks.length,
              itemBuilder: (context, index) {
                final product = bookmarkState.bookmarks[index];
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    product.name,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.bookmark, color: Colors.red),
                                  onPressed: () {
                                    ref.read(bookmarkProvider.notifier).toggleBookmark(product);
                                  },
                                ),
                              ],
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
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
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
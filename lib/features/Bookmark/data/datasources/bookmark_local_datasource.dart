import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:gamezone_flutter/core/constants/hive_constant_table.dart';
import 'package:gamezone_flutter/features/Product/domain/entities/product_entity.dart';

final bookmarkLocalDatasourceProvider = Provider<IBookmarkLocalDataSource>((ref) {
  return BookmarkLocalDatasource();
});

abstract interface class IBookmarkLocalDataSource {
  Future<List<ProductEntity>> getBookmarks();
  Future<void> addBookmark(ProductEntity product);
  Future<void> removeBookmark(String productId);
  Future<bool> isBookmarked(String productId);
}

class BookmarkLocalDatasource implements IBookmarkLocalDataSource {
  late Box _bookmarkBox;

  @override
  Future<List<ProductEntity>> getBookmarks() async {
    _bookmarkBox = Hive.box(HiveTableConstant.bookmarkBox);
    print('=== GET BOOKMARKS ===');
    print('Box keys: ${_bookmarkBox.keys.toList()}');
    final bookmarks = <ProductEntity>[];
    for (var key in _bookmarkBox.keys) {
      print('Processing key: "$key"');
      final data = _bookmarkBox.get(key);
      if (data != null) {
        bookmarks.add(_productFromMap(Map<String, dynamic>.from(data)));
      }
    }
    print('=== END GET: ${bookmarks.length} items ===');
    return bookmarks;
  }

  @override
  Future<void> addBookmark(ProductEntity product) async {
    _bookmarkBox = Hive.box(HiveTableConstant.bookmarkBox);
    print('=== ADD BOOKMARK ===');
    print('Product ID to save: "${product.id}"');
    print('Product ID type: ${product.id.runtimeType}');
    await _bookmarkBox.put(product.id, _productToMap(product));
    print('Box keys after add: ${_bookmarkBox.keys.toList()}');
    print('=== END ADD ===');
  }

  @override
  Future<void> removeBookmark(String productId) async {
    _bookmarkBox = Hive.box(HiveTableConstant.bookmarkBox);
    print('Removing bookmark: $productId');
    await _bookmarkBox.delete(productId);
    print('Bookmark box after remove: ${_bookmarkBox.keys.toList()}');
  }

  @override
  Future<bool> isBookmarked(String productId) async {
    _bookmarkBox = Hive.box(HiveTableConstant.bookmarkBox);
    return _bookmarkBox.containsKey(productId);
  }

  Map<String, dynamic> _productToMap(ProductEntity product) {
    return {
      'id': product.id,
      'name': product.name,
      'price': product.price,
      'category': product.category,
      'stock': product.stock,
      'description': product.description,
      'imageUrl': product.imageUrl,
    };
  }

  ProductEntity _productFromMap(Map<String, dynamic> map) {
    return ProductEntity(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] is String)
          ? double.parse(map['price'])
          : (map['price'] ?? 0).toDouble(),
      category: map['category'] ?? '',
      stock: (map['stock'] is String)
          ? int.parse(map['stock'])
          : (map['stock'] ?? 0).toInt(),
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'],
    );
  }
}
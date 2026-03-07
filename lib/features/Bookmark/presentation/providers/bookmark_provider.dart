import 'package:flutter_riverpod/legacy.dart';
import 'package:gamezone_flutter/features/Bookmark/data/datasources/bookmark_local_datasource.dart';
import 'package:gamezone_flutter/features/Product/domain/entities/product_entity.dart';

final bookmarkProvider = StateNotifierProvider<BookmarkNotifier, BookmarkState>((ref) {
  return BookmarkNotifier(ref.read(bookmarkLocalDatasourceProvider));
});

class BookmarkState {
  final List<ProductEntity> bookmarks;
  final Set<String> bookmarkedIds;

  BookmarkState({
    this.bookmarks = const [],
    this.bookmarkedIds = const {},
  });

  BookmarkState copyWith({
    List<ProductEntity>? bookmarks,
    Set<String>? bookmarkedIds,
  }) {
    return BookmarkState(
      bookmarks: bookmarks ?? this.bookmarks,
      bookmarkedIds: bookmarkedIds ?? this.bookmarkedIds,
    );
  }
}

class BookmarkNotifier extends StateNotifier<BookmarkState> {
  final IBookmarkLocalDataSource _bookmarkLocalDatasource;

  BookmarkNotifier(this._bookmarkLocalDatasource) : super(BookmarkState());

  Future<void> loadBookmarks() async {
    print('Loading bookmarks...');
    try {
      final bookmarks = await _bookmarkLocalDatasource.getBookmarks();
      print('Loaded bookmarks: ${bookmarks.length}');
      final ids = bookmarks.map((p) => p.id).toSet();
      state = state.copyWith(bookmarks: bookmarks, bookmarkedIds: ids);
    } catch (e) {
      print('Load bookmarks error: $e');
    }
  }

  Future<void> toggleBookmark(ProductEntity product) async {
    print('=== TOGGLE BOOKMARK ===');
    print('Product ID: "${product.id}"');
    print('Product ID length: ${product.id.length}');
    print('Product ID isEmpty: ${product.id.isEmpty}');
    print('Product name: ${product.name}');
    print('Current bookmarkedIds: ${state.bookmarkedIds}');
    
    final isBookmarked = state.bookmarkedIds.contains(product.id);
    print('Is already bookmarked: $isBookmarked');
    
    if (isBookmarked) {
      print('Removing bookmark...');
      await _bookmarkLocalDatasource.removeBookmark(product.id);
      final newBookmarks = state.bookmarks.where((p) => p.id != product.id).toList();
      final newIds = Set<String>.from(state.bookmarkedIds)..remove(product.id);
      state = state.copyWith(bookmarks: newBookmarks, bookmarkedIds: newIds);
      print('Bookmark removed. New count: ${newBookmarks.length}');
    } else {
      print('Adding bookmark...');
      await _bookmarkLocalDatasource.addBookmark(product);
      final newBookmarks = [...state.bookmarks, product];
      final newIds = Set<String>.from(state.bookmarkedIds)..add(product.id);
      state = state.copyWith(bookmarks: newBookmarks, bookmarkedIds: newIds);
      print('Bookmark added. New count: ${newBookmarks.length}');
    }
    print('=== END TOGGLE ===');
  }

  bool isBookmarked(String productId) {
    return state.bookmarkedIds.contains(productId);
  }
}

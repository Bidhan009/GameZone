import 'package:flutter_riverpod/legacy.dart';
import 'package:gamezone_flutter/features/Product/domain/entities/product_entity.dart';
import 'package:gamezone_flutter/features/Product/domain/use_case/get_products_usecase.dart';
enum ProductStatus { initial, loading, loaded, error }
class ProductState {
  final ProductStatus status;
  final List<ProductEntity> products;
  final String? errorMessage;
  final int currentPage;
  final bool hasReachedMax;
  ProductState({
    this.status = ProductStatus.initial,
    this.products = const [],
    this.errorMessage,
    this.currentPage = 1,
    this.hasReachedMax = false,
  });
  ProductState copyWith({
    ProductStatus? status,
    List<ProductEntity>? products,
    String? errorMessage,
    int? currentPage,
    bool? hasReachedMax,
  }) {
    return ProductState(
      status: status ?? this.status,
      products: products ?? this.products,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}
class ProductNotifier extends StateNotifier<ProductState> {
  final GetProductsUseCase _getProductsUseCase;
  ProductNotifier(this._getProductsUseCase) : super(ProductState());
  Future<void> loadProducts({bool refresh = false}) async {
    if (state.hasReachedMax && !refresh) return;
    final newPage = refresh ? 1 : state.currentPage;
    state = state.copyWith(
      status: ProductStatus.loading,
      products: refresh ? [] : state.products,
      currentPage: newPage,
    );
    final result = await _getProductsUseCase(GetProductsParams(page: newPage, limit: 10));
    result.fold(
      (failure) {
        state = state.copyWith(
          status: ProductStatus.error,
          errorMessage: failure.message,
        );
      },
      (products) {
        state = state.copyWith(
          status: ProductStatus.loaded,
          products: refresh ? products : [...state.products, ...products],
          hasReachedMax: products.isEmpty,
          currentPage: newPage + 1,
        );
      },
    );
  }
  Future<void> refreshProducts() async {
    await loadProducts(refresh: true);
  }
}
final productProvider = StateNotifierProvider<ProductNotifier, ProductState>((ref) {
  return ProductNotifier(ref.read(getProductsUseCaseProvider));
});
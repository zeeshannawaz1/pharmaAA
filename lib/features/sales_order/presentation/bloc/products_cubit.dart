import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/get_products.dart';

class ProductsState {
  final List<Product> products;
  final bool loading;
  final String? error;
  ProductsState({this.products = const [], this.loading = false, this.error});
}

class ProductsCubit extends Cubit<ProductsState> {
  final GetProducts getProducts;
  ProductsCubit({required this.getProducts}) : super(ProductsState(loading: true)) {
    loadProducts();
  }

  Future<void> loadProducts() async {
    emit(ProductsState(loading: true));
    try {
      final products = await getProducts();
      emit(ProductsState(products: products, loading: false));
    } catch (e) {
      emit(ProductsState(loading: false, error: e.toString()));
    }
  }
} 

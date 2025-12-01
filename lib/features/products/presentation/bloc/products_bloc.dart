import 'package:flutter_bloc/flutter_bloc.dart';
import 'products_event.dart';
import 'products_state.dart';
import '../../domain/usecases/get_products.dart';
import '../../data/repositories/products_repository_impl.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final GetProducts getProducts;
  ProductsBloc({required this.getProducts}) : super(const ProductsState.initial()) {
    on<ProductsEvent>((event, emit) async {
      await event.map(
        loadProducts: (e) async {
          emit(const ProductsState.loading());
          try {
            final products = await getProducts();
            // Check for offline warning
            String? warning;
            if (getProducts.repository is ProductsRepositoryImpl) {
              warning = (getProducts.repository as ProductsRepositoryImpl).offlineWarning;
            }
            emit(ProductsState.loaded(products, warning: warning));
          } catch (e) {
            emit(ProductsState.error(e.toString()));
          }
        },
      );
    });
  }
} 

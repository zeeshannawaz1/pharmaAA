import '../entities/product.dart';
import '../../data/repositories/products_repository_impl.dart';

class GetProducts {
  final ProductsRepositoryImpl repository;
  GetProducts(this.repository);

  Future<List<Product>> call() async {
    return await repository.fetchProducts();
  }
} 

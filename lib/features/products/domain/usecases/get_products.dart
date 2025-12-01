import '../../../sales_order/domain/entities/product.dart';
import '../repositories/products_repository.dart';

class GetProducts {
  final ProductsRepository repository;
  GetProducts(this.repository);

  Future<List<Product>> call() async {
    return await repository.getProducts();
  }
} 

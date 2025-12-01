import '../../../sales_order/domain/entities/product.dart';
 
abstract class ProductsRepository {
  Future<List<Product>> getProducts();
} 

import '../../domain/entities/product.dart';
import '../datasources/products_remote_data_source.dart';

class ProductsRepositoryImpl {
  final ProductsRemoteDataSource remoteDataSource;
  ProductsRepositoryImpl({required this.remoteDataSource});

  Future<List<Product>> fetchProducts() async {
    final models = await remoteDataSource.fetchProducts();
    return models
        .map((m) => Product(
          prcode: m.code,
          pcode: m.code,
          pname: m.name,
          tprice: m.price.toString(),
          pdisc: m.pdisc.toString(),
        ))
        .toList();
  }
} 

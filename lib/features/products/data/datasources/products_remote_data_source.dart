import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

abstract class ProductsRemoteDataSource {
  Future<List<ProductModel>> fetchProducts();
}

class ProductsRemoteDataSourceImpl implements ProductsRemoteDataSource {
  final String baseUrl;
  ProductsRemoteDataSourceImpl({required this.baseUrl});

  @override
  Future<List<ProductModel>> fetchProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/getOrclProds.php')).timeout(Duration(seconds: 5));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => ProductModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }
} 

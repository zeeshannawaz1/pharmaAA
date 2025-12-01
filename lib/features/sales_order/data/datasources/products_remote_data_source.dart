import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ProductsRemoteDataSource {
  final String baseUrl;
  ProductsRemoteDataSource({required this.baseUrl});

  Future<List<ProductModel>> fetchProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/getOrclProds.php'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => ProductModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }
} 

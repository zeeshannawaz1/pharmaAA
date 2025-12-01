import 'dart:convert';
import 'package:http/http.dart' as http;
import '../error/failures.dart';

typedef Json = Map<String, dynamic>;

class ApiClient {
  Future<List<dynamic>> getRequest(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      } else {
        throw ServerFailure('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
} 

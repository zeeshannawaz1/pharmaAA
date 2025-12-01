import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/client_model.dart';

class ClientsRemoteDataSource {
  final String baseUrl;
  ClientsRemoteDataSource({required this.baseUrl});

  Future<List<ClientModel>> fetchClients() async {
    final response = await http.get(Uri.parse('$baseUrl/getOrclClients.php')).timeout(Duration(seconds: 5));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => ClientModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load clients');
    }
  }

  Future<int> fetchClientAreaCount() async {
    final response = await http.get(Uri.parse('$baseUrl/getclientarea.php')).timeout(Duration(seconds: 5));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.length;
    } else {
      throw Exception('Failed to load client area data');
    }
  }

  Future<int> fetchClientCityCount() async {
    final response = await http.get(Uri.parse('$baseUrl/getclientcity.php')).timeout(Duration(seconds: 5));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.length;
    } else {
      throw Exception('Failed to load client city data');
    }
  }

  Future<List<dynamic>> fetchClientAreaData() async {
    final response = await http.get(Uri.parse('$baseUrl/getclientarea.php')).timeout(Duration(seconds: 5));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to load client area data');
    }
  }

  Future<List<dynamic>> fetchClientCityData() async {
    final response = await http.get(Uri.parse('$baseUrl/getclientcity.php')).timeout(Duration(seconds: 5));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to fetch client city data');
    }
  }
} 

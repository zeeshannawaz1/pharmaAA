import 'package:aa_app/core/network/api_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String baseUrl, required String userId});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;
  AuthRemoteDataSourceImpl(this.apiClient);

  @override
  Future<UserModel> login({required String baseUrl, required String userId}) async {
    // Normalize baseUrl to ensure it starts with http:// or https://
    String normalizedBaseUrl = baseUrl.startsWith('http://') || baseUrl.startsWith('https://')
        ? baseUrl
        : 'http://$baseUrl';
    final url = '$normalizedBaseUrl/getUserLogin.php?p_userid=$userId';
    
    print('=== AUTH DEBUG ===');
    print('Attempting login with URL: $url');
    print('User ID: $userId');
    print('Base URL: $baseUrl');
    print('Normalized URL: $normalizedBaseUrl');
    
    try {
      final response = await apiClient.getRequest(url);
      print('=== AUTH DEBUG: Response received ===');
      print('Response length: ${response.length}');
      if (response.isNotEmpty) {
        print('First response item: ${response[0]}');
      }
      
      if (response.isNotEmpty && response[0]['USERID'] != 'No ID') {
        print('=== AUTH DEBUG: Login successful ===');
        return UserModel.fromJson(response[0]);
      } else {
        print('=== AUTH DEBUG: Login failed - No valid user found ===');
        throw Exception('Invalid credentials');
      }
    } catch (e) {
      print('=== AUTH DEBUG: Network error ===');
      print('Error: $e');
      throw Exception('Network error: $e');
    }
  }
} 

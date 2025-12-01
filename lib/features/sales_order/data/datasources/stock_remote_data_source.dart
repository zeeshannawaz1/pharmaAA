import 'dart:convert';
import 'package:http/http.dart' as http;

class StockRemoteDataSource {
  final String baseUrl;
  StockRemoteDataSource({required this.baseUrl});

  Future<double> fetchStock({required String date, required String pcode, String prcode = '0', String prgcode = '0'}) async {
    final url = '$baseUrl/getDailySSR.php?p_date=$date&p_prcode=$prcode&p_prgcode=$prgcode';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final body = response.body.trim();
      if (body.isEmpty || body.startsWith('<')) {
        throw Exception('Server returned invalid data or error page.');
      }
      // Extract the first valid JSON array from the response
      final arrayMatch = RegExp(r'(\[.*?\])').firstMatch(body);
      if (arrayMatch == null) {
        throw Exception('No valid JSON array found in server response: $body');
      }
      final arrayStr = arrayMatch.group(1)!;
      final List<dynamic> data = json.decode(arrayStr);
      if (data.isNotEmpty && data[0]['PCODE'] != 'No Data') {
        // Find the specific product
        final productData = data.firstWhere(
          (item) => item['PCODE'] == pcode,
          orElse: () => {'CLQTY': '0'},
        );
        return double.tryParse(productData['CLQTY'].toString()) ?? 0.0;
      }
      return 0.0;
    } else {
      throw Exception('Failed to load stock');
    }
  }

  // New method to fetch all stock data for offline syncing
  Future<List<Map<String, dynamic>>> fetchAllStockData({required String date, String prcode = '0', String prgcode = '0'}) async {
    final url = '$baseUrl/getDailySSR.php?p_date=$date&p_prcode=$prcode&p_prgcode=$prgcode';
    
    print('=== STOCK API DEBUG ===');
    print('URL: $url');
    print('Date: $date');
    print('PR Code: $prcode');
    print('PRG Code: $prgcode');
    
    final response = await http.get(Uri.parse(url));
    print('=== STOCK API DEBUG: Response status: ${response.statusCode} ===');
    print('=== STOCK API DEBUG: Response body length: ${response.body.length} ===');
    
    if (response.statusCode == 200) {
      final body = response.body.trim();
      print('=== STOCK API DEBUG: Response body: $body ===');
      
      if (body.isEmpty || body.startsWith('<')) {
        print('=== STOCK API DEBUG: Invalid response - empty or HTML ===');
        throw Exception('Server returned invalid data or error page.');
      }
      // Extract the first valid JSON array from the response
      final arrayMatch = RegExp(r'(\[.*?\])').firstMatch(body);
      if (arrayMatch == null) {
        print('=== STOCK API DEBUG: No JSON array found in response ===');
        throw Exception('No valid JSON array found in server response: $body');
      }
      final arrayStr = arrayMatch.group(1)!;
      print('=== STOCK API DEBUG: Extracted JSON array: $arrayStr ===');
      
      try {
        final List<dynamic> data = json.decode(arrayStr);
        print('=== STOCK API DEBUG: Parsed ${data.length} stock items ===');
        
        if (data.isNotEmpty && data[0]['PCODE'] != 'No Data') {
          final result = data.cast<Map<String, dynamic>>();
          print('=== STOCK API DEBUG: Returning ${result.length} valid stock items ===');
          return result;
        } else {
          print('=== STOCK API DEBUG: No valid stock data found ===');
          return [];
        }
      } catch (e) {
        print('=== STOCK API DEBUG: JSON parsing error: $e ===');
        throw Exception('Failed to parse stock data: $e');
      }
    } else {
      print('=== STOCK API DEBUG: HTTP error ${response.statusCode} ===');
      throw Exception('Failed to load stock data (HTTP ${response.statusCode})');
    }
  }
} 

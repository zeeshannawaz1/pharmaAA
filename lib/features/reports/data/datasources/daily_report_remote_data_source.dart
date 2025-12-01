import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/daily_report_model.dart';

abstract class DailyReportRemoteDataSource {
  Future<List<DailyReportModel>> fetchDailyReports({required String date, required String prcode, required String prgcode});
}

class DailyReportRemoteDataSourceImpl implements DailyReportRemoteDataSource {
  final String baseUrl;
  DailyReportRemoteDataSourceImpl({required this.baseUrl});

  @override
  Future<List<DailyReportModel>> fetchDailyReports({required String date, required String prcode, required String prgcode}) async {
    final response = await http.get(Uri.parse('$baseUrl/getDailySSR.php?p_date=$date&p_prcode=$prcode&p_prgcode=$prgcode'));
    print('DailyReport API response: ' + response.body);
    if (response.statusCode == 200) {
      final body = response.body.trim();
      if (body.isEmpty || body.startsWith('<')) {
        throw Exception('Server returned invalid data or error page.');
      }
      final arrayMatch = RegExp(r'(\[.*?\])').firstMatch(body);
      if (arrayMatch == null) {
        throw Exception('No valid JSON array found in server response: $body');
      }
      final arrayStr = arrayMatch.group(1)!;
      try {
        final List<dynamic> data = json.decode(arrayStr);
        return data.map((e) => DailyReportModel.fromJson(e)).toList();
      } catch (e) {
        throw Exception('Failed to parse report data. Server response: $arrayStr');
      }
    } else {
      throw Exception('Failed to load daily reports (HTTP ${response.statusCode})');
    }
  }
} 

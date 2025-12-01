import '../entities/daily_report.dart';
 
abstract class DailyReportRepository {
  Future<List<DailyReport>> getDailyReports({required String date, required String prcode, required String prgcode});
} 

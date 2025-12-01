import '../entities/daily_report.dart';
import '../repositories/daily_report_repository.dart';

class GetDailyReports {
  final DailyReportRepository repository;
  GetDailyReports(this.repository);

  Future<List<DailyReport>> call({required String date, required String prcode, required String prgcode}) async {
    return await repository.getDailyReports(date: date, prcode: prcode, prgcode: prgcode);
  }
} 

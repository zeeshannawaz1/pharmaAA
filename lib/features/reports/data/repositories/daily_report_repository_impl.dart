import '../../domain/entities/daily_report.dart';
import '../../domain/repositories/daily_report_repository.dart';
import '../datasources/daily_report_remote_data_source.dart';

class DailyReportRepositoryImpl implements DailyReportRepository {
  final DailyReportRemoteDataSource remoteDataSource;
  DailyReportRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<DailyReport>> getDailyReports({required String date, required String prcode, required String prgcode}) async {
    final models = await remoteDataSource.fetchDailyReports(date: date, prcode: prcode, prgcode: prgcode);
    return models.map((e) => e.toEntity()).toList();
  }
} 

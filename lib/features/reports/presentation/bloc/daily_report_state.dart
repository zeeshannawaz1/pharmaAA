import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/daily_report.dart';

part 'daily_report_state.freezed.dart';

@freezed
class DailyReportState with _$DailyReportState {
  const factory DailyReportState.initial() = _Initial;
  const factory DailyReportState.loading() = _Loading;
  const factory DailyReportState.loaded(List<DailyReport> reports) = _Loaded;
  const factory DailyReportState.error(String message) = _Error;
} 

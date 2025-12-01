import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_report_event.freezed.dart';
 
@freezed
class DailyReportEvent with _$DailyReportEvent {
  const factory DailyReportEvent.load({required String date, required String prcode, required String prgcode}) = _Load;
  const factory DailyReportEvent.loadReports() = _LoadReports;
} 

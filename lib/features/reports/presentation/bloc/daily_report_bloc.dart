import 'package:flutter_bloc/flutter_bloc.dart';
import 'daily_report_event.dart';
import 'daily_report_state.dart';
import '../../domain/usecases/get_daily_reports.dart';

class DailyReportBloc extends Bloc<DailyReportEvent, DailyReportState> {
  final GetDailyReports getDailyReports;
  DailyReportBloc({required this.getDailyReports}) : super(const DailyReportState.initial()) {
    on<DailyReportEvent>((event, emit) async {
      await event.map(
        load: (e) async {
          emit(const DailyReportState.loading());
          try {
            final reports = await getDailyReports(
              date: e.date,
              prcode: e.prcode,
              prgcode: e.prgcode,
            );
            emit(DailyReportState.loaded(reports));
          } catch (e) {
            emit(DailyReportState.error(e.toString()));
          }
        },
        loadReports: (e) async {
          emit(const DailyReportState.loading());
          try {
            // For now, return empty list for loadReports
            // This can be updated to fetch all reports without specific parameters
            emit(const DailyReportState.loaded([]));
          } catch (e) {
            emit(DailyReportState.error(e.toString()));
          }
        },
      );
    });
  }
} 

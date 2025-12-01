import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_stock.dart';

class StockState {
  final double? stock;
  final bool loading;
  final String? error;
  StockState({this.stock, this.loading = false, this.error});
}

class StockCubit extends Cubit<StockState> {
  final GetStock getStock;
  StockCubit({required this.getStock}) : super(StockState());

  Future<void> loadStock({required String date, required String pcode, String prcode = '0', String prgcode = '0'}) async {
    print('=== STOCK CUBIT DEBUG: Starting stock load ===');
    print('Date: $date, PCode: $pcode, PRCode: $prcode, PRGCode: $prgcode');
    
    emit(StockState(loading: true));
    try {
      final stock = await getStock(date: date, pcode: pcode, prcode: prcode, prgcode: prgcode);
      print('=== STOCK CUBIT DEBUG: Stock loaded successfully: $stock ===');
      emit(StockState(stock: stock, loading: false));
    } catch (e) {
      print('=== STOCK CUBIT DEBUG: Stock load error: ${e.toString()} ===');
      emit(StockState(loading: false, error: e.toString()));
    }
  }
} 

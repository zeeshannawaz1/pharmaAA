import 'package:connectivity_plus/connectivity_plus.dart';
import '../datasources/stock_remote_data_source.dart';
import '../../../../core/database/offline_database_service.dart';

class StockRepositoryImpl {
  final StockRemoteDataSource remoteDataSource;
  
  StockRepositoryImpl({required this.remoteDataSource});

  Future<double> fetchStock({required String date, required String pcode, String prcode = '0', String prgcode = '0'}) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    bool isOnline = connectivityResult != ConnectivityResult.none;
    
    if (isOnline) {
      try {
        return await remoteDataSource.fetchStock(date: date, pcode: pcode, prcode: prcode, prgcode: prgcode);
      } catch (e) {
        print('=== STOCK DEBUG: Online fetch failed, trying offline:  [31m${e.toString()} [0m ===');
        // Fallback to offline data
        return await _getOfflineStock(pcode, date, prcode, prgcode);
      }
    } else {
      print('=== STOCK DEBUG: No internet, using offline data ===');
      return await _getOfflineStock(pcode, date, prcode, prgcode);
    }
  }

  Future<double> _getOfflineStock(String pcode, String date, String prcode, String prgcode) async {
    try {
      final offlineStock = await OfflineDatabaseService().getOfflineStock(pcode, date, prcode, prgcode);
      if (offlineStock != null) {
        print('=== STOCK DEBUG: Found offline stock: $offlineStock ===');
        return offlineStock;
      } else {
        print('=== STOCK DEBUG: No offline stock found ===');
        return 0.0;
      }
    } catch (e) {
      print('=== STOCK DEBUG: Offline stock error:  [31m${e.toString()} [0m ===');
      return 0.0;
    }
  }
} 

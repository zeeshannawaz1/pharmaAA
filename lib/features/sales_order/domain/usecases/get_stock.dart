import '../../data/repositories/stock_repository_impl.dart';

class GetStock {
  final StockRepositoryImpl repository;
  GetStock(this.repository);
 
  Future<double> call({required String date, required String pcode, String prcode = '0', String prgcode = '0'}) async {
    return await repository.fetchStock(date: date, pcode: pcode, prcode: prcode, prgcode: prgcode);
  }
} 

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import '../../../sales_order/domain/entities/product.dart';
import '../../domain/repositories/products_repository.dart';
import '../datasources/products_remote_data_source.dart';
import '../models/product_model.dart';
import 'package:aa_app/core/database/offline_database_service.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  final ProductsRemoteDataSource remoteDataSource;
  final OfflineDatabaseService _offlineDatabase = OfflineDatabaseService();
  
  ProductsRepositoryImpl({required this.remoteDataSource});

  String? offlineWarning;

  @override
  Future<List<Product>> getProducts() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    bool isOnline = connectivityResult != ConnectivityResult.none;
    
    if (isOnline) {
      try {
        final models = await remoteDataSource.fetchProducts();
        offlineWarning = null;
        return models.map((e) => e.toEntity()).toList();
      } catch (e) {
        offlineWarning = 'Remote server is not online. Loading offline data.';
        return await _loadOfflineData();
      }
    } else {
      offlineWarning = 'No internet connection. Loading offline data.';
      return await _loadOfflineData();
    }
  }

  Future<List<Product>> _loadOfflineData() async {
    try {
      // First try to load from offline database
      final offlineProducts = await _offlineDatabase.getOfflineProducts();
      if (offlineProducts.isNotEmpty) {
        return offlineProducts;
      }
      
      // Fallback to CSV if no offline database data
      return await _loadProductsFromCsv();
    } catch (e) {
      // Final fallback to CSV
      return await _loadProductsFromCsv();
    }
  }

  Future<List<Product>> _loadProductsFromCsv() async {
    try {
      final rawData = await rootBundle.loadString('assets/csv/products.csv');
      final List<List<dynamic>> csvData = const CsvToListConverter().convert(rawData, eol: '\n');
      // Assuming first row is header
      final headers = csvData.first.map((e) => e.toString()).toList();
      final dataRows = csvData.skip(1);
      return dataRows.map((row) {
        final map = <String, dynamic>{};
        for (int i = 0; i < headers.length && i < row.length; i++) {
          map[headers[i]] = row[i];
        }
        return ProductModel.fromJson(map).toEntity();
      }).toList();
    } catch (e) {
      throw Exception('Failed to load products from CSV: $e');
    }
  }
} 

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:aa_app/core/database/offline_database_service.dart';
import 'package:aa_app/features/products/data/datasources/products_remote_data_source.dart';
import 'package:aa_app/features/sales_order/data/datasources/clients_remote_data_source.dart';
import 'package:aa_app/features/sales_order/data/datasources/stock_remote_data_source.dart';
import '../../features/sales_order/domain/entities/product.dart';
import '../../features/sales_order/domain/entities/client.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class OfflineSyncService {
  final OfflineDatabaseService _databaseService = OfflineDatabaseService();

  Future<Map<String, dynamic>> syncOfflineData({required String baseUrl, void Function(String message, {bool? error, int? progress, int? total})? onProgress}) async {
    print('[SYNC] Starting syncOfflineData with baseUrl: $baseUrl');
    try {
      // Check connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      print('[SYNC] Connectivity result: $connectivityResult');
      if (connectivityResult == ConnectivityResult.none) {
        print('[SYNC] No internet connection available');
        onProgress?.call('No internet connection available', error: true);
        return {
          'success': false,
          'message': 'No internet connection available',
          'products_synced': 0,
          'clients_synced': 0,
          'stock_synced': 0,
        };
      }

      // Test server connectivity first
      onProgress?.call('Testing server connectivity...');
      try {
        final testUrl = Uri.parse('$baseUrl/getOrclProds.php');
        final response = await http.get(testUrl).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException('Server connection timeout', const Duration(seconds: 10));
          },
        );
        
        if (response.statusCode != 200) {
          throw Exception('Server returned status code: ${response.statusCode}');
        }
        
        print('[SYNC] Server connectivity test passed');
        onProgress?.call('Server connection verified');
      } catch (e) {
        print('[SYNC] Server connectivity test failed: $e');
        String errorMessage = 'Server is not available';
        
        if (e.toString().contains('SocketException') ||
            e.toString().contains('No route to host') ||
            e.toString().contains('Failed host lookup')) {
          errorMessage = 'Server is unreachable. Please check your connection or try again later.';
        } else if (e.toString().contains('TimeoutException')) {
          errorMessage = 'Server connection timeout. Please try again.';
        } else if (e.toString().contains('Connection refused')) {
          errorMessage = 'Server is currently unavailable. Please try again later.';
        }
        
        onProgress?.call(errorMessage, error: true);
        return {
          'success': false,
          'message': errorMessage,
          'products_synced': 0,
          'clients_synced': 0,
          'stock_synced': 0,
        };
      }

      int productsSynced = 0;
      int clientsSynced = 0;
      int stockSynced = 0;
      int clientAreaCount = 0;
      int clientCityCount = 0;
      String message = '';

      final productsDataSource = ProductsRemoteDataSourceImpl(baseUrl: baseUrl);
      final clientsDataSource = ClientsRemoteDataSource(baseUrl: baseUrl);
      final stockDataSource = StockRemoteDataSource(baseUrl: baseUrl);

      // Sync products
      try {
        print('[SYNC] Fetching products...');
        onProgress?.call('Syncing products...');
        final products = await productsDataSource.fetchProducts();
        print('[SYNC] Products fetched:  [32m${products.length} [0m');
        await _databaseService.saveProducts(products.map((e) => e.toEntity()).toList());
        print('[SYNC] Products saved to DB');
        onProgress?.call('Products synced: ${products.length}');
        productsSynced = products.length;
        message += 'Products synced successfully. ';
      } catch (e) {
        print('[SYNC][ERROR] Failed to sync products: $e');
        String errorMsg = 'Failed to sync products';
        if (e.toString().contains('SocketException') || e.toString().contains('Connection refused')) {
          errorMsg = 'Server connection lost while syncing products';
        } else if (e.toString().contains('TimeoutException')) {
          errorMsg = 'Product sync timed out';
        }
        onProgress?.call('$errorMsg: ${e.toString()}', error: true);
        message += '$errorMsg. ';
      }

      // Sync clients
      try {
        print('[SYNC] Fetching clients...');
        onProgress?.call('Syncing clients...');
        final clients = await clientsDataSource.fetchClients();
        print('[SYNC] Clients fetched:  [32m${clients.length} [0m');
        
        // Clear existing duplicates before saving new clients
        await _databaseService.clearDuplicateClients();
        
        await _databaseService.saveClients(clients.map((e) => Client(
          code: e.clientCode,
          name: e.clientName,
          address: e.clientAdd,
          city: e.city,
          area: e.area ?? '',
        )).toList());
        print('[SYNC] Clients saved to DB');
        onProgress?.call('Clients synced: ${clients.length}');
        clientsSynced = clients.length;
        // Professional: Verify clients are saved and check for duplicates
        final savedClients = await _databaseService.getOfflineClients();
        final duplicates = await _databaseService.checkDuplicateClients();
        
        print('[DEBUG] Clients loaded from SQLite:');
        for (final c in savedClients) {
          print('  code:  [36m${c.code} [0m, name:  [36m${c.name} [0m, city:  [36m${c.city} [0m, area:  [36m${c.area} [0m');
        }
        
        if (duplicates.isNotEmpty) {
          print('[SYNC][WARNING] Found ${duplicates.length} duplicate client codes: $duplicates');
          onProgress?.call('Warning: Found duplicate clients. Cleaning up...');
          await _databaseService.clearDuplicateClients();
          // Reload clients after cleanup
          final cleanedClients = await _databaseService.getOfflineClients();
          print('[SYNC] After cleanup: ${cleanedClients.length} unique clients');
        }
        
        if (savedClients.isEmpty) {
          print('[SYNC][ERROR] No clients found in SQLite after save!');
          onProgress?.call('Error: No clients saved for offline use. Please check server data and storage.', error: true);
          message += 'No clients saved for offline use. ';
        } else {
          print('[SYNC] Verified ${savedClients.length} clients in SQLite.');
        }
        message += 'Clients synced successfully. ';
      } catch (e) {
        print('[SYNC][ERROR] Failed to sync clients: $e');
        String errorMsg = 'Failed to sync clients';
        if (e.toString().contains('SocketException') || e.toString().contains('Connection refused')) {
          errorMsg = 'Server connection lost while syncing clients';
        } else if (e.toString().contains('TimeoutException')) {
          errorMsg = 'Client sync timed out';
        }
        onProgress?.call('$errorMsg: ${e.toString()}', error: true);
        message += '$errorMsg. ';
      }

      // Sync client area data (save as JSON file)
      try {
        print('[SYNC] Fetching client area data...');
        onProgress?.call('Syncing client area data...');
        final clientAreaData = await clientsDataSource.fetchClientAreaData();
        print('[SYNC] Client area data fetched:  [32m${clientAreaData.length} [0m');
        final appDocDir = await getApplicationDocumentsDirectory();
        final dir = Directory('${appDocDir.path}/offline_data');
        if (!await dir.exists()) {
          print('[SYNC] Creating offline_data directory');
          await dir.create(recursive: true);
        }
        final file = File('${dir.path}/getclientarea.json');
        await file.writeAsString(jsonEncode(clientAreaData));
        print('[SYNC] Client area data saved to file: ${file.path}');
        onProgress?.call('Client area data synced: ${clientAreaData.length}');
        clientAreaCount = clientAreaData.length;
        message += 'Client area data synced. ';
      } catch (e) {
        print('[SYNC][ERROR] Failed to sync client area data: $e');
        onProgress?.call('Failed to sync client area data: ${e.toString()}', error: true);
        message += 'Failed to sync client area data: ${e.toString()}. ';
      }

      // Sync client city data (save as JSON file)
            try {
        print('[SYNC] Fetching client city data...');
        onProgress?.call('Syncing client city data...');
        final clientCityData = await clientsDataSource.fetchClientCityData();
        print('[SYNC] Client city data fetched:  [32m${clientCityData.length} [0m');
        final appDocDir = await getApplicationDocumentsDirectory();
        final dir = Directory('${appDocDir.path}/offline_data');
        if (!await dir.exists()) {
          print('[SYNC] Creating offline_data directory');
          await dir.create(recursive: true);
        }
        final file = File('${dir.path}/getclientcity.json');
        await file.writeAsString(jsonEncode(clientCityData));
        print('[SYNC] Client city data saved to file: ${file.path}');
        onProgress?.call('Client city data synced: ${clientCityData.length}');
        clientCityCount = clientCityData.length;
        message += 'Client city data synced. ';
      } catch (e) {
        print('[SYNC][ERROR] Failed to sync client city data: $e');
        onProgress?.call('Failed to sync client city data: ${e.toString()}', error: true);
        message += 'Failed to sync client city data: ${e.toString()}. ';
      }

      // Remove the entire block that syncs stock data (getDailySSR.php)
      // No stock data will be fetched or saved during sync.

      // Final notification
      onProgress?.call('Sync finished!');
      print('[SYNC] Sync finished!');
      print('[SYNC] Sync complete. Products: $productsSynced, Clients: $clientsSynced, Stock: $stockSynced, Areas: $clientAreaCount');
      return {
        'success': true,
        'message': message.trim(),
        'products_synced': productsSynced,
        'clients_synced': clientsSynced,
        'stock_synced': stockSynced,
        'client_area_count': clientAreaCount,
        'client_city_count': clientCityCount,
      };
    } catch (e) {
      print('[SYNC][ERROR] Sync failed: $e');
      onProgress?.call('Sync failed: ${e.toString()}', error: true);
      return {
        'success': false,
        'message': 'Sync failed: ${e.toString()}',
        'products_synced': 0,
        'clients_synced': 0,
        'stock_synced': 0,
      };
    }
  }

  Future<Map<String, dynamic>> getSyncStatus() async {
    return await _databaseService.getSyncStatus();
  }

  Future<List<Product>> getOfflineProducts() async {
    return await _databaseService.getOfflineProducts();
  }

  Future<List<Client>> getOfflineClients() async {
    return await _databaseService.getOfflineClients();
  }

  Future<double?> getOfflineStock(String pcode, String date, String prcode, String prgcode) async {
    return await _databaseService.getOfflineStock(pcode, date, prcode, prgcode);
  }

  Future<void> clearOfflineData() async {
    await _databaseService.clearAllOfflineData();
  }
} 

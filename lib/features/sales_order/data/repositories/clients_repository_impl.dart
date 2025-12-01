import 'package:connectivity_plus/connectivity_plus.dart';
import '../../domain/entities/client.dart';
import '../datasources/clients_remote_data_source.dart';
import 'package:aa_app/core/database/offline_database_service.dart';

class ClientsRepositoryImpl {
  final ClientsRemoteDataSource remoteDataSource;
  final OfflineDatabaseService _offlineDatabase = OfflineDatabaseService();
  
  ClientsRepositoryImpl({required this.remoteDataSource});

  Future<List<Client>> fetchClients() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    bool isOnline = connectivityResult != ConnectivityResult.none;
    
    if (isOnline) {
      try {
        final models = await remoteDataSource.fetchClients();
        return models
            .map((m) => Client(
              code: m.clientCode, 
              name: m.clientName, 
              address: m.clientAdd,
              city: m.city,
              area: m.area,
            ))
            .toList();
      } catch (e) {
        // Fallback to offline data if remote fails
        return await _loadOfflineClients();
      }
    } else {
      // Use offline data when no internet
      return await _loadOfflineClients();
    }
  }

  Future<List<String>> getCities() async {
    final clients = await fetchClients();
    final cities = clients.map((c) => c.city).where((c) => c.isNotEmpty).toSet().toList();
    cities.sort();
    return cities;
  }

  Future<List<String>> getAreas() async {
    final clients = await fetchClients();
    final areas = clients.map((c) => c.area).where((a) => a.isNotEmpty).toSet().toList();
    areas.sort();
    return areas;
  }

  Future<List<Client>> _loadOfflineClients() async {
    try {
      final offlineClients = await _offlineDatabase.getOfflineClients();
      if (offlineClients.isNotEmpty) {
        return offlineClients;
      }
      
      // Return empty list if no offline data available
      return [];
    } catch (e) {
      return [];
    }
  }
} 

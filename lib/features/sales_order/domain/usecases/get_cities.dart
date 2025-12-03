import '../../data/repositories/clients_repository_impl.dart';

class GetCities {
  final ClientsRepositoryImpl repository;
  GetCities(this.repository);

  Future<List<String>> call() async {
    final clients = await repository.fetchClients();
    final cities = clients.map((c) => c.city).where((c) => c.isNotEmpty).toSet().toList();
    cities.sort();
    return cities;
  }
} 

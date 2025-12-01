import '../entities/client.dart';
import '../../data/repositories/clients_repository_impl.dart';

class GetAreas {
  final ClientsRepositoryImpl repository;
  GetAreas(this.repository);

  Future<List<String>> call() async {
    final clients = await repository.fetchClients();
    final areas = clients.map((c) => c.area).where((a) => a.isNotEmpty).toSet().toList();
    areas.sort();
    return areas;
  }
} 

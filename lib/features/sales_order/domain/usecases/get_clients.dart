import '../entities/client.dart';
import '../../data/repositories/clients_repository_impl.dart';

class GetClients {
  final ClientsRepositoryImpl repository;
  GetClients(this.repository);

  Future<List<Client>> call() async {
    return await repository.fetchClients();
  }
} 

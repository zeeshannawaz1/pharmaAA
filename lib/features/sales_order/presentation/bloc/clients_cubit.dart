import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/client.dart';
import '../../domain/usecases/get_clients.dart';

class ClientsState {
  final List<Client> clients;
  final bool loading;
  final String? error;
  ClientsState({this.clients = const [], this.loading = false, this.error});
}

class ClientsCubit extends Cubit<ClientsState> {
  final GetClients getClients;
  ClientsCubit({required this.getClients}) : super(ClientsState(loading: true)) {
    loadClients();
  }

  Future<void> loadClients() async {
    emit(ClientsState(loading: true));
    try {
      final clients = await getClients();
      emit(ClientsState(clients: clients, loading: false));
    } catch (e) {
      emit(ClientsState(loading: false, error: e.toString()));
    }
  }
} 

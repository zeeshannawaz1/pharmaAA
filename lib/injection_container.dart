import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/network/api_client.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_user.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/sales_order/data/datasources/order_draft_local_data_source.dart';
import 'features/sales_order/data/repositories/order_draft_repository_impl.dart';
import 'features/sales_order/domain/repositories/order_draft_repository.dart';
import 'features/sales_order/domain/usecases/get_order_drafts.dart';
import 'features/sales_order/domain/usecases/save_order_draft.dart';
import 'features/sales_order/domain/usecases/delete_order_draft.dart';
import 'features/sales_order/domain/usecases/delete_all_order_drafts.dart';
import 'features/sales_order/presentation/bloc/order_draft_bloc.dart';

final sl = GetIt.instance;

void init() async {
  // Core
  sl.registerLazySingleton<ApiClient>(() => ApiClient());
  
  // SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // Auth Feature
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerFactory(() => AuthBloc(loginUser: sl()));

  // Order Draft Feature
  sl.registerLazySingleton<OrderDraftLocalDataSource>(
    () => OrderDraftLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<OrderDraftRepository>(
    () => OrderDraftRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetOrderDrafts(sl()));
  sl.registerLazySingleton(() => SaveOrderDraft(sl()));
  sl.registerLazySingleton(() => DeleteOrderDraft(sl()));
  sl.registerLazySingleton(() => DeleteAllOrderDrafts(sl()));
  sl.registerFactory(() => OrderDraftBloc(
    getOrderDrafts: sl(),
    saveOrderDraft: sl(),
    deleteOrderDraft: sl(),
    deleteAllOrderDrafts: sl(),
  ));
} 

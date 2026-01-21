import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Infrastructure - Providers
import 'infrastructure/providers/http_client.dart';
import 'infrastructure/providers/firebase_auth_provider.dart';
import 'infrastructure/providers/qr_api.dart';
import 'infrastructure/providers/access_history_api.dart';
import 'infrastructure/providers/visitor_api.dart';
import 'infrastructure/providers/family_members_api.dart';
import 'infrastructure/providers/admin_api.dart';

// Infrastructure - Adapters
import 'infrastructure/adapters/auth_repository_impl.dart';
import 'infrastructure/adapters/account_repository_impl.dart';
import 'infrastructure/adapters/qr_repository_impl.dart';
import 'infrastructure/adapters/access_history_repository_impl.dart';
import 'infrastructure/adapters/visitor_repository_impl.dart';
import 'infrastructure/adapters/admin_repository_impl.dart';

// Domain - Ports
import 'domain/ports/auth_repository.dart';
import 'domain/ports/account_repository.dart';
import 'domain/ports/qr_repository.dart';
import 'domain/ports/access_history_repository.dart';
import 'domain/ports/visitor_repository.dart';
import 'domain/ports/admin_repository.dart';

// Domain - Use Cases
import 'domain/usecases/login_usecase.dart';
import 'domain/usecases/generate_qr_usecase.dart';
import 'domain/usecases/generate_visit_qr_usecase.dart';
import 'domain/usecases/load_access_history_usecase.dart';
import 'domain/usecases/manage_visitor_usecase.dart';
import 'domain/usecases/get_admin_metrics_usecase.dart';
import 'domain/usecases/get_residents_usecase.dart';

// BLoCs
import 'application/blocs/admin/admin_dashboard_bloc.dart';

final sl = GetIt.instance;

Future<void> inject() async {
  // Configuration
  const String apiBaseUrl = 'http://192.168.1.3:8080/api/v1'; // Cambiar según ambiente

  // Firebase
  final firebaseAuth = FirebaseAuth.instance;
  sl.registerLazySingleton<FirebaseAuth>(() => firebaseAuth);

  // HTTP Client
  final apiHttpClient = ApiHttpClient(
    baseUrl: apiBaseUrl,
    firebaseAuth: firebaseAuth,
  );
  sl.registerLazySingleton<ApiHttpClient>(() => apiHttpClient);

  // Providers
  sl.registerLazySingleton<FirebaseAuthProvider>(
    () => FirebaseAuthProvider(firebaseAuth),
  );

  sl.registerLazySingleton<ApiAuthProvider>(
    () => ApiAuthProvider(apiHttpClient.dio),
  );

  sl.registerLazySingleton<QrApi>(
    () => QrApi(apiHttpClient.dio),
  );

  sl.registerLazySingleton<AccessHistoryApi>(
    () => AccessHistoryApi(apiHttpClient.dio),
  );

  sl.registerLazySingleton<VisitorApi>(
    () => VisitorApi(apiHttpClient.dio),
  );

  sl.registerLazySingleton<FamilyMembersApi>(
    () => FamilyMembersApi(apiHttpClient.dio),
  );

  sl.registerLazySingleton<AdminApi>(
    () => AdminApi(apiHttpClient.dio),
  );

  // Adapters (Repositories)
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      firebaseProvider: sl<FirebaseAuthProvider>(),
      apiProvider: sl<ApiAuthProvider>(),
    ),
  );

  sl.registerLazySingleton<AccountRepository>(
    () => AccountRepositoryImpl(sl<ApiAuthProvider>(), sl<FamilyMembersApi>()),
  );

  sl.registerLazySingleton<QrRepository>(
    () => QrRepositoryImpl(sl<QrApi>()),
  );

  sl.registerLazySingleton<AccessHistoryRepository>(
    () => AccessHistoryRepositoryImpl(sl<AccessHistoryApi>()),
  );

  sl.registerFactory<VisitorRepository>(
    () {
      // Get personaId from authenticated user
      final user = firebaseAuth.currentUser;
      final personaId = user != null ? int.tryParse(user.uid) ?? 0 : 0;
      return VisitorRepositoryImpl(
        api: sl<VisitorApi>(),
        personaId: personaId,
      );
    },
  );

  sl.registerLazySingleton<AdminRepository>(
    () => AdminRepositoryImpl(sl<AdminApi>()),
  );

  // Use Cases
  sl.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<GenerateQrUseCase>(
    () => GenerateQrUseCase(sl<QrRepository>()),
  );

  sl.registerLazySingleton<LoadAccessHistoryUseCase>(
    () => LoadAccessHistoryUseCase(sl<AccessHistoryRepository>()),
  );

  sl.registerLazySingleton<GenerateVisitQrUseCase>(
    () => GenerateVisitQrUseCase(sl<QrRepository>()),
  );

  sl.registerLazySingleton<ManageVisitorUseCase>(
    () => ManageVisitorUseCase(sl<VisitorRepository>()),
  );

  sl.registerLazySingleton<GetAdminMetricsUseCase>(
    () => GetAdminMetricsUseCase(sl<AdminRepository>()),
  );

  sl.registerLazySingleton<GetResidentsUseCase>(
    () => GetResidentsUseCase(sl<AdminRepository>()),
  );

  // BLoCs
  sl.registerLazySingleton<AdminDashboardBloc>(
    () => AdminDashboardBloc(sl<GetAdminMetricsUseCase>()),
  );
}

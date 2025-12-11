import 'package:get_it/get_it.dart';
import 'core/config/env.dart';
import 'core/config/brand_theme.dart';
import 'data/providers/firebase_auth_provider.dart';
import 'data/providers/firestore_provider.dart';
import 'data/providers/http_client.dart';
import 'data/providers/face_api.dart';
import 'data/providers/face_local.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/account_repository_impl.dart';
import 'data/repositories/qr_repository_impl.dart';
import 'data/repositories/access_history_repository_impl.dart';
import 'data/repositories/face_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/account_repository.dart';
import 'domain/repositories/qr_repository.dart';
import 'domain/repositories/access_history_repository.dart';
import 'domain/repositories/face_repository.dart';
import 'core/config/brand_theme.dart';

final sl = GetIt.instance;

Future<void> inject() async {
  // Env y tema parametrizable por cliente
  sl.registerLazySingleton<Env>(() => Env(
        baseUrl: 'https://api.example.com',
        faceMode: FaceMode.local,
        brandTheme: defaultBrand,
      ));

  // HTTP client (si se usa backend adicional)
  sl.registerLazySingleton<HttpClient>(() => HttpClient(baseUrl: sl<Env>().baseUrl));

  // Firebase
  sl.registerLazySingleton<FirebaseAuthProvider>(() => FirebaseAuthProvider());
  sl.registerLazySingleton<FirestoreProvider>(() => FirestoreProvider());

  // Providers Face
  sl.registerLazySingleton<FaceApi>(() => FaceApi(sl<HttpClient>()));
  sl.registerLazySingleton<FaceLocal>(() => FaceLocal());

  // Repos Face conmutables
  sl.registerLazySingleton<FaceRepository>(() => FaceRepositoryImpl(
        mode: sl<Env>().faceMode,
        api: sl<FaceApi>(),
        local: sl<FaceLocal>(),
      ));

  // Repositorios
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(
        auth: sl<FirebaseAuthProvider>(),
        db: sl<FirestoreProvider>(),
      ));
  sl.registerLazySingleton<AccountRepository>(() => AccountRepositoryImpl(db: sl<FirestoreProvider>()));
  sl.registerLazySingleton<QrRepository>(() => QrRepositoryImpl(db: sl<FirestoreProvider>()));
  sl.registerLazySingleton<AccessHistoryRepository>(() => AccessHistoryRepositoryImpl(db: sl<FirestoreProvider>()));
}

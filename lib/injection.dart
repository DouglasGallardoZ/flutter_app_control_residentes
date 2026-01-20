import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'infrastructure/providers/firestore_provider.dart';
import 'infrastructure/providers/firebase_auth_provider.dart';
import 'infrastructure/adapters/auth_repository_impl.dart';
import 'infrastructure/adapters/account_repository_impl.dart';
import 'infrastructure/adapters/qr_repository_impl.dart';
import 'infrastructure/adapters/access_history_repository_impl.dart';
import 'infrastructure/adapters/visitor_repository_impl.dart';

import 'domain/ports/auth_repository.dart';
import 'domain/ports/account_repository.dart';
import 'domain/ports/qr_repository.dart';
import 'domain/ports/access_history_repository.dart';
import 'domain/ports/visitor_repository.dart';

import 'domain/usecases/login_usecase.dart';
import 'domain/usecases/register_account_usecase.dart';
import 'domain/usecases/load_family_members_usecase.dart';
import 'domain/usecases/generate_qr_usecase.dart';
import 'domain/usecases/load_access_history_usecase.dart';
import 'domain/usecases/manage_visitor_usecase.dart';
import 'domain/usecases/generate_visit_qr_usecase.dart';

final sl = GetIt.instance;

Future<void> inject() async {
  // Providers
  sl.registerLazySingleton(() => FirestoreProvider(FirebaseFirestore.instance));
  sl.registerLazySingleton(() => FirebaseAuthProvider(FirebaseAuth.instance));

  // Adapters (repos)
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<AccountRepository>(() => AccountRepositoryImpl(sl()));
  sl.registerLazySingleton<QrRepository>(() => QrRepositoryImpl(sl()));
  sl.registerLazySingleton<AccessHistoryRepository>(() => AccessHistoryRepositoryImpl(sl()));
  sl.registerLazySingleton<VisitorRepository>(() => VisitorRepositoryImpl(sl()));

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl(), sl()));
  sl.registerLazySingleton(() => RegisterAccountUseCase(sl()));
  sl.registerLazySingleton(() => LoadFamilyMembersUseCase(sl()));
  sl.registerLazySingleton(() => GenerateQrUseCase(sl()));
  sl.registerLazySingleton(() => LoadAccessHistoryUseCase(sl()));
  sl.registerLazySingleton(() => GenerateVisitQrUseCase(sl()));
  sl.registerLazySingleton(() => ManageVisitorUseCase(sl()));
}

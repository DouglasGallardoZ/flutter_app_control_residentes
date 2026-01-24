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
import 'infrastructure/adapters/resident_repository_impl.dart';
import 'infrastructure/adapters/owner_repository_impl.dart';
import 'infrastructure/adapters/member_repository_impl.dart';
import 'infrastructure/adapters/admin_account_repository_impl.dart';

// Domain - Ports
import 'domain/ports/auth_repository.dart';
import 'domain/ports/account_repository.dart';
import 'domain/ports/qr_repository.dart';
import 'domain/ports/access_history_repository.dart';
import 'domain/ports/visitor_repository.dart';
import 'domain/ports/admin_repository.dart';
import 'domain/ports/resident_repository.dart';
import 'domain/ports/owner_repository.dart';
import 'domain/ports/member_repository.dart';
import 'domain/ports/admin_account_repository.dart';

// Domain - Use Cases
import 'domain/usecases/login_usecase.dart';
import 'domain/usecases/generate_qr_usecase.dart';
import 'domain/usecases/generate_visit_qr_usecase.dart';
import 'domain/usecases/load_access_history_usecase.dart';
import 'domain/usecases/manage_visitor_usecase.dart';
import 'domain/usecases/get_admin_metrics_usecase.dart';
import 'domain/usecases/get_residents_usecase.dart';
import 'domain/usecases/create_resident_usecase.dart';
import 'domain/usecases/load_residents_by_location_usecase.dart';
import 'domain/usecases/deactivate_resident_usecase.dart';
import 'domain/usecases/reactivate_resident_usecase.dart';
import 'domain/usecases/delete_resident_usecase.dart';
import 'domain/usecases/load_owners_by_location_usecase.dart';
import 'domain/usecases/block_owner_usecase.dart';
import 'domain/usecases/unblock_owner_usecase.dart';
import 'domain/usecases/delete_owner_usecase.dart';
import 'domain/usecases/get_owner_properties_usecase.dart';
import 'domain/usecases/create_owner_usecase.dart';
import 'domain/usecases/load_members_by_location_usecase.dart';
import 'domain/usecases/deactivate_member_usecase.dart';
import 'domain/usecases/reactivate_member_usecase.dart';
import 'domain/usecases/delete_member_usecase.dart';
import 'domain/usecases/create_member_usecase.dart';
import 'domain/usecases/search_account_by_email_usecase.dart';
import 'domain/usecases/search_account_by_location_usecase.dart';
import 'domain/usecases/block_account_usecase.dart';
import 'domain/usecases/unblock_account_usecase.dart';
import 'domain/usecases/delete_account_usecase.dart';
import 'domain/usecases/reset_password_usecase.dart';

// BLoCs
import 'application/blocs/admin/admin_dashboard_bloc.dart';
import 'application/blocs/facial_enrollment/facial_enrollment_bloc.dart';
import 'application/blocs/resident/resident_bloc.dart';
import 'application/blocs/owner/owner_bloc.dart';
import 'application/blocs/member/member_bloc.dart';
import 'application/blocs/admin_account/admin_account_bloc.dart';

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

  sl.registerLazySingleton<ResidentRepository>(
    () => ResidentRepositoryImpl(sl<AdminApi>()),
  );

  sl.registerLazySingleton<OwnerRepository>(
    () => OwnerRepositoryImpl(adminApi: sl<AdminApi>()),
  );

  sl.registerLazySingleton<MemberRepository>(
    () => MemberRepositoryImpl(adminApi: sl<AdminApi>()),
  );

  sl.registerLazySingleton<AdminAccountRepository>(
    () => AdminAccountRepositoryImpl(adminApi: sl<AdminApi>()),
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

  sl.registerLazySingleton<CreateResidentUseCase>(
    () => CreateResidentUseCase(sl<ResidentRepository>()),
  );

  sl.registerLazySingleton<LoadResidentsByLocationUseCase>(
    () => LoadResidentsByLocationUseCase(sl<ResidentRepository>()),
  );

  sl.registerLazySingleton<DeactivateResidentUseCase>(
    () => DeactivateResidentUseCase(sl<ResidentRepository>()),
  );

  sl.registerLazySingleton<ReactivateResidentUseCase>(
    () => ReactivateResidentUseCase(sl<ResidentRepository>()),
  );

  sl.registerLazySingleton<DeleteResidentUseCase>(
    () => DeleteResidentUseCase(sl<ResidentRepository>()),
  );

  sl.registerLazySingleton<LoadOwnersByLocationUseCase>(
    () => LoadOwnersByLocationUseCase(sl<OwnerRepository>()),
  );

  sl.registerLazySingleton<BlockOwnerUseCase>(
    () => BlockOwnerUseCase(sl<OwnerRepository>()),
  );

  sl.registerLazySingleton<UnblockOwnerUseCase>(
    () => UnblockOwnerUseCase(sl<OwnerRepository>()),
  );

  sl.registerLazySingleton<DeleteOwnerUseCase>(
    () => DeleteOwnerUseCase(sl<OwnerRepository>()),
  );

  sl.registerLazySingleton<GetOwnerPropertiesUseCase>(
    () => GetOwnerPropertiesUseCase(sl<OwnerRepository>()),
  );

  sl.registerLazySingleton<CreateOwnerUseCase>(
    () => CreateOwnerUseCase(sl<OwnerRepository>()),
  );

  sl.registerLazySingleton<LoadMembersByLocationUseCase>(
    () => LoadMembersByLocationUseCase(sl<MemberRepository>()),
  );

  sl.registerLazySingleton<DeactivateMemberUseCase>(
    () => DeactivateMemberUseCase(sl<MemberRepository>()),
  );

  sl.registerLazySingleton<ReactivateMemberUseCase>(
    () => ReactivateMemberUseCase(sl<MemberRepository>()),
  );

  sl.registerLazySingleton<DeleteMemberUseCase>(
    () => DeleteMemberUseCase(sl<MemberRepository>()),
  );

  sl.registerLazySingleton<CreateMemberUseCase>(
    () => CreateMemberUseCase(sl<MemberRepository>()),
  );

  sl.registerLazySingleton<SearchAccountByEmailUseCase>(
    () => SearchAccountByEmailUseCase(sl<AdminAccountRepository>()),
  );

  sl.registerLazySingleton<SearchAccountByLocationUseCase>(
    () => SearchAccountByLocationUseCase(sl<AdminAccountRepository>()),
  );

  sl.registerLazySingleton<BlockAccountUseCase>(
    () => BlockAccountUseCase(sl<AdminAccountRepository>()),
  );

  sl.registerLazySingleton<UnblockAccountUseCase>(
    () => UnblockAccountUseCase(sl<AdminAccountRepository>()),
  );

  sl.registerLazySingleton<DeleteAccountUseCase>(
    () => DeleteAccountUseCase(sl<AdminAccountRepository>()),
  );

  sl.registerLazySingleton<ResetPasswordUseCase>(
    () => ResetPasswordUseCase(sl<AdminAccountRepository>()),
  );

  // BLoCs
  sl.registerLazySingleton<AdminDashboardBloc>(
    () => AdminDashboardBloc(sl<GetAdminMetricsUseCase>()),
  );

  sl.registerLazySingleton<ResidentBloc>(
    () => ResidentBloc(
      createResidentUseCase: sl<CreateResidentUseCase>(),
      loadResidentsByLocationUseCase: sl<LoadResidentsByLocationUseCase>(),
      deactivateResidentUseCase: sl<DeactivateResidentUseCase>(),
      reactivateResidentUseCase: sl<ReactivateResidentUseCase>(),
      deleteResidentUseCase: sl<DeleteResidentUseCase>(),
      residentRepository: sl<ResidentRepository>(),
    ),
  );

  sl.registerLazySingleton<FacialEnrollmentBloc>(
    () => FacialEnrollmentBloc(adminApi: sl<AdminApi>()),
  );

  sl.registerLazySingleton<OwnerBloc>(
    () => OwnerBloc(
      loadOwnersByLocationUseCase: sl<LoadOwnersByLocationUseCase>(),
      blockOwnerUseCase: sl<BlockOwnerUseCase>(),
      unblockOwnerUseCase: sl<UnblockOwnerUseCase>(),
      deleteOwnerUseCase: sl<DeleteOwnerUseCase>(),
      getOwnerPropertiesUseCase: sl<GetOwnerPropertiesUseCase>(),
      createOwnerUseCase: sl<CreateOwnerUseCase>(),
    ),
  );

  sl.registerLazySingleton<MemberBloc>(
    () => MemberBloc(
      loadMembersByLocationUseCase: sl<LoadMembersByLocationUseCase>(),
      deactivateMemberUseCase: sl<DeactivateMemberUseCase>(),
      reactivateMemberUseCase: sl<ReactivateMemberUseCase>(),
      deleteMemberUseCase: sl<DeleteMemberUseCase>(),
      createMemberUseCase: sl<CreateMemberUseCase>(),
      memberRepository: sl<MemberRepository>(),
    ),
  );

  sl.registerLazySingleton<AdminAccountBloc>(
    () => AdminAccountBloc(
      searchByEmailUseCase: sl<SearchAccountByEmailUseCase>(),
      searchByLocationUseCase: sl<SearchAccountByLocationUseCase>(),
      blockAccountUseCase: sl<BlockAccountUseCase>(),
      unblockAccountUseCase: sl<UnblockAccountUseCase>(),
      deleteAccountUseCase: sl<DeleteAccountUseCase>(),
      resetPasswordUseCase: sl<ResetPasswordUseCase>(),
      accountRepository: sl<AdminAccountRepository>(),
    ),
  );
}

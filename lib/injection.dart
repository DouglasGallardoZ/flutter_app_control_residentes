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
import 'infrastructure/providers/account_api_provider.dart';
// New Providers
import 'infrastructure/providers/biometrics/facial_enrollment_api_impl.dart';
import 'infrastructure/providers/biometrics/facial_verification_api_impl.dart';
import 'infrastructure/providers/metrics/admin_metrics_api_impl.dart';
import 'infrastructure/providers/person_management/resident_api_impl.dart';
import 'infrastructure/providers/person_management/owner_api_impl.dart';
import 'infrastructure/providers/person_management/spouse_api_impl.dart';
import 'infrastructure/providers/person_management/family_member_api_impl.dart';
import 'infrastructure/providers/account_management/account_management_api_impl.dart';
import 'infrastructure/providers/access_management/access_history_api_impl.dart';
import 'infrastructure/providers/qr_management/qr_generation_api_impl.dart';
import 'infrastructure/providers/qr_management/qr_query_api_impl.dart';

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
import 'domain/ports/firebase_auth_provider_port.dart';
import 'domain/ports/api_auth_provider_port.dart';
// New Ports
import 'domain/ports/biometrics/facial_enrollment_api_port.dart';
import 'domain/ports/biometrics/facial_verification_api_port.dart';
import 'domain/ports/metrics/admin_metrics_api_port.dart';
import 'domain/ports/person_management/resident_api_port.dart';
import 'domain/ports/person_management/owner_api_port.dart';
import 'domain/ports/person_management/spouse_api_port.dart';
import 'domain/ports/person_management/family_member_api_port.dart';
import 'domain/ports/account_management/account_management_api_port.dart';
import 'domain/ports/access_management/access_history_api_port.dart';
import 'domain/ports/qr_management/qr_generation_api_port.dart';
import 'domain/ports/qr_management/qr_query_api_port.dart';

// Domain - Use Cases
import 'domain/usecases/login_usecase.dart';
import 'domain/usecases/generate_qr_usecase.dart';
import 'domain/usecases/generate_visit_qr_usecase.dart';
import 'domain/usecases/load_access_history_usecase.dart';
import 'domain/usecases/manage_visitor_usecase.dart';
import 'domain/usecases/get_admin_metrics_usecase.dart';
import 'domain/usecases/get_access_history_usecase.dart';
import 'domain/usecases/get_residence_accesses_usecase.dart';
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
import 'domain/usecases/get_qr_list_usecase.dart';

// BLoCs
import 'application/blocs/admin/admin_dashboard_bloc.dart';
import 'application/blocs/facial_enrollment/facial_enrollment_bloc.dart';
import 'application/blocs/facial_verification/facial_verification_bloc.dart';
import 'application/blocs/resident/resident_bloc.dart';
import 'application/blocs/owner/owner_bloc.dart';
import 'application/blocs/member/member_bloc.dart';
import 'application/blocs/admin_account/admin_account_bloc.dart';
import 'application/blocs/qr_display/qr_display_bloc.dart';
import 'application/blocs/qr_list/qr_list_bloc.dart';
import 'application/blocs/auth/auth_bloc.dart';
import 'application/blocs/prospecto_validation/prospecto_validation_bloc.dart';
import 'application/blocs/registro_residente/registro_residente_bloc.dart';
import 'application/blocs/visitor/visitor_bloc.dart';

final sl = GetIt.instance;

Future<void> inject() async {
  // Configuration
  const String apiBaseUrl = 'http://10.0.2.2:8080/api/v1'; // API general
  const String biometryBaseUrl =
      'http://10.0.2.2:8000/api/v1'; // Servicio de biometría (puerto diferente)

  // Firebase
  final firebaseAuth = FirebaseAuth.instance;
  sl.registerLazySingleton<FirebaseAuth>(() => firebaseAuth);

  // HTTP Client - API General
  final apiHttpClient = ApiHttpClient(
    baseUrl: apiBaseUrl,
    firebaseAuth: firebaseAuth,
  );
  sl.registerLazySingleton<ApiHttpClient>(() => apiHttpClient);

  // HTTP Client - Servicio de Biometría
  final biometryHttpClient = ApiHttpClient(
    baseUrl: biometryBaseUrl,
    firebaseAuth: firebaseAuth,
  );
  sl.registerLazySingleton<ApiHttpClient>(
    () => biometryHttpClient,
    instanceName: 'biometryClient',
  );

  // Providers
  sl.registerLazySingleton<FirebaseAuthProviderPort>(
    () => FirebaseAuthProviderImpl(firebaseAuth),
  );

  sl.registerLazySingleton<ApiAuthProviderPort>(
    () => ApiAuthProviderImpl(apiHttpClient.dio),
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

  sl.registerLazySingleton<AdminApi>(
    () => AdminApi(
      apiHttpClient.dio,
      biometryDio: sl<ApiHttpClient>(instanceName: 'biometryClient').dio,
    ),
    instanceName: 'biometryAdminApi',
  );

  sl.registerLazySingleton<AccountApiProvider>(
    () => AccountApiProvider(dio: apiHttpClient.dio),
  );

  // New Providers - Biometrics
  sl.registerLazySingleton<FacialEnrollmentApiPort>(
    () => FacialEnrollmentApiImpl(
        sl<ApiHttpClient>(instanceName: 'biometryClient').dio),
  );

  sl.registerLazySingleton<FacialVerificationApiPort>(
    () => FacialVerificationApiImpl(
        sl<ApiHttpClient>(instanceName: 'biometryClient').dio),
  );

  // New Providers - Metrics
  sl.registerLazySingleton<AdminMetricsApiPort>(
    () => AdminMetricsApiImpl(apiHttpClient.dio),
  );

  // New Providers - Person Management
  sl.registerLazySingleton<ResidentApiPort>(
    () => ResidentApiImpl(apiHttpClient.dio),
  );

  sl.registerLazySingleton<OwnerApiPort>(
    () => OwnerApiImpl(apiHttpClient.dio),
  );

  sl.registerLazySingleton<SpouseApiPort>(
    () => SpouseApiImpl(apiHttpClient.dio),
  );

  sl.registerLazySingleton<FamilyMemberApiPort>(
    () => FamilyMemberApiImpl(apiHttpClient.dio),
  );

  // New Providers - Account Management
  sl.registerLazySingleton<AccountManagementApiPort>(
    () => AccountManagementApiImpl(apiHttpClient.dio),
  );

  // New Providers - Access Management
  sl.registerLazySingleton<AccessHistoryApiPort>(
    () => AccessHistoryApiImpl(apiHttpClient.dio),
  );

  // New Providers - QR Management
  sl.registerLazySingleton<QrGenerationApiPort>(
    () => QrGenerationApiImpl(apiHttpClient.dio),
  );

  sl.registerLazySingleton<QrQueryApiPort>(
    () => QrQueryApiImpl(apiHttpClient.dio),
  );

  // Adapters (Repositories)
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      firebaseProvider: sl<FirebaseAuthProviderPort>(),
      apiProvider: sl<ApiAuthProviderPort>(),
    ),
  );

  sl.registerLazySingleton<AccountRepository>(
    () => AccountRepositoryImpl(
      sl<ApiAuthProviderPort>(),
      sl<FamilyMembersApi>(),
      sl<AccountApiProvider>(),
    ),
  );

  sl.registerLazySingleton<QrRepository>(
    () => QrRepositoryImpl(sl<QrApi>()),
  );

  sl.registerLazySingleton<AccessHistoryRepository>(
    () => AccessHistoryRepositoryImpl(sl<AccessHistoryApi>()),
  );

  sl.registerLazySingleton<VisitorRepository>(
    () => VisitorRepositoryImpl(api: sl<VisitorApi>()),
  );

  sl.registerLazySingleton<AdminRepository>(
    () => AdminRepositoryImpl(
      metricsApi: sl<AdminMetricsApiPort>(),
      residentApi: sl<ResidentApiPort>(),
      ownerApi: sl<OwnerApiPort>(),
      familyMemberApi: sl<FamilyMemberApiPort>(),
      accountManagementApi: sl<AccountManagementApiPort>(),
    ),
  );

  sl.registerLazySingleton<ResidentRepository>(
    () => ResidentRepositoryImpl(
      residentApi: sl<ResidentApiPort>(),
      accessHistoryApi: sl<AccessHistoryApiPort>(),
    ),
  );

  sl.registerLazySingleton<OwnerRepository>(
    () => OwnerRepositoryImpl(
      ownerApi: sl<OwnerApiPort>(),
      spouseApi: sl<SpouseApiPort>(),
    ),
  );

  sl.registerLazySingleton<MemberRepository>(
    () => MemberRepositoryImpl(
      familyMemberApi: sl<FamilyMemberApiPort>(),
      accountManagementApi: sl<AccountManagementApiPort>(),
    ),
  );

  sl.registerLazySingleton<AdminAccountRepository>(
    () => AdminAccountRepositoryImpl(
      accountManagementApi: sl<AccountManagementApiPort>(),
    ),
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

  sl.registerLazySingleton<GetAccessHistoryUseCase>(
    () => GetAccessHistoryUseCase(sl<AdminRepository>()),
  );

  sl.registerLazySingleton<GetResidenceAccessesUseCase>(
    () => GetResidenceAccessesUseCase(sl<ResidentRepository>()),
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

  sl.registerLazySingleton<GetQrListUseCase>(
    () => GetQrListUseCaseImpl(qrQueryApi: sl<QrQueryApiPort>()),
  );

  // BLoCs
  sl.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      login: sl<LoginUseCase>(),
      authRepo: sl<AuthRepository>(),
      accountRepo: sl<AccountRepository>(),
    ),
  );

  sl.registerLazySingleton<AdminDashboardBloc>(
    () => AdminDashboardBloc(
      sl<GetAdminMetricsUseCase>(),
      sl<GetAccessHistoryUseCase>(),
    ),
  );

  sl.registerLazySingleton<ResidentBloc>(
    () => ResidentBloc(
      createResidentUseCase: sl<CreateResidentUseCase>(),
      loadResidentsByLocationUseCase: sl<LoadResidentsByLocationUseCase>(),
      deactivateResidentUseCase: sl<DeactivateResidentUseCase>(),
      reactivateResidentUseCase: sl<ReactivateResidentUseCase>(),
      deleteResidentUseCase: sl<DeleteResidentUseCase>(),
      getResidenceAccessesUseCase: sl<GetResidenceAccessesUseCase>(),
      residentRepository: sl<ResidentRepository>(),
    ),
  );

  sl.registerLazySingleton<FacialEnrollmentBloc>(
    () => FacialEnrollmentBloc(
      enrollmentApi: sl<FacialEnrollmentApiPort>(),
      authProvider: sl<FirebaseAuthProviderPort>(),
    ),
  );

  sl.registerLazySingleton<FacialVerificationBloc>(
    () => FacialVerificationBloc(
        verificationApi: sl<FacialVerificationApiPort>()),
  );

  sl.registerLazySingleton<OwnerBloc>(
    () => OwnerBloc(
      loadOwnersByLocationUseCase: sl<LoadOwnersByLocationUseCase>(),
      blockOwnerUseCase: sl<BlockOwnerUseCase>(),
      unblockOwnerUseCase: sl<UnblockOwnerUseCase>(),
      deleteOwnerUseCase: sl<DeleteOwnerUseCase>(),
      getOwnerPropertiesUseCase: sl<GetOwnerPropertiesUseCase>(),
      createOwnerUseCase: sl<CreateOwnerUseCase>(),
      ownerRepository: sl<OwnerRepository>(),
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

  sl.registerLazySingleton<QrDisplayBloc>(
    () => QrDisplayBloc(authBloc: sl<AuthBloc>()),
  );

  sl.registerFactory<QrListBloc>(
    () => QrListBloc(getQrListUseCase: sl<GetQrListUseCase>()),
  );

  sl.registerLazySingleton<ProspectoValidationBloc>(
    () => ProspectoValidationBloc(sl<AccountRepository>()),
  );

  sl.registerLazySingleton<RegistroResidenteBloc>(
    () => RegistroResidenteBloc(sl<AccountRepository>()),
  );

  sl.registerLazySingleton<VisitorBloc>(
    () => VisitorBloc(usecase: sl<ManageVisitorUseCase>()),
  );
}

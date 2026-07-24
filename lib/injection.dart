import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

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
import 'infrastructure/providers/biometrics/face_detection_mobile_impl.dart';
import 'infrastructure/providers/biometrics/face_detection_web_impl.dart';
import 'infrastructure/providers/metrics/admin_metrics_api_impl.dart';
import 'infrastructure/providers/person_management/resident_api_impl.dart';
import 'infrastructure/providers/person_management/owner_api_impl.dart';
import 'infrastructure/providers/person_management/spouse_api_impl.dart';
import 'infrastructure/providers/person_management/family_member_api_impl.dart';
import 'infrastructure/providers/account_management/account_management_api_impl.dart';
import 'infrastructure/providers/access_management/access_history_api_impl.dart';
import 'infrastructure/providers/qr_management/qr_generation_api_impl.dart';
import 'infrastructure/providers/qr_management/qr_query_api_impl.dart';
import 'infrastructure/providers/qr_list_api.dart';
import 'infrastructure/providers/notificacion_api_provider.dart';
import 'infrastructure/providers/admin_notificaciones_api_provider.dart';
import 'infrastructure/providers/fcm_provider.dart';
import 'infrastructure/providers/firestore_provider.dart';
import 'infrastructure/providers/solicitud_miembro_api_provider.dart';
import 'infrastructure/providers/vivienda_api.dart';

import 'infrastructure/adapters/vivienda_repository_impl.dart';
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
import 'infrastructure/adapters/session_port_impl.dart';
import 'infrastructure/adapters/session_cleanup_impl.dart';
import 'infrastructure/adapters/notificacion_repository_impl.dart';
import 'infrastructure/adapters/admin_notificaciones_repository_impl.dart';
import 'infrastructure/adapters/notificacion_push_handler_impl.dart';
import 'infrastructure/adapters/solicitud_miembro_repository_impl.dart';
import 'infrastructure/adapters/camera_port_impl.dart';

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
import 'domain/ports/face_detection_port.dart';
import 'domain/ports/metrics/admin_metrics_api_port.dart';
import 'domain/ports/person_management/resident_api_port.dart';
import 'domain/ports/person_management/owner_api_port.dart';
import 'domain/ports/person_management/spouse_api_port.dart';
import 'domain/ports/person_management/family_member_api_port.dart';
import 'domain/ports/account_management/account_management_api_port.dart';
import 'domain/ports/access_management/access_history_api_port.dart';
import 'domain/ports/qr_management/qr_generation_api_port.dart';
import 'domain/ports/qr_management/qr_query_api_port.dart';
import 'domain/ports/session_port.dart';
import 'domain/ports/session_cleanup_port.dart';
import 'domain/ports/notificacion_repository_port.dart';
import 'domain/ports/admin_notificaciones_repository_port.dart';
import 'domain/ports/notificacion_push_handler_port.dart';
import 'domain/ports/solicitud_miembro_repository_port.dart';
import 'domain/ports/vivienda_repository_port.dart';
import 'domain/ports/camera_port.dart';

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
import 'domain/usecases/register_account_usecase.dart';
import 'domain/usecases/update_email_usecase.dart';
import 'domain/usecases/load_family_members_usecase.dart';
import 'domain/usecases/crear_cuenta_residente_usecase.dart';
import 'domain/usecases/crear_cuenta_miembro_usecase.dart';
import 'domain/usecases/validar_prospecto_residente_usecase.dart';
import 'domain/usecases/validar_prospecto_miembro_usecase.dart';
import 'domain/usecases/logout_usecase.dart';
import 'domain/usecases/get_current_user_usecase.dart';
import 'domain/usecases/get_id_token_usecase.dart';
import 'domain/usecases/sign_up_usecase.dart';
import 'domain/usecases/load_residents_usecase.dart';
import 'domain/usecases/get_owner_with_spouses_usecase.dart';
import 'domain/usecases/create_spouse_usecase.dart';
import 'domain/usecases/delete_spouse_usecase.dart';
import 'domain/usecases/block_spouse_usecase.dart';
import 'domain/usecases/generar_retos_liveness_usecase.dart';
import 'domain/usecases/perform_full_logout_usecase.dart';

// Domain - Use Cases (Notificaciones)
import 'domain/usecases/obtener_notificaciones_usecase.dart';
import 'domain/usecases/obtener_no_leidas_usecase.dart';
import 'domain/usecases/marcar_notificacion_leida_usecase.dart';
import 'domain/usecases/marcar_todas_leidas_usecase.dart';
import 'domain/usecases/eliminar_notificacion_usecase.dart';
import 'domain/usecases/registrar_token_fcm_usecase.dart';
import 'domain/usecases/solicitar_registro_miembro_usecase.dart';
import 'domain/usecases/consultar_estado_solicitud_usecase.dart';
import 'domain/usecases/listar_solicitudes_pendientes_usecase.dart';
import 'domain/usecases/aprobar_solicitud_miembro_usecase.dart';
import 'domain/usecases/rechazar_solicitud_miembro_usecase.dart';
import 'domain/usecases/listar_viviendas_usecase.dart';
import 'domain/usecases/crear_vivienda_usecase.dart';
import 'domain/usecases/actualizar_vivienda_usecase.dart';
import 'domain/usecases/cambiar_estado_vivienda_usecase.dart';
import 'domain/usecases/cambiar_propietario_vivienda_usecase.dart';

import 'application/blocs/vivienda/vivienda_bloc.dart';

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
import 'application/blocs/account/account_bloc.dart';
import 'application/blocs/prospecto_validation/prospecto_validation_bloc.dart';
import 'application/blocs/registro_residente/registro_residente_bloc.dart';
import 'application/blocs/visitor/visitor_bloc.dart';
import 'application/blocs/security_session/security_session_bloc.dart';
import 'application/blocs/notificaciones/notificaciones_bloc.dart';
import 'application/blocs/admin/admin_notificaciones_bloc.dart';
import 'application/blocs/autorizacion_miembro/autorizacion_miembro_bloc.dart';
import 'application/blocs/aprobacion_miembro/aprobacion_miembro_bloc.dart';

final sl = GetIt.instance;

Future<void> inject() async {
  final String apiBaseUrl = kIsWeb 
    ? 'http://localhost:8080/api/v1' 
    // : 'http://10.0.2.2:8080/api/v1';
    : 'http://192.168.1.18:8080/api/v1';

  final String biometryBaseUrl = kIsWeb 
      ? 'http://localhost:8000/api/v1' 
      // : 'http://10.0.2.2:8000/api/v1';
      : 'http://192.168.1.18:8000/api/v1';

  // Firebase
  final firebaseAuth = FirebaseAuth.instance;
  sl.registerLazySingleton<FirebaseAuth>(() => firebaseAuth);

  final firebaseMessaging = FirebaseMessaging.instance;
  sl.registerLazySingleton<FirebaseMessaging>(() => firebaseMessaging);

  final firestore = FirebaseFirestore.instance;
  sl.registerLazySingleton<FirebaseFirestore>(() => firestore);

  sl.registerLazySingleton<FirestoreProvider>(
    () => FirestoreProvider(sl<FirebaseFirestore>()),
  );

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

  sl.registerLazySingleton<FaceDetectionPort>(
    () {
      if (kIsWeb) {
        return FaceDetectionWebImpl(
            dio: sl<ApiHttpClient>(instanceName: 'biometryClient').dio);
      }
      return FaceDetectionMobileImpl();
    },
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

  sl.registerLazySingleton<QrListApi>(
    () => QrListApi(apiHttpClient.dio),
  );

  // Providers - Notificaciones
  sl.registerLazySingleton<NotificacionApiProvider>(
    () => NotificacionApiProvider(sl<ApiHttpClient>()),
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

  // Notificaciones
  sl.registerLazySingleton<NotificacionRepositoryPort>(
    () => NotificacionRepositoryImpl(sl<NotificacionApiProvider>()),
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

  sl.registerLazySingleton<RegisterAccountUseCase>(
    () => RegisterAccountUseCase(sl<AccountRepository>()),
  );

  sl.registerLazySingleton<UpdateEmailUseCase>(
    () => UpdateEmailUseCase(sl<AccountRepository>()),
  );

  sl.registerLazySingleton<LoadFamilyMembersUseCase>(
    () => LoadFamilyMembersUseCase(sl<AccountRepository>()),
  );

  sl.registerLazySingleton<CrearCuentaResidenteUseCase>(
    () => CrearCuentaResidenteUseCase(sl<AccountRepository>()),
  );

  sl.registerLazySingleton<CrearCuentaMiembroUseCase>(
    () => CrearCuentaMiembroUseCase(sl<AccountRepository>()),
  );

  sl.registerLazySingleton<ValidarProspectoResidenteUseCase>(
    () => ValidarProspectoResidenteUseCase(sl<AccountRepository>()),
  );

  sl.registerLazySingleton<ValidarProspectoMiembroUseCase>(
    () => ValidarProspectoMiembroUseCase(sl<AccountRepository>()),
  );

  sl.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(
      sl<AuthRepository>(),
      performFullLogout: sl<PerformFullLogoutUseCase>(),
    ),
  );

  sl.registerLazySingleton<PerformFullLogoutUseCase>(
    () =>
        PerformFullLogoutUseCase(sessionCleanup: sl<SessionCleanupPort>()),
  );

  sl.registerLazySingleton<GetCurrentUserUseCase>(
    () => GetCurrentUserUseCase(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<GetIdTokenUseCase>(
    () => GetIdTokenUseCase(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<SignUpUseCase>(
    () => SignUpUseCase(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<LoadResidentsUseCase>(
    () => LoadResidentsUseCase(sl<ResidentRepository>()),
  );

  sl.registerLazySingleton<GetOwnerWithSpousesUseCase>(
    () => GetOwnerWithSpousesUseCase(sl<OwnerRepository>()),
  );

  sl.registerLazySingleton<CreateSpouseUseCase>(
    () => CreateSpouseUseCase(sl<OwnerRepository>()),
  );

  sl.registerLazySingleton<DeleteSpouseUseCase>(
    () => DeleteSpouseUseCase(sl<OwnerRepository>()),
  );

  sl.registerLazySingleton<BlockSpouseUseCase>(
    () => BlockSpouseUseCase(sl<OwnerRepository>()),
  );

  sl.registerLazySingleton<GenerarRetosLivenessUseCase>(
    () => GenerarRetosLivenessUseCase(),
  );

  sl.registerLazySingleton<SessionPort>(
    () => SessionPortImpl(
        authRepo: sl<AuthRepository>(), accountRepo: sl<AccountRepository>()),
  );

  sl.registerLazySingleton<SessionCleanupPort>(
    () => SessionCleanupImpl(
      authProvider: sl<FirebaseAuthProviderPort>(),
      generalHttpClient: sl<ApiHttpClient>(),
      biometryHttpClient:
          sl<ApiHttpClient>(instanceName: 'biometryClient'),
    ),
  );

  // BLoCs
  sl.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      login: sl<LoginUseCase>(),
      logout: sl<LogoutUseCase>(),
      getCurrentUser: sl<GetCurrentUserUseCase>(),
      getIdToken: sl<GetIdTokenUseCase>(),
      signUp: sl<SignUpUseCase>(),
      accountRepo: sl<AccountRepository>(),
      authProvider: sl<FirebaseAuthProviderPort>(),
    ),
  );

  sl.registerLazySingleton<AdminDashboardBloc>(
    () => AdminDashboardBloc(
      sl<GetAdminMetricsUseCase>(),
      sl<GetAccessHistoryUseCase>(),
    ),
  );

  sl.registerFactory<ResidentBloc>(
    () => ResidentBloc(
      createResidentUseCase: sl<CreateResidentUseCase>(),
      loadResidentsByLocationUseCase: sl<LoadResidentsByLocationUseCase>(),
      deactivateResidentUseCase: sl<DeactivateResidentUseCase>(),
      reactivateResidentUseCase: sl<ReactivateResidentUseCase>(),
      deleteResidentUseCase: sl<DeleteResidentUseCase>(),
      getResidenceAccessesUseCase: sl<GetResidenceAccessesUseCase>(),
      loadResidentsUseCase: sl<LoadResidentsUseCase>(),
    ),
  );

  sl.registerFactory<FacialEnrollmentBloc>(
    () => FacialEnrollmentBloc(
      enrollmentApi: sl<FacialEnrollmentApiPort>(),
      authProvider: sl<FirebaseAuthProviderPort>(),
    ),
  );

  sl.registerFactory<FacialVerificationBloc>(
    () => FacialVerificationBloc(
      verificationApi: sl<FacialVerificationApiPort>(),
      generarRetos: sl<GenerarRetosLivenessUseCase>(),
      authProvider: sl<FirebaseAuthProviderPort>(),
    ),
  );

  sl.registerFactory<OwnerBloc>(
    () => OwnerBloc(
      loadOwnersByLocationUseCase: sl<LoadOwnersByLocationUseCase>(),
      blockOwnerUseCase: sl<BlockOwnerUseCase>(),
      unblockOwnerUseCase: sl<UnblockOwnerUseCase>(),
      deleteOwnerUseCase: sl<DeleteOwnerUseCase>(),
      getOwnerPropertiesUseCase: sl<GetOwnerPropertiesUseCase>(),
      createOwnerUseCase: sl<CreateOwnerUseCase>(),
      getOwnerWithSpousesUseCase: sl<GetOwnerWithSpousesUseCase>(),
      createSpouseUseCase: sl<CreateSpouseUseCase>(),
      deleteSpouseUseCase: sl<DeleteSpouseUseCase>(),
      blockSpouseUseCase: sl<BlockSpouseUseCase>(),
    ),
  );

  sl.registerFactory<MemberBloc>(
    () => MemberBloc(
      loadMembersByLocationUseCase: sl<LoadMembersByLocationUseCase>(),
      deactivateMemberUseCase: sl<DeactivateMemberUseCase>(),
      reactivateMemberUseCase: sl<ReactivateMemberUseCase>(),
      deleteMemberUseCase: sl<DeleteMemberUseCase>(),
      createMemberUseCase: sl<CreateMemberUseCase>(),
      memberRepository: sl<MemberRepository>(),
    ),
  );

  sl.registerFactory<AdminAccountBloc>(
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

  sl.registerFactory<QrDisplayBloc>(
    () => QrDisplayBloc(sessionPort: sl<SessionPort>()),
  );

  sl.registerFactory<QrListBloc>(
    () => QrListBloc(
      getQrListUseCase: sl<GetQrListUseCase>(),
      qrListApi: sl<QrListApi>(),
    ),
  );

  sl.registerFactory<ProspectoValidationBloc>(
    () => ProspectoValidationBloc(
      validarResidente: sl<ValidarProspectoResidenteUseCase>(),
      validarMiembro: sl<ValidarProspectoMiembroUseCase>(),
    ),
  );

  sl.registerFactory<RegistroResidenteBloc>(
    () => RegistroResidenteBloc(
      crearCuentaResidente: sl<CrearCuentaResidenteUseCase>(),
      crearCuentaMiembro: sl<CrearCuentaMiembroUseCase>(),
    ),
  );

  sl.registerFactory<VisitorBloc>(
    () => VisitorBloc(usecase: sl<ManageVisitorUseCase>()),
  );

  sl.registerFactory<AccountBloc>(
    () => AccountBloc(
      registerAccount: sl<RegisterAccountUseCase>(),
      updateEmail: sl<UpdateEmailUseCase>(),
      loadFamilyMembers: sl<LoadFamilyMembersUseCase>(),
    ),
  );

  sl.registerLazySingleton<SecuritySessionBloc>(
    () => SecuritySessionBloc(),
  );

  // ── Casos de Uso de Notificaciones ──
  sl.registerLazySingleton<ObtenerNotificacionesUseCase>(
    () => ObtenerNotificacionesUseCase(sl<NotificacionRepositoryPort>()),
  );

  sl.registerLazySingleton<ObtenerNoLeidasUseCase>(
    () => ObtenerNoLeidasUseCase(sl<NotificacionRepositoryPort>()),
  );

  sl.registerLazySingleton<MarcarNotificacionLeidaUseCase>(
    () => MarcarNotificacionLeidaUseCase(sl<NotificacionRepositoryPort>()),
  );

  sl.registerLazySingleton<MarcarTodasLeidasUseCase>(
    () => MarcarTodasLeidasUseCase(sl<NotificacionRepositoryPort>()),
  );

  sl.registerLazySingleton<EliminarNotificacionUseCase>(
    () => EliminarNotificacionUseCase(sl<NotificacionRepositoryPort>()),
  );

  sl.registerLazySingleton<RegistrarTokenFCMUseCase>(
    () => RegistrarTokenFCMUseCase(sl<NotificacionRepositoryPort>()),
  );

  // ── BLoC de Notificaciones ──
  sl.registerFactory<NotificacionesBloc>(
    () => NotificacionesBloc(
      obtenerNotificaciones: sl<ObtenerNotificacionesUseCase>(),
      obtenerNoLeidas: sl<ObtenerNoLeidasUseCase>(),
      marcarComoLeida: sl<MarcarNotificacionLeidaUseCase>(),
      marcarTodasComoLeidas: sl<MarcarTodasLeidasUseCase>(),
      eliminarNotificacion: sl<EliminarNotificacionUseCase>(),
    ),
  );

  // ── Admin Notificaciones ──
  sl.registerLazySingleton<AdminNotificacionesApiProvider>(
    () => AdminNotificacionesApiProvider(sl<ApiHttpClient>()),
  );

  sl.registerLazySingleton<AdminNotificacionesRepositoryPort>(
    () => AdminNotificacionesRepositoryImpl(
        sl<AdminNotificacionesApiProvider>()),
  );

  sl.registerFactory<AdminNotificacionesBloc>(
    () =>
        AdminNotificacionesBloc(sl<AdminNotificacionesRepositoryPort>()),
  );

  // Services
  final localNotifications =
      FlutterLocalNotificationsPlugin();
  sl.registerLazySingleton<FlutterLocalNotificationsPlugin>(
    () => localNotifications,
  );

  // Camera Port — singleton para evitar ciclos create→dispose en GPU Mali
  sl.registerLazySingleton<CameraPort>(() => CameraPortImpl());

  // FCM Provider
  sl.registerLazySingleton<FcmProvider>(
    () => FcmProvider(
        sl<FirebaseMessaging>(), sl<FlutterLocalNotificationsPlugin>()),
  );

  // Notificaciones Push
  sl.registerLazySingleton<NotificacionPushHandlerPort>(
    () =>
        NotificacionPushHandlerImpl(sl<FcmProvider>()),
  );

  // Solicitud Miembro (Autorización del titular)
  sl.registerLazySingleton<SolicitudMiembroApiProvider>(
    () => SolicitudMiembroApiProvider(sl<ApiHttpClient>()),
  );

  sl.registerLazySingleton<SolicitudMiembroRepositoryPort>(
    () => SolicitudMiembroRepositoryImpl(
        sl<SolicitudMiembroApiProvider>()),
  );

  // Use Cases — Autorización Miembro
  sl.registerLazySingleton<SolicitarRegistroMiembroUseCase>(
    () => SolicitarRegistroMiembroUseCase(
        sl<SolicitudMiembroRepositoryPort>()),
  );

  sl.registerLazySingleton<ConsultarEstadoSolicitudUseCase>(
    () => ConsultarEstadoSolicitudUseCase(
        sl<SolicitudMiembroRepositoryPort>()),
  );

  sl.registerLazySingleton<ListarSolicitudesPendientesUseCase>(
    () => ListarSolicitudesPendientesUseCase(
        sl<SolicitudMiembroRepositoryPort>()),
  );

  sl.registerLazySingleton<AprobarSolicitudMiembroUseCase>(
    () => AprobarSolicitudMiembroUseCase(
        sl<SolicitudMiembroRepositoryPort>()),
  );

  sl.registerLazySingleton<RechazarSolicitudMiembroUseCase>(
    () => RechazarSolicitudMiembroUseCase(
        sl<SolicitudMiembroRepositoryPort>()),
  );

  // BLoC — Autorización Miembro (factory)
  sl.registerFactory<AutorizacionMiembroBloc>(
    () => AutorizacionMiembroBloc(
      solicitarRegistro:
          sl<SolicitarRegistroMiembroUseCase>(),
      consultarEstado:
          sl<ConsultarEstadoSolicitudUseCase>(),
    ),
  );

  // BLoC — Titular: Aprobación de solicitudes (factory)
  sl.registerFactory<AprobacionMiembroBloc>(
    () => AprobacionMiembroBloc(
      listarPendientes: sl<ListarSolicitudesPendientesUseCase>(),
      aprobar: sl<AprobarSolicitudMiembroUseCase>(),
      rechazar: sl<RechazarSolicitudMiembroUseCase>(),
    ),
  );

  // Providers - Viviendas
  sl.registerLazySingleton<ViviendaApi>(
    () => ViviendaApi(sl<ApiHttpClient>().dio),
  );

  // Adapters - Viviendas
  sl.registerLazySingleton<ViviendaRepositoryPort>(
    () => ViviendaRepositoryImpl(api: sl<ViviendaApi>()),
  );

  // Use Cases - Viviendas
  sl.registerLazySingleton<ListarViviendasUseCase>(
    () => ListarViviendasUseCase(sl<ViviendaRepositoryPort>()),
  );
  sl.registerLazySingleton<CrearViviendaUseCase>(
    () => CrearViviendaUseCase(sl<ViviendaRepositoryPort>()),
  );
  sl.registerLazySingleton<ActualizarViviendaUseCase>(
    () => ActualizarViviendaUseCase(sl<ViviendaRepositoryPort>()),
  );
  sl.registerLazySingleton<CambiarEstadoViviendaUseCase>(
    () => CambiarEstadoViviendaUseCase(sl<ViviendaRepositoryPort>()),
  );
  sl.registerLazySingleton<CambiarPropietarioViviendaUseCase>(
    () => CambiarPropietarioViviendaUseCase(sl<ViviendaRepositoryPort>()),
  );

  // BLoCs - Viviendas
  sl.registerFactory<ViviendaBloc>(
    () => ViviendaBloc(
      listarUseCase: sl<ListarViviendasUseCase>(),
      crearUseCase: sl<CrearViviendaUseCase>(),
      actualizarUseCase: sl<ActualizarViviendaUseCase>(),
      cambiarEstadoUseCase: sl<CambiarEstadoViviendaUseCase>(),
      cambiarPropietarioUseCase: sl<CambiarPropietarioViviendaUseCase>(),
    ),
  );
}

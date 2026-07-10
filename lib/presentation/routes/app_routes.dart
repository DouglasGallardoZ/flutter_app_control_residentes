// lib/presentation/routes/app_routes.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:guardin/presentation/pages/members_page.dart';
import 'package:guardin/presentation/pages/qr_list_page.dart';
import '../pages/login_page.dart';
import '../pages/resident_dashboard_page.dart';
import '../pages/qr_self_page.dart';
import '../pages/qr_visit_page.dart';
import '../pages/access_history_page.dart';
import '../pages/profile_page.dart';
import '../pages/admin_dashboard_page.dart';
import '../pages/admin_access_history_page.dart';
import '../pages/admin_profile_page.dart';
import '../pages/admin_users_page.dart';
import '../pages/admin_residents_page.dart';
import '../pages/admin_owners_page.dart';
import '../pages/admin_members_page.dart';
import '../pages/admin_accounts_page.dart';
import '../pages/admin_create_resident_page.dart';
import '../pages/admin_create_owner_page.dart';
import '../pages/admin_create_member_page.dart';
import '../pages/admin_facial_enrollment_page.dart';
import '../pages/admin_viviendas_page.dart';
import '../pages/admin/admin_notificaciones_page.dart';
import '../pages/notificaciones/notificaciones_lista_page.dart';
import '../pages/notificaciones/notificacion_detalle_page.dart';
import '../pages/miembros/esperar_autorizacion_page.dart';
import '../pages/miembros/aprobacion_miembro_page.dart';
import '../pages/family_dashboard_page.dart';
import '../pages/register_option_page.dart';
import '../pages/prospecto_residente_page.dart';
import '../pages/prospecto_miembro_page.dart';
import '../pages/facial_verification_page.dart';
import '../pages/credentials_residente_page.dart';
import '../pages/credentials_miembro_page.dart';
import '../pages/member_create_registration_page.dart';
import '../pages/member_facial_enrollment_page.dart';
import '../../domain/entities/prospecto_residente.dart';
import '../../domain/entities/notificacion_item.dart';
import '../../application/blocs/qr_list/qr_list_bloc.dart';
import '../../application/blocs/prospecto_validation/prospecto_validation_bloc.dart';
import '../../application/blocs/registro_residente/registro_residente_bloc.dart';
import '../../application/blocs/visitor/visitor_bloc.dart';
import '../../application/blocs/vivienda/vivienda_bloc.dart';
import '../../application/blocs/admin/admin_notificaciones_bloc.dart';
import '../../injection.dart';

class AppRoutes {
  static const String login = '/login';
  static const String registerOption = '/registerOption';
  static const String prospectoResidente = '/prospectoResidente';
  static const String prospectoMiembro = '/prospectoMiembro';
  static const String facialVerification = '/facialVerification';
  static const String credentialsResidente = '/credentialsResidente';
  static const String credentialsMiembro = '/credentialsMiembro';
  static const String memberCreateRegistration = '/memberCreateRegistration';
  static const String memberFacialEnrollment = '/memberFacialEnrollment';
  static const String esperarAutorizacion =
      '/esperarAutorizacion';
  static const String solicitudesPendientes =
      '/solicitudes-pendientes';
  static const String aprobacionMiembro =
      '/aprobacionMiembro';
  static const String residentDashboard = '/residentDashboard';
  static const String qrSelf = '/qrSelf';
  static const String qrVisit = '/qrVisit';
  static const String qrList = '/qrList';
  static const String accessHistory = '/accessHistory';
  static const String profile = '/profile';
  static const String members = '/members';

  static const String adminDashboard = '/adminDashboard';
  static const String adminAccessHistory = '/adminAccessHistory';
  static const String adminUsers = '/adminUsers';
  static const String adminResidents = '/adminResidents';
  static const String adminOwners = '/adminOwners';
  static const String adminMembers = '/adminMembers';
  static const String adminAccounts = '/adminAccounts';
  static const String adminCreateResident = '/adminCreateResident';
  static const String adminCreateOwner = '/adminCreateOwner';
  static const String adminCreateMember = '/adminCreateMember';
  static const String adminFacialEnrollment = '/adminFacialEnrollment';
  static const String adminProfile = '/adminProfile';
  static const String adminNotificaciones = '/adminNotificaciones';
  static const String adminViviendas = '/adminViviendas';
  static const String notificaciones = '/notificaciones';
  static const String notificacionDetalle =
      '/notificaciones/detalle';
  static const String familyDashboard = '/familyDashboard';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case registerOption:
        return MaterialPageRoute(builder: (_) => const RegisterOptionPage());

      case prospectoResidente:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<ProspectoValidationBloc>(
            create: (_) => GetIt.instance<ProspectoValidationBloc>(),
            child: const ProspectoResidentePage(),
          ),
        );

      case prospectoMiembro:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<ProspectoValidationBloc>(
            create: (_) => GetIt.instance<ProspectoValidationBloc>(),
            child: const ProspectoMiembroPage(),
          ),
        );

      case facialVerification: {
        final prospecto = settings.arguments; // No hacer cast específico
        if (prospecto != null) {
          return MaterialPageRoute(
            builder: (_) => FacialVerificationPage(prospecto: prospecto),
          );
        }
        return _errorRoute('Faltan argumentos en FacialVerificationPage');
      }

      case credentialsResidente: {
        final args = settings.arguments as Map<String, dynamic>?;
        final prospecto = args?['prospecto'];
        final imagePath = args?['imagePath'] as String?;
        if (prospecto != null && imagePath != null) {
          return MaterialPageRoute(
            builder: (_) => BlocProvider<RegistroResidenteBloc>(
              create: (_) => GetIt.instance<RegistroResidenteBloc>(),
              child: CredentialsResidentePage(
                prospecto: prospecto,
                imagePath: imagePath,
              ),
            ),
          );
        }
        return _errorRoute('Faltan argumentos en CredentialsResidentePage');
      }

      case credentialsMiembro: {
        final args = settings.arguments as Map<String, dynamic>?;
        final prospecto = args?['prospecto'];
        final imagePath = args?['imagePath'] as String?;
        
        // Manejo flexible para ProspectoMiembro o ProspectoResidente
        int? personaId;
        String? nombres;
        String? apellidos;
        
        if (prospecto is ProspectoMiembro) {
          personaId = prospecto.personaId;
          nombres = prospecto.nombres;
          apellidos = prospecto.apellidos;
        } else if (prospecto is ProspectoResidente) {
          personaId = prospecto.personaId;
          nombres = prospecto.nombres;
          apellidos = prospecto.apellidos;
        }
        
        if (personaId != null && nombres != null && apellidos != null) {
          return MaterialPageRoute(
            builder: (_) => BlocProvider<RegistroResidenteBloc>(
              create: (_) => GetIt.instance<RegistroResidenteBloc>(),
              child: CredentialsMiembroPage(
                prospecto: prospecto is ProspectoResidente ? prospecto : null,
                imagePath: imagePath,
                personaId: personaId,
                nombres: nombres,
                apellidos: apellidos,
              ),
            ),
          );
        }
        return _errorRoute('Faltan argumentos en CredentialsMiembroPage');
      }

      case memberCreateRegistration: {
        final identificacion = settings.arguments as String?;
        if (identificacion != null) {
          return MaterialPageRoute(
            builder: (_) => MemberCreateRegistrationPage(
              identificacion: identificacion,
            ),
          );
        }
        return _errorRoute('Falta identificación en MemberCreateRegistrationPage');
      }

      case memberFacialEnrollment: {
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final personaId = int.tryParse(args['personaId']?.toString() ?? '0') ?? 0;
        final nombres = args['nombres'] as String? ?? '';
        final apellidos = args['apellidos'] as String? ?? '';
        final type = args['type'] as String? ?? 'member';
        final origen = args['origen'] as String?;
        final prospectoCompleto = args['prospectoCompleto'];

        if (personaId > 0 && nombres.isNotEmpty && apellidos.isNotEmpty) {
          return MaterialPageRoute(
            builder: (_) => MemberFacialEnrollmentPage(
              personaId: personaId,
              nombres: nombres,
              apellidos: apellidos,
              type: type,
              origen: origen,
              prospectoCompleto: prospectoCompleto,
            ),
            settings: settings,
          );
        }
        return _errorRoute('Falta información en MemberFacialEnrollmentPage');
      }

      case esperarAutorizacion: {
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => EsperarAutorizacionPage(
            identificacion: args['identificacion'] ?? '',
            nombres: args['nombres'] ?? '',
            apellidos: args['apellidos'] ?? '',
            parentesco: args['parentesco'] ?? '',
            manzana: args['manzana'] ?? '',
            villa: args['villa'] ?? '',
            fechaNacimiento: args['fechaNacimiento'] ?? '',
            correo: args['correo'],
            celular: args['celular'],
            identificacionResidente: args['identificacionResidente'] ?? '',
          ),
          settings: settings,
        );
      }

      case solicitudesPendientes:
        return MaterialPageRoute(
          builder: (_) => const AprobacionMiembroPage(),
          settings: settings,
        );

      case aprobacionMiembro:
        return MaterialPageRoute(
          builder: (_) => const AprobacionMiembroPage(),
          settings: settings,
        );

      case residentDashboard: {
        final args = settings.arguments as Map<String, dynamic>?;
        final personaId = int.tryParse(args?['personaId']?.toString() ?? '') ?? 0;
        final identificacion = args?['identificacion'] as String? ?? '';
        final residenceId = args?['residenceId'] as String?;
        if (personaId != null && identificacion != null && residenceId != null) {
          return _fadeRoute(ResidentDashboardPage(personaId: personaId, identificacion: identificacion, residenceId: residenceId), settings: settings);
        }
        return _fadeRoute(const ResidentDashboardPage(personaId: 0, identificacion: '', residenceId: ''), settings: settings);
      }

      case qrSelf: {
        final args = settings.arguments as Map<String, dynamic>?;
        final personaId = int.tryParse(args?['personaId']?.toString() ?? '') ?? 0;
        final identificacion = args?['identificacion'] as String? ?? '';
        final residenceId = args?['residenceId'] as String?;
        if (personaId == null || identificacion == null) return _errorRoute('Faltan argumentos en QrSelfPage');
        return _fadeRoute(QrSelfPage(personaId: personaId, identificacion: identificacion, residenceId: residenceId), settings: settings);
      }

      case qrVisit: {
        final args = settings.arguments as Map<String, dynamic>?;
        final personaId = int.tryParse(args?['personaId']?.toString() ?? '') ?? 0;
        final identificacion = args?['identificacion'] as String? ?? '';
        final residenceId = args?['residenceId'] as String?;
        if (personaId == null || identificacion == null || residenceId == null) {
          return _errorRoute('Faltan argumentos en QrVisitPage');
        }
        return _fadeRoute(
          BlocProvider<VisitorBloc>(
            create: (_) => sl<VisitorBloc>(),
            child: QrVisitPage(
              personaId: personaId,
              identificacion: identificacion,
              residenceId: residenceId,
            ),
          ),
          settings: settings,
        );
      }

      case qrList: {
        final args = settings.arguments as Map<String, dynamic>?;
        final personaId = int.tryParse(args?['personaId']?.toString() ?? '') ?? 0;
        final identificacion = args?['identificacion'] as String? ?? '';
        final residenceId = args?['residenceId'] as String?;
        if (personaId == null || identificacion == null || residenceId == null) {
          return _errorRoute('Faltan argumentos en QrListPage');
        }
        return _fadeRoute(
          BlocProvider<QrListBloc>(
            create: (_) => GetIt.instance<QrListBloc>(),
            child: QrListPage(personaId: personaId, identificacion: identificacion, residenceId: residenceId),
          ),
          settings: settings,
        );
      }

      case accessHistory: {
        final args = settings.arguments as Map<String, dynamic>?;
        final personaId = int.tryParse(args?['personaId']?.toString() ?? '') ?? 0;
        final identificacion = args?['identificacion'] as String? ?? '';
        final residenceId = args?['residenceId'] as String?;
        if (personaId != null && identificacion != null) {
          return _fadeRoute(AccessHistoryPage(personaId: personaId, identificacion: identificacion, residenceId: residenceId), settings: settings);
        }
        return _fadeRoute(const AccessHistoryPage(personaId: 0, identificacion: '', residenceId: ''), settings: settings);
      }

      case profile: {
        final args = settings.arguments as Map<String, dynamic>?;
        final personaId = int.tryParse(args?['personaId']?.toString() ?? '') ?? 0;
        final identificacion = args?['identificacion'] as String? ?? '';
        if (personaId != null && identificacion != null) {
          return _fadeRoute(ProfilePage(personaId: personaId, identificacion: identificacion), settings: settings);
        }
        return _fadeRoute(const ProfilePage(personaId: 0, identificacion: ''), settings: settings);
      }

      case members: {
        final args = settings.arguments as Map<String, dynamic>?;
        final personaId = int.tryParse(args?['personaId']?.toString() ?? '') ?? 0;
        final identificacion = args?['identificacion'] as String? ?? '';
        final residenceId = args?['residenceId'] as String?;
        if (personaId != null && identificacion != null) {
          return _fadeRoute(MembersPage(personaId: personaId, identificacion: identificacion, residenceId: residenceId), settings: settings);
        }
        return _fadeRoute(const MembersPage(personaId: 0, identificacion: '', residenceId: ''), settings: settings);
      }

      case adminDashboard: {
        final args = settings.arguments as Map<String, dynamic>?;
        final personaId = int.tryParse(args?['personaId']?.toString() ?? '') ?? 0;
        final identificacion = args?['identificacion'] as String? ?? '';
        return _fadeRoute(AdminDashboardPage(personaId: personaId, identificacion: identificacion), settings: settings);
      }

      case adminAccessHistory: {
        final args = settings.arguments as Map<String, dynamic>?;
        final personaId = int.tryParse(args?['personaId']?.toString() ?? '') ?? 0;
        final identificacion = args?['identificacion'] as String? ?? '';
        return _fadeRoute(AdminAccessHistoryPage(personaId: personaId, identificacion: identificacion), settings: settings);
      }

      case adminUsers: {
        final args = settings.arguments as Map<String, dynamic>?;
        final personaId = int.tryParse(args?['personaId']?.toString() ?? '') ?? 0;
        final identificacion = args?['identificacion'] as String? ?? '';
        return _fadeRoute(AdminUsersPage(personaId: personaId, identificacion: identificacion), settings: settings);
      }

      case adminResidents: {
        final args = settings.arguments as Map<String, dynamic>?;
        final personaId = int.tryParse(args?['personaId']?.toString() ?? '') ?? 0;
        final identificacion = args?['identificacion'] as String? ?? '';
        return MaterialPageRoute(builder: (_) => AdminResidentsPage(personaId: personaId, identificacion: identificacion));
      }

      case adminOwners: {
        final args = settings.arguments as Map<String, dynamic>?;
        final personaId = int.tryParse(args?['personaId']?.toString() ?? '') ?? 0;
        final identificacion = args?['identificacion'] as String? ?? '';
        return MaterialPageRoute(builder: (_) => AdminOwnersPage(personaId: personaId, identificacion: identificacion));
      }

      case adminMembers: {
        final args = settings.arguments as Map<String, dynamic>?;
        final personaId = int.tryParse(args?['personaId']?.toString() ?? '') ?? 0;
        final identificacion = args?['identificacion'] as String? ?? '';
        return MaterialPageRoute(builder: (_) => AdminMembersPage(personaId: personaId, identificacion: identificacion));
      }

      case adminAccounts: {
        final args = settings.arguments as Map<String, dynamic>?;
        final personaId = int.tryParse(args?['personaId']?.toString() ?? '') ?? 0;
        final identificacion = args?['identificacion'] as String? ?? '';
        return MaterialPageRoute(builder: (_) => AdminAccountsPage(personaId: personaId, identificacion: identificacion));
      }

      case adminCreateResident: {
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => AdminCreateResidentPage(
            personaId: args?['personaId'] as int? ?? 0,
            identificacion: args?['identificacion'] as String? ?? '',
          ),
        );
      }

      case adminCreateOwner: {
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => AdminCreateOwnerPage(
            personaId: args?['personaId'] as int? ?? 0,
            identificacion: args?['identificacion'] as String? ?? '',
          ),
        );
      }

      case adminCreateMember: {
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => AdminCreateMemberPage(
            personaId: args?['personaId'] as int? ?? 0,
            identificacion: args?['identificacion'] as String? ?? '',
          ),
        );
      }

      case adminFacialEnrollment: {
        final args = settings.arguments as Map<String, dynamic>?;
        final personaId = int.tryParse(args?['personaId']?.toString() ?? '');
        final nombres = args?['nombres'] as String?;
        final apellidos = args?['apellidos'] as String?;
        final type = args?['type'] as String?;
        if (personaId == null || nombres == null || apellidos == null) {
          return _errorRoute('Faltan argumentos en AdminFacialEnrollmentPage');
        }
        return MaterialPageRoute(
          builder: (_) => AdminFacialEnrollmentPage(
            personaId: personaId,
            nombres: nombres,
            apellidos: apellidos,
            type: type,
          ),
        );
      }

      case adminProfile: {
        final args = settings.arguments as Map<String, dynamic>?;
        final personaId = int.tryParse(args?['personaId']?.toString() ?? '') ?? 0;
        final identificacion = args?['identificacion'] as String? ?? '';
        return _fadeRoute(AdminProfilePage(personaId: personaId, identificacion: identificacion), settings: settings);
      }

      case adminNotificaciones: {
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final personaId = args['personaId'] as int? ?? 0;
        final identificacion = args['identificacion'] as String? ?? '';
        return _fadeRoute(
          BlocProvider<AdminNotificacionesBloc>(
            create: (_) => sl<AdminNotificacionesBloc>(),
            child: AdminNotificacionesPage(
              personaId: personaId,
              identificacion: identificacion,
            ),
          ),
          settings: settings,
        );
      }

      case adminViviendas: {
        final args = settings.arguments as Map<String, dynamic>?;
        final personaId = int.tryParse(args?['personaId']?.toString() ?? '') ?? 0;
        final identificacion = args?['identificacion'] as String? ?? '';
        return _fadeRoute(
          BlocProvider<ViviendaBloc>(
            create: (_) => sl<ViviendaBloc>(),
            child: AdminViviendasPage(personaId: personaId, identificacion: identificacion),
          ),
          settings: settings,
        );
      }

      case notificaciones:
        final userId =
            settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) =>
              NotificacionesListaPage(
                  usuarioId: userId),
          settings: settings,
        );

      case notificacionDetalle:
        final notificacion =
            settings.arguments
                as NotificacionItem;
        return MaterialPageRoute(
          builder: (_) =>
              NotificacionDetallePage(
                  notificacion: notificacion),
          settings: settings,
        );

      case familyDashboard: {
        final args = settings.arguments as Map<String, dynamic>?;
        final personaId = int.tryParse(args?['personaId']?.toString() ?? '') ?? 0;
        final identificacion = args?['identificacion'] as String? ?? '';
        final residenceId = args?['residenceId'] as String?;
        if (personaId != null && identificacion != null && residenceId != null) {
          return _fadeRoute(FamilyDashboardPage(personaId: personaId, identificacion: identificacion, residenceId: residenceId), settings: settings);
        }
        return _fadeRoute(const FamilyDashboardPage(personaId: 0, identificacion: '', residenceId: ''), settings: settings);
      }

      default:
        return _errorRoute('Ruta desconocida: ${settings.name}');
    }
  }

  static Route<dynamic> _fadeRoute(Widget page, {RouteSettings? settings}) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 150),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      settings: settings,
    );
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')), 
        body: Text(message)
      ),
    );
  }
}

// lib/presentation/routes/app_routes.dart
import 'package:flutter/material.dart';
import 'package:guardin/presentation/pages/members_page.dart';
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
import '../pages/family_dashboard_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String residentDashboard = '/residentDashboard';
  static const String qrSelf = '/qrSelf';
  static const String qrVisit = '/qrVisit';
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
  static const String familyDashboard = '/familyDashboard';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case residentDashboard: {
        // Ya no requiere argumentos - obtiene datos del AuthBloc y QrBloc
        final args = settings.arguments as Map<String, dynamic>?;
        final personaId = int.tryParse(args?['personaId']?.toString() ?? '');
        final identificacion = args?['identificacion'] as String?;
        final residenceId = args?['residenceId'] as String?;
        // Solo usar argumentos si vienen, sino dejar que la página los obtenga del BLoC
        if (personaId != null && identificacion != null && residenceId != null) {
          return MaterialPageRoute(
            builder: (_) => ResidentDashboardPage(personaId: personaId, identificacion: identificacion, residenceId: residenceId),
          );
        }
        // Fallback: retornar sin argumentos y dejar que la página use los BLoCs
        return MaterialPageRoute(
          builder: (_) => const ResidentDashboardPage(personaId: 0, identificacion: '', residenceId: ''),
        );
      }

      case qrSelf: {
        final args = settings.arguments as Map<String, dynamic>?;
        final personaId = int.tryParse(args?['personaId']?.toString() ?? '');
        final identificacion = args?['identificacion'] as String?;
        final residenceId = args?['residenceId'] as String?;
        if (personaId == null || identificacion == null) return _errorRoute('Faltan argumentos en QrSelfPage');
        return MaterialPageRoute(builder: (_) => QrSelfPage(personaId: personaId, identificacion: identificacion, residenceId: residenceId));
      }

      case qrVisit: {
        final args = settings.arguments as Map<String, dynamic>?;
        final personaId = int.tryParse(args?['personaId']?.toString() ?? '');
        final identificacion = args?['identificacion'] as String?;
        final residenceId = args?['residenceId'] as String?;
        if (personaId == null || identificacion == null || residenceId == null) {
          return _errorRoute('Faltan argumentos en QrVisitPage');
        }
        return MaterialPageRoute(
          builder: (_) => QrVisitPage(personaId: personaId, identificacion: identificacion, residenceId: residenceId),
        );
      }

      case accessHistory: {
        // Ya no requiere argumentos estrictamente
        final args = settings.arguments as Map<String, dynamic>?;
        final personaId = int.tryParse(args?['personaId']?.toString() ?? '');
        final identificacion = args?['identificacion'] as String?;
        final residenceId = args?['residenceId'] as String?;
        if (personaId != null && identificacion != null) {
          return MaterialPageRoute(builder: (_) => AccessHistoryPage(personaId: personaId, identificacion: identificacion, residenceId: residenceId));
        }
        return MaterialPageRoute(builder: (_) => const AccessHistoryPage(personaId: 0, identificacion: '', residenceId: ''));
      }

      case profile: {
        // Ya no requiere argumentos estrictamente
        final args = settings.arguments as Map<String, dynamic>?;
        final personaId = int.tryParse(args?['personaId']?.toString() ?? '');
        final identificacion = args?['identificacion'] as String?;
        if (personaId != null && identificacion != null) {
          return MaterialPageRoute(builder: (_) => ProfilePage(personaId: personaId, identificacion: identificacion));
        }
        return MaterialPageRoute(builder: (_) => const ProfilePage(personaId: 0, identificacion: ''));
      }

      case members: {
        // Ya no requiere argumentos estrictamente
        final args = settings.arguments as Map<String, dynamic>?;
        final personaId = int.tryParse(args?['personaId']?.toString() ?? '');
        final identificacion = args?['identificacion'] as String?;
        final residenceId = args?['residenceId'] as String?;
        if (personaId != null && identificacion != null) {
          return MaterialPageRoute(builder: (_) => MembersPage(personaId: personaId, identificacion: identificacion, residenceId: residenceId));
        }
        return MaterialPageRoute(builder: (_) => const MembersPage(personaId: 0, identificacion: '', residenceId: ''));
      }

      case adminDashboard: {
        final args = settings.arguments as Map<String, dynamic>?;
        final personaId = int.tryParse(args?['personaId']?.toString() ?? '');
        final identificacion = args?['identificacion'] as String?;
        if (personaId == null || identificacion == null) return _errorRoute('Faltan argumentos en AdminDashboardPage');
        return MaterialPageRoute(builder: (_) => AdminDashboardPage(personaId: personaId, identificacion: identificacion));
      }

      case adminAccessHistory: {
        final args = settings.arguments as Map<String, dynamic>?;
        final personaId = int.tryParse(args?['personaId']?.toString() ?? '');
        final identificacion = args?['identificacion'] as String?;
        if (personaId == null || identificacion == null) return _errorRoute('Faltan argumentos en AdminAccessHistoryPage');
        return MaterialPageRoute(builder: (_) => AdminAccessHistoryPage(personaId: personaId, identificacion: identificacion));
      }

      case adminUsers: {
        final args = settings.arguments as Map<String, dynamic>?;
        final personaId = int.tryParse(args?['personaId']?.toString() ?? '');
        final identificacion = args?['identificacion'] as String?;
        if (personaId == null || identificacion == null) return _errorRoute('Faltan argumentos en AdminUsersPage');
        return MaterialPageRoute(builder: (_) => AdminUsersPage(personaId: personaId, identificacion: identificacion));
      }

      case adminResidents: {
        final args = settings.arguments as Map<String, dynamic>?;
        final personaId = int.tryParse(args?['personaId']?.toString() ?? '');
        final identificacion = args?['identificacion'] as String?;
        if (personaId == null || identificacion == null) return _errorRoute('Faltan argumentos en AdminResidentsPage');
        return MaterialPageRoute(builder: (_) => AdminResidentsPage(personaId: personaId, identificacion: identificacion));
      }

      case adminOwners: {
        final args = settings.arguments as Map<String, dynamic>?;
        final personaId = int.tryParse(args?['personaId']?.toString() ?? '');
        final identificacion = args?['identificacion'] as String?;
        if (personaId == null || identificacion == null) return _errorRoute('Faltan argumentos en AdminOwnersPage');
        return MaterialPageRoute(builder: (_) => AdminOwnersPage(personaId: personaId, identificacion: identificacion));
      }

      case adminMembers: {
        final args = settings.arguments as Map<String, dynamic>?;
        final personaId = int.tryParse(args?['personaId']?.toString() ?? '');
        final identificacion = args?['identificacion'] as String?;
        if (personaId == null || identificacion == null) return _errorRoute('Faltan argumentos en AdminMembersPage');
        return MaterialPageRoute(builder: (_) => AdminMembersPage(personaId: personaId, identificacion: identificacion));
      }

      case adminAccounts: {
        final args = settings.arguments as Map<String, dynamic>?;
        final personaId = int.tryParse(args?['personaId']?.toString() ?? '');
        final identificacion = args?['identificacion'] as String?;
        if (personaId == null || identificacion == null) return _errorRoute('Faltan argumentos en AdminAccountsPage');
        return MaterialPageRoute(builder: (_) => AdminAccountsPage(personaId: personaId, identificacion: identificacion));
      }

      case adminCreateResident: {
        final args = settings.arguments as Map<String, dynamic>?;
        final personaId = int.tryParse(args?['personaId']?.toString() ?? '');
        final identificacion = args?['identificacion'] as String?;
        if (personaId == null || identificacion == null) return _errorRoute('Faltan argumentos en AdminCreateResidentPage');
        return MaterialPageRoute(builder: (_) => AdminCreateResidentPage(personaId: personaId, identificacion: identificacion));
      }

      case adminCreateOwner: {
        final args = settings.arguments as Map<String, dynamic>?;
        final personaId = int.tryParse(args?['personaId']?.toString() ?? '');
        final identificacion = args?['identificacion'] as String?;
        if (personaId == null || identificacion == null) return _errorRoute('Faltan argumentos en AdminCreateOwnerPage');
        return MaterialPageRoute(builder: (_) => AdminCreateOwnerPage(personaId: personaId, identificacion: identificacion));
      }

      case adminCreateMember: {
        final args = settings.arguments as Map<String, dynamic>?;
        final personaId = int.tryParse(args?['personaId']?.toString() ?? '');
        final identificacion = args?['identificacion'] as String?;
        if (personaId == null || identificacion == null) return _errorRoute('Faltan argumentos en AdminCreateMemberPage');
        return MaterialPageRoute(builder: (_) => AdminCreateMemberPage(personaId: personaId, identificacion: identificacion));
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
        final personaId = int.tryParse(args?['personaId']?.toString() ?? '');
        final identificacion = args?['identificacion'] as String?;
        if (personaId == null || identificacion == null) return _errorRoute('Faltan argumentos en AdminProfilePage');
        return MaterialPageRoute(builder: (_) => AdminProfilePage(personaId: personaId, identificacion: identificacion));
      }

      case familyDashboard: {
        final args = settings.arguments as Map<String, dynamic>?;
        final personaId = int.tryParse(args?['personaId']?.toString() ?? '');
        final identificacion = args?['identificacion'] as String?;
        final residenceId = args?['residenceId'] as String?;
        // Los argumentos son opcionales - la página puede obtener datos del AuthBloc
        if (personaId != null && identificacion != null && residenceId != null) {
          return MaterialPageRoute(
            builder: (_) => FamilyDashboardPage(personaId: personaId, identificacion: identificacion, residenceId: residenceId),
          );
        }
        // Fallback: retornar sin argumentos y dejar que la página use los BLoCs
        return MaterialPageRoute(
          builder: (_) => const FamilyDashboardPage(personaId: 0, identificacion: '', residenceId: ''),
        );
      }

      default:
        return _errorRoute('Ruta desconocida: ${settings.name}');
    }
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

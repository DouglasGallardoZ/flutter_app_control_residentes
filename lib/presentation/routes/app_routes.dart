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
  static const String familyDashboard = '/familyDashboard';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case residentDashboard: {
        final args = settings.arguments as Map<String, dynamic>?;
        final personaId = args?['personaId'] as int?;
        final identificacion = args?['identificacion'] as String?;
        final residenceId = args?['residenceId'] as String?;
        final userName = args?['userName'] as String?;
        if (personaId == null || identificacion == null || residenceId == null || userName == null) {
          return _errorRoute('Faltan argumentos en ResidentDashboard');
        }
        return MaterialPageRoute(
          builder: (_) => ResidentDashboardPage(personaId: personaId, identificacion: identificacion, residenceId: residenceId, userName: userName,),
        );
      }

      case qrSelf: {
        final args = settings.arguments as Map<String, dynamic>?;
        final personaId = args?['personaId'] as int?;
        final identificacion = args?['identificacion'] as String?;
        final residenceId = args?['residenceId'] as String?;
        final userName = args?['userName'] as String?;
        if (personaId == null || identificacion == null || userName == null) return _errorRoute('Faltan argumentos en QrSelfPage');
        return MaterialPageRoute(builder: (_) => QrSelfPage(personaId: personaId, identificacion: identificacion, residenceId: residenceId, userName: userName));
      }

      case qrVisit: {
        final args = settings.arguments as Map<String, dynamic>?;
        final personaId = args?['personaId'] as int?;
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
        final args = settings.arguments as Map<String, dynamic>?;
        final personaId = args?['personaId'] as int?;
        final identificacion = args?['identificacion'] as String?;
        final residenceId = args?['residenceId'] as String?;
        if (personaId == null || identificacion == null) return _errorRoute('Faltan argumentos en AccessHistoryPage');
        return MaterialPageRoute(builder: (_) => AccessHistoryPage(personaId: personaId, identificacion: identificacion, residenceId: residenceId));
      }

      case profile: {
        final args = settings.arguments as Map<String, dynamic>?;
        final personaId = args?['personaId'] as int?;
        final identificacion = args?['identificacion'] as String?;
        if (personaId == null || identificacion == null) return _errorRoute('Faltan argumentos en ProfilePage');
        return MaterialPageRoute(builder: (_) => ProfilePage(personaId: personaId, identificacion: identificacion));
      }

      case members: {
        final args = settings.arguments as Map<String, dynamic>?;
        final personaId = args?['personaId'] as int?;
        final identificacion = args?['identificacion'] as String?;
        final residenceId = args?['residenceId'] as String?;
        if (personaId == null || identificacion == null) return _errorRoute('Faltan argumentos en MembersPage');
        return MaterialPageRoute(builder: (_) => MembersPage(personaId: personaId, identificacion: identificacion, residenceId: residenceId));
      }

      case adminDashboard: {
        final args = settings.arguments as Map<String, dynamic>?;
        final personaId = args?['personaId'] as int?;
        final identificacion = args?['identificacion'] as String?;
        if (personaId == null || identificacion == null) return _errorRoute('Faltan argumentos en AdminDashboardPage');
        return MaterialPageRoute(builder: (_) => AdminDashboardPage(personaId: personaId, identificacion: identificacion));
      }
      case familyDashboard: {
        final args = settings.arguments as Map<String, dynamic>?;
        final personaId = args?['personaId'] as int?;
        final identificacion = args?['identificacion'] as String?;
        final residenceId = args?['residenceId'] as String?;
        if (personaId == null || identificacion == null) return _errorRoute('Faltan argumentos en FamilyDashboardPage');
        return MaterialPageRoute(builder: (_) => FamilyDashboardPage(personaId: personaId, identificacion: identificacion, residenceId: residenceId));
      }

      default:
        return _errorRoute('Ruta desconocida: ${settings.name}');
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text(message)),
      ),
    );
  }
}

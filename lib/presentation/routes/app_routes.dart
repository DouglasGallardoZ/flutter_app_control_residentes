// lib/presentation/routes/app_routes.dart
import 'package:flutter/material.dart';
import '../pages/login_page.dart';
import '../pages/resident_dashboard_page.dart';
import '../pages/qr_self_page.dart';
import '../pages/qr_visit_page.dart';
import '../pages/access_history_page.dart';
import '../pages/profile_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String residentDashboard = '/residentDashboard';
  static const String qrSelf = '/qrSelf';
  static const String qrVisit = '/qrVisit';
  static const String accessHistory = '/accessHistory';
  static const String profile = '/profile';

  static const String adminDashboard = '/adminDashboard';
  static const String familyDashboard = '/familyDashboard';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case residentDashboard: {
        final args = settings.arguments as Map<String, dynamic>?;
        final userId = args?['userId'] as String?;
        final residenceId = args?['residenceId'] as String?;
        final userName = args?['userName'] as String?;
        if (userId == null || residenceId == null || userName == null) {
          return _errorRoute('Faltan argumentos en ResidentDashboard');
        }
        return MaterialPageRoute(
          builder: (_) => ResidentDashboardPage(userId: userId, residenceId: residenceId, userName: userName,),
        );
      }

      case qrSelf: {
        final args = settings.arguments as Map<String, dynamic>?;
        final userId = args?['userId'] as String?;
        final userName = args?['userName'] as String?;
        if (userId == null || userName == null) return _errorRoute('Falta argumento userId en QrSelfPage');
        return MaterialPageRoute(builder: (_) => QrSelfPage(userId: userId, userName: userName));
      }

      case qrVisit: {
        final args = settings.arguments as Map<String, dynamic>?;
        final userId = args?['userId'] as String?;
        final residenceId = args?['residenceId'] as String?;
        if (userId == null || residenceId == null) {
          return _errorRoute('Faltan argumentos en QrVisitPage');
        }
        return MaterialPageRoute(
          builder: (_) => QrVisitPage(userId: userId, residenceId: residenceId),
        );
      }

      case accessHistory: {
        final args = settings.arguments as Map<String, dynamic>?;
        final userId = args?['userId'] as String?;
        if (userId == null) return _errorRoute('Falta argumento userId en AccessHistoryPage');
        return MaterialPageRoute(builder: (_) => AccessHistoryPage(userId: userId));
      }

      case profile: {
        final args = settings.arguments as Map<String, dynamic>?;
        final userId = args?['userId'] as String?;
        if (userId == null) return _errorRoute('Falta argumento userId en ProfilePage');
        return MaterialPageRoute(builder: (_) => ProfilePage(userId: userId));
      }

      case adminDashboard:
        return _errorRoute('AdminDashboard aún no implementado');
      case familyDashboard:
        return _errorRoute('FamilyDashboard aún no implementado');

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

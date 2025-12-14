import 'package:flutter/material.dart';
import '../pages/login_page.dart';
import '../pages/resident_dashboard_page.dart';
import '../pages/qr_self_page.dart';
import '../pages/qr_visit_page.dart';
import '../pages/access_history_page.dart';
import '../pages/profile_page.dart';
// Si luego agregas AdminDashboardPage o FamilyDashboardPage, también los importas aquí.

class AppRoutes {
  // Definición de nombres de rutas
  static const String login = '/login';
  static const String residentDashboard = '/residentDashboard';
  static const String qrSelf = '/qrSelf';
  static const String qrVisit = '/qrVisit';
  static const String accessHistory = '/accessHistory';
  static const String profile = '/profile';

  static const String adminDashboard = '/adminDashboard';
  static const String familyDashboard = '/familyDashboard';

  /// Método centralizado para generar rutas con validación de argumentos
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case residentDashboard:
        final args = settings.arguments as String?;
        if (args == null) {
          return _errorRoute('Falta argumento userId en ResidentDashboard');
        }
        return MaterialPageRoute(builder: (_) => ResidentDashboardPage(userId: args));

      case qrSelf:
        final args = settings.arguments as String?;
        if (args == null) {
          return _errorRoute('Falta argumento userId en QrSelfPage');
        }
        return MaterialPageRoute(builder: (_) => QrSelfPage(userId: args));

      case qrVisit:
        final args = settings.arguments as String?;
        if (args == null) {
          return _errorRoute('Falta argumento userId en QrVisitPage');
        }
        return MaterialPageRoute(builder: (_) => QrVisitPage(userId: args));

      case accessHistory:
        final args = settings.arguments as String?;
        if (args == null) {
          return _errorRoute('Falta argumento userId en AccessHistoryPage');
        }
        return MaterialPageRoute(builder: (_) => AccessHistoryPage(userId: args));

      case profile:
        final args = settings.arguments as String?;
        if (args == null) {
          return _errorRoute('Falta argumento userId en ProfilePage');
        }
        return MaterialPageRoute(builder: (_) => ProfilePage(userId: args));

      // Ejemplo de rutas futuras
      case adminDashboard:
        return _errorRoute('AdminDashboard aún no implementado');
      case familyDashboard:
        return _errorRoute('FamilyDashboard aún no implementado');

      default:
        return _errorRoute('Ruta desconocida: ${settings.name}');
    }
  }

  /// Ruta de error genérica
  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text(message)),
      ),
    );
  }
}

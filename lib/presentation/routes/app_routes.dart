import 'package:flutter/material.dart';
import '../pages/login_page.dart';
import '../pages/admin_dashboard_page.dart';
import '../pages/resident_dashboard_page.dart';
import '../pages/family_dashboard_page.dart';
import '../pages/qr_self_page.dart';
import '../pages/qr_visit_page.dart';
import '../pages/access_history_page.dart';
import '../pages/qr_view_page.dart';

class AppRoutes {
  static const initial = '/login';
  static const login = '/login';
  static const adminDashboard = '/admin/dashboard';
  static const residentDashboard = '/resident/dashboard';
  static const familyDashboard = '/family/dashboard';
  static const qrSelf = '/qr/self';
  static const qrVisit = '/qr/visit';
  static const qrView = '/qr/view';
  static const accessHistory = '/history';

  static Map<String, WidgetBuilder> get routes => {
        // initial: (_) => const LoginPage(),
        login: (_) => const LoginPage(),
        adminDashboard: (_) => const AdminDashboardPage(),
        residentDashboard: (_) => const ResidentDashboardPage(),
        familyDashboard: (_) => const FamilyDashboardPage(),
        qrSelf: (_) => const QrSelfPage(),
        qrVisit: (_) => const QrVisitPage(),
      };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case qrView:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(builder: (_) => QrViewPage(value: args['value'] as String));
      case accessHistory:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(builder: (_) => AccessHistoryPage(userId: args['userId'] as String));
      default:
        return null;
    }
  }
}

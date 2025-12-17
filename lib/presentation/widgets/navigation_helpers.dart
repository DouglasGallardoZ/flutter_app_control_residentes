import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/blocs/auth/auth_bloc.dart';
import '../../application/blocs/auth/auth_state.dart';
import '../routes/app_routes.dart';

/// Navigate to the appropriate home/dashboard page depending on the current role.
/// Falls back to `ResidentDashboard` when role is unknown.
Future<void> navigateToHome(BuildContext context, {String? routeUserId, String? routeResidenceId, String? routeUserName}) async {
  final authState = context.read<AuthBloc>().state;
  String? userId = routeUserId;
  String? residenceId = routeResidenceId;
  String? userName = routeUserName;

  if (authState is AuthSuccess) {
    userId ??= (authState.user['id'] ?? authState.user['uid']) as String?;
    residenceId ??= authState.user['residence'] as String?;
    userName ??= authState.user['name'] as String?;
  }

  final role = authState is AuthSuccess ? (authState.user['role'] as String? ?? 'resident') : 'resident';

  switch (role) {
    case 'admin':
      Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard, arguments: {'userId': userId, 'residenceId': residenceId, 'userName': userName});
      break;
    case 'family':
      Navigator.pushReplacementNamed(context, AppRoutes.familyDashboard, arguments: {'userId': userId, 'residenceId': residenceId});
      break;
    default:
      if (userId != null && residenceId != null && userName != null) {
        Navigator.pushReplacementNamed(context, AppRoutes.residentDashboard, arguments: {'userId': userId, 'residenceId': residenceId, 'userName': userName});
      } else if (userId != null) {
        // Try to navigate with minimal args to resident dashboard if possible
        Navigator.pushReplacementNamed(context, AppRoutes.residentDashboard, arguments: {'userId': userId, 'residenceId': residenceId ?? '', 'userName': userName ?? ''});
      } else {
        // Fallback to login if we can't resolve user
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (r) => false);
      }
  }
}

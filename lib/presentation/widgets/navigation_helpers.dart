import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/blocs/auth/auth_bloc.dart';
import '../../application/blocs/auth/auth_state.dart';
import '../routes/app_routes.dart';

/// Extrae los datos del usuario del AuthBloc
class AuthUserData {
  final int? personaId;
  final String identificacion;
  final String residenceId;
  final String userName;

  AuthUserData({
    required this.personaId,
    required this.identificacion,
    required this.residenceId,
    required this.userName,
  });
}

/// Obtiene los datos del usuario actual del AuthBloc
AuthUserData getUserDataFromAuth(BuildContext context) {
  final authState = context.read<AuthBloc>().state;
  
  if (authState is AuthSuccess) {
    final personaId = authState.user['persona_id'] as int? ?? authState.user['id'] as int?;
    final identificacion = authState.user['identificacion'] as String? ?? '';
    final residenceId = authState.user['residence'] as String? ?? '';
    final userName = authState.user['name'] as String? ?? '';
    
    return AuthUserData(
      personaId: personaId,
      identificacion: identificacion,
      residenceId: residenceId,
      userName: userName,
    );
  }
  
  return AuthUserData(
    personaId: null,
    identificacion: '',
    residenceId: '',
    userName: '',
  );
}

/// Navigate to the appropriate home/dashboard page depending on the current role.
/// Falls back to `ResidentDashboard` when role is unknown.
Future<void> navigateToHome(BuildContext context, {String? routeUserId, String? routeResidenceId, String? routeUserName}) async {
  final authState = context.read<AuthBloc>().state;
  String? userId = routeUserId;
  String? residenceId = routeResidenceId;
  String? userName = routeUserName;

  if (authState is AuthSuccess) {
    userId ??= (authState.user['id'] ?? authState.user['uid'])?.toString();
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

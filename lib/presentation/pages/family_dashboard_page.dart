import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/blocs/session/session_cubit.dart';
import '../../application/blocs/auth/auth_bloc.dart';
import '../../application/blocs/auth/auth_state.dart';
import '../widgets/app_scaffold.dart';

class FamilyDashboardPage extends StatelessWidget {
  final int personaId;
  final String identificacion;
  final String? residenceId;
  const FamilyDashboardPage({super.key, required this.personaId, required this.identificacion, this.residenceId});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionCubit>().state;
    final id = session.accountId ?? 'ACCOUNT_ID';
    final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String,dynamic>?;
    final maybeResidenceId = routeArgs?['residenceId'] as String? ?? residenceId;
    final maybePersonaId = routeArgs?['personaId'] as int? ?? personaId;
    final maybeIdentificacion = routeArgs?['identificacion'] as String? ?? identificacion;
    final maybeUserName = routeArgs?['userName'] as String?;
    final authState = context.read<AuthBloc>().state;
    String? authUserId;
    String? authResidence;
    String? authName;
    if (authState is AuthSuccess) {
      authUserId = (authState.user['id'] ?? authState.user['uid']) as String?;
      authResidence = authState.user['residence'] as String?;
      authName = authState.user['name'] as String?;
    }

    return AppScaffold(
      title: 'Miembro de familia',
      currentIndex: 3,
      onTabSelected: (i) {
        switch (i) {
          case 0:
            final pid = maybePersonaId;
            final rid = maybeResidenceId;
            final idn = maybeIdentificacion;
            final uname = maybeUserName;
            if (pid != null && rid != null && idn.isNotEmpty && uname != null) {
              Navigator.pushReplacementNamed(context, '/residentDashboard', arguments: {'personaId': pid, 'identificacion': idn, 'residenceId': rid, 'userName': uname});
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faltan datos para ir a Inicio')));
            }
            break;
          case 1:
            final pid2 = maybePersonaId;
            final idn2 = maybeIdentificacion;
            final uname2 = maybeUserName;
            if (pid2 != null && idn2.isNotEmpty && uname2 != null) Navigator.pushReplacementNamed(context, '/qrSelf', arguments: {'personaId': pid2, 'identificacion': idn2, 'userName': uname2}); else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faltan datos')));
            break;
          case 2:
            final pid3 = maybePersonaId;
            final idn3 = maybeIdentificacion;
            final rid3 = maybeResidenceId;
            if (pid3 != null && idn3.isNotEmpty) Navigator.pushReplacementNamed(context, '/accessHistory', arguments: {'personaId': pid3, 'identificacion': idn3, 'residenceId': rid3}); else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faltan datos')));
            break;
          case 3: break;
          case 4:
            final pid4 = maybePersonaId;
            final idn4 = maybeIdentificacion;
            if (pid4 != null && idn4.isNotEmpty) Navigator.pushReplacementNamed(context, '/profile', arguments: {'personaId': pid4, 'identificacion': idn4}); else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faltan datos')));
            break;
        }
      },
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('QR propio'),
            onTap: () {
              if (maybePersonaId != null && maybeIdentificacion.isNotEmpty && maybeUserName != null) Navigator.pushNamed(context, '/qrSelf', arguments: {'personaId': maybePersonaId, 'identificacion': maybeIdentificacion, 'userName': maybeUserName});
            },
          ),
          ListTile(
            title: const Text('QR visita'),
            onTap: () {
              if (maybePersonaId != null && maybeIdentificacion.isNotEmpty && maybeResidenceId != null) Navigator.pushNamed(context, '/qrVisit', arguments: {'personaId': maybePersonaId, 'identificacion': maybeIdentificacion, 'residenceId': maybeResidenceId});
            },
          ),
          ListTile(
            title: const Text('Historial general'),
            onTap: () {
              if (maybePersonaId != null && maybeIdentificacion.isNotEmpty) Navigator.pushNamed(context, '/accessHistory', arguments: {'personaId': maybePersonaId, 'identificacion': maybeIdentificacion, 'residenceId': maybeResidenceId});
            },
          ),
        ],
      ),
    );
  }
}

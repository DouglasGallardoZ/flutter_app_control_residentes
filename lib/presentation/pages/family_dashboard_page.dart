import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/blocs/session/session_cubit.dart';
import '../../application/blocs/auth/auth_bloc.dart';
import '../../application/blocs/auth/auth_state.dart';
import '../widgets/app_scaffold.dart';

class FamilyDashboardPage extends StatelessWidget {
  const FamilyDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionCubit>().state;
    final id = session.accountId ?? 'ACCOUNT_ID';
    final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String,dynamic>?;
    final maybeResidenceId = routeArgs?['residenceId'] as String?;
    final maybeUserId = routeArgs?['userId'] as String?;
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
            final uid = maybeUserId ?? authUserId;
            final rid = maybeResidenceId ?? authResidence;
            final uname = routeArgs?['userName'] as String? ?? authName;
            if (uid != null && rid != null && uname != null) {
              Navigator.pushReplacementNamed(context, '/residentDashboard', arguments: {'userId': uid, 'residenceId': rid, 'userName': uname});
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faltan datos para ir a Inicio')));
            }
            break;
          case 1:
            final uid2 = maybeUserId ?? authUserId;
            final uname2 = routeArgs?['userName'] as String? ?? authName;
            if (uid2 != null && uname2 != null) Navigator.pushReplacementNamed(context, '/qrSelf', arguments: {'userId': uid2, 'userName': uname2}); else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faltan datos')));
            break;
          case 2:
            final uid3 = maybeUserId ?? authUserId;
            if (uid3 != null) Navigator.pushReplacementNamed(context, '/accessHistory', arguments: {'userId': uid3}); else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faltan datos')));
            break;
          case 3: break;
          case 4:
            final uid4 = maybeUserId ?? authUserId;
            if (uid4 != null) Navigator.pushReplacementNamed(context, '/profile', arguments: {'userId': uid4}); else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faltan datos')));
            break;
        }
      },
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('QR propio'),
            onTap: () {
              if (maybeUserId != null && routeArgs?['userName'] != null) Navigator.pushNamed(context, '/qrSelf', arguments: {'userId': maybeUserId, 'userName': routeArgs!['userName']});
            },
          ),
          ListTile(
            title: const Text('QR visita'),
            onTap: () {
              if (maybeUserId != null && maybeResidenceId != null) Navigator.pushNamed(context, '/qrVisit', arguments: {'userId': maybeUserId, 'residenceId': maybeResidenceId});
            },
          ),
          ListTile(
            title: const Text('Historial general'),
            onTap: () => Navigator.pushNamed(context, '/accessHistory', arguments: {'userId': id}),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/qr_preview.dart';
import '../widgets/app_scaffold.dart';
import '../../application/blocs/auth/auth_bloc.dart';
import '../../application/blocs/auth/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QrViewPage extends StatelessWidget {
  final String value;
  final int? personaId;
  final String? identificacion;
  const QrViewPage({super.key, required this.value, this.personaId, this.identificacion});

  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String,dynamic>?;
    final maybePersonaId = routeArgs?['personaId'] as int? ?? personaId;
    final maybeIdentificacion = routeArgs?['identificacion'] as String? ?? identificacion;
    final authState = context.read<AuthBloc>().state;
    String? authUserId;
    String? authResidence;
    String? authName;
    if (authState is AuthSuccess) {
      authUserId = (authState.user['id'] ?? authState.user['uid'])?.toString();
      authResidence = authState.user['residence'] as String?;
      authName = authState.user['name'] as String?;
    }

    return AppScaffold(
      title: 'QR generado',
      currentIndex: 1,
      onTabSelected: (i) {
        switch (i) {
          case 0:
            final pid = maybePersonaId;
            final rid = authResidence;
            final idn = maybeIdentificacion;
            final uname = authName ?? routeArgs?['userName'] as String?;
            if (pid != null && rid != null && idn != null && uname != null) {
              Navigator.pushReplacementNamed(context, '/residentDashboard', arguments: {'personaId': pid, 'identificacion': idn, 'residenceId': rid, 'userName': uname});
            }
            break;
          case 1: break;
          case 2:
            final pid2 = maybePersonaId;
            final idn2 = maybeIdentificacion;
            if (pid2 != null && idn2 != null) Navigator.pushReplacementNamed(context, '/accessHistory', arguments: {'personaId': pid2, 'identificacion': idn2});
            break;
          case 3:
            final pid3 = maybePersonaId;
            final idn3 = maybeIdentificacion;
            if (pid3 != null && idn3 != null) Navigator.pushReplacementNamed(context, '/members', arguments: {'personaId': pid3, 'identificacion': idn3});
            break;
          case 4:
            final pid4 = maybePersonaId;
            final idn4 = maybeIdentificacion;
            if (pid4 != null && idn4 != null) Navigator.pushReplacementNamed(context, '/profile', arguments: {'personaId': pid4, 'identificacion': idn4});
            break;
        }
      },
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            QrPreview(value: value),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Share.share('QR: $value'),
              child: const Text('Compartir'),
            ),
          ],
        ),
      ),
    );
  }
}

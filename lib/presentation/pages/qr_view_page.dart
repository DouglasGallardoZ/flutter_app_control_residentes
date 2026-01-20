import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/qr_preview.dart';
import '../widgets/app_scaffold.dart';
import '../../application/blocs/auth/auth_bloc.dart';
import '../../application/blocs/auth/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QrViewPage extends StatelessWidget {
  final String value;
  const QrViewPage({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String,dynamic>?;
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
      title: 'QR generado',
      currentIndex: 1,
      onTabSelected: (i) {
        switch (i) {
          case 0:
            final uid = maybeUserId ?? authUserId;
            final rid = authResidence;
            final uname = authName ?? routeArgs?['userName'] as String?;
            if (uid != null && rid != null && uname != null) {
              Navigator.pushReplacementNamed(context, '/residentDashboard', arguments: {'userId': uid, 'residenceId': rid, 'userName': uname});
            }
            break;
          case 1: break;
          case 2:
            final uid2 = maybeUserId ?? authUserId;
            if (uid2 != null) Navigator.pushReplacementNamed(context, '/accessHistory', arguments: {'userId': uid2});
            break;
          case 3:
            final uid3 = maybeUserId ?? authUserId;
            if (uid3 != null) Navigator.pushReplacementNamed(context, '/members', arguments: {'userId': uid3});
            break;
          case 4:
            final uid4 = maybeUserId ?? authUserId;
            if (uid4 != null) Navigator.pushReplacementNamed(context, '/profile', arguments: {'userId': uid4});
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

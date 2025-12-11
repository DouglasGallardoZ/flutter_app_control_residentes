import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import 'members_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/session/session_cubit.dart';

class ResidentDashboardPage extends StatelessWidget {
  const ResidentDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionCubit>().state;
    final id = session.accountId ?? 'ACCOUNT_ID';
    return Scaffold(
      appBar: AppBar(title: const Text('Residente')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('QR propio'),
            onTap: () => Navigator.pushNamed(context, AppRoutes.qrSelf),
          ),
          ListTile(
            title: const Text('QR visita'),
            onTap: () => Navigator.pushNamed(context, AppRoutes.qrVisit),
          ),
          ListTile(
            title: const Text('Historial general'),
            onTap: () => Navigator.pushNamed(context, AppRoutes.accessHistory, arguments: {'userId': id}),
          ),
          ListTile(
            title: const Text('Miembros de familia'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MembersPage())),
          ),
        ],
      ),
    );
  }
}

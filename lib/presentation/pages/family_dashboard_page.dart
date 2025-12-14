import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/blocs/session/session_cubit.dart';

class FamilyDashboardPage extends StatelessWidget {
  const FamilyDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionCubit>().state;
    final id = session.accountId ?? 'ACCOUNT_ID';
    return Scaffold(
      appBar: AppBar(title: const Text('Miembro de familia')),
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
        ],
      ),
    );
  }
}

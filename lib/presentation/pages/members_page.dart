import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/form_fields.dart';
import '../../domain/entities/account.dart';
import '../../application/blocs/account/account_bloc.dart';
import '../../application/blocs/account/account_event.dart';
import '../../application/blocs/account/account_state.dart';
import '../widgets/app_scaffold.dart';
import '../../application/blocs/auth/auth_bloc.dart';
import '../../application/blocs/auth/auth_state.dart';

class MembersPage extends StatefulWidget {
  const MembersPage({super.key});

  @override
  State<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> {
  final idCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

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
      title: 'Miembros de familia',
      currentIndex: 3,
      onTabSelected: (i) {
        switch (i) {
          case 0:
            final uid = maybeUserId ?? authUserId;
            final rid = authResidence;
            final uname = authName;
            if (uid != null && rid != null && uname != null) {
              Navigator.pushReplacementNamed(context, '/residentDashboard', arguments: {'userId': uid, 'residenceId': rid, 'userName': uname});
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faltan datos')));
            }
            break;
          case 1:
            final uid1 = maybeUserId ?? authUserId;
            final uname1 = authName;
            if (uid1 != null && uname1 != null) Navigator.pushReplacementNamed(context, '/qrSelf', arguments: {'userId': uid1, 'userName': uname1}); else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faltan datos')));
            break;
          case 2:
            final uid2 = maybeUserId ?? authUserId;
            if (uid2 != null) Navigator.pushReplacementNamed(context, '/accessHistory', arguments: {'userId': uid2}); else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faltan datos')));
            break;
          case 3: break;
          case 4:
            final uid4 = maybeUserId ?? authUserId;
            if (uid4 != null) Navigator.pushReplacementNamed(context, '/profile', arguments: {'userId': uid4}); else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faltan datos')));
            break;
        }
      },
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocConsumer<AccountBloc, AccountState>(
          listener: (ctx, state) {
            if (state is AccountRegistered) {
              ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Miembro registrado')));
            } else if (state is AccountError) {
              ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (ctx, state) {
            return Column(
              children: [
                LabeledField(controller: idCtrl, label: 'Identificación (10 dígitos)'),
                const SizedBox(height: 8),
                LabeledField(controller: nameCtrl, label: 'Nombre completo'),
                const SizedBox(height: 8),
                LabeledField(controller: emailCtrl, label: 'Correo (opcional)'),
                const SizedBox(height: 12),
                if (state is AccountLoading) const CircularProgressIndicator(),
                ElevatedButton(
                  onPressed: () {
                    final acc = Account(
                      uid: 'generated-uid',
                      id: idCtrl.text.trim(),
                      role: 'family',
                      status: 'activo',
                      email: emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim(),
                      name: nameCtrl.text.trim(),
                    );
                    context.read<AccountBloc>().add(RegisterAccountSubmitted(acc));
                  },
                  child: const Text('Registrar miembro'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

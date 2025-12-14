import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/form_fields.dart';
import '../../domain/entities/account.dart';
import '../../application/blocs/account/account_bloc.dart';
import '../../application/blocs/account/account_event.dart';
import '../../application/blocs/account/account_state.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('Miembros de familia')),
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

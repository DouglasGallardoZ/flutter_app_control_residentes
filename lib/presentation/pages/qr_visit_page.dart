import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/qr/qr_bloc.dart';
import '../blocs/qr/qr_event.dart';
import '../blocs/qr/qr_state.dart';
import '../widgets/qr_preview.dart';
import '../blocs/session/session_cubit.dart';

class QrVisitPage extends StatefulWidget {
  const QrVisitPage({super.key});

  @override
  State<QrVisitPage> createState() => _QrVisitPageState();
}

class _QrVisitPageState extends State<QrVisitPage> {
  final nameCtrl = TextEditingController();
  final idCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionCubit>().state;
    final accountId = session.accountId ?? 'ACCOUNT_ID';

    return Scaffold(
      appBar: AppBar(title: const Text('Generar QR de visita')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocBuilder<QrBloc, QrState>(
          builder: (ctx, state) {
            return Column(
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre del visitante'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: idCtrl,
                  decoration: const InputDecoration(labelText: 'Identificación del visitante'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    ctx.read<QrBloc>().add(GenerateVisitQr(
                      accountId,
                      {
                        'expiresAt': DateTime.now().add(const Duration(hours: 4)).toIso8601String(),
                        'maxUses': 1,
                      },
                      nameCtrl.text.trim(),
                      idCtrl.text.trim(),
                    ));
                  },
                  child: const Text('Generar QR'),
                ),
                const SizedBox(height: 20),
                if (state is QrLoading) const CircularProgressIndicator(),
                if (state is QrReady) QrPreview(value: state.qr.value),
                if (state is QrError) Text(state.message),
              ],
            );
          },
        ),
      ),
    );
  }
}

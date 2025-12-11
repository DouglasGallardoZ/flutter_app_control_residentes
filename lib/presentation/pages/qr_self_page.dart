import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/qr/qr_bloc.dart';
import '../blocs/qr/qr_event.dart';
import '../blocs/qr/qr_state.dart';
import '../routes/app_routes.dart';
import '../widgets/qr_preview.dart';
import '../blocs/session/session_cubit.dart';

class QrSelfPage extends StatelessWidget {
  const QrSelfPage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionCubit>().state;
    final accountId = session.accountId ?? 'ACCOUNT_ID';
    return Scaffold(
      appBar: AppBar(title: const Text('QR propio')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocConsumer<QrBloc, QrState>(
          listener: (ctx, state) {
            if (state is QrReady) {
              Navigator.pushNamed(ctx, AppRoutes.qrView, arguments: {'value': state.qr.value});
            }
          },
          builder: (ctx, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () {
                    ctx.read<QrBloc>().add(GenerateSelfQr(accountId, {
                      'expiresAt': DateTime.now().add(const Duration(hours: 4)).toIso8601String(),
                      'maxUses': 1,
                    }));
                  },
                  child: const Text('Generar QR'),
                ),
                const SizedBox(height: 16),
                if (state is QrLoading) const Center(child: CircularProgressIndicator()),
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

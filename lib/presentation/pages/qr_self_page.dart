import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/blocs/qr/qr_bloc.dart';
import '../../application/blocs/qr/qr_event.dart';
import '../../application/blocs/qr/qr_state.dart';

class QrSelfPage extends StatelessWidget {
  final String userId;
  const QrSelfPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Propio')),
      body: BlocBuilder<QrBloc, QrState>(
        builder: (ctx, state) {
          if (state is QrInitial) {
            return Center(
              child: ElevatedButton(
                onPressed: () => ctx.read<QrBloc>().add(
                  GenerateSelfQr(userId, DateTime.now().add(const Duration(hours: 4))),
                ),
                child: const Text('Generar QR'),
              ),
            );
          } else if (state is QrLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is QrReady) {
            return Center(child: Text('Código: ${state.qr.value}'));
          } else if (state is QrError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/blocs/qr/qr_bloc.dart';
import '../../application/blocs/qr/qr_event.dart';
import '../../application/blocs/qr/qr_state.dart';
import '../widgets/app_scaffold.dart';

class QrSelfPage extends StatelessWidget {
  final String userId;
  const QrSelfPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Mi Código QR',
      body: BlocBuilder<QrBloc, QrState>(
        builder: (ctx, state) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Tu Código de Acceso Personal', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              const Text('Genera tu código QR para ingresar al residencial. Este código es personal e intransferible.'),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Identificación: $userId'),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => ctx.read<QrBloc>().add(
                          GenerateSelfQr(userId, DateTime.now().add(const Duration(hours: 4))),
                        ),
                        child: const Text('Generar Mi QR'),
                      ),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 16),
              if (state is QrLoading) const Center(child: CircularProgressIndicator()),
              if (state is QrReady)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Placeholder(fallbackHeight: 180), // aquí va el widget QR real
                      const SizedBox(height: 12),
                      Text('Tu Código de Acceso', style: Theme.of(context).textTheme.titleMedium),
                      Text('Válido hasta: ${state.qr.expiresAt}'),
                      const SizedBox(height: 12),
                      Wrap(spacing: 8, children: [
                        OutlinedButton(onPressed: () {}, child: const Text('Compartir')),
                        OutlinedButton(onPressed: () {}, child: const Text('Descargar')),
                      ]),
                      const SizedBox(height: 8),
                      TextButton(onPressed: () => ctx.read<QrBloc>().add(
                        GenerateSelfQr(userId, DateTime.now().add(const Duration(hours: 4))),
                      ), child: const Text('Generar Otro Código')),
                    ]),
                  ),
                ),
              if (state is QrError) Text(state.message, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ]),
          );
        },
      ),
    );
  }
}

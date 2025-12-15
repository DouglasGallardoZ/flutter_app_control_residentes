import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/blocs/qr/qr_bloc.dart';
import '../../application/blocs/qr/qr_event.dart';
import '../../application/blocs/qr/qr_state.dart';
import '../widgets/app_scaffold.dart';

class QrVisitPage extends StatefulWidget {
  final String userId;
  const QrVisitPage({super.key, required this.userId});

  @override
  State<QrVisitPage> createState() => _QrVisitPageState();
}

class _QrVisitPageState extends State<QrVisitPage> {
  final formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final idCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'QR de Visitante',
      actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.refresh))],
      body: BlocBuilder<QrBloc, QrState>(
        builder: (ctx, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Información del Visitante', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              const Text('Complete los datos del visitante para generar su código de acceso temporal.'),
              const SizedBox(height: 16),
              Form(
                key: formKey,
                child: Column(children: [
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Nombre del Visitante', hintText: 'Ej: Ana García'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'El nombre del visitante es obligatorio' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: idCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Identificación', helperText: '8-10 dígitos'),
                    validator: (v) {
                      final d = v?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
                      if (d.length < 8 || d.length > 10) return 'Ingrese entre 8 y 10 dígitos';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        ctx.read<QrBloc>().add(GenerateVisitQr(
                          widget.userId,
                          idCtrl.text.trim(),
                          nameCtrl.text.trim(),
                          DateTime.now().add(const Duration(hours: 8)),
                        ));
                      }
                    },
                    child: const Text('Generar QR de Visitante'),
                  ),
                ]),
              ),
              const SizedBox(height: 16),
              if (state is QrReady)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Placeholder(fallbackHeight: 180),
                      const SizedBox(height: 8),
                      Text('QR para ${nameCtrl.text}', style: Theme.of(context).textTheme.titleMedium),
                      Text('Identificación: ${idCtrl.text}'),
                      Text('Válido hasta: ${state.qr.expiresAt}'),
                      const SizedBox(height: 12),
                      Wrap(spacing: 8, children: [
                        OutlinedButton(onPressed: () {}, child: const Text('Compartir')),
                        OutlinedButton(onPressed: () {}, child: const Text('Descargar')),
                      ]),
                      TextButton(
                        onPressed: () => setState(() {
                          nameCtrl.clear();
                          idCtrl.clear();
                        }),
                        child: const Text('Generar Otro Código'),
                      ),
                    ]),
                  ),
                ),
              if (state is QrError) Text(state.message, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
          );
        },
      ),
    );
  }
}

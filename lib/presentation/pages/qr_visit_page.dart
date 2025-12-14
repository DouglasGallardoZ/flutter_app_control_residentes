import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/blocs/qr/qr_bloc.dart';
import '../../application/blocs/qr/qr_event.dart';
import '../../application/blocs/qr/qr_state.dart';

class QrVisitPage extends StatefulWidget {
  final String userId;
  const QrVisitPage({super.key, required this.userId});

  @override
  State<QrVisitPage> createState() => _QrVisitPageState();
}

class _QrVisitPageState extends State<QrVisitPage> {
  final idCtrl = TextEditingController();
  final nameCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR de visita')),
      body: BlocBuilder<QrBloc, QrState>(
        builder: (ctx, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(controller: idCtrl, decoration: const InputDecoration(labelText: 'Identificación visitante')),
              const SizedBox(height: 12),
              TextFormField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre visitante')),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => ctx.read<QrBloc>().add(
                  GenerateVisitQr(widget.userId, idCtrl.text, nameCtrl.text,
                    DateTime.now().add(const Duration(hours: 4))),
                ),
                child: const Text('Generar QR'),
              ),
              if (state is QrLoading) const Center(child: CircularProgressIndicator()),
              if (state is QrReady) Center(child: Text('Código: ${state.qr.value}')),
              if (state is QrError) Center(child: Text(state.message)),
            ],
          );
        },
      ),
    );
  }
}

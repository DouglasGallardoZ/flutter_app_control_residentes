import 'package:flutter/material.dart';

class AdminDashboardPage extends StatelessWidget {
  final int personaId;
  final String identificacion;
  const AdminDashboardPage({super.key, required this.personaId, required this.identificacion});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel Administrador')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ListTile(
            leading: Icon(Icons.people),
            title: Text('Gestión de cuentas'),
            subtitle: Text('Registrar, bloquear, desbloquear, eliminar cuentas'),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.history),
            title: Text('Bitácora'),
            subtitle: Text('Ver historial de operaciones y accesos'),
          ),
        ],
      ),
    );
  }
}

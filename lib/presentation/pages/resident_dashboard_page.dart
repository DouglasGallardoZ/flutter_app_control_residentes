import 'package:flutter/material.dart';
import 'qr_self_page.dart';
import 'qr_visit_page.dart';
import 'access_history_page.dart';
import 'profile_page.dart';

class ResidentDashboardPage extends StatelessWidget {
  final String userId;
  const ResidentDashboardPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel Residente')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.qr_code),
            title: const Text('QR propio'),
            onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => QrSelfPage(userId: userId))),
          ),
          ListTile(
            leading: const Icon(Icons.group_add),
            title: const Text('QR de visita'),
            onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => QrVisitPage(userId: userId))),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Historial de accesos'),
            onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => AccessHistoryPage(userId: userId))),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Perfil'),
            onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => ProfilePage(userId: userId))),
          ),
        ],
      ),
    );
  }
}

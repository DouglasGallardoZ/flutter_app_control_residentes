import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final int? currentIndex;
  final void Function(int)? onTabSelected;
  final List<Widget>? actions;
  final bool isRoot; // 👈 marca pantallas raíz (sin back)

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.currentIndex,
    this.onTabSelected,
    this.actions,
    this.isRoot = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        // Siempre ocultamos la flecha de navegación atrás en las pantallas
        automaticallyImplyLeading: false,
        leading: null,
        actions: actions,
      ),
      body: body,
      bottomNavigationBar: (currentIndex != null && onTabSelected != null)
          ? NavigationBar(
              selectedIndex: currentIndex!,
              onDestinationSelected: onTabSelected!,
              destinations: const [
                NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Inicio'),
                NavigationDestination(icon: Icon(Icons.qr_code_2), label: 'Mi QR'),
                NavigationDestination(icon: Icon(Icons.history), label: 'Historial'),
                NavigationDestination(icon: Icon(Icons.group), label: 'Familia'),
                NavigationDestination(icon: Icon(Icons.person_outline), label: 'Perfil'),
              ],
            )
          : null,
    );
  }
}

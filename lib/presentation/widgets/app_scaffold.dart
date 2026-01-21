import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final int? currentIndex;
  final void Function(int)? onTabSelected;
  final List<Widget>? actions;
  final bool isRoot; // 👈 marca pantallas raíz (sin back)
  final bool isFamilyMember; // 👈 indica si es miembro familiar (sin tab Familia)
  final String? routeName; // 👈 nombre explícito de la ruta para calcular el índice

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.currentIndex,
    this.onTabSelected,
    this.actions,
    this.isRoot = false,
    this.isFamilyMember = false,
    this.routeName,
  });

  /// Mapea el nombre de la ruta al índice del tab
  static int _getTabIndexFromRoute(String routeName, bool isFamilyMember) {
    switch (routeName) {
      case '/residentDashboard':
      case '/familyDashboard':
        return 0;
      case '/qrSelf':
      case '/qrVisit':
        return 1;
      case '/accessHistory':
        return 2;
      case '/members':
        return isFamilyMember ? 3 : 3; // Familia (solo residentes)
      case '/profile':
        return isFamilyMember ? 3 : 4; // Perfil (último tab)
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usar el routeName pasado explícitamente, o intentar obtenerlo del context
    final currentRoute = routeName ?? (ModalRoute.of(context)?.settings.name ?? '');
    
    // Calcular el tab index desde el nombre de la ruta SIEMPRE
    final calculatedIndex = _getTabIndexFromRoute(currentRoute, isFamilyMember);
    
    debugPrint('[AppScaffold] title=$title, currentRoute=$currentRoute, calculatedIndex=$calculatedIndex, isFamilyMember=$isFamilyMember');
    
    // Construir las destinations dinámicamente según el tipo de usuario
    final destinations = <NavigationDestination>[
      const NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Inicio'),
      const NavigationDestination(icon: Icon(Icons.qr_code_2), label: 'Mi QR'),
      const NavigationDestination(icon: Icon(Icons.history), label: 'Historial'),
    ];
    
    // Si NO es miembro familiar, agregar tabs adicionales
    if (!isFamilyMember) {
      destinations.addAll([
        const NavigationDestination(icon: Icon(Icons.group), label: 'Familia'),
        const NavigationDestination(icon: Icon(Icons.person_outline), label: 'Perfil'),
      ]);
    } else {
      // Si ES miembro familiar, solo agregar el tab de Perfil
      destinations.add(const NavigationDestination(icon: Icon(Icons.person_outline), label: 'Perfil'));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        // Siempre ocultamos la flecha de navegación atrás en las pantallas
        automaticallyImplyLeading: false,
        leading: null,
        actions: actions,
      ),
      body: body,
      bottomNavigationBar: onTabSelected != null
          ? NavigationBar(
              selectedIndex: calculatedIndex, // 👈 USAR índice calculado desde la ruta actual
              onDestinationSelected: onTabSelected!,
              destinations: destinations,
            )
          : null,
    );
  }
}


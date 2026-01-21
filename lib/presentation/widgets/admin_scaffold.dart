import 'package:flutter/material.dart';

class AdminScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final int? currentIndex;
  final void Function(int)? onTabSelected;
  final List<Widget>? actions;
  final String? routeName;

  const AdminScaffold({
    super.key,
    required this.title,
    required this.body,
    this.currentIndex,
    this.onTabSelected,
    this.actions,
    this.routeName,
  });

  /// Mapea el nombre de la ruta al índice del tab del admin
  static int _getTabIndexFromRoute(String routeName) {
    switch (routeName) {
      case '/adminDashboard':
        return 0;
      case '/adminAccessHistory':
        return 1;
      case '/adminUsers':
        return 2;
      case '/adminProfile':
        return 3;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usar el routeName pasado explícitamente
    final currentRoute = routeName ?? (ModalRoute.of(context)?.settings.name ?? '');

    // Calcular el tab index desde el nombre de la ruta
    final calculatedIndex = _getTabIndexFromRoute(currentRoute);

    debugPrint(
      '[AdminScaffold] title=$title, currentRoute=$currentRoute, calculatedIndex=$calculatedIndex',
    );

    // Tabs específicos para admin
    const destinations = <NavigationDestination>[
      NavigationDestination(
        icon: Icon(Icons.dashboard_outlined),
        selectedIcon: Icon(Icons.dashboard),
        label: 'Dashboard',
      ),
      NavigationDestination(
        icon: Icon(Icons.history_outlined),
        selectedIcon: Icon(Icons.history),
        label: 'Historial',
      ),
      NavigationDestination(
        icon: Icon(Icons.people_outlined),
        selectedIcon: Icon(Icons.people),
        label: 'Usuarios',
      ),
      NavigationDestination(
        icon: Icon(Icons.person_outlined),
        selectedIcon: Icon(Icons.person),
        label: 'Perfil',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        // Sin botón de atrás para pantallas admin
        automaticallyImplyLeading: false,
        leading: null,
        elevation: 0,
        actions: actions,
      ),
      body: body,
      bottomNavigationBar: onTabSelected != null
          ? NavigationBar(
              selectedIndex: calculatedIndex,
              onDestinationSelected: onTabSelected,
              destinations: destinations,
            )
          : null,
    );
  }
}

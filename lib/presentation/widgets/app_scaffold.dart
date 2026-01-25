import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/blocs/auth/auth_bloc.dart';
import '../../application/blocs/auth/auth_state.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final int? currentIndex;
  final void Function(int)? onTabSelected;
  final List<Widget>? actions;
  final bool isRoot; // 👈 marca pantallas raíz (sin back)
  final String? routeName; // 👈 nombre explícito de la ruta para calcular el índice
  final bool showBackButton; // 👈 mostrar botón de back

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.currentIndex,
    this.onTabSelected,
    this.actions,
    this.isRoot = false,
    this.routeName,
    this.showBackButton = false,
  });

  /// Determina si el usuario es miembro familiar basado en su rol
  static bool _isFamilyMemberByRole(String? role) {
    if (role == null) return false;
    final normalized = role.toLowerCase();
    return normalized == 'miembro_familia' || normalized == 'family' || normalized == 'miembro de familia';
  }

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
    // Obtener el rol desde AuthBloc (fuente de verdad)
    final authState = context.read<AuthBloc>().state;
    String? userRole;
    if (authState is AuthSuccess) {
      userRole = authState.user['rol'] as String?;
    }
    final isFamilyMember = _isFamilyMemberByRole(userRole);
    
    // Usar el routeName pasado explícitamente, o intentar obtenerlo del context
    final currentRoute = routeName ?? (ModalRoute.of(context)?.settings.name ?? '');
    
    // Calcular el tab index desde el nombre de la ruta SIEMPRE
    final calculatedIndex = _getTabIndexFromRoute(currentRoute, isFamilyMember);
    
    debugPrint('[AppScaffold] title=$title, currentRoute=$currentRoute, calculatedIndex=$calculatedIndex, isFamilyMember=$isFamilyMember, rol=$userRole');
    
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
        // Mostrar back button si showBackButton es true
        automaticallyImplyLeading: showBackButton,
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
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


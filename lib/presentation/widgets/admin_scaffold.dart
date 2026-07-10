import 'package:flutter/material.dart';
import 'responsive_layout.dart';

class AdminScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final int? currentIndex;
  final void Function(int)? onTabSelected;
  final List<Widget>? actions;
  final String? routeName;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const AdminScaffold({
    super.key,
    required this.title,
    required this.body,
    this.currentIndex,
    this.onTabSelected,
    this.actions,
    this.routeName,
    this.showBackButton = false,
    this.onBackPressed,
  });

  static int _getTabIndexFromRoute(String routeName) {
    switch (routeName) {
      case '/adminDashboard':
        return 0;
      case '/adminAccessHistory':
        return 1;
      case '/adminUsers':
      case '/adminResidents':
      case '/adminOwners':
      case '/adminMembers':
      case '/adminAccounts':
      case '/adminCreateResident':
      case '/adminCreateOwner':
      case '/adminCreateMember':
      case '/adminFacialEnrollment':
        return 2;
      case '/adminProfile':
        return 3;
      case '/adminNotificaciones':
        return 4;
      default:
        return 0;
    }
  }

  static const _destinations = <NavigationDestination>[
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
    NavigationDestination(
      icon: Icon(Icons.notifications_outlined),
      selectedIcon: Icon(Icons.notifications),
      label: 'Notificaciones',
    ),
  ];

  static const _railDestinations = <NavigationRailDestination>[
    NavigationRailDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: Text('Dashboard'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.history_outlined),
      selectedIcon: Icon(Icons.history),
      label: Text('Historial'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.people_outlined),
      selectedIcon: Icon(Icons.people),
      label: Text('Usuarios'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.person_outlined),
      selectedIcon: Icon(Icons.person),
      label: Text('Perfil'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.notifications_outlined),
      selectedIcon: Icon(Icons.notifications),
      label: Text('Notificaciones'),
    ),
  ];

  static const _drawerItems = [
    (Icons.dashboard, 'Dashboard', 0),
    (Icons.history, 'Historial', 1),
    (Icons.people, 'Usuarios', 2),
    (Icons.person, 'Perfil', 3),
    (Icons.notifications, 'Notificaciones', 4),
  ];

  Widget _buildDrawer(int calculatedIndex, BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: Theme.of(context).brightness ==
                          Brightness.light
                      ? const [
                          Color(0xFFFFFFFF),
                          Color(0xFFDCDBE5)
                        ]
                      : const [
                          Color(0xFF1A1A2E),
                          Color(0xFF2D1B3D)
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                mainAxisAlignment:
                    MainAxisAlignment.end,
                children: [
                  Icon(Icons.admin_panel_settings,
                      size: 48,
                      color: Theme.of(context)
                          .colorScheme
                          .primary),
                  const SizedBox(height: 8),
                  const Text('Panel Admin',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight:
                              FontWeight.bold)),
                ],
              ),
            ),
            ..._drawerItems.map((entry) {
              final (icon, label, index) = entry;
              final selected =
                  index == calculatedIndex;
              return ListTile(
                leading: Icon(icon,
                    color: selected
                        ? Theme.of(context)
                            .colorScheme
                            .primary
                        : null),
                title: Text(label,
                    style: TextStyle(
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight
                                .normal)),
                selected: selected,
                onTap: () {
                  Navigator.of(context).pop();
                  onTabSelected?.call(index);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildWideLayout(int calculatedIndex,
      BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        automaticallyImplyLeading: showBackButton,
        leading: showBackButton
            ? IconButton(
                icon:
                    const Icon(Icons.arrow_back),
                onPressed: onBackPressed ??
                    () =>
                        Navigator.of(context)
                            .pop(),
              )
            : null,
        elevation: 0,
        actions: actions,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: Theme.of(context).brightness ==
                        Brightness.light
                    ? const [
                        Color(0xFFFFFFFF),
                        Color(0xFFDCDBE5)
                      ]
                    : const [
                        Color(0xFF1A1A2E),
                        Color(0xFF2D1B3D)
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                if (onTabSelected != null)
                  NavigationRail(
                    selectedIndex:
                        calculatedIndex,
                    onDestinationSelected:
                        onTabSelected!,
                    destinations:
                        _railDestinations,
                    labelType:
                        NavigationRailLabelType
                            .all,
                  ),
                if (onTabSelected != null)
                  const VerticalDivider(width: 1),
                Expanded(child: body),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(int calculatedIndex,
      BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        automaticallyImplyLeading: showBackButton,
        leading: showBackButton
            ? IconButton(
                icon:
                    const Icon(Icons.arrow_back),
                onPressed: onBackPressed ??
                    () =>
                        Navigator.of(context)
                            .pop(),
              )
            : (onTabSelected != null
                ? Builder(
                    builder: (ctx) => IconButton(
                      icon:
                          const Icon(Icons.menu),
                      onPressed: () =>
                          Scaffold.of(ctx)
                              .openDrawer(),
                    ),
                  )
                : null),
        elevation: 0,
        actions: actions,
      ),
      drawer: onTabSelected != null
          ? _buildDrawer(
              calculatedIndex, context)
          : null,
      body: body,
      bottomNavigationBar:
          onTabSelected != null
              ? NavigationBar(
                  selectedIndex:
                      calculatedIndex,
                  onDestinationSelected:
                      onTabSelected!,
                  destinations:
                      _destinations,
                )
              : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = routeName ??
        (ModalRoute.of(context)
                ?.settings
                .name ??
            '');
    final calculatedIndex =
        _getTabIndexFromRoute(currentRoute);

    return ResponsiveLayout(
      mobile: _buildMobileLayout(
          calculatedIndex, context),
      tablet: _buildWideLayout(
          calculatedIndex, context),
      desktop: _buildWideLayout(
          calculatedIndex, context),
    );
  }
}

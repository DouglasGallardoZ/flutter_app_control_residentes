import 'package:flutter/material.dart';
import '../widgets/admin_scaffold.dart';

class AdminUsersPage extends StatefulWidget {
  final int personaId;
  final String identificacion;

  const AdminUsersPage({
    super.key,
    required this.personaId,
    required this.identificacion,
  });

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Gestión de Usuarios',
      routeName: '/adminUsers',
      onTabSelected: (index) {
        if (index == 2) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final routes = [
            '/adminDashboard',
            '/adminAccessHistory',
            null,
            '/adminProfile',
            '/adminNotificaciones',
            '/adminViviendas',
          ];
          if (routes[index] != null) {
            Navigator.of(context).pushReplacementNamed(
              routes[index]!,
              arguments: {
                'personaId': widget.personaId,
                'identificacion': widget.identificacion,
              },
            );
          }
        });
      },
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
              // Card de Gestión de Residentes
              _UserManagementCard(
                title: 'Gestión de Residentes',
                subtitle: 'Administrar residentes del complejo',
                icon: Icons.home,
                iconColor: Colors.blue,
                description: 'Ver, editar, bloquear o eliminar residentes',
                onTap: () {
                  Navigator.of(context).pushNamed(
                    '/adminResidents',
                    arguments: {
                      'personaId': widget.personaId,
                      'identificacion': widget.identificacion,
                    },
                  );
                },
              ),
              const SizedBox(height: 16),

              // Card de Gestión de Propietarios
              _UserManagementCard(
                title: 'Gestión de Propietarios',
                subtitle: 'Administrar propietarios',
                icon: Icons.business_center,
                iconColor: Colors.purple,
                description: 'Ver, bloquear o eliminar propietarios',
                onTap: () {
                  Navigator.of(context).pushNamed(
                    '/adminOwners',
                    arguments: {
                      'personaId': widget.personaId,
                      'identificacion': widget.identificacion,
                    },
                  );
                },
              ),
              const SizedBox(height: 16),

              // Card de Gestión de Miembros
              _UserManagementCard(
                title: 'Gestión de Miembros',
                subtitle: 'Administrar miembros de familia',
                icon: Icons.group,
                iconColor: Colors.pink,
                description: 'Gestionar miembros de familia vinculados',
                onTap: () {
                  Navigator.of(context).pushNamed(
                    '/adminMembers',
                    arguments: {
                      'personaId': widget.personaId,
                      'identificacion': widget.identificacion,
                    },
                  );
                },
              ),
              const SizedBox(height: 16),

              // Card de Gestión de Cuentas
              _UserManagementCard(
                title: 'Gestión de Cuentas',
                subtitle: 'Administrar cuentas de usuario',
                icon: Icons.account_circle,
                iconColor: Colors.orange,
                description: 'Gestionar cuentas de usuario',
                onTap: () {
                  Navigator.of(context).pushNamed(
                    '/adminAccounts',
                    arguments: {
                      'personaId': widget.personaId,
                      'identificacion': widget.identificacion,
                    },
                  );
                },
              ),
            ],
          ),
    );
  }
}

class _UserManagementCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final String description;
  final VoidCallback onTap;

  const _UserManagementCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 18, color: iconColor),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

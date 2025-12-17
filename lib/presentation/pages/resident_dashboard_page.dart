import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/blocs/auth/auth_bloc.dart';
import '../../application/blocs/auth/auth_state.dart';
import '../../application/blocs/account/account_bloc.dart';
import '../../application/blocs/account/account_event.dart';
import '../../application/blocs/account/account_state.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/metric_card.dart';
import '../widgets/activity_item.dart';
import '../routes/app_routes.dart';
import '../../presentation/theme/theme_controller.dart';

class ResidentDashboardPage extends StatefulWidget {
  final String userId;
  final String residenceId;
  final String userName;
  const ResidentDashboardPage({super.key, required this.userId, required this.residenceId, required this.userName});

  @override
  State<ResidentDashboardPage> createState() => _ResidentDashboardPageState();
}

class _ResidentDashboardPageState extends State<ResidentDashboardPage> {
  int tabIndex = 0;
  bool _requestedMembers = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final separatorColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;

    final authState = context.read<AuthBloc>().state;
    String? authName;
    String? authResidence;
    if (authState is AuthSuccess) {
      authName = authState.user['name'] as String?;
      authResidence = authState.user['residence'] as String?;
    }

    final displayName = (widget.userName.isNotEmpty) ? widget.userName : (authName ?? 'Usuario');
    final displayResidence = (widget.residenceId.isNotEmpty) ? widget.residenceId : (authResidence ?? '—');

    return AppScaffold(
      title: 'Acceso Residencial',
      isRoot: true,
      currentIndex: tabIndex,
      onTabSelected: (i) {
        setState(() => tabIndex = i);
        switch (i) {
          case 1: Navigator.pushNamed(context, AppRoutes.qrSelf, arguments: {'userId': widget.userId, 'residenceId': widget.residenceId, 'userName': widget.userName}); break;
          case 2: Navigator.pushNamed(context, AppRoutes.accessHistory, arguments: {'userId': widget.userId, 'residenceId': widget.residenceId}); break;
          case 3: Navigator.pushNamed(context, AppRoutes.members, arguments: {'userId': widget.userId, 'residenceId': widget.residenceId}); break;
          case 4: Navigator.pushNamed(context, AppRoutes.profile, arguments: {'userId': widget.userId, 'residenceId': widget.residenceId}); break;
        }
      },
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header con nombre y residencia
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(displayName, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Row(children: [
                  Icon(Icons.home_outlined, size: 16, color: theme.hintColor),
                  const SizedBox(width: 6),
                  Text('Residencia $displayResidence', style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
                ]),
              ]),
              IconButton(
                onPressed: () => ThemeController.toggle(),
                icon: Icon(
                  Theme.of(context).brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: separatorColor),
          const SizedBox(height: 12),

          // Métricas
          Wrap(spacing: 12, runSpacing: 12, children: [
            SizedBox(width: 175, child: MetricCard(label: 'Accesos Hoy', value: '2', icon: Icons.today)),
            Builder(builder: (ctx) {
              final residenceId = (widget.residenceId.isNotEmpty) ? widget.residenceId : (authResidence ?? '');
              if (!_requestedMembers && residenceId.isNotEmpty) {
                context.read<AccountBloc>().add(LoadFamilyMembersRequested(residenceId));
                _requestedMembers = true;
              }
              return SizedBox(
                width: 160,
                child: BlocBuilder<AccountBloc, AccountState>(builder: (c, s) {
                  int count = 0;
                  if (s is AccountMembersLoaded) count = s.members.length;
                  return MetricCard(label: 'Miembros', value: '$count', icon: Icons.group);
                }),
              );
            }),
          ]),
          const SizedBox(height: 16),
          Divider(color: separatorColor),
          const SizedBox(height: 12),

          // Acceso rápido
          Text('Acceso Rápido', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          GridView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.25,
            ),
            children: [
              _QuickCard(icon: Icons.qr_code_2, label: 'Mi QR', onTap: () {
                Navigator.pushNamed(context, AppRoutes.qrSelf, arguments: {'userId': widget.userId, 'residenceId': widget.residenceId, 'userName': widget.userName});
              }),
              _QuickCard(icon: Icons.group_add, label: 'QR Visita', onTap: () {
                Navigator.pushNamed(context, AppRoutes.qrVisit, arguments: {'userId': widget.userId, 'residenceId': widget.residenceId});
              }),
              _QuickCard(icon: Icons.history, label: 'Historial', onTap: () {
                Navigator.pushNamed(context, AppRoutes.accessHistory, arguments: {'userId': widget.userId, 'residenceId': widget.residenceId});
              }),
              _QuickCard(icon: Icons.family_restroom, label: 'Familia', onTap: () {
                Navigator.pushNamed(context, AppRoutes.members, arguments: {'userId': widget.userId, 'residenceId': widget.residenceId});
              }),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: separatorColor),
          const SizedBox(height: 12),

          // Actividad reciente
          Text('Actividad Reciente', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          const ActivityItem(
            title: 'Acceso propio',
            subtitle: 'Entrada Principal · 14 dic, 17:17',
            time: 'Exitoso',
            success: true,
          ),
        ],
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickCard({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 32, color: theme.colorScheme.primary),
            const SizedBox(height: 10),
            Text(label, style: theme.textTheme.titleMedium),
          ]),
        ),
      ),
    );
  }
}

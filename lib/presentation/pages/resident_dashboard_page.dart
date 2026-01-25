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

class ResidentDashboardPage extends StatefulWidget {
  final int personaId;
  final String identificacion;
  final String residenceId;
  const ResidentDashboardPage({
    super.key,
    required this.personaId,
    required this.identificacion,
    required this.residenceId,
  });

  @override
  State<ResidentDashboardPage> createState() => _ResidentDashboardPageState();
}

class _ResidentDashboardPageState extends State<ResidentDashboardPage> {
  int tabIndex = 0;
  bool _requestedMembers = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final separatorColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;

    final authState = context.read<AuthBloc>().state;
    
    // Extraer datos del AuthBloc - SIEMPRE deben estar disponibles después del login
    String displayName = 'Usuario';
    int personaId = 0;
    String identificacion = '';
    String residenceId = '';
    int? viviendaId;
    
    if (authState is AuthSuccess) {
      // SIEMPRE usar datos del AuthBloc (son la fuente de verdad)
      displayName = (authState.user['name'] ?? 
                    authState.user['nombreCompleto'] ?? 
                    authState.user['nombres'] ?? 'Usuario') as String;
      personaId = authState.user['personaId'] as int? ?? 0;
      identificacion = (authState.user['identificacion'] ?? 
                       authState.user['identification'] ?? 
                       authState.user['dni'] ?? '') as String;
      residenceId = (authState.user['residence'] ?? '') as String;
      viviendaId = authState.user['residence_id'] as int?;
    }
    
    // Los parámetros del widget son FALLBACK (para compatibilidad con rutas antiguas)
    if (residenceId.isEmpty && widget.residenceId.isNotEmpty) residenceId = widget.residenceId;
    if (identificacion.isEmpty && widget.identificacion.isNotEmpty) identificacion = widget.identificacion;
    if (personaId == 0 && widget.personaId != 0) personaId = widget.personaId;

    final displayResidence = residenceId.isNotEmpty ? residenceId : '—';

    return AppScaffold(
      title: 'Acceso Residencial',
      routeName: '/residentDashboard',
      isRoot: true,
      onTabSelected: (i) {
        if (i == 0) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          switch (i) {
            case 1: Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.qrSelf, (route) => false, arguments: {'personaId': personaId, 'identificacion': identificacion, 'residenceId': residenceId}); break;
            case 2: Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.accessHistory, (route) => false, arguments: {'personaId': personaId, 'identificacion': identificacion, 'residenceId': residenceId}); break;
            case 3: Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.members, (route) => false, arguments: {'personaId': personaId, 'identificacion': identificacion, 'residenceId': residenceId}); break;
            case 4: Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.profile, (route) => false, arguments: {'personaId': personaId, 'identificacion': identificacion, 'residenceId': residenceId}); break;
          }
        });
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
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: separatorColor),
          const SizedBox(height: 12),

          // Métricas
          Wrap(spacing: 12, runSpacing: 12, children: [
            SizedBox(width: 175, child: MetricCard(label: 'Accesos Hoy', value: '2', icon: Icons.today)),
            Builder(builder: (ctx) {
              if (!_requestedMembers) {
                // Preferentemente usar vivienda_id si está disponible
                if (viviendaId != null && viviendaId! > 0) {
                  context.read<AccountBloc>().add(LoadFamilyMembersRequested(viviendaId));
                } else if (residenceId.isNotEmpty) {
                  context.read<AccountBloc>().add(LoadFamilyMembersRequested(residenceId));
                }
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
                Navigator.pushNamed(context, AppRoutes.qrSelf, arguments: {'personaId': personaId, 'identificacion': identificacion, 'residenceId': residenceId});
              }),
              _QuickCard(icon: Icons.group_add, label: 'QR Visita', onTap: () {
                Navigator.pushNamed(context, AppRoutes.qrVisit, arguments: {'personaId': personaId, 'identificacion': identificacion, 'residenceId': residenceId});
              }),
              _QuickCard(icon: Icons.history, label: 'Historial', onTap: () {
                Navigator.pushNamed(context, AppRoutes.accessHistory, arguments: {'personaId': personaId, 'identificacion': identificacion, 'residenceId': residenceId});
              }),
              _QuickCard(icon: Icons.family_restroom, label: 'Familia', onTap: () {
                Navigator.pushNamed(context, AppRoutes.members, arguments: {'personaId': personaId, 'identificacion': identificacion, 'residenceId': residenceId});
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

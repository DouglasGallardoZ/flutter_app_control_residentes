import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/blocs/auth/auth_bloc.dart';
import '../../application/blocs/auth/auth_state.dart';
import '../../application/blocs/account/account_bloc.dart';
import '../../application/blocs/account/account_event.dart';
import '../../application/blocs/account/account_state.dart';
import '../../application/blocs/resident/resident_bloc.dart';
import '../../application/blocs/resident/resident_event.dart';
import '../../application/blocs/resident/resident_state.dart';
import '../../application/blocs/security_session/security_session_bloc.dart';
import '../../application/blocs/security_session/security_session_state.dart';
import '../../domain/entities/prospecto_residente.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/metric_card.dart';
import '../widgets/activity_item.dart';
import '../widgets/insignia_notificaciones.dart';
import '../routes/app_routes.dart';
import 'facial_verification_page.dart';

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
  bool _requestedAccesses = false;

  Future<bool> _navigateSeguro(
    String route, {
    required Map<String, dynamic> args,
    required String nombres,
    required String apellidos,
    required ViviendaInfo vivienda,
  }) async {
    final securityState = context.read<SecuritySessionBloc>().state;
    bool canAccess = securityState is SecuritySessionActive;

    if (!canAccess) {
      final prospecto = ProspectoResidente(
        personaId: args['personaId'] as int? ?? 0,
        identificacion: args['identificacion'] as String? ?? '',
        nombres: nombres,
        apellidos: apellidos,
        tipoRegistro: 'residente',
        vivienda: vivienda,
        puedeCrearCuenta: false,
      );

      final success = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => FacialVerificationPage(
            prospecto: prospecto,
            mode: VerificationMode.unlockApp,
          ),
        ),
      );
      canAccess = success == true;
    }

    if (canAccess && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushNamedAndRemoveUntil(
            route, (_) => false,
            arguments: args);
      });
    }
    return canAccess;
  }

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
    String nombres = '';
    String apellidos = '';
    String displayName = 'Usuario';
    int personaId = 0;
    String identificacion = '';
    String residenceId = '';
    int? viviendaId;
    
    if (authState is AuthSuccess) {
      nombres = (authState.user['nombres'] ?? '') as String;
      apellidos = (authState.user['apellidos'] ?? '') as String;
      displayName = '$nombres $apellidos'.trim().isNotEmpty ? '$nombres $apellidos' : 'Usuario';
      personaId = authState.user['personaId'] as int? ?? 0;
      identificacion = (authState.user['identificacion'] ?? 
                       authState.user['identification'] ?? 
                       authState.user['dni'] ?? '') as String;
      residenceId = (authState.user['residence'] ?? '') as String;
      viviendaId = authState.user['residence_id'] as int?;
    }

    final viviendaMap = (authState is AuthSuccess
            ? authState.user['vivienda'] as Map<String, dynamic>?
            : null) ??
        <String, dynamic>{};
    final viviendaInfo = ViviendaInfo(
      viviendaId: viviendaMap['vivienda_id'] as int? ?? viviendaMap['viviendaId'] as int? ?? 0,
      manzana: viviendaMap['manzana'] as String? ?? '',
      villa: viviendaMap['villa'] as String? ?? '',
    );

    final _args = {
      'personaId': personaId,
      'identificacion': identificacion,
      'residenceId': residenceId,
    };
    
    // Los parámetros del widget son FALLBACK (para compatibilidad con rutas antiguas)
    if (residenceId.isEmpty && widget.residenceId.isNotEmpty) residenceId = widget.residenceId;
    if (identificacion.isEmpty && widget.identificacion.isNotEmpty) identificacion = widget.identificacion;
    if (personaId == 0 && widget.personaId != 0) personaId = widget.personaId;

    final displayResidence = residenceId.isNotEmpty ? residenceId : '—';

    return AppScaffold(
      title: 'Acceso Residencial',
      routeName: '/residentDashboard',
      isRoot: true,
      actions: [
        InsigniaNotificaciones(
          usuarioId: personaId.toString(),
        ),
      ],
      onTabSelected: (i) {
        if (i == 0) return;
        if (i == 1) {
          _navigateSeguro(AppRoutes.qrSelf,
              args: _args,
              nombres: nombres,
              apellidos: apellidos,
              vivienda: viviendaInfo);
          return;
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          switch (i) {
            case 2: Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.accessHistory, (route) => false, arguments: _args); break;
            case 3: Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.members, (route) => false, arguments: _args); break;
            case 4: Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.profile, (route) => false, arguments: _args); break;
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
            Builder(builder: (ctx) {
              // Load accesses on first build
              if (!_requestedAccesses && viviendaId != null && viviendaId > 0) {
                // Get today's date in format YYYY-MM-DD
                final today = DateTime.now();
                final fechaHoy = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
                
                context.read<ResidentBloc>().add(LoadResidenceAccessesEvent(
                  viviendaId: viviendaId,
                  fechaInicio: fechaHoy,
                  fechaFin: fechaHoy,
                ));
                _requestedAccesses = true;
              }
              
              return SizedBox(
                width: 175,
                child: BlocBuilder<ResidentBloc, ResidentState>(
                  builder: (c, s) {
                    int accessesCount = 0;
                    if (s is ResidenceAccessesLoaded) {
                      final accesos = s.accessesData['accesos'] as List<dynamic>?;
                      accessesCount = accesos?.length ?? 0;
                    }
                    return MetricCard(
                      label: 'Accesos Hoy',
                      value: '$accessesCount',
                      icon: Icons.today,
                    );
                  },
                ),
              );
            }),
            Builder(builder: (ctx) {
              if (!_requestedMembers) {
                // Preferentemente usar vivienda_id si está disponible
                if (viviendaId != null && viviendaId > 0) {
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
              _QuickCard(icon: Icons.qr_code_2, label: 'Mi QR', onTap: () async {
                await _navigateSeguro(AppRoutes.qrSelf, args: _args, nombres: nombres, apellidos: apellidos, vivienda: viviendaInfo);
              }),
              _QuickCard(icon: Icons.group_add, label: 'QR Visita', onTap: () async {
                await _navigateSeguro(AppRoutes.qrVisit, args: _args, nombres: nombres, apellidos: apellidos, vivienda: viviendaInfo);
              }),
              _QuickCard(icon: Icons.history, label: 'Historial', onTap: () {
                Navigator.pushNamed(context, AppRoutes.accessHistory, arguments: _args);
              }),
              _QuickCard(icon: Icons.family_restroom, label: 'Familia', onTap: () {
                Navigator.pushNamed(context, AppRoutes.members, arguments: _args);
              }),
              _QuickCard(icon: Icons.list_alt, label: 'Mis QRs', onTap: () {
                Navigator.pushNamed(context, AppRoutes.qrList, arguments: _args);
              }),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: separatorColor),
          const SizedBox(height: 12),

          // Actividad reciente
          Text('Actividad Reciente', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          BlocBuilder<ResidentBloc, ResidentState>(
            builder: (c, s) {
              if (s is ResidenceAccessesLoaded) {
                final accesos = s.accessesData['accesos'] as List<dynamic>?;
                if (accesos == null || accesos.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text('No hay accesos registrados hoy', style: theme.textTheme.bodyMedium),
                    ),
                  );
                }
                
                // Show up to 3 most recent accesses
                final recentAccesos = accesos.take(3).toList();
                return Column(
                  children: recentAccesos.map((acceso) {
                    final a = acceso as Map<String, dynamic>;
                    final tipo = a['tipo'] as String? ?? '';
                    final resultado = a['resultado'] as String? ?? '';
                    final fechaCreado = a['fecha_creado'] as String? ?? '';
                    final isExitoso = resultado.toLowerCase() == 'autorizado';
                    
                    String tipoLabel = 'Acceso';
                    if (tipo.contains('qr_residente')) {
                      tipoLabel = 'QR Residente';
                    } else if (tipo.contains('qr_visita')) {
                      tipoLabel = 'QR Visita';
                    } else if (tipo.contains('manual_guardia')) {
                      tipoLabel = 'Autorizado por Guardia';
                    }
                    
                    return ActivityItem(
                      title: tipoLabel,
                      subtitle: 'Entrada Principal · $fechaCreado',
                      time: isExitoso ? 'Exitoso' : 'Rechazado',
                      success: isExitoso,
                    );
                  }).toList(),
                );
              }
              
              // Loading or initial state
              return const SizedBox(
                height: 60,
                child: Center(child: CircularProgressIndicator()),
              );
            },
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

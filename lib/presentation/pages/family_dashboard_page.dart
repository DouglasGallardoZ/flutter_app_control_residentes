import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/blocs/auth/auth_bloc.dart';
import '../../application/blocs/auth/auth_state.dart';
import '../../application/blocs/security_session/security_session_bloc.dart';
import '../../application/blocs/security_session/security_session_state.dart';
import '../../domain/entities/prospecto_residente.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/activity_item.dart';
import '../widgets/insignia_notificaciones.dart';
import '../widgets/metric_card.dart';
import 'facial_verification_page.dart';

/// Extensión helper para determinar el rol del usuario
extension AuthStateExtension on AuthState {
  bool get isFamilyMember {
    if (this is AuthSuccess) {
      final success = this as AuthSuccess;
      final role = success.user['role'] as String?;
      return role?.toLowerCase() == 'family' || role?.toLowerCase() == 'miembro de familia';
    }
    return false;
  }
}

class FamilyDashboardPage extends StatefulWidget {
  final int personaId;
  final String identificacion;
  final String? residenceId;
  const FamilyDashboardPage({super.key, required this.personaId, required this.identificacion, this.residenceId});

  @override
  State<FamilyDashboardPage> createState() => _FamilyDashboardPageState();
}

class _FamilyDashboardPageState extends State<FamilyDashboardPage> {

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
        tipoRegistro: 'miembro_familia',
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final separatorColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;

    // Para familia miembro, usar datos del AuthBloc
    final authState = context.read<AuthBloc>().state;
    String nombres = '';
    String apellidos = '';
    String displayName = 'Usuario';
    int personaId = 0;
    String identificacion = '';
    String residenceId = '';
    
    if (authState is AuthSuccess) {
      nombres = (authState.user['nombres'] ?? '') as String;
      apellidos = (authState.user['apellidos'] ?? '') as String;
      displayName = '$nombres $apellidos'.trim().isNotEmpty ? '$nombres $apellidos' : 'Usuario';
      personaId = authState.user['personaId'] as int? ?? 0;
      identificacion = (authState.user['identificacion'] ?? 
                       authState.user['identification'] ?? 
                       authState.user['dni'] ?? '') as String;
      residenceId = (authState.user['residence'] ?? '') as String;
    }
    
    // Los parámetros del widget son FALLBACK
    if (residenceId.isEmpty && (widget.residenceId?.isNotEmpty ?? false)) residenceId = widget.residenceId ?? '';
    if (identificacion.isEmpty && widget.identificacion.isNotEmpty) identificacion = widget.identificacion;
    if (personaId == 0 && widget.personaId != 0) personaId = widget.personaId;

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

    final displayResidence = residenceId.isNotEmpty ? residenceId : '—';

    return AppScaffold(
      title: 'Acceso Residencial',
      routeName: '/familyDashboard',
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
            case 2:
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.accessHistory, (_) => false, arguments: _args);
              break;
            case 3:
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.profile, (_) => false, arguments: _args);
              break;
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

          // Métricas - Solo Accesos Hoy (sin Miembros para familia)
          SizedBox(
            width: 175,
            child: MetricCard(label: 'Accesos Hoy', value: '0', icon: Icons.today),
          ),
          const SizedBox(height: 16),
          Divider(color: separatorColor),
          const SizedBox(height: 12),

          // Acceso rápido - Sin la opción de Familia
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
              _QuickCard(icon: Icons.list_alt, label: 'Mis QRs', onTap: () {
                Navigator.pushNamed(context, AppRoutes.qrList, arguments: {'personaId': personaId, 'identificacion': identificacion, 'residenceId': residenceId});
              }),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: separatorColor),
          const SizedBox(height: 12),

          // Actividad reciente
          Text('Actividad Reciente', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('No hay accesos registrados hoy', style: theme.textTheme.bodyMedium)
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

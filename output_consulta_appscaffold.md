# Resultados de la solicitud

## 1. Lugares donde se usa `AppScaffold(` en `lib/`

```
lib/presentation/pages/family_dashboard_page.dart:128     return AppScaffold(
lib/presentation/pages/resident_dashboard_page.dart:145   return AppScaffold(
lib/presentation/pages/profile_page.dart:182              return AppScaffold(
lib/presentation/pages/qr_visit_page.dart:240             child: AppScaffold(
lib/presentation/pages/qr_view_page.dart:35               return AppScaffold(
lib/presentation/pages/qr_self_page.dart:216              return AppScaffold(
lib/presentation/pages/qr_list_page.dart:102              return AppScaffold(
lib/presentation/pages/qr_display_page.dart:191           : AppScaffold(
lib/presentation/pages/members_page.dart:57               return AppScaffold(
lib/presentation/pages/access_history_page.dart:58        return AppScaffold(
```

(El match en `app_scaffold.dart:28` es la **definición** del constructor, no un uso)

## 2. `lib/presentation/pages/family_dashboard_page.dart` — COMPLETO

```dart
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
              Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.profile, (_) => false, arguments: _args);
              break;
          }
        });
      },
      body: ListView(
        // ... body content (métricas, acceso rápido, actividad reciente)
      ),
    );
  }
}
```

## 3. Cases específicos de `lib/presentation/routes/app_routes.dart`

### `/familyDashboard` (líneas 470-479)
```dart
      case familyDashboard: {
        final args = settings.arguments as Map<String, dynamic>?;
        final personaId = int.tryParse(args?['personaId']?.toString() ?? '');
        final identificacion = args?['identificacion'] as String?;
        final residenceId = args?['residenceId'] as String?;
        if (personaId != null && identificacion != null && residenceId != null) {
          return _fadeRoute(FamilyDashboardPage(personaId: personaId, identificacion: identificacion, residenceId: residenceId), settings: settings);
        }
        return _fadeRoute(const FamilyDashboardPage(personaId: 0, identificacion: '', residenceId: ''), settings: settings);
      }
```

### `/qrSelf` (líneas 257-264)
```dart
      case qrSelf: {
        final args = settings.arguments as Map<String, dynamic>?;
        final personaId = int.tryParse(args?['personaId']?.toString() ?? '');
        final identificacion = args?['identificacion'] as String?;
        final residenceId = args?['residenceId'] as String?;
        if (personaId == null || identificacion == null) return _errorRoute('Faltan argumentos en QrSelfPage');
        return _fadeRoute(QrSelfPage(personaId: personaId, identificacion: identificacion, residenceId: residenceId), settings: settings);
      }
```

### `/qrVisit` (líneas 266-278)
```dart
      case qrVisit: {
        final args = settings.arguments as Map<String, dynamic>?;
        final personaId = int.tryParse(args?['personaId']?.toString() ?? '');
        final identificacion = args?['identificacion'] as String?;
        final residenceId = args?['residenceId'] as String?;
        if (personaId == null || identificacion == null || residenceId == null) {
          return _errorRoute('Faltan argumentos en QrVisitPage');
        }
        return _fadeRoute(
          QrVisitPage(personaId: personaId, identificacion: identificacion, residenceId: residenceId),
          settings: settings,
        );
      }
```

### `/accessHistory` (líneas 297-306)
```dart
      case accessHistory: {
        final args = settings.arguments as Map<String, dynamic>?;
        final personaId = int.tryParse(args?['personaId']?.toString() ?? '');
        final identificacion = args?['identificacion'] as String?;
        final residenceId = args?['residenceId'] as String?;
        if (personaId != null && identificacion != null) {
          return _fadeRoute(AccessHistoryPage(personaId: personaId, identificacion: identificacion, residenceId: residenceId), settings: settings);
        }
        return _fadeRoute(const AccessHistoryPage(personaId: 0, identificacion: '', residenceId: ''), settings: settings);
      }
```

### `/profile` (líneas 308-316)
```dart
      case profile: {
        final args = settings.arguments as Map<String, dynamic>?;
        final personaId = int.tryParse(args?['personaId']?.toString() ?? '');
        final identificacion = args?['identificacion'] as String?;
        if (personaId != null && identificacion != null) {
          return _fadeRoute(ProfilePage(personaId: personaId, identificacion: identificacion), settings: settings);
        }
        return _fadeRoute(const ProfilePage(personaId: 0, identificacion: ''), settings: settings);
      }
```

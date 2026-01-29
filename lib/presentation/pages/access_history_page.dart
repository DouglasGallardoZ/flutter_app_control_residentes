import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/blocs/resident/resident_bloc.dart';
import '../../application/blocs/resident/resident_event.dart';
import '../../application/blocs/resident/resident_state.dart';
import '../../application/blocs/auth/auth_bloc.dart';
import '../../application/blocs/auth/auth_state.dart';
import '../widgets/app_scaffold.dart';

class AccessHistoryPage extends StatefulWidget {
  final int personaId;
  final String identificacion;
  final String? residenceId;
  const AccessHistoryPage({super.key, required this.personaId, required this.identificacion, this.residenceId});

  @override
  State<AccessHistoryPage> createState() => _AccessHistoryPageState();
}

class _AccessHistoryPageState extends State<AccessHistoryPage> {
  String statusFilter = 'Todos';
  String typeFilter = 'Todos';
  bool _loadedAccesses = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Try to recover route arguments for navigation between tabs
    final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final maybeResidenceId = routeArgs?['residenceId'] as String? ?? widget.residenceId;
    final maybeUserName = routeArgs?['userName'] as String?;
    final maybePersonaId = routeArgs?['personaId'] as int? ?? widget.personaId;
    final maybeIdentificacion = routeArgs?['identificacion'] as String? ?? widget.identificacion;
    
    // Obtener datos del AuthBloc
    final authState = context.read<AuthBloc>().state;
    bool isFamilyMember = false;
    int? authViviendaId;
    
    if (authState is AuthSuccess) {
      final role = authState.user['rol'] as String?;
      isFamilyMember = role?.toLowerCase() == 'miembro_familia' || role?.toLowerCase() == 'family' || role?.toLowerCase() == 'miembro de familia';
      authViviendaId = authState.user['residence_id'] as int?;
    }

    // Load accesses on first build
    if (!_loadedAccesses && authViviendaId != null && authViviendaId > 0) {
      context.read<ResidentBloc>().add(LoadResidenceAccessesEvent(
        viviendaId: authViviendaId,
      ));
      _loadedAccesses = true;
    }

    return AppScaffold(
      title: 'Historial de Accesos',
      routeName: '/accessHistory',
      onTabSelected: (i) {
        if (i == 2) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          switch (i) {
            case 0:
              final pid = maybePersonaId;
              final rid = maybeResidenceId;
              final idn = maybeIdentificacion;
              if (rid != null && idn.isNotEmpty) {
                final route = isFamilyMember ? '/familyDashboard' : '/residentDashboard';
                Navigator.of(context).pushNamedAndRemoveUntil(route, (route) => false, arguments: {'personaId': pid, 'identificacion': idn, 'residenceId': rid, 'userName': maybeUserName});
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faltan datos para ir a Inicio')));
              }
              break;
            case 1:
              final pid2 = maybePersonaId;
              final idn2 = maybeIdentificacion;
              if (idn2.isNotEmpty) {
                Navigator.of(context).pushNamedAndRemoveUntil('/qrSelf', (route) => false, arguments: {'personaId': pid2, 'identificacion': idn2, 'userName': maybeUserName});
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faltan datos para ir a Mi QR')));
              }
              break;
            case 3:
              if (!isFamilyMember) {
                final pid3 = maybePersonaId;
                final rid3 = maybeResidenceId;
                final idn3 = maybeIdentificacion;
                if (rid3 != null && idn3.isNotEmpty) {
                  Navigator.of(context).pushNamedAndRemoveUntil('/members', (route) => false, arguments: {'personaId': pid3, 'identificacion': idn3, 'residenceId': rid3});
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faltan datos para ir a Familia')));
                }
              } else {
                // Para miembros familiares, case 3 es Profile
                final pid3 = maybePersonaId;
                final idn3 = maybeIdentificacion;
                if (idn3.isNotEmpty) {
                  Navigator.of(context).pushNamedAndRemoveUntil('/profile', (route) => false, arguments: {'personaId': pid3, 'identificacion': idn3});
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faltan datos para ir a Perfil')));
                }
              }
              break;
            case 4:
              if (!isFamilyMember) {
                final pid4 = maybePersonaId;
                final idn4 = maybeIdentificacion;
                if (idn4.isNotEmpty) {
                  Navigator.of(context).pushNamedAndRemoveUntil('/profile', (route) => false, arguments: {'personaId': pid4, 'identificacion': idn4});
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faltan datos para ir a Perfil')));
                }
              }
              break;
          }
        });
      },
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(spacing: 8, runSpacing: 8, children: [
              FilterChip(
                label: const Text('Todos'),
                selected: statusFilter == 'Todos',
                onSelected: (_) => setState(() => statusFilter = 'Todos'),
              ),
              FilterChip(
                label: const Text('Exitosos'),
                selected: statusFilter == 'Exitosos',
                onSelected: (_) => setState(() => statusFilter = 'Exitosos'),
              ),
              FilterChip(
                label: const Text('Rechazados'),
                selected: statusFilter == 'Rechazados',
                onSelected: (_) => setState(() => statusFilter = 'Rechazados'),
              ),
              const SizedBox(width: 12),
              FilterChip(
                label: const Text('QR Residente'),
                selected: typeFilter == 'QR Residente',
                onSelected: (_) => setState(() => typeFilter = 'QR Residente'),
              ),
              FilterChip(
                label: const Text('QR Visita'),
                selected: typeFilter == 'QR Visita',
                onSelected: (_) => setState(() => typeFilter = 'QR Visita'),
              ),
            ]),
          ),
          Expanded(
            child: BlocBuilder<ResidentBloc, ResidentState>(
              builder: (ctx, state) {
                if (state is ResidentLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ResidenceAccessesLoaded) {
                  final accesos = state.accessesData['accesos'] as List<dynamic>? ?? [];
                  
                  // Filter accesos based on filters
                  final filteredAccesos = accesos.where((acceso) {
                    final a = acceso as Map<String, dynamic>;
                    final resultado = a['resultado'] as String? ?? '';
                    final tipo = a['tipo'] as String? ?? '';
                    
                    final statusOk = statusFilter == 'Todos' || 
                                   (resultado.toLowerCase() == 'autorizado' && statusFilter == 'Exitosos') ||
                                   (resultado.toLowerCase() != 'autorizado' && statusFilter == 'Rechazados');
                    
                    final typeOk = typeFilter == 'Todos' ||
                                  (tipo.contains('qr_residente') && typeFilter == 'QR Residente') ||
                                  (tipo.contains('qr_visita') && typeFilter == 'QR Visita');
                    
                    return statusOk && typeOk;
                  }).toList();

                  if (accesos.isEmpty) {
                    return Center(
                      child: Text('No hay registros de acceso', style: Theme.of(context).textTheme.bodyMedium),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredAccesos.length,
                    itemBuilder: (ctx, i) {
                      final a = filteredAccesos[i] as Map<String, dynamic>;
                      final tipo = a['tipo'] as String? ?? '';
                      final resultado = a['resultado'] as String? ?? '';
                      final fechaCreado = a['fecha_creado'] as String? ?? '';
                      final visitaNombres = a['visita_nombres'] as String?;
                      final isExitoso = resultado.toLowerCase() == 'autorizado';
                      
                      String tipoLabel = 'Acceso';
                      if (tipo.contains('qr_residente')) {
                        tipoLabel = 'QR Residente';
                      } else if (tipo.contains('qr_visita')) {
                        tipoLabel = 'QR Visita';
                      } else if (tipo.contains('manual_guardia')) {
                        tipoLabel = 'Autorizado por Guardia';
                      }
                      
                      final title = visitaNombres != null ? 'Visitante: $visitaNombres' : tipoLabel;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(title),
                          subtitle: Text(fechaCreado),
                          trailing: Icon(
                            isExitoso ? Icons.check_circle : Icons.cancel,
                            color: isExitoso ? const Color(0xFF10B981) : Theme.of(context).colorScheme.error,
                          ),
                        ),
                      );
                    },
                  );
                } else if (state is ResidentError) {
                  return Center(child: Text('Error: ${state.message}'));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}


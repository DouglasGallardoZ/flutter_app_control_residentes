import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/app_scaffold.dart';
import '../../application/blocs/account/account_bloc.dart';
import '../../application/blocs/account/account_event.dart';
import '../../application/blocs/account/account_state.dart';
import '../../application/blocs/auth/auth_bloc.dart';
import '../../application/blocs/auth/auth_state.dart';
import '../../domain/entities/account.dart';
import '../../application/blocs/member/member_bloc.dart';
import '../../application/blocs/member/member_event.dart';
import '../../application/blocs/member/member_state.dart';
import '../../injection.dart';

class MembersPage extends StatefulWidget {
  final int personaId;
  final String identificacion;
  final String? residenceId;
  const MembersPage({super.key, required this.personaId, required this.identificacion, this.residenceId});

  @override
  State<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> {
  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _mostrarDialogoBloqueo(BuildContext context, Account miembro) async {
    final motivoCtrl = TextEditingController();
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Bloquear a ${miembro.nombres} ${miembro.apellidos}'.trim()),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('¿Está seguro de bloquear a este miembro?'),
              const SizedBox(height: 12),
              TextField(
                controller: motivoCtrl,
                decoration: const InputDecoration(labelText: 'Motivo', border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Bloquear'),
          ),
        ],
      ),
    );
    if (confirmado == true && motivoCtrl.text.isNotEmpty && context.mounted) {
      context.read<MemberBloc>().add(BloquearMiembroEvent(memberId: miembro.personaId, reason: motivoCtrl.text.trim()));
    }
  }

  Future<void> _mostrarDialogoDesbloqueo(BuildContext context, Account miembro) async {
    final motivoCtrl = TextEditingController();
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Desbloquear a ${miembro.nombres} ${miembro.apellidos}'.trim()),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('¿Está seguro de desbloquear a este miembro?'),
              const SizedBox(height: 12),
              TextField(
                controller: motivoCtrl,
                decoration: const InputDecoration(labelText: 'Motivo', border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Desbloquear'),
          ),
        ],
      ),
    );
    if (confirmado == true && motivoCtrl.text.isNotEmpty && context.mounted) {
      context.read<MemberBloc>().add(DesbloquearMiembroEvent(memberId: miembro.personaId, reason: motivoCtrl.text.trim()));
    }
  }

  bool _requested = false;

  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String,dynamic>?;
    final maybePersonaId = routeArgs?['personaId'] as int? ?? widget.personaId;
    final maybeIdentificacion = routeArgs?['identificacion'] as String? ?? widget.identificacion;
    final maybeResidenceId = routeArgs?['residenceId'] as String? ?? widget.residenceId;
    final authState = context.read<AuthBloc>().state;
    
    // Obtener datos desde AuthBloc (determina si es miembro familiar)
    bool isFamilyMember = false;
    String? authUserId;
    String? authResidence;
    String? authName;
    int? authViviendaId;
    if (authState is AuthSuccess) {
      final role = authState.user['rol'] as String?;
      isFamilyMember = role?.toLowerCase() == 'miembro_familia' || role?.toLowerCase() == 'family' || role?.toLowerCase() == 'miembro de familia';
      authUserId = (authState.user['personaId']?.toString() ?? authState.user['uid'])?.toString();
      authResidence = authState.user['residence'] as String?;
      authName = authState.user['name'] as String?;
      
      // Extraer vivienda_id desde vivienda object
      final vivienda = authState.user['vivienda'] as Map<String, dynamic>?;
      if (vivienda != null) {
        authViviendaId = vivienda['viviendaId'] as int? ?? (vivienda['vivienda_id'] as int?);
      }
    }

    return AppScaffold(
      title: 'Miembros de familia',
      routeName: '/members',
      onTabSelected: (i) {
        if (i == 3) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final pid = maybePersonaId > 0 ? maybePersonaId : (authUserId != null ? int.tryParse(authUserId!) ?? 0 : 0);
          final idn = maybeIdentificacion.isNotEmpty ? maybeIdentificacion : (authState is AuthSuccess ? authState.user['identificacion'] as String? : null) ?? '';
          final rid = maybeResidenceId ?? authResidence ?? '';
          final uname = authName ?? '';
          
          if (pid <= 0 || idn.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faltan datos de usuario')));
            return;
          }
          
          switch (i) {
            case 0:
              final route = isFamilyMember ? '/familyDashboard' : '/residentDashboard';
              Navigator.of(context).pushNamedAndRemoveUntil(route, (route) => false, arguments: {'personaId': pid, 'identificacion': idn, 'residenceId': rid, 'userName': uname});
              break;
            case 1:
              Navigator.of(context).pushNamedAndRemoveUntil('/qrSelf', (route) => false, arguments: {'personaId': pid, 'identificacion': idn, 'residenceId': rid});
              break;
            case 2:
              Navigator.of(context).pushNamedAndRemoveUntil('/accessHistory', (route) => false, arguments: {'personaId': pid, 'identificacion': idn, 'residenceId': rid});
              break;
            case 4:
              Navigator.of(context).pushNamedAndRemoveUntil('/profile', (route) => false, arguments: {'personaId': pid, 'identificacion': idn});
              break;
          }
        });
      },
        body: BlocProvider<MemberBloc>(
          create: (_) => sl<MemberBloc>(),
          child: BlocListener<MemberBloc, MemberState>(
            listener: (context, state) {
              if (state is MemberDeactivated) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.orange));
                setState(() => _requested = false);
              } else if (state is MemberReactivated) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.green));
                setState(() => _requested = false);
              }
            },
            child: Padding(
          padding: const EdgeInsets.all(16),
          child: Builder(builder: (ctx) {
            // Resolver vivienda_id desde route args o auth state
            final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String,dynamic>?;
            final maybePersonaId = routeArgs?['personaId'] as int? ?? widget.personaId;
            final maybeResidenceId = routeArgs?['residenceId'] as String? ?? widget.residenceId;
            final authState = context.read<AuthBloc>().state;
            
            String? authResidence;
            int? authViviendaId;
            if (authState is AuthSuccess) {
              authResidence = authState.user['residence'] as String?;
              
              // Extraer vivienda_id desde vivienda object
              final vivienda = authState.user['vivienda'] as Map<String, dynamic>?;
              if (vivienda != null) {
                authViviendaId = vivienda['viviendaId'] as int? ?? (vivienda['vivienda_id'] as int?);
              }
            }

            // Preferir vivienda_id (int) si está disponible, sino usar residenceId (String)
            final viviendaId = authViviendaId ?? (maybeResidenceId != null ? int.tryParse(maybeResidenceId) : null);
            final residenceId = maybeResidenceId ?? authResidence;
            
            if (viviendaId == null && residenceId == null) {
              return Center(child: Text('No se pudo determinar la residencia', style: Theme.of(context).textTheme.bodyLarge));
            }

            if (!_requested) {
              // Solicitar miembros usando vivienda_id si está disponible
              if (viviendaId != null) {
                context.read<AccountBloc>().add(LoadFamilyMembersRequested(viviendaId));
              } else if (residenceId != null) {
                context.read<AccountBloc>().add(LoadFamilyMembersRequested(residenceId));
              }
              _requested = true;
            }

            return BlocBuilder<AccountBloc, AccountState>(builder: (ctxb, state) {
              if (state is AccountLoading) return const Center(child: CircularProgressIndicator());
              if (state is AccountError) return Center(child: Text(state.message));
              List members = [];
              if (state is AccountMembersLoaded) members = state.members;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Miembros Registrados', style: Theme.of(context).textTheme.titleMedium),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Theme.of(context).colorScheme.primary.withOpacity(0.1)),
                        child: Text('${members.length}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (members.isEmpty)
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_outline, size: 64, color: Theme.of(context).hintColor),
                          const SizedBox(height: 8),
                          Text('No hay miembros registrados', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).hintColor)),
                        ],
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: members.length,
                        itemBuilder: (context, i) {
                          final m = members[i] as Account;
                          final name = '${m.nombres} ${m.apellidos}'.trim();
                          final identification = m.identificacion;
                          final email = m.correo;
                          final relationship = m.parentesco;
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  CircleAvatar(radius: 28, child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?')),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(name, style: Theme.of(context).textTheme.titleMedium),
                                        const SizedBox(height: 6),
                                        Row(children: [Icon(Icons.badge_outlined, size: 16, color: Theme.of(context).hintColor), const SizedBox(width: 6), Text(identification, style: Theme.of(context).textTheme.bodyMedium)]),
                                          if (relationship != null && relationship.isNotEmpty) const SizedBox(height: 6),
                                          if (relationship != null && relationship.isNotEmpty) Row(children: [Icon(Icons.family_restroom, size: 16, color: Theme.of(context).hintColor), const SizedBox(width: 6), Text(relationship.toUpperCase(), style: Theme.of(context).textTheme.bodyMedium)]),
                                          const SizedBox(height: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: m.estado == 'activo' ? Colors.green.shade50 : Colors.red.shade50,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: m.estado == 'activo' ? Colors.green : Colors.red),
                                            ),
                                            child: Text(
                                              m.estado == 'activo' ? 'Activo' : 'Inactivo',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: m.estado == 'activo' ? Colors.green : Colors.red,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          if (email != null && email.isNotEmpty) const SizedBox(height: 6),
                                          if (email != null && email.isNotEmpty) Row(children: [Icon(Icons.email_outlined, size: 16, color: Theme.of(context).hintColor), const SizedBox(width: 6), Expanded(child: Text(email, style: Theme.of(context).textTheme.bodyMedium, overflow: TextOverflow.ellipsis))]),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    onSelected: (opcion) {
                                      if (opcion == 'bloquear') _mostrarDialogoBloqueo(context, m);
                                      if (opcion == 'desbloquear') _mostrarDialogoDesbloqueo(context, m);
                                    },
                                    itemBuilder: (_) => [
                                      if (m.estado == 'activo')
                                        const PopupMenuItem(
                                          value: 'bloquear',
                                          child: Row(children: [
                                            Icon(Icons.block, color: Colors.orange, size: 20),
                                            SizedBox(width: 8),
                                            Text('Bloquear'),
                                          ]),
                                        ),
                                      if (m.estado == 'inactivo')
                                        const PopupMenuItem(
                                          value: 'desbloquear',
                                          child: Row(children: [
                                            Icon(Icons.check_circle, color: Colors.green, size: 20),
                                            SizedBox(width: 8),
                                            Text('Desbloquear'),
                                          ]),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Theme.of(context).dividerColor)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Sobre los miembros de familia', style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 6),
                      Text('Los miembros de familia podrán generar sus propios códigos QR y ver el historial de accesos asociados a esta residencia.', style: Theme.of(context).textTheme.bodyMedium),
                    ]),
                  ),
                ],
              );
            });
          }),
        ),
      ),
    ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/app_scaffold.dart';
import '../../application/blocs/account/account_bloc.dart';
import '../../application/blocs/account/account_event.dart';
import '../../application/blocs/account/account_state.dart';
import '../../application/blocs/auth/auth_bloc.dart';
import '../../application/blocs/auth/auth_state.dart';

class MembersPage extends StatefulWidget {
  const MembersPage({super.key});

  @override
  State<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> {
  @override
  void dispose() {
    super.dispose();
  }

  bool _requested = false;

  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String,dynamic>?;
    final maybeUserId = routeArgs?['userId'] as String?;
    final authState = context.read<AuthBloc>().state;
    String? authUserId;
    String? authResidence;
    String? authName;
    if (authState is AuthSuccess) {
      authUserId = (authState.user['id'] ?? authState.user['uid']) as String?;
      authResidence = authState.user['residence'] as String?;
      authName = authState.user['name'] as String?;
    }

    return AppScaffold(
      title: 'Miembros de familia',
      currentIndex: 3,
      onTabSelected: (i) {
        switch (i) {
          case 0:
            final uid = maybeUserId ?? authUserId;
            final rid = authResidence;
            final uname = authName;
            if (uid != null && rid != null && uname != null) {
              Navigator.pushReplacementNamed(context, '/residentDashboard', arguments: {'userId': uid, 'residenceId': rid, 'userName': uname});
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faltan datos')));
            }
            break;
          case 1:
            final uid1 = maybeUserId ?? authUserId;
            final uname1 = authName;
            if (uid1 != null && uname1 != null) Navigator.pushReplacementNamed(context, '/qrSelf', arguments: {'userId': uid1, 'userName': uname1}); else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faltan datos')));
            break;
          case 2:
            final uid2 = maybeUserId ?? authUserId;
            if (uid2 != null) Navigator.pushReplacementNamed(context, '/accessHistory', arguments: {'userId': uid2}); else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faltan datos')));
            break;
          case 3: break;
          case 4:
            final uid4 = maybeUserId ?? authUserId;
            if (uid4 != null) Navigator.pushReplacementNamed(context, '/profile', arguments: {'userId': uid4}); else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faltan datos')));
            break;
        }
      },
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Builder(builder: (ctx) {
          // Resolve residenceId from route args or auth state
          final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String,dynamic>?;
          final maybeUserId = routeArgs?['userId'] as String?;
          final maybeResidenceId = routeArgs?['residenceId'] as String?;
          final authState = context.read<AuthBloc>().state;
          String? authResidence;
          if (authState is AuthSuccess) {
            authResidence = authState.user['residence'] as String?;
          }

          final residenceId = maybeResidenceId ?? authResidence;
          if (residenceId == null) {
            return Center(child: Text('No se pudo determinar la residencia', style: Theme.of(context).textTheme.bodyLarge));
          }

          if (!_requested) {
            // Request members once
            context.read<AccountBloc>().add(LoadFamilyMembersRequested(residenceId));
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
                        final m = members[i];
                        final name = (m.name ?? m['name']) as String? ?? '';
                        final identification = (m.id ?? m['id']) as String? ?? '';
                        final email = (m.email ?? m['email']) as String?;
                        final relationship = (m.relationship ?? m['relationship']) as String?;
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
                                        if (relationship != null) const SizedBox(height: 6),
                                        if (relationship != null) Row(children: [Icon(Icons.family_restroom, size: 16, color: Theme.of(context).hintColor), const SizedBox(width: 6), Text(relationship, style: Theme.of(context).textTheme.bodyMedium)]),
                                        if (email != null) const SizedBox(height: 6),
                                        if (email != null) Row(children: [Icon(Icons.email_outlined, size: 16, color: Theme.of(context).hintColor), const SizedBox(width: 6), Text(email, style: Theme.of(context).textTheme.bodyMedium)]),
                                    ],
                                  ),
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
    );
  }
}

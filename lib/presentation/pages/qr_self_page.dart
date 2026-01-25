// removed unused: dart:io, dart:ui
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// removed unused import: qr_flutter
// removed unused: share_plus

import '../../application/blocs/qr/qr_bloc.dart';
import '../../application/blocs/qr/qr_event.dart';
import '../../application/blocs/qr/qr_state.dart';
import '../widgets/app_scaffold.dart';
import '../routes/app_routes.dart';
import 'qr_display_page.dart';
import '../../application/blocs/auth/auth_bloc.dart';
import '../../application/blocs/auth/auth_state.dart';
import '../widgets/navigation_helpers.dart';

class QrSelfPage extends StatefulWidget {
  final int personaId;
  final String identificacion;
  final String? residenceId;
  const QrSelfPage({super.key, required this.personaId, required this.identificacion, this.residenceId});

  @override
  State<QrSelfPage> createState() => _QrSelfPageState();
}

class _QrSelfPageState extends State<QrSelfPage> {
  final GlobalKey qrBoundaryKey = GlobalKey();

  DateTime? startDate;
  TimeOfDay? startTime;
  int? durationHours; // 1,3,6,12
  bool qrGenerated = false;

  DateTime? get validFrom {
    if (startDate == null || startTime == null) return null;
    return DateTime(
      startDate!.year, startDate!.month, startDate!.day,
      startTime!.hour, startTime!.minute,
    );
  }

  DateTime? get validUntil {
    if (validFrom == null || durationHours == null) return null;
    return validFrom!.add(Duration(hours: durationHours!));
  }

  String _fmtShortES(DateTime dt, {bool includeWeek = true}) {
    const wd = ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];
    const months = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
    final w = wd[(dt.weekday % 7)];
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return includeWeek ? '$w, ${dt.day} ${months[dt.month - 1]}, $hh:$mm' : '${dt.day} ${months[dt.month - 1]}, $hh:$mm';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final res = await showDatePicker(
      context: context,
      initialDate: startDate ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (res != null) setState(() => startDate = res);
  }

  Future<void> _pickTime() async {
    final res = await showTimePicker(context: context, initialTime: startTime ?? TimeOfDay.now());
    if (res != null) setState(() => startTime = res);
  }

  // helper removed (snackbars are shown inline where needed)

  void _error(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _confirmAndGenerate(int personaId) async {
    if (startDate == null) return _error('La fecha de inicio es obligatoria');
    if (startTime == null) return _error('La hora de inicio es obligatoria');
    if (durationHours == null || durationHours! <= 0) return _error('La duración debe ser mayor a 0 horas');
    if (validFrom!.isBefore(DateTime.now())) return _error('La fecha y hora de inicio no puede ser en el pasado');

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Confirmar Generación de QR', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              IconButton(onPressed: () => Navigator.pop(context, false), icon: const Icon(Icons.close)),
            ]),
            const SizedBox(height: 12),
            Center(child: Icon(Icons.qr_code_2, size: 64, color: Theme.of(context).colorScheme.primary)),
            const SizedBox(height: 12),
            const Text('¿Confirmas la generación del código QR con los siguientes datos?'),
            const SizedBox(height: 12),
            Builder(builder: (builderCtx) {
              final authState = builderCtx.read<AuthBloc>().state;
              final authUserName = (authState is AuthSuccess) ? (authState.user['name'] as String? ?? 'Usuario') : 'Usuario';
              return _DetailRow(label: 'Para:', value: authUserName);
            }),
            _DetailRow(label: 'Inicio:', value: _fmtShortES(validFrom!, includeWeek: true)),
            _DetailRow(label: 'Fin:', value: _fmtShortES(validUntil!, includeWeek: true)),
            _DetailRow(label: 'Duración:', value: '${durationHours} horas'),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              OutlinedButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context, true),
                icon: const Icon(Icons.check_circle),
                label: const Text('Confirmar y Generar'),
              ),
            ]),
          ]),
        ),
      ),
    );

    if (ok == true) {
      context.read<QrBloc>().add(GenerateSelfQrConfigured(personaId, validFrom!, durationHours!));
      setState(() => qrGenerated = true);
      // _toastSuccess('Generando código QR...');
    }
  }

  // Share / download helpers removed (unused). Keep `qrBoundaryKey` for future use.

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final separatorColor = theme.brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade300;

    final authState = context.read<AuthBloc>().state;
    
    // Obtener rol desde AuthBloc (determina si es miembro familiar)
    bool isFamilyMember = false;
    // Extraer datos del AuthBloc - SIEMPRE deben estar disponibles después del login
    int personaId = 0;
    String identificacion = '';
    String residenceId = '';
    
    if (authState is AuthSuccess) {
      // SIEMPRE usar datos del AuthBloc (son la fuente de verdad)
      final role = authState.user['rol'] as String?;
      isFamilyMember = role?.toLowerCase() == 'miembro_familia' || role?.toLowerCase() == 'family' || role?.toLowerCase() == 'miembro de familia';
      personaId = authState.user['personaId'] as int? ?? 0;
      identificacion = (authState.user['identificacion'] ?? 
                       authState.user['identification'] ?? 
                       authState.user['dni'] ?? '') as String;
      residenceId = (authState.user['residence'] ?? '') as String;
    }
    
    // Los parámetros del widget son FALLBACK
    if (residenceId.isEmpty && (widget.residenceId?.isNotEmpty ?? false)) residenceId = widget.residenceId!;
    if (identificacion.isEmpty && widget.identificacion.isNotEmpty) identificacion = widget.identificacion;
    if (personaId == 0 && widget.personaId != 0) personaId = widget.personaId;

    return AppScaffold(
      title: 'Mi Código QR',
      routeName: '/qrSelf',
      isRoot: true,
      onTabSelected: (i) {
        if (i == 1) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          switch (i) {
            case 0:
              final route = isFamilyMember ? AppRoutes.familyDashboard : AppRoutes.residentDashboard;
              Navigator.of(context).pushNamedAndRemoveUntil(route, (route) => false, arguments: {'personaId': personaId, 'identificacion': identificacion, 'residenceId': residenceId ?? ''});
              break;
            case 2:
              Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.accessHistory, (route) => false, arguments: {'personaId': personaId, 'identificacion': identificacion});
              break;
            case 3:
              Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.members, (route) => false, arguments: {'personaId': personaId, 'identificacion': identificacion});
              break;
            case 4:
              Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.profile, (route) => false, arguments: {'personaId': personaId, 'identificacion': identificacion});
              break;
          }
        });
      },
      body: BlocConsumer<QrBloc, QrState>(
        listener: (ctx, state) {
          if (state is QrReady && qrGenerated) {
            ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Código QR generado exitosamente'), behavior: SnackBarBehavior.floating));
            
            // Obtener datos del usuario del AuthBloc
            final authData = getUserDataFromAuth(ctx);
            
            // Guardar contexto de navegación en QrBloc para self QR
            ctx.read<QrBloc>().add(SaveQrNavigationContext(
              personaId: personaId,
              identificacion: identificacion,
              residenceId: residenceId ?? '',
              userName: authData.userName,
              qrValue: state.qr.value,
              validFrom: validFrom!,
              validUntil: validUntil!,
              durationHours: durationHours!,
            ));
            
            Navigator.of(ctx).push(
              MaterialPageRoute(
                builder: (_) => QrDisplayPage(
                  userName: authData.userName,
                  personaId: personaId,
                  identificacion: identificacion,
                  validFrom: validFrom!,
                  validUntil: validUntil!,
                  durationHours: durationHours!,
                  qrValue: state.qr.value,
                ),
              ),
            );
            setState(() => qrGenerated = false);
          }
        },
        builder: (ctx, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header similar to web TSX: back button, centered title, placeholder at right
              // Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              //   IconButton(onPressed: () => navigateToHome(context, routeUserId: widget.userId, routeUserName: widget.userName, routeResidenceId: null), icon: const Icon(Icons.arrow_back)),
              //   Expanded(child: Center(child: Text('Mi Código QR', style: theme.textTheme.titleLarge))),
              //   const SizedBox(width: 48),
              // ]),
              const SizedBox(height: 12),
              Center(child: Icon(Icons.qr_code_2, size: 64, color: theme.colorScheme.primary)),
              const SizedBox(height: 8),
              Text('Tu Código de Acceso Personal', style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text('Configura el periodo de validez para tu código QR de acceso.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
              const SizedBox(height: 16),

              // Datos del usuario
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Icon(Icons.person_outline, color: Colors.grey),
                      const SizedBox(width: 8),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Nombre', style: TextStyle(fontWeight: FontWeight.w600)),
                        Builder(builder: (builderCtx) {
                          final authState = builderCtx.read<AuthBloc>().state;
                          final authUserName = (authState is AuthSuccess) ? (authState.user['name'] as String? ?? 'Usuario') : 'Usuario';
                          return Text(authUserName);
                        }),
                      ]),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      const Icon(Icons.badge_outlined, color: Colors.grey),
                      const SizedBox(width: 8),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Identificación', style: TextStyle(fontWeight: FontWeight.w600)),
                        Text(widget.identificacion),
                      ]),
                    ]),
                  ]),
                ),
              ),

              const SizedBox(height: 12),

              // Formulario de configuración
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    Align(alignment: Alignment.centerLeft, child: Text('Fecha de Inicio', style: theme.textTheme.labelLarge)),
                    const SizedBox(height: 6),
                    TextField(
                      readOnly: true,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.calendar_today),
                        hintText: 'mm / dd / yyyy',
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(
                        text: startDate == null ? '' : '${startDate!.month}/${startDate!.day}/${startDate!.year}',
                      ),
                      onTap: _pickDate,
                    ),
                    const SizedBox(height: 12),

                    Align(alignment: Alignment.centerLeft, child: Text('Hora de Inicio', style: theme.textTheme.labelLarge)),
                    const SizedBox(height: 6),
                    TextField(
                      readOnly: true,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.schedule),
                        hintText: '-- : -- --',
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(text: startTime == null ? '' : startTime!.format(context)),
                      onTap: _pickTime,
                    ),
                    const SizedBox(height: 12),

                    Align(alignment: Alignment.centerLeft, child: Text('Duración (horas)', style: theme.textTheme.labelLarge)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<int>(
                      value: durationHours,
                      decoration: const InputDecoration(prefixIcon: Icon(Icons.access_time), border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('Seleccione duración')), // placeholder
                        DropdownMenuItem(value: 1, child: Text('1 hora')),
                        DropdownMenuItem(value: 3, child: Text('3 horas')),
                        DropdownMenuItem(value: 6, child: Text('6 horas')),
                        DropdownMenuItem(value: 12, child: Text('12 horas')),
                      ],
                      onChanged: (v) => setState(() => durationHours = (v == 0) ? null : v),
                    ),
                    const SizedBox(height: 12),

                    if (validFrom != null && validUntil != null)
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Periodo de Validez', style: theme.textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Row(children: [
                            const Text('Inicio: ', style: TextStyle(fontWeight: FontWeight.w600)),
                            Text(_fmtShortES(validFrom!, includeWeek: true)),
                          ]),
                          const SizedBox(height: 4),
                          Row(children: [
                            const Text('Fin: ', style: TextStyle(fontWeight: FontWeight.w600)),
                            Text(_fmtShortES(validUntil!, includeWeek: true)),
                          ]),
                        ]),
                      ),

                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _confirmAndGenerate(personaId),
                        icon: const Icon(Icons.qr_code),
                        label: const Text('Generar Mi QR'),
                      ),
                    ),
                  ]),
                ),
              ),

              const SizedBox(height: 16),
              Divider(color: separatorColor),

              // Pantalla final con QR y acciones (omitted for brevity)
            ],
          );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        SizedBox(width: 140, child: Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600))),
        Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
      ]),
    );
  }
}

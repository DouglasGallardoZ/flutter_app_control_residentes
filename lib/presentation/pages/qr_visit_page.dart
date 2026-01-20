import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/blocs/visitor/visitor_bloc.dart';
import '../../application/blocs/visitor/visitor_event.dart';
import '../../application/blocs/visitor/visitor_state.dart';
import '../../application/blocs/qr_visit/qr_visit_bloc.dart';
import '../../application/blocs/qr_visit/qr_visit_event.dart';
import '../../application/blocs/qr_visit/qr_visit_state.dart';
import '../../application/blocs/qr/qr_bloc.dart';
import '../../application/blocs/qr/qr_event.dart';
import '../widgets/app_scaffold.dart';
import '../routes/app_routes.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../application/blocs/auth/auth_bloc.dart';
import '../../application/blocs/auth/auth_state.dart';
import 'qr_display_page.dart';
import '../widgets/navigation_helpers.dart';
import '../../injection.dart';
import '../../domain/usecases/manage_visitor_usecase.dart';
import '../../infrastructure/providers/visitor_api.dart';
import '../../infrastructure/adapters/visitor_repository_impl.dart';

class QrVisitPage extends StatefulWidget {
  final int personaId;
  final String identificacion;
  final String residenceId;
  const QrVisitPage({super.key, required this.personaId, required this.identificacion, required this.residenceId});

  @override
  State<QrVisitPage> createState() => _QrVisitPageState();
}

class _QrVisitPageState extends State<QrVisitPage> {
  final GlobalKey qrBoundaryKey = GlobalKey();  late ScrollController _scrollController;
  String mode = 'saved'; // saved | new
  final searchCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final idCtrl = TextEditingController();

  DateTime? startDate;
  TimeOfDay? startTime;
  int? durationHours;

  bool qrGenerated = false;
  String? successBadge; // “Visitante registrado exitosamente” cuando es new

  DateTime? get validFrom {
    if (startDate == null || startTime == null) return null;
    return DateTime(startDate!.year, startDate!.month, startDate!.day, startTime!.hour, startTime!.minute);
  }

  DateTime? get validUntil {
    if (validFrom == null || durationHours == null) return null;
    return validFrom!.add(Duration(hours: durationHours!));
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    nameCtrl.dispose();
    idCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _clearSelection() {
    setState(() {
      mode = 'saved';
      nameCtrl.clear();
      idCtrl.clear();
      searchCtrl.clear();
      startDate = null;
      startTime = null;
      durationHours = null;
    });
  }

  String _fmtShortES(DateTime dt, {bool includeWeek = true}) {
    const wd = ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];
    const months = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
    final w = wd[(dt.weekday % 7)];
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return includeWeek ? '$w, ${dt.day} ${months[dt.month - 1]}, $hh:$mm' : '${dt.day} ${months[dt.month - 1]}, $hh:$mm';
  }

  void _error(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
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

  Future<void> _confirmDialog(BuildContext builderCtx) async {
    if ((mode == 'new' && (nameCtrl.text.trim().isEmpty || idCtrl.text.trim().isEmpty))) {
      return _error('Complete nombre e identificación');
    }
    if (startDate == null) return _error('La fecha de inicio es obligatoria');
    if (startTime == null) return _error('La hora de inicio es obligatoria');
    if (durationHours == null || durationHours! <= 0) return _error('La duración debe ser mayor a 0 horas');
    if (validFrom!.isBefore(DateTime.now())) return _error('La fecha y hora de inicio no puede ser en el pasado');

    final visitorName = nameCtrl.text.trim();
    final visitorId = idCtrl.text.trim();

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
            if (mode == 'new') ...[
              const SizedBox(height: 10),
              Row(children: const [
                Icon(Icons.check_circle, color: Color(0xFF10B981), size: 20),
                SizedBox(width: 6),
                Text('El visitante será registrado automáticamente en el sistema', style: TextStyle(color: Colors.blue, fontSize: 12)),
              ]),
            ],
            const SizedBox(height: 12),
            _DetailRow(label: 'Para:', value: visitorName),
            _DetailRow(label: 'Identificación:', value: visitorId),
            _DetailRow(label: 'Inicio:', value: _fmtShortES(validFrom!, includeWeek: true)),
            _DetailRow(label: 'Fin:', value: _fmtShortES(validUntil!, includeWeek: true)),
            _DetailRow(label: 'Duración:', value: '${durationHours} horas'),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Flexible(
                child: OutlinedButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context, true),
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Confirmar y Generar'),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );

    if (ok == true) {
      // Solo generar QR - El API registrará automáticamente al visitante
      builderCtx.read<QrVisitBloc>().add(GenerateVisitQrRequested(widget.personaId, visitorId, visitorName, validFrom!, durationHours!));
      setState(() {
        qrGenerated = true;
        successBadge = mode == 'new' ? 'Visitante registrado automáticamente' : null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código QR generado exitosamente'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final separatorColor = theme.brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade300;

    return BlocProvider<VisitorBloc>(
      create: (_) {
        // Crear VisitorRepository manualmente con el personaId correcto
        final visitorApi = sl<VisitorApi>();
        final visitorRepo = VisitorRepositoryImpl(api: visitorApi, personaId: widget.personaId);
        final usecase = ManageVisitorUseCase(visitorRepo);
        return VisitorBloc(usecase);
      },
      child: PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            Navigator.pushReplacementNamed(context, '/residentDashboard');
          }
        },
        child: AppScaffold(
          title: 'QR de Visitante',
        isRoot: true,
        currentIndex: 1,
        onTabSelected: (i) {
          final authState = context.read<AuthBloc>().state;
          String? authName;
          if (authState is AuthSuccess) authName = authState.user['name'] as String?;

          switch (i) {
            case 0:
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.residentDashboard,
              arguments: {
                'personaId': widget.personaId,
                'identificacion': widget.identificacion,
                'residenceId': widget.residenceId,
                'userName': authName ?? '',
              },
            );
            break;
          case 1:
            break;
          case 2:
            Navigator.pushNamed(context, AppRoutes.accessHistory, arguments: {'personaId': widget.personaId, 'identificacion': widget.identificacion});
            break;
          case 3:
            Navigator.pushNamed(context, AppRoutes.members, arguments: {'personaId': widget.personaId, 'identificacion': widget.identificacion, 'residenceId': widget.residenceId});
            break;
          case 4:
            Navigator.pushNamed(context, AppRoutes.profile, arguments: {'personaId': widget.personaId, 'identificacion': widget.identificacion});
            break;
        }
      },
      body: BlocListener<QrVisitBloc, QrVisitState>(
        listener: (listenerCtx, qrState) {
          if (qrState is QrVisitReady && qrGenerated) {
            // Recargar lista de visitantes después de generar QR
            listenerCtx.read<VisitorBloc>().add(LoadVisitors(widget.residenceId));
            
            // Obtener datos del usuario del AuthBloc
            final authData = getUserDataFromAuth(listenerCtx);
            
            // Guardar contexto de navegación en QrBloc
            listenerCtx.read<QrBloc>().add(SaveQrNavigationContext(
              personaId: widget.personaId,
              identificacion: widget.identificacion,
              residenceId: widget.residenceId,
              userName: authData.userName,
              qrValue: qrState.qr.value,
              validFrom: qrState.qr.validFrom,
              validUntil: qrState.qr.expiresAt,
              durationHours: qrState.qr.durationHours ?? durationHours ?? 0,
              visitName: nameCtrl.text.isNotEmpty ? nameCtrl.text : 'Visitante',
              visitIdentificacion: idCtrl.text.isNotEmpty ? idCtrl.text : '',
            ));
            
            // Navigate to display page sin argumentos
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => QrDisplayPage(
                  userName: authData.userName,
                  personaId: widget.personaId,
                  identificacion: widget.identificacion,
                  validFrom: qrState.qr.validFrom,
                  validUntil: qrState.qr.expiresAt,
                  durationHours: qrState.qr.durationHours ?? durationHours ?? 0,
                  qrValue: qrState.qr.value,
                  // Datos de la visita
                  visitName: nameCtrl.text.isNotEmpty ? nameCtrl.text : 'Visitante',
                  visitIdentificacion: idCtrl.text.isNotEmpty ? idCtrl.text : '',
                ),
              ),
            );
            setState(() => qrGenerated = false);
          }
        },
        child: BlocBuilder<VisitorBloc, VisitorState>(
          builder: (ctx, vstState) {
            // Load visitors on first build using the new endpoint
            if (vstState is VisitorInitial) {
              ctx.read<VisitorBloc>().add(LoadVisitantesVivienda());
            }
            
            return BlocBuilder<QrVisitBloc, QrVisitState>(
              builder: (qrCtx, qrState) {
                return SingleChildScrollView(
                  controller: _scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                  Center(child: Icon(Icons.person_add_alt_1, size: 64, color: theme.colorScheme.secondary)),
                  const SizedBox(height: 8),
                  Text('Código QR de Visitante', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text('Seleccione un visitante frecuente o registre uno nuevo.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
                  const SizedBox(height: 16),

                  // Toggle de modo
                  Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            mode = 'saved';
                            nameCtrl.clear();
                            idCtrl.clear();
                          });
                        },
                        icon: const Icon(Icons.groups),
                        label: Text('Visitantes Frecuentes', style: TextStyle(color: mode == 'saved' ? theme.colorScheme.primary : null)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: mode == 'saved' ? theme.colorScheme.primary : theme.dividerColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            mode = 'new';
                            nameCtrl.clear();
                            idCtrl.clear();
                          });
                        },
                        icon: const Icon(Icons.person_add),
                        label: Text('Nuevo Visitante', style: TextStyle(color: mode == 'new' ? theme.colorScheme.primary : null)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: mode == 'new' ? theme.colorScheme.primary : theme.dividerColor),
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 16),

                  if (mode == 'saved') ...[
                    // Buscador
                    TextField(
                      controller: searchCtrl,
                      onChanged: (query) {
                        ctx.read<VisitorBloc>().add(SearchVisitors(query));
                      },
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Buscar por nombre o identificación',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Lista de visitantes - mostrar solo si no hay selección
                    if (vstState is VisitorLoaded && vstState.filtered.isNotEmpty && vstState.selected == null)
                      Container(
                        constraints: const BoxConstraints(maxHeight: 250),
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.dividerColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: vstState.filtered.length,
                          separatorBuilder: (_, __) => Divider(height: 1, color: theme.dividerColor),
                          itemBuilder: (_, i) {
                            final v = vstState.filtered[i];
                            return InkWell(
                              onTap: () {
                                ctx.read<VisitorBloc>().add(SelectVisitor(v));
                                nameCtrl.text = v.name;
                                idCtrl.text = v.id;
                                // Scroll hacia el card de confirmación
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  _scrollController.animateTo(
                                    _scrollController.position.maxScrollExtent,
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeInOut,
                                  );
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                child: Row(children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                                    child: Text(
                                      v.name.isNotEmpty ? v.name[0].toUpperCase() : '?',
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                                    Text(v.name, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                                    Text(v.id, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                                  ])),
                                  Icon(Icons.arrow_forward_ios, size: 16, color: theme.colorScheme.primary),
                                ]),
                              ),
                            );
                          },
                        ),
                      )
                    else
                      Column(children: [
                        const Icon(Icons.groups, size: 36, color: Colors.grey),
                        const SizedBox(height: 4),
                        Text(
                          vstState is VisitorLoaded 
                            ? 'No hay visitantes registrados en esta vivienda'
                            : 'Cargando visitantes...', 
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Selecciona "Nuevo Visitante" para registrar a alguien', 
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                        ),
                      ]),
                  ],

                  if (mode == 'new' || (vstState is VisitorLoaded && vstState.selected != null)) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          if (mode == 'new') ...[
                            TextField(
                              controller: nameCtrl,
                              decoration: const InputDecoration(labelText: 'Nombre del Visitante', border: OutlineInputBorder()),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: idCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Identificación (8-10 dígitos)', border: OutlineInputBorder()),
                              onChanged: (v) {
                                final filtered = v.replaceAll(RegExp(r'[^0-9]'), '');
                                if (filtered.length <= 10) idCtrl.text = filtered;
                                idCtrl.selection = TextSelection.fromPosition(TextPosition(offset: idCtrl.text.length));
                              },
                            ),
                            const SizedBox(height: 4),
                            Text('${idCtrl.text.length}/10 dígitos', style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                          ] else ...[
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Expanded(
                                child: Row(children: const [
                                  Icon(Icons.person_outline, color: Colors.grey),
                                  SizedBox(width: 8),
                                  Flexible(
                                    child: Text('Visitante Seleccionado', style: TextStyle(fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                                  ),
                                ]),
                              ),
                              TextButton.icon(
                                onPressed: _clearSelection,
                                icon: const Icon(Icons.edit),
                                label: const Text('Cambiar'),
                              ),
                            ]),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
                              ),
                              child: Row(children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: theme.colorScheme.primary,
                                  child: Text(
                                    nameCtrl.text.isNotEmpty ? nameCtrl.text[0].toUpperCase() : '?',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(nameCtrl.text, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                  Text(idCtrl.text, style: theme.textTheme.bodySmall),
                                  if (vstState is VisitorLoaded && vstState.selected?.lastVisitAt != null)
                                    Text(
                                      'Registrado: ${_fmtShortES(vstState.selected!.lastVisitAt!, includeWeek: false)}',
                                      style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                                    ),
                                ])),
                              ]),
                            ),
                          ],

                          const SizedBox(height: 20),
                          if (mode != 'new') ...[
                            Text('Configurar vigencia del acceso', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                          ],
                          // Fecha
                          Align(alignment: Alignment.centerLeft, child: Text('Fecha de Inicio', style: theme.textTheme.labelLarge)),
                          const SizedBox(height: 6),
                          TextField(
                            readOnly: true,
                            decoration: const InputDecoration(prefixIcon: Icon(Icons.calendar_today), hintText: 'mm / dd / yyyy', border: OutlineInputBorder()),
                            controller: TextEditingController(text: startDate == null ? '' : '${startDate!.month}/${startDate!.day}/${startDate!.year}'),
                            onTap: _pickDate,
                          ),
                          const SizedBox(height: 12),
                          // Hora
                          Align(alignment: Alignment.centerLeft, child: Text('Hora de Inicio', style: theme.textTheme.labelLarge)),
                          const SizedBox(height: 6),
                          TextField(
                            readOnly: true,
                            decoration: const InputDecoration(prefixIcon: Icon(Icons.schedule), hintText: '-- : -- --', border: OutlineInputBorder()),
                            controller: TextEditingController(text: startTime == null ? '' : startTime!.format(context)),
                            onTap: _pickTime,
                          ),
                          const SizedBox(height: 12),
                          // Duración
                          Align(alignment: Alignment.centerLeft, child: Text('Duración (horas)', style: theme.textTheme.labelLarge)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<int>(
                            value: durationHours,
                            decoration: const InputDecoration(prefixIcon: Icon(Icons.access_time), border: OutlineInputBorder()),
                            items: const [
                              DropdownMenuItem(value: 0, child: Text('Seleccione duración')),
                              DropdownMenuItem(value: 1, child: Text('1 hora')),
                              DropdownMenuItem(value: 3, child: Text('3 horas')),
                              DropdownMenuItem(value: 6, child: Text('6 horas')),
                              DropdownMenuItem(value: 12, child: Text('12 horas')),
                            ],
                            onChanged: (v) => setState(() => durationHours = (v == 0) ? null : v),
                          ),

                          const SizedBox(height: 16),
                          if (validFrom != null && validUntil != null)
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text('Periodo de Validez', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
                                const SizedBox(height: 12),
                                Row(children: [
                                  Icon(Icons.access_time, size: 18, color: theme.colorScheme.primary),
                                  const SizedBox(width: 8),
                                  const Text('Inicio: ', style: TextStyle(fontWeight: FontWeight.w600)),
                                  Expanded(child: Text(_fmtShortES(validFrom!, includeWeek: true))),
                                ]),
                                const SizedBox(height: 8),
                                Row(children: [
                                  Icon(Icons.access_time_filled, size: 18, color: theme.colorScheme.primary),
                                  const SizedBox(width: 8),
                                  const Text('Fin: ', style: TextStyle(fontWeight: FontWeight.w600)),
                                  Expanded(child: Text(_fmtShortES(validUntil!, includeWeek: true))),
                                ]),
                              ]),
                            ),

                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _confirmDialog(ctx),
                              icon: const Icon(Icons.qr_code),
                              label: const Text('Generar QR de Visitante'),
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),
                  Divider(color: separatorColor),

                  if (qrState is QrVisitReady && qrGenerated) ...[
                    // QR container
                    Center(
                      child: Container(
                        width: 220,
                        height: 220,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: separatorColor),
                        ),
                        child: RepaintBoundary(
                          key: qrBoundaryKey,
                          child: QrImageView(
                            data: qrState.qr.value,
                            version: QrVersions.auto,
                            size: 200,
                            foregroundColor: Colors.black,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Info card y badge de éxito
                    Text('QR para ${nameCtrl.text}', style: theme.textTheme.titleMedium),
                    Text('El visitante debe mostrar este código al ingresar', style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
                    const SizedBox(height: 8),
                    if (successBadge != null)
                      Row(children: const [
                        Icon(Icons.check_circle, color: Color(0xFF10B981)),
                        SizedBox(width: 6),
                        Text('Visitante registrado exitosamente'),
                      ]),
                    const SizedBox(height: 8),

                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: separatorColor),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(children: [
                        _DetailRow(label: 'Válido para:', value: nameCtrl.text),
                        _DetailRow(label: 'Identificación:', value: idCtrl.text),
                        _DetailRow(label: 'Válido desde:', value: _fmtShortES(qrState.qr.validFrom, includeWeek: false)),
                        _DetailRow(label: 'Válido hasta:', value: _fmtShortES(qrState.qr.expiresAt, includeWeek: false)),
                        _DetailRow(label: 'Duración:', value: '${qrState.qr.durationHours} horas'),
                      ]),
                    ),
                    const SizedBox(height: 12),

                    // Acciones
                    Row(children: [
                      Expanded(child: OutlinedButton.icon(onPressed: () => _error('Compartir disponible al integrar captura'), icon: const Icon(Icons.share), label: const Text('Compartir'))),
                      const SizedBox(width: 8),
                      Expanded(child: OutlinedButton.icon(onPressed: () => _error('Descargar disponible al integrar captura'), icon: const Icon(Icons.download), label: const Text('Descargar'))),
                    ]),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            qrGenerated = false;
                            successBadge = null;
                          });
                        },
                        child: Text('Volver', style: TextStyle(color: theme.colorScheme.primary)),
                      ),
                    ),
                  ],
                  ]),
                ));
              },
            );
          },
        ),
      ),
    )));
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

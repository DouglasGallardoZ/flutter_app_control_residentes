import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/blocs/vivienda/vivienda_bloc.dart';
import '../../../application/blocs/owner/owner_bloc.dart';
import '../../../application/blocs/owner/owner_event.dart';
import '../../../domain/entities/villa_detalle_entity.dart';

class AdminVillaDetallePage extends StatefulWidget {
  final int viviendaId;
  final String manzana;
  final String villa;

  const AdminVillaDetallePage({
    super.key,
    required this.viviendaId,
    required this.manzana,
    required this.villa,
  });

  @override
  State<AdminVillaDetallePage> createState() =>
      _AdminVillaDetallePageState();
}

class _AdminVillaDetallePageState
    extends State<AdminVillaDetallePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ViviendaBloc>().add(
          LoadVillaDetalle(viviendaId: widget.viviendaId));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manzana ${widget.manzana} - Villa ${widget.villa}'),
      ),
      body: BlocConsumer<ViviendaBloc, ViviendaState>(
        listener: (context, state) {
          if (state is PropietarioCambiado) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.mensaje),
                backgroundColor: Colors.green));
            context.read<ViviendaBloc>().add(
                LoadVillaDetalle(viviendaId: widget.viviendaId));
          }
          if (state is ViviendaError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.mensaje),
                backgroundColor: Colors.red));
          }
        },
        builder: (context, state) {
          if (state is VillaDetalleLoaded) {
            return _VillaDetalleContent(detalle: state.detalle);
          }
          if (state is ViviendaLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ViviendaError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    state.mensaje,
                    style: TextStyle(color: Colors.red[700], fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ViviendaBloc>().add(
                          LoadVillaDetalle(viviendaId: widget.viviendaId));
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                final blState = context.read<ViviendaBloc>().state;
                if (blState is VillaDetalleLoaded) {
                  _mostrarDialogoCambioPropietario(blState.detalle);
                }
              },
              icon: const Icon(Icons.swap_horiz),
              label: const Text('Cambiar Propietario'),
              style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _mostrarDialogoCambioPropietario(
      VillaDetalleEntity detalle) async {
    final ownerBloc = context.read<OwnerBloc>();
    final viviendaBloc = context.read<ViviendaBloc>();
    ownerBloc.add(const LoadActiveOwners());

    final result = await showDialog<CambioPropietarioData>(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: ownerBloc,
        child: _ChangeOwnerDialog(
          viviendaId: widget.viviendaId,
          manzana: widget.manzana,
          villaNum: widget.villa,
          propietarioActual: detalle.propietarios.isNotEmpty
              ? detalle.propietarios.first.nombreCompleto
              : null,
          tipoActual: detalle.propietarios.isNotEmpty
              ? detalle.propietarios.first.tipo
              : null,
        ),
      ),
    );

    if (!mounted) return;
    if (result != null) {
      viviendaBloc.add(CambiarPropietario(
            viviendaId: result.viviendaId,
            nuevoPropietarioId: result.nuevoPropietarioId,
            tipo: result.tipo,
            motivo: result.motivo,
          ));
    }
  }
}

class CambioPropietarioData {
  final int viviendaId;
  final int nuevoPropietarioId;
  final String tipo;
  final String motivo;

  CambioPropietarioData({
    required this.viviendaId,
    required this.nuevoPropietarioId,
    required this.tipo,
    required this.motivo,
  });
}

class _VillaDetalleContent extends StatelessWidget {
  final VillaDetalleEntity detalle;
  const _VillaDetalleContent({required this.detalle});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionHeader(title: 'Propietarios', icon: Icons.person, count: detalle.propietarios.length),
        if (detalle.propietarios.isEmpty)
          _EmptyCard('Sin propietarios asignados')
        else
          ...detalle.propietarios.map((p) => _PersonaCard(
                nombre: p.nombreCompleto,
                identificacion: p.identificacion,
                correo: p.correo,
                celular: p.celular,
                badges: [
                  _BadgeData(p.tipo == 'titular' ? 'Titular' : 'Copropietario',
                      p.tipo == 'titular' ? Colors.blue : Colors.teal),
                  _BadgeData(p.estado == 'activo' ? 'Activo' : 'Inactivo',
                      p.estado == 'activo' ? Colors.green : Colors.red),
                ],
              )),
        const SizedBox(height: 20),
        _SectionHeader(title: 'Residentes', icon: Icons.people, count: detalle.residentes.length),
        if (detalle.residentes.isEmpty)
          _EmptyCard('Sin residentes registrados')
        else
          ...detalle.residentes.map((r) => _PersonaCard(
                nombre: r.nombreCompleto,
                identificacion: r.identificacion,
                correo: r.correo,
                celular: r.celular,
                badges: [
                  _BadgeData(r.estado == 'activo' ? 'Activo' : 'Inactivo',
                      r.estado == 'activo' ? Colors.green : Colors.red),
                ],
              )),
        const SizedBox(height: 20),
        _SectionHeader(title: 'Miembros de Familia', icon: Icons.family_restroom, count: detalle.miembros.length),
        if (detalle.miembros.isEmpty)
          _EmptyCard('Sin miembros registrados')
        else
          ...detalle.miembros.map((m) => _PersonaCard(
                nombre: m.nombreCompleto,
                identificacion: m.identificacion,
                badges: [
                  _BadgeData(m.estado == 'activo' ? 'Activo' : 'Inactivo',
                      m.estado == 'activo' ? Colors.green : Colors.red),
                ],
                extraLines: [
                  _InfoRow(icon: Icons.link, text: m.parentesco),
                  _InfoRow(icon: Icons.person_outline, text: 'Residente: ${m.residenteNombre}'),
                ],
              )),
        const SizedBox(height: 80),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final int count;
  const _SectionHeader({required this.title, required this.icon, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Icon(icon, size: 20, color: Colors.blueGrey),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
          decoration: BoxDecoration(color: Colors.blueGrey.shade50, borderRadius: BorderRadius.circular(10)),
          child: Text('$count', style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade700)),
        ),
      ]),
    );
  }
}

class _BadgeData {
  final String label;
  final Color color;
  const _BadgeData(this.label, this.color);
}

class _PersonaCard extends StatelessWidget {
  final String nombre;
  final String identificacion;
  final String? correo;
  final String? celular;
  final List<_BadgeData> badges;
  final List<Widget>? extraLines;

  const _PersonaCard({
    required this.nombre,
    required this.identificacion,
    this.correo, this.celular,
    this.badges = const [], this.extraLines,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(nombre, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15))),
            ...badges.map((b) => Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: b.color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(b.label, style: TextStyle(fontSize: 11, color: b.color, fontWeight: FontWeight.w500)),
              ),
            )),
          ]),
          const SizedBox(height: 6),
          _InfoRow(icon: Icons.badge_outlined, text: identificacion),
          if (correo != null) ...[const SizedBox(height: 2), _InfoRow(icon: Icons.email_outlined, text: correo!)],
          if (celular != null) ...[const SizedBox(height: 2), _InfoRow(icon: Icons.phone_outlined, text: celular!)],
          if (extraLines != null) ...extraLines!,
        ]),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 14, color: Colors.grey.shade500),
      const SizedBox(width: 6),
      Expanded(child: Text(text, style: TextStyle(fontSize: 13, color: Colors.grey.shade700), overflow: TextOverflow.ellipsis)),
    ]);
  }
}

class _EmptyCard extends StatelessWidget {
  final String message;
  const _EmptyCard(this.message);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Icon(Icons.info_outline, color: Colors.grey.shade400),
          const SizedBox(width: 12),
          Text(message, style: TextStyle(color: Colors.grey.shade500)),
        ]),
      ),
    );
  }
}

class _ChangeOwnerDialog extends StatefulWidget {
  final int viviendaId;
  final String manzana;
  final String villaNum;
  final String? propietarioActual;
  final String? tipoActual;

  const _ChangeOwnerDialog({
    required this.viviendaId, required this.manzana, required this.villaNum,
    this.propietarioActual, this.tipoActual,
  });

  @override
  State<_ChangeOwnerDialog> createState() => _ChangeOwnerDialogState();
}

class _ChangeOwnerDialogState extends State<_ChangeOwnerDialog> {
  String _ownerId = '';
  String _tipo = 'titular';
  final _motivoCtrl = TextEditingController();
  bool _confirmado = false;

  bool get _formValido => _ownerId.isNotEmpty && _motivoCtrl.text.trim().isNotEmpty && _confirmado;

  @override
  void dispose() { _motivoCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cambiar Propietario'),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (widget.propietarioActual != null)
            Text('Actual: ${widget.propietarioActual}${widget.tipoActual != null ? " (${widget.tipoActual})" : ""}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          const SizedBox(height: 12),
          TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'ID del nuevo propietario', border: OutlineInputBorder()),
            onChanged: (v) => setState(() => _ownerId = v),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _tipo,
            decoration: const InputDecoration(labelText: 'Tipo', border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: 'titular', child: Text('Titular')),
              DropdownMenuItem(value: 'copropietario', child: Text('Copropietario')),
            ],
            onChanged: (v) => setState(() => _tipo = v ?? 'titular'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _motivoCtrl,
            decoration: const InputDecoration(labelText: 'Motivo del cambio *', border: OutlineInputBorder()),
            maxLines: 2, onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            value: _confirmado, title: const Text('Confirmo el cambio'),
            controlAffinity: ListTileControlAffinity.leading, contentPadding: EdgeInsets.zero,
            onChanged: (v) => setState(() => _confirmado = v ?? false),
          ),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(
          onPressed: _formValido
              ? () {
                  final nuevoId = int.tryParse(_ownerId);
                  if (nuevoId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('ID invalido'),
                            backgroundColor: Colors.red));
                    return;
                  }
                  Navigator.pop(
                    context,
                    CambioPropietarioData(
                      viviendaId: widget.viviendaId,
                      nuevoPropietarioId: nuevoId,
                      tipo: _tipo,
                      motivo: _motivoCtrl.text.trim(),
                    ),
                  );
                }
              : null,
          style: FilledButton.styleFrom(backgroundColor: const Color(0xFF04345C)),
          child: const Text('Confirmar Cambio'),
        ),
      ],
    );
  }
}

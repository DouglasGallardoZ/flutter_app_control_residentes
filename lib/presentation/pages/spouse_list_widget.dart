import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/blocs/owner/owner_bloc.dart';
import '../../application/blocs/owner/owner_event.dart';
import '../../domain/entities/conyuge_entity.dart';

class SpouseListWidget extends StatelessWidget {
  final List<ConyugeEntity> spouses;
  final int ownerId;

  const SpouseListWidget({
    super.key,
    required this.spouses,
    required this.ownerId,
  });

  void _showDeleteConfirmation(BuildContext context, ConyugeEntity spouse) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Cónyuge'),
        content: Text(
          '¿Estás seguro de que deseas eliminar a ${spouse.nombreCompleto}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<OwnerBloc>().add(DeleteSpouseEvent(spouse.id));
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _toggleBlockSpouse(BuildContext context, ConyugeEntity spouse) {
    context.read<OwnerBloc>().add(
      BlockSpouseEvent(spouse.id, !spouse.isBlocked),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (spouses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Icon(
                Icons.people_outline,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 12),
              Text(
                'No hay cónyuges registrados',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: spouses.length,
      itemBuilder: (context, index) {
        final spouse = spouses[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: spouse.isBlocked ? Colors.red.shade200 : Colors.blue.shade200,
              child: Icon(
                Icons.person,
                color: spouse.isBlocked ? Colors.red : Colors.blue,
              ),
            ),
            title: Text(spouse.nombreCompleto),
            subtitle: Text(spouse.identificacion),
            trailing: spouse.isBlocked
                ? Chip(
                    label: const Text('Bloqueado', style: TextStyle(fontSize: 10)),
                    backgroundColor: Colors.red.shade100,
                    labelStyle: TextStyle(color: Colors.red.shade700),
                    side: BorderSide(color: Colors.red.shade300),
                  )
                : PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'block') {
                        _toggleBlockSpouse(context, spouse);
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(context, spouse);
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem(
                        value: 'block',
                        child: Text('Bloquear'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Eliminar', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Detalles del Cónyuge'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DetailRow(label: 'Nombre', value: spouse.nombre),
                      _DetailRow(label: 'Apellido', value: spouse.apellido),
                      _DetailRow(label: 'Identificación', value: spouse.identificacion),
                      _DetailRow(label: 'Email', value: spouse.correo),
                      _DetailRow(label: 'Teléfono', value: spouse.celular),
                      _DetailRow(
                        label: 'Estado',
                        value: spouse.estado.toUpperCase(),
                        valueColor: spouse.isBlocked ? Colors.red : Colors.green,
                      ),
                      if (spouse.fechaCreacion != null)
                        _DetailRow(
                          label: 'Registrado',
                          value: '${spouse.fechaCreacion!.day}/${spouse.fechaCreacion!.month}/${spouse.fechaCreacion!.year}',
                        ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cerrar'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/blocs/qr_list/qr_list_bloc.dart';
import '../../application/blocs/qr_list/qr_list_event.dart';
import '../../application/blocs/qr_list/qr_list_state.dart';
import '../widgets/qr_list_card.dart';
import '../widgets/app_scaffold.dart';
import 'qr_display_page.dart';

class QrListPage extends StatefulWidget {
  final int personaId;
  final String identificacion;
  final String residenceId;

  const QrListPage({
    super.key,
    required this.personaId,
    required this.identificacion,
    required this.residenceId,
  });

  @override
  State<QrListPage> createState() => _QrListPageState();
}

class _QrListPageState extends State<QrListPage> {
  late ScrollController _scrollController;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    // Cargar QRs inicialmente con personaId
    context.read<QrListBloc>().add(
      LoadQrList(
        tipoIngreso: _selectedFilter,
        usuarioId: widget.personaId.toString(),
      ),
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // Cargar más QRs cuando llega al final
      final state = context.read<QrListBloc>().state;
      if (state is QrListLoaded && state.hasNext) {
        context.read<QrListBloc>().add(LoadMoreQrList(usuarioId: widget.personaId.toString()));
      }
    }
  }

  void _onFilterChanged(String? filter) {
    if (filter != null && filter != _selectedFilter) {
      setState(() => _selectedFilter = filter);
      context.read<QrListBloc>().add(
        FilterQrList(
          tipoIngreso: filter,
          usuarioId: widget.personaId.toString(),
        ),
      );
    }
  }

  void _mostrarQR(int qrPk, String token, DateTime inicio, DateTime fin, int duracion, String nombre, String? visitanteNombre, String? visitanteIdentificacion) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: QrDisplayPage(
          userName: nombre,
          personaId: widget.personaId,
          identificacion: widget.identificacion,
          validFrom: inicio,
          validUntil: fin,
          durationHours: duracion,
          qrValue: token,
          visitName: visitanteNombre,
          visitIdentificacion: visitanteIdentificacion,
          isModal: true,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final separatorColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;

    return AppScaffold(
      title: 'Códigos QR Generados',
      routeName: '/qrList',
      isRoot: false,
      showBackButton: true,
      body: BlocProvider<QrListBloc>(
        create: (_) => context.read<QrListBloc>(),
        child: BlocBuilder<QrListBloc, QrListState>(
          builder: (ctx, state) {
            if (state is QrListInitial || state is QrListLoading && state is! QrListLoaded) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is QrListError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        context.read<QrListBloc>().add(
                          LoadQrList(
                            tipoIngreso: _selectedFilter,
                            usuarioId: widget.personaId.toString(),
                          ),
                        );
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
          }

          if (state is QrListLoaded) {
            final qrs = state.qrs;

            return Column(
              children: [
                // Filtros
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filtrar por tipo',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _FilterChip(
                              label: 'Todos',
                              value: 'all',
                              selected: _selectedFilter == 'all',
                              onSelected: _onFilterChanged,
                            ),
                            const SizedBox(width: 8),
                            _FilterChip(
                              label: 'Propios',
                              value: 'propio',
                              selected: _selectedFilter == 'propio',
                              onSelected: _onFilterChanged,
                            ),
                            const SizedBox(width: 8),
                            _FilterChip(
                              label: 'Visitas',
                              value: 'visita',
                              selected: _selectedFilter == 'visita',
                              onSelected: _onFilterChanged,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${state.total} código(s) QR',
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                      ),
                    ],
                  ),
                ),
                Divider(color: separatorColor),
                // Lista de QRs
                Expanded(
                  child: qrs.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.qr_code_2,
                                size: 64,
                                color: theme.colorScheme.outline.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No hay códigos QR generados',
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Genera tu primer QR para comenzar',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.hintColor,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: qrs.length + (state.hasNext ? 1 : 0),
                          itemBuilder: (ctx, index) {
                            if (index >= qrs.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            final qr = qrs[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: QrListCard(
                                qr: qr,
                                onVerQr: () {
                                  _mostrarQR(
                                    qr.qrPk,
                                    qr.token,
                                    qr.horaInicio,
                                    qr.horaFin,
                                    qr.horaFin.difference(qr.horaInicio).inHours,
                                    qr.autorizadoPorNombre,
                                    qr.tipoIngreso == 'visita' ? qr.autorizadoParaNombre : null,
                                    null,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
            },
          ),
        ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final Function(String?) onSelected;

  const _FilterChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (sel) => onSelected(value),
      backgroundColor: theme.colorScheme.surface,
      selectedColor: theme.colorScheme.primary.withOpacity(0.2),
      side: BorderSide(
        color: selected ? theme.colorScheme.primary : theme.colorScheme.outline,
      ),
      labelStyle: theme.textTheme.labelMedium?.copyWith(
        color: selected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
      ),
    );
  }
}

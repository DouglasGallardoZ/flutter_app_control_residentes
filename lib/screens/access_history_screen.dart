import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:guardin/models/user.dart';
import 'package:guardin/models/access_event.dart';
import 'package:guardin/services/access_event_service.dart';

class AccessHistoryScreen extends StatefulWidget {
  final User user;

  const AccessHistoryScreen({super.key, required this.user});

  @override
  State<AccessHistoryScreen> createState() => _AccessHistoryScreenState();
}

class _AccessHistoryScreenState extends State<AccessHistoryScreen> {
  final _eventService = AccessEventService();
  List<AccessEvent> _events = [];
  bool _isLoading = true;
  String _filterType = 'todos';

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    try {
      final events = await _eventService.getEventsByUserId(widget.user.id);
      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<AccessEvent> get _filteredEvents {
    if (_filterType == 'todos') return _events;
    return _events.where((e) => e.eventType == _filterType).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial de accesos'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _filteredEvents.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadEvents,
                        child: ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: _filteredEvents.length,
                          itemBuilder: (context, index) =>
                              _AccessEventCard(event: _filteredEvents[index]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterChip(
              label: 'Todos',
              isSelected: _filterType == 'todos',
              onTap: () => setState(() => _filterType = 'todos'),
            ),
            SizedBox(width: 8),
            _FilterChip(
              label: 'Entradas',
              isSelected: _filterType == 'entrada',
              onTap: () => setState(() => _filterType = 'entrada'),
            ),
            SizedBox(width: 8),
            _FilterChip(
              label: 'Salidas',
              isSelected: _filterType == 'salida',
              onTap: () => setState(() => _filterType = 'salida'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            SizedBox(height: 24),
            Text(
              'No hay eventos de acceso',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Los eventos de acceso aparecerán aquí',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isSelected
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _AccessEventCard extends StatelessWidget {
  final AccessEvent event;

  const _AccessEventCard({required this.event});

  IconData _getEventIcon(String eventType, String accessMethod) {
    if (eventType == 'entrada') {
      return accessMethod == 'facial' ? Icons.face : Icons.qr_code;
    }
    return Icons.exit_to_app;
  }

  Color _getEventColor(String eventType, bool isAuthorized) {
    if (!isAuthorized) return Colors.red;
    return eventType == 'entrada' ? Color(0xFF4CAF50) : Color(0xFF2196F3);
  }

  String _getEventLabel(String eventType) {
    return eventType == 'entrada' ? 'Entrada' : 'Salida';
  }

  String _getAccessMethodLabel(String accessMethod) {
    return accessMethod == 'facial' ? 'Reconocimiento facial' : 'Código QR';
  }

  @override
  Widget build(BuildContext context) {
    final eventColor = _getEventColor(event.eventType, event.isAuthorized);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: eventColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: eventColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getEventIcon(event.eventType, event.accessMethod),
              color: eventColor,
              size: 28,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _getEventLabel(event.eventType),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: eventColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        event.isAuthorized ? 'Autorizado' : 'Denegado',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: eventColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  _getAccessMethodLabel(event.accessMethod),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    SizedBox(width: 4),
                    Text(
                      DateFormat('dd/MM/yyyy - HH:mm').format(event.timestamp),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                if (event.notes != null && event.notes!.isNotEmpty) ...[
                  SizedBox(height: 6),
                  Text(
                    event.notes!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

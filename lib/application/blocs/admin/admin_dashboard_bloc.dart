import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_admin_metrics_usecase.dart';
import '../../../domain/usecases/get_access_history_usecase.dart';
import 'admin_dashboard_event.dart';
import 'admin_dashboard_state.dart';

class AdminDashboardBloc extends Bloc<AdminDashboardEvent, AdminDashboardState> {
  final GetAdminMetricsUseCase getAdminMetricsUseCase;
  final GetAccessHistoryUseCase getAccessHistoryUseCase;
  
  // Estado interno para mantener el filtro actual
  String _currentTimeFilter = 'today';
  String? _customFechaInicio;
  String? _customFechaFin;

  AdminDashboardBloc(this.getAdminMetricsUseCase, this.getAccessHistoryUseCase)
      : super(const AdminDashboardInitial()) {
    on<LoadAdminMetrics>(_onLoadAdminMetrics);
    on<RefreshAdminMetrics>(_onRefreshAdminMetrics);
    on<ChangeTimeFilter>(_onChangeTimeFilter);
    on<LoadAccessHistory>(_onLoadAccessHistory);
  }

  Future<void> _onLoadAdminMetrics(LoadAdminMetrics event, Emitter<AdminDashboardState> emit) async {
    emit(const AdminDashboardLoading());
    try {
      final (fechaInicio, fechaFin) = _calculateDateRange(_currentTimeFilter, _customFechaInicio, _customFechaFin);
      final metrics = await getAdminMetricsUseCase(
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
      );
      emit(AdminDashboardLoaded(
        metrics,
        currentTimeFilter: _currentTimeFilter,
        customFechaInicio: _customFechaInicio,
        customFechaFin: _customFechaFin,
      ));
    } catch (e) {
      emit(AdminDashboardError('Error al cargar métricas: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshAdminMetrics(RefreshAdminMetrics event, Emitter<AdminDashboardState> emit) async {
    try {
      final (fechaInicio, fechaFin) = _calculateDateRange(_currentTimeFilter, _customFechaInicio, _customFechaFin);
      final metrics = await getAdminMetricsUseCase(
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
      );
      emit(AdminDashboardLoaded(
        metrics,
        currentTimeFilter: _currentTimeFilter,
        customFechaInicio: _customFechaInicio,
        customFechaFin: _customFechaFin,
      ));
    } catch (e) {
      emit(AdminDashboardError('Error al actualizar métricas: ${e.toString()}'));
    }
  }

  Future<void> _onChangeTimeFilter(
    ChangeTimeFilter event,
    Emitter<AdminDashboardState> emit,
  ) async {
    // Actualizar el filtro actual
    _currentTimeFilter = event.filterType;
    if (event.filterType == 'custom') {
      _customFechaInicio = event.customFechaInicio;
      _customFechaFin = event.customFechaFin;
    } else {
      _customFechaInicio = null;
      _customFechaFin = null;
    }

    // Recargar métricas con el nuevo filtro
    emit(const AdminDashboardLoading());
    try {
      // Calcular fechas según el filtro
      final (fechaInicio, fechaFin) = _calculateDateRange(event.filterType, event.customFechaInicio, event.customFechaFin);
      
      final metrics = await getAdminMetricsUseCase(
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
      );
      emit(AdminDashboardLoaded(
        metrics,
        currentTimeFilter: _currentTimeFilter,
        customFechaInicio: _customFechaInicio,
        customFechaFin: _customFechaFin,
      ));
    } catch (e) {
      emit(AdminDashboardError('Error al cambiar filtro de tiempo: ${e.toString()}'));
    }
  }

  Future<void> _onLoadAccessHistory(
    LoadAccessHistory event,
    Emitter<AdminDashboardState> emit,
  ) async {
    emit(const AccessHistoryLoading());
    try {
      final history = await getAccessHistoryUseCase(
        page: event.page,
        pageSize: event.pageSize,
        fechaInicio: event.fechaInicio,
        fechaFin: event.fechaFin,
        tipo: event.tipo,
        resultado: event.resultado,
      );
      emit(AccessHistoryLoaded(history));
    } catch (e) {
      emit(AccessHistoryError('Error al cargar historial de accesos: ${e.toString()}'));
    }
  }

  /// Calcula el rango de fechas según el filtro seleccionado
  (String, String) _calculateDateRange(
    String filterType,
    String? customFechaInicio,
    String? customFechaFin,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (filterType) {
      case 'today':
        return (
          today.toIso8601String().split('T')[0],
          today.toIso8601String().split('T')[0],
        );
      case 'week':
        final weekAgo = today.subtract(const Duration(days: 7));
        return (
          weekAgo.toIso8601String().split('T')[0],
          today.toIso8601String().split('T')[0],
        );
      case 'month':
        final monthAgo = today.subtract(const Duration(days: 30));
        return (
          monthAgo.toIso8601String().split('T')[0],
          today.toIso8601String().split('T')[0],
        );
      case 'custom':
        return (
          customFechaInicio ?? today.toIso8601String().split('T')[0],
          customFechaFin ?? today.toIso8601String().split('T')[0],
        );
      default:
        return (
          today.toIso8601String().split('T')[0],
          today.toIso8601String().split('T')[0],
        );
    }
  }
}


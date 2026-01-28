abstract class AdminDashboardEvent {
  const AdminDashboardEvent();
}

class LoadAdminMetrics extends AdminDashboardEvent {
  const LoadAdminMetrics();
}

class RefreshAdminMetrics extends AdminDashboardEvent {
  const RefreshAdminMetrics();
}

class ChangeTimeFilter extends AdminDashboardEvent {
  final String filterType; // 'today', 'week', 'month', 'custom'
  final String? customFechaInicio; // Para filtro 'custom'
  final String? customFechaFin; // Para filtro 'custom'

  const ChangeTimeFilter({
    required this.filterType,
    this.customFechaInicio,
    this.customFechaFin,
  });
}

class LoadAccessHistory extends AdminDashboardEvent {
  final int page;
  final int pageSize;
  final String? fechaInicio;
  final String? fechaFin;
  final String? tipo;
  final String? resultado;

  const LoadAccessHistory({
    this.page = 1,
    this.pageSize = 50,
    this.fechaInicio,
    this.fechaFin,
    this.tipo,
    this.resultado,
  });
}


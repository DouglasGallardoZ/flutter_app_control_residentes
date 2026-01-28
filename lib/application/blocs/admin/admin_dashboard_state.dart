import '../../../domain/entities/admin_metrics.dart';

abstract class AdminDashboardState {
  const AdminDashboardState();
}

class AdminDashboardInitial extends AdminDashboardState {
  const AdminDashboardInitial();
}

class AdminDashboardLoading extends AdminDashboardState {
  const AdminDashboardLoading();
}

class AdminDashboardLoaded extends AdminDashboardState {
  final AdminMetrics metrics;
  final String currentTimeFilter; // 'today', 'week', 'month', 'custom'
  final String? customFechaInicio;
  final String? customFechaFin;

  const AdminDashboardLoaded(
    this.metrics, {
    this.currentTimeFilter = 'today',
    this.customFechaInicio,
    this.customFechaFin,
  });
}

class AdminDashboardError extends AdminDashboardState {
  final String message;

  const AdminDashboardError(this.message);
}

class AccessHistoryLoading extends AdminDashboardState {
  const AccessHistoryLoading();
}

class AccessHistoryLoaded extends AdminDashboardState {
  final Map<String, dynamic> accessHistory;

  const AccessHistoryLoaded(this.accessHistory);
}

class AccessHistoryError extends AdminDashboardState {
  final String message;

  const AccessHistoryError(this.message);
}


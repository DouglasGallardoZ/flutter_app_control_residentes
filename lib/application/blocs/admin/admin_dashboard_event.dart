abstract class AdminDashboardEvent {
  const AdminDashboardEvent();
}

class LoadAdminMetrics extends AdminDashboardEvent {
  const LoadAdminMetrics();
}

class RefreshAdminMetrics extends AdminDashboardEvent {
  const RefreshAdminMetrics();
}

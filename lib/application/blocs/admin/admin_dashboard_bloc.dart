import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_admin_metrics_usecase.dart';
import 'admin_dashboard_event.dart';
import 'admin_dashboard_state.dart';

class AdminDashboardBloc extends Bloc<AdminDashboardEvent, AdminDashboardState> {
  final GetAdminMetricsUseCase getAdminMetricsUseCase;

  AdminDashboardBloc(this.getAdminMetricsUseCase) : super(const AdminDashboardInitial()) {
    on<LoadAdminMetrics>(_onLoadAdminMetrics);
    on<RefreshAdminMetrics>(_onRefreshAdminMetrics);
  }

  Future<void> _onLoadAdminMetrics(LoadAdminMetrics event, Emitter<AdminDashboardState> emit) async {
    emit(const AdminDashboardLoading());
    try {
      final metrics = await getAdminMetricsUseCase();
      emit(AdminDashboardLoaded(metrics));
    } catch (e) {
      emit(AdminDashboardError('Error al cargar métricas: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshAdminMetrics(RefreshAdminMetrics event, Emitter<AdminDashboardState> emit) async {
    try {
      final metrics = await getAdminMetricsUseCase();
      emit(AdminDashboardLoaded(metrics));
    } catch (e) {
      emit(AdminDashboardError('Error al actualizar métricas: ${e.toString()}'));
    }
  }
}

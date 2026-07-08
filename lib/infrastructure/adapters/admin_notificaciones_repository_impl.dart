import '../../domain/entities/destinatario.dart';
import '../../domain/ports/admin_notificaciones_repository_port.dart';
import '../providers/admin_notificaciones_api_provider.dart';

class AdminNotificacionesRepositoryImpl
    implements AdminNotificacionesRepositoryPort {
  final AdminNotificacionesApiProvider _apiProvider;

  AdminNotificacionesRepositoryImpl(this._apiProvider);

  @override
  Future<List<Destinatario>> obtenerDestinatarios({
    String? busqueda,
  }) async {
    final data = await _apiProvider.obtenerDestinatarios(
        busqueda: busqueda);
    return data
        .map((json) => Destinatario.fromJson(json))
        .toList();
  }

  @override
  Future<void> enviarNotificacion({
    required String titulo,
    required String mensaje,
    required String prioridad,
    required String categoria,
    required List<int> destinatarioIds,
    required bool enviarATodos,
    String? rutaAccion,
    Map<String, dynamic>? datosAccion,
  }) async {
    await _apiProvider.enviarNotificacion(
      titulo: titulo,
      mensaje: mensaje,
      prioridad: prioridad,
      categoria: categoria,
      destinatarioIds: destinatarioIds,
      enviarATodos: enviarATodos,
      rutaAccion: rutaAccion,
      datosAccion: datosAccion,
    );
  }
}

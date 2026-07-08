import '../entities/destinatario.dart';

abstract class AdminNotificacionesRepositoryPort {
  Future<List<Destinatario>> obtenerDestinatarios({
    String? busqueda,
  });

  Future<void> enviarNotificacion({
    required String titulo,
    required String mensaje,
    required String prioridad,
    required String categoria,
    required List<int> destinatarioIds,
    required bool enviarATodos,
    String? rutaAccion,
    Map<String, dynamic>? datosAccion,
  });
}

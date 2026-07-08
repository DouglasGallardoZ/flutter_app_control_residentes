import '../providers/http_client.dart';

class AdminNotificacionesApiProvider {
  final ApiHttpClient _cliente;

  AdminNotificacionesApiProvider(this._cliente);

  Future<List<Map<String, dynamic>>> obtenerDestinatarios({
    String? busqueda,
  }) async {
    final queryParams = <String, dynamic>{};
    if (busqueda != null && busqueda.isNotEmpty) {
      queryParams['busqueda'] = busqueda;
    }
    final respuesta = await _cliente.dio.get(
      '/notificaciones/destinatarios',
      queryParameters: queryParams,
    );
    final lista = respuesta.data;
    if (lista is List) {
      return lista.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<Map<String, dynamic>> enviarNotificacion({
    required String titulo,
    required String mensaje,
    required String prioridad,
    required String categoria,
    required List<int> destinatarioIds,
    required bool enviarATodos,
    String? rutaAccion,
    Map<String, dynamic>? datosAccion,
  }) async {
    final body = {
      'titulo': titulo,
      'mensaje': mensaje,
      'prioridad': prioridad,
      'categoria': categoria,
      'destinatario_ids':
          enviarATodos ? [] : destinatarioIds,
      'enviar_a_todos': enviarATodos,
      if (rutaAccion != null) 'ruta_accion': rutaAccion,
      if (datosAccion != null)
        'datos_accion': datosAccion,
    };

    print('🔍 API PROVIDER DEBUG:');
    print('  - Body enviado: $body');

    final respuesta = await _cliente.dio.post(
      '/notificaciones/enviar',
      data: body,
    );

    print('🔍 RESPUESTA: ${respuesta.data}');
    return respuesta.data;
  }
}

import 'package:dio/dio.dart';

class ApiErrorHandler {
  static String manejar(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        final statusCode = error.response!.statusCode;
        final data = error.response!.data;

        if (data is Map) {
          if (statusCode == 422 && data.containsKey('detail')) {
            final detail = data['detail'];
            if (detail is List && detail.isNotEmpty) {
              return detail.map<String>((d) {
                var msg = d['msg']?.toString() ?? 'Error de validación';
                msg = msg
                    .replaceAll('Value error, ', '')
                    .replaceAll('Error: ', '')
                    .replaceAll('Input should be ', '');
                final loc = d['loc'] as List?;
                if (loc != null && loc.length > 1) {
                  msg = 'Error: $msg';
                }
                return msg;
              }).join('\n');
            }
            if (detail is String && detail.isNotEmpty) return detail;
          }

          if (data.containsKey('detail')) {
            final detail = data['detail'];
            if (detail is String && detail.isNotEmpty) return detail;
            if (detail is List && detail.isNotEmpty) {
              final first = detail.first;
              if (first is Map && first.containsKey('msg')) {
                return first['msg'] as String;
              }
            }
          }

          if (data.containsKey('mensaje')) {
            return '[$statusCode] ${data['mensaje']}';
          }

          if (data.containsKey('message')) {
            final msg = data['message']?.toString() ?? 'Error desconocido';
            if (msg.isNotEmpty) return msg;
          }

          if (data.containsKey('error')) {
            return data['error'] as String;
          }

          return 'Error del servidor ($statusCode)';
        }

        return error.message ?? 'Error en la solicitud';
      }

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return 'Error de conexión: tiempo de espera agotado';
        case DioExceptionType.sendTimeout:
          return 'Error de conexión: tiempo de envío agotado';
        case DioExceptionType.receiveTimeout:
          return 'Error de conexión: tiempo de respuesta agotado';
        case DioExceptionType.connectionError:
          return 'Error de conexión: no se puede conectar al servidor';
        case DioExceptionType.cancel:
          return 'Solicitud cancelada';
        default:
          return error.message ?? 'Error de conexión';
      }
    }
    return error.toString();
  }
}

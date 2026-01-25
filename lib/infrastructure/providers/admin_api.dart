import 'package:dio/dio.dart';

class AdminApi {
  final Dio dio;

  AdminApi(this.dio);

  /// Método auxiliar para extraer errores detallados de la respuesta API
  String _extractErrorMessage(dynamic error) {
    if (error is DioException && error.response != null) {
      final data = error.response?.data;
      if (data is Map) {
        // Intenta extraer el field 'detail' primero
        if (data.containsKey('detail')) {
          final detail = data['detail'];
          if (detail is String) return detail;
          if (detail is List && detail.isNotEmpty) {
            final firstItem = detail.first;
            if (firstItem is Map && firstItem.containsKey('msg')) {
              return firstItem['msg'];
            }
          }
        }
        // Si hay 'message', usa eso
        if (data.containsKey('message')) {
          return data['message'] ?? 'Error desconocido';
        }
      }
      return error.message ?? 'Error en la solicitud';
    }
    return error.toString();
  }

  /// Obtener métricas del dashboard del administrador (MOCK)
  /// Nota: Backend aún no implementa endpoint de métricas
  /// Por ahora retorna datos ficticios para demostración
  Future<Map<String, dynamic>> getAdminMetrics() async {
    try {
      // TODO: Cuando el backend implemente /api/v1/admin/metrics, usar:
      // final response = await dio.get('/admin/metrics');
      // return response.data ?? {};
      
      // Por ahora retornamos datos mock
      return _generateMockMetrics();
    } catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Obtener lista de residentes (usando endpoint documentado)
  Future<List<dynamic>> getResidents({
    int page = 1,
    int pageSize = 20,
    String? searchQuery,
    String? statusFilter,
  }) async {
    try {
      // Endpoint documentado: GET /api/v1/residentes?page=1&page_size=20
      final queryParams = {
        'page': page,
        'page_size': pageSize,
        if (searchQuery != null) 'search': searchQuery,
      };
      final response = await dio.get(
        '/residentes',
        queryParameters: queryParams,
      );
      return response.data ?? [];
    } catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Obtener residentes por ubicación (manzana y villa)
  /// Endpoint: GET /api/v1/residentes/manzana-villa/{manzana}/{villa}
  Future<List<dynamic>> getResidentsByLocation({
    required String manzana,
    required String villa,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'page_size': pageSize,
      };
      final response = await dio.get(
        '/residentes/manzana-villa/$manzana/$villa',
        queryParameters: queryParams,
      );
      return response.data?['residentes'] ?? [];
    } catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Obtener lista de miembros de familia (usando endpoint documentado)
  Future<List<dynamic>> getFamilyMembers({
    int page = 1,
    int pageSize = 20,
    String? searchQuery,
  }) async {
    try {
      // Endpoint documentado: GET /api/v1/miembros-familia?page=1&page_size=20
      final queryParams = {
        'page': page,
        'page_size': pageSize,
        if (searchQuery != null) 'search': searchQuery,
      };
      final response = await dio.get(
        '/miembros-familia',
        queryParameters: queryParams,
      );
      return response.data ?? [];
    } catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Obtener miembros de familia por vivienda
  /// Endpoint: GET /api/v1/miembros/{vivienda_id}
  Future<List<dynamic>> getFamilyMembersByVivienda({
    required int viviendaId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'page_size': pageSize,
      };
      final response = await dio.get(
        '/miembros/$viviendaId',
        queryParameters: queryParams,
      );
      return response.data?['miembros'] ?? [];
    } catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Obtener miembros de familia por ubicación (manzana y villa)
  /// Endpoint: GET /api/v1/miembros-familia/manzana-villa/{manzana}/{villa}
  Future<List<dynamic>> getFamilyMembersByLocation({
    required String manzana,
    required String villa,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await dio.get(
        '/miembros/manzana-villa/$manzana/$villa',
      );
      return response.data?['miembros'] ?? [];
    } catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Obtener lista de propietarios (usando endpoint documentado)
  Future<List<dynamic>> getOwners({
    int page = 1,
    int pageSize = 20,
    String? searchQuery,
  }) async {
    try {
      // Endpoint documentado: GET /api/v1/propietarios?page=1&page_size=20
      final queryParams = {
        'page': page,
        'page_size': pageSize,
        if (searchQuery != null) 'search': searchQuery,
      };
      final response = await dio.get(
        '/propietarios',
        queryParameters: queryParams,
      );
      return response.data ?? [];
    } catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Obtener propietarios por ubicación (manzana y villa)
  /// Endpoint: GET /api/v1/propietarios/manzana-villa/{manzana}/{villa}
  Future<List<dynamic>> getOwnersByLocation({
    required String manzana,
    required String villa,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'page_size': pageSize,
      };
      final response = await dio.get(
        '/propietarios/manzana-villa/$manzana/$villa',
        queryParameters: queryParams,
      );
      return response.data?['propietarios'] ?? [];
    } catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Obtener usuario por correo electrónico
  /// Endpoint: GET /api/v1/cuentas/usuario/por-correo/{correo}
  Future<Map<String, dynamic>> getUserByEmail({
    required String correo,
  }) async {
    try {
      final response = await dio.get(
        '/cuentas/usuario/por-correo/$correo',
      );
      return response.data ?? {};
    } catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Obtener usuarios de una vivienda por manzana y villa
  /// Endpoint: GET /api/v1/vivienda/{manzana}/{villa}/usuarios
  Future<List<dynamic>> getUsersByVivienda({
    required String manzana,
    required String villa,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await dio.get(
        '/cuentas/vivienda/$manzana/$villa/usuarios',
      );
      return response.data?['usuarios'] ?? [];
    } catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Cambiar estado de una cuenta (MOCK - endpoint no existe)
  /// Nota: No hay endpoint POST para cambiar estado, se usa bloquear/desbloquear
  Future<void> updateAccountStatus(int personaId, String newStatus) async {
    try {
      // Alternativamente usar bloquear/desbloquear según newStatus
      await Future.delayed(const Duration(milliseconds: 500)); // Simular delay
    } catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Bloquear una cuenta (Endpoint documentado: POST /cuentas/{cuenta_id}/bloquear)
  /// Requiere: usuario_actualizado, motivo, cascada (opcional)
  Future<Map<String, dynamic>> blockAccount(
    int cuentaId,
    String reason, {
    String usuarioActualizado = 'admin_system',
    bool cascada = true,
  }) async {
    try {
      final response = await dio.post(
        '/cuentas/$cuentaId/bloquear',
        data: {
          'usuario_actualizado': usuarioActualizado,
          'motivo': reason,
          'cascada': cascada,
        },
      );
      return response.data ?? {};
    } catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Desbloquear una cuenta (Endpoint documentado: POST /cuentas/{cuenta_id}/desbloquear)
  /// Requiere: usuario_actualizado, motivo, cascada (opcional)
  Future<Map<String, dynamic>> unblockAccount(
    int cuentaId, 
    String reason,{
    String usuarioActualizado = 'admin_system',
    bool cascada = true,
  }) async {
    try {
      final response = await dio.post(
        '/cuentas/$cuentaId/desbloquear',
        data: {
          'usuario_actualizado': usuarioActualizado,
          'motivo': reason,
          'cascada': cascada,
        },
      );
      return response.data ?? {};
    } catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Eliminar una cuenta (Endpoint documentado: DELETE /cuentas/{cuenta_id})
  /// Soft delete - marca como eliminada
  Future<Map<String, dynamic>> deleteAccount(
    int cuentaId, {
    String usuarioActualizado = 'admin_system',
    String reason = 'Solicitud de eliminación de datos',
  }) async {
    try {
      final response = await dio.delete(
        '/cuentas/$cuentaId',
        data: {
          'motivo': reason,
          'usuario_actualizado': usuarioActualizado,
        },
      );
      return response.data ?? {};
    } catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Obtener detalles de una cuenta por Firebase UID
  /// Endpoint documentado: GET /cuentas/perfil/{firebase_uid}
  Future<Map<String, dynamic>> getAccountDetails(int firebaseUid) async {
    try {
      final response = await dio.get('/cuentas/perfil/$firebaseUid');
      return response.data ?? {};
    } catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Desactivar un residente (Endpoint: POST /residentes/{residente_id}/desactivar)
  /// Requiere: motivo de desactivación
  Future<Map<String, dynamic>> deactivateResident(
    int residenteId,
    String reason, {
    String usuarioActualizado = 'admin_system',
  }) async {
    try {
      final response = await dio.post(
        '/residentes/$residenteId/desactivar',
        data: {
          'motivo': reason,
          'usuario_actualizado': usuarioActualizado,
        },
      );
      return response.data ?? {};
    } catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Reactivar un residente (Endpoint: POST /residentes/{residente_id}/reactivar)
  /// Requiere: motivo de reactivación
  Future<Map<String, dynamic>> reactivateResident(
    int residenteId,
    String reason, {
    String usuarioActualizado = 'admin_system',
  }) async {
    try {
      final response = await dio.post(
        '/residentes/$residenteId/reactivar',
        data: {
          'motivo': reason,
          'usuario_actualizado': usuarioActualizado,
        },
      );
      return response.data ?? {};
    } catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Registrar un nuevo residente (Endpoint: POST /residentes)
  /// Body request directo con manzana y villa
  /// 
  /// Ejemplo de body:
  /// {
  ///   "identificacion": "1234567890",
  ///   "tipo_identificacion": "CC",
  ///   "nombres": "Juan",
  ///   "apellidos": "García",
  ///   "fecha_nacimiento": "1990-01-15",
  ///   "nacionalidad": "Colombiana",
  ///   "correo": "juan@mail.com",
  ///   "celular": "3001234567",
  ///   "direccion_alternativa": "Carrera 10",
  ///   "manzana": "A",
  ///   "villa": "101",
  ///   "usuario_creado": "admin_001",
  ///   "doc_autorizacion_pdf": "ruta/documento.pdf"
  /// }
  Future<Map<String, dynamic>> createResident({
    required String identificacion,
    required String tipoIdentificacion,
    required String nombres,
    required String apellidos,
    required String fechaNacimiento,
    required String correo,
    required String celular,
    required String manzana,
    required String villa,
    String? nacionalidad,
    String? direccionAlternativa,
    String? docAutorizacionPdf,
    String? usuarioCreado,
  }) async {
    try {
      final requestBody = {
        'identificacion': identificacion,
        'tipo_identificacion': tipoIdentificacion,
        'nombres': nombres,
        'apellidos': apellidos,
        'fecha_nacimiento': fechaNacimiento,
        'correo': correo,
        'celular': celular,
        'manzana': manzana,
        'villa': villa,
        if (nacionalidad != null && nacionalidad.isNotEmpty) 'nacionalidad': nacionalidad,
        if (direccionAlternativa != null && direccionAlternativa.isNotEmpty)
          'direccion_alternativa': direccionAlternativa,
        if (docAutorizacionPdf != null && docAutorizacionPdf.isNotEmpty)
          'doc_autorizacion_pdf': docAutorizacionPdf,
        'usuario_creado': usuarioCreado ?? 'admin_system',
      };

      final response = await dio.post(
        '/residentes',
        data: requestBody,
      );
      return response.data ?? {};
    } catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Dar de baja a un propietario (Endpoint: POST /propietarios/{propietario_id}/baja)
  /// Requiere: motivo de baja
  Future<Map<String, dynamic>> deactivateOwner(
    int propietarioId,
    String reason, {
    String usuarioActualizado = 'admin_system',
  }) async {
    try {
      final response = await dio.post(
        '/propietarios/$propietarioId/baja',
        data: {
          'motivo': reason,
          'usuario_actualizado': usuarioActualizado,
        },
      );
      return response.data ?? {};
    } catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Bloquear un propietario (Endpoint: POST /propietarios/{propietario_id}/baja)
  /// Requiere: motivo de bloqueo
  Future<Map<String, dynamic>> blockOwner(
    int propietarioId,
    String reason, {
    String usuarioActualizado = 'admin_system',
  }) async {
    try {
      final response = await dio.post(
        '/propietarios/$propietarioId/baja',
        data: {
          'motivo': reason,
          'usuario_actualizado': usuarioActualizado,
        },
      );
      return response.data ?? {};
    } catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Desbloquear un propietario (Endpoint: POST /propietarios/{propietario_id}/desbloquear)
  /// Requiere: motivo de desbloqueo
  Future<Map<String, dynamic>> unblockOwner(
    int propietarioId,
    String reason, {
    String usuarioActualizado = 'admin_system',
  }) async {
    try {
      final response = await dio.post(
        '/propietarios/$propietarioId/desbloquear',
        data: {
          'motivo': reason,
          'usuario_actualizado': usuarioActualizado,
        },
      );
      return response.data ?? {};
    } catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Eliminar un propietario (Endpoint: DELETE /propietarios/{propietario_id})
  /// Soft delete - marca como eliminada
  Future<Map<String, dynamic>> deleteOwner(
    int propietarioId, {
    String usuarioActualizado = 'admin_system',
    String reason = 'Solicitud de eliminación de datos',
  }) async {
    try {
      final response = await dio.delete(
        '/propietarios/$propietarioId',
        data: {
          'motivo': reason,
          'usuario_actualizado': usuarioActualizado,
        },
      );
      return response.data ?? {};
    } catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Desactivar un miembro de familia (Endpoint: POST /miembros/{miembro_id}/desactivar)
  /// Requiere: motivo de desactivación
  Future<Map<String, dynamic>> deactivateMember(
    int miembroId,
    String reason, {
    String usuarioActualizado = 'admin_system',
  }) async {
    try {
      final response = await dio.post(
        '/miembros/$miembroId/desactivar',
        data: {
          'motivo': reason,
          'usuario_actualizado': usuarioActualizado,
        },
      );
      return response.data ?? {};
    } catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Reactivar un miembro de familia (Endpoint: POST /miembros/{miembro_id}/reactivar)
  /// Requiere: motivo de reactivación
  Future<Map<String, dynamic>> reactivateMember(
    int miembroId,
    String reason, {
    String usuarioActualizado = 'admin_system',
  }) async {
    try {
      final response = await dio.post(
        '/miembros/$miembroId/reactivar',
        data: {
          'motivo': reason,
          'usuario_actualizado': usuarioActualizado,
        },
      );
      return response.data ?? {};
    } catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Enroll facial data para residente/miembro
  /// Servicio de biometría en puerto 8000
  /// Endpoint: POST /enroll
  /// FormData: user_id (personaId), images (lista de archivos), usuario_creado
  Future<Map<String, dynamic>> enrollFacialData({
    required String personaId,
    required List<String> imagenesRutas,
    String? usuarioCreado,
  }) async {
    try {
      final formData = FormData();
      
      // Agregar persona ID como persona_id
      formData.fields.add(MapEntry('persona_id', personaId));
      
      // Agregar usuario_creado para auditoría
      formData.fields.add(MapEntry('usuario_creado', usuarioCreado ?? 'flutter_app'));
      
      // Agregar cada imagen
      for (int i = 0; i < imagenesRutas.length; i++) {
        final archivo = await MultipartFile.fromFile(
          imagenesRutas[i],
          filename: 'face_$i.jpg',
        );
        formData.files.add(MapEntry('images', archivo));
      }

      // Obtener la URL base y reemplazar el puerto por 8000 para biometría
      final dioBaseUrl = dio.options.baseUrl;
      final biometryUrl = dioBaseUrl.replaceAll(RegExp(r':\d+'), ':8000');

      final response = await dio.post(
        '$biometryUrl/enroll',
        data: formData,
      );
      return response.data ?? {};
    } catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Generar datos ficticios para métricas
  /// TODO: Reemplazar con /api/v1/admin/metrics cuando backend lo implemente
  Map<String, dynamic> _generateMockMetrics() {
    return {
      'total_access': 156,
      'successful_access': 150,
      'denied_access': 6,
      'visitors': 12,
      'recent_activity': [
        {
          'person_name': 'María Rodríguez',
          'person_role': 'residente',
          'access_type': 'own',
          'related_person': '',
          'timestamp': DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String(),
          'entry_point': 'Entrada Principal',
          'status': 'success',
        },
        {
          'person_name': 'Ana García',
          'person_role': 'visitante',
          'access_type': 'visitor',
          'related_person': 'María Rodríguez',
          'timestamp': DateTime.now().subtract(const Duration(minutes: 10)).toIso8601String(),
          'entry_point': 'Entrada Principal',
          'status': 'success',
        },
        {
          'person_name': 'Juan Rodríguez',
          'person_role': 'residente',
          'access_type': 'own',
          'related_person': '',
          'timestamp': DateTime.now().subtract(const Duration(minutes: 15)).toIso8601String(),
          'entry_point': 'Entrada Lateral',
          'status': 'success',
        },
        {
          'person_name': 'Carlos López',
          'person_role': 'visitante',
          'access_type': 'visitor',
          'related_person': 'Juan Rodríguez',
          'timestamp': DateTime.now().subtract(const Duration(minutes: 25)).toIso8601String(),
          'entry_point': 'Entrada Principal',
          'status': 'denied',
        },
      ],
    };
  }

  /// Crear un nuevo propietario
  /// Endpoint: POST /api/v1/propietarios
  Future<Map<String, dynamic>> createOwner({
    required String identificacion,
    required String tipoIdentificacion,
    required String nombres,
    required String apellidos,
    required String fechaNacimiento,
    required String correo,
    required String celular,
    required String manzana,
    required String villa,
    String? nacionalidad,
    String? direccionAlternativa,
    String? usuarioCreado,
  }) async {
    try {
      final requestBody = {
        'identificacion': identificacion,
        'tipo_identificacion': tipoIdentificacion,
        'nombres': nombres,
        'apellidos': apellidos,
        'fecha_nacimiento': fechaNacimiento,
        'correo': correo,
        'celular': celular,
        'manzana': manzana,
        'villa': villa,
        if (nacionalidad != null && nacionalidad.isNotEmpty) 'nacionalidad': nacionalidad,
        if (direccionAlternativa != null && direccionAlternativa.isNotEmpty)
          'direccion_alternativa': direccionAlternativa,
        'usuario_creado': usuarioCreado ?? 'admin_system',
      };

      final response = await dio.post(
        '/propietarios',
        data: requestBody,
      );
      return response.data ?? {};
    } catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Agregar miembro de familia a un residente
  /// Endpoint: POST /api/v1/miembros/agregar
  Future<Map<String, dynamic>> addFamilyMember({
    required String residenteId,
    required String identificacion,
    required String tipoIdentificacion,
    required String nombres,
    required String apellidos,
    required String fechaNacimiento,
    required String manzana,
    required String villa,
    required String parentesco,
    String? nacionalidad,
    String? correo,
    String? celular,
    String? direccionAlternativa,
    String? parentescoOtroDesc,
    String? usuarioCreado,
  }) async {
    try {
      final requestBody = {
        'identificacion_residente': residenteId,
        'manzana': manzana,
        'villa': villa,
        'identificacion': identificacion,
        'tipo_identificacion': tipoIdentificacion,
        'nombres': nombres,
        'apellidos': apellidos,
        'fecha_nacimiento': fechaNacimiento,
        'parentesco': parentesco,
        if (nacionalidad != null && nacionalidad.isNotEmpty) 'nacionalidad': nacionalidad,
        if (correo != null && correo.isNotEmpty) 'correo': correo,
        if (celular != null && celular.isNotEmpty) 'celular': celular,
        if (direccionAlternativa != null && direccionAlternativa.isNotEmpty)
          'direccion_alternativa': direccionAlternativa,
        if (parentesco == 'otro' && parentescoOtroDesc != null && parentescoOtroDesc.isNotEmpty)
          'parentesco_otro_desc': parentescoOtroDesc,
        'usuario_creado': usuarioCreado ?? 'admin_system',
      };

      final response = await dio.post(
        '/miembros/agregar',
        data: requestBody,
      );
      return response.data ?? {};
    } catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }
}

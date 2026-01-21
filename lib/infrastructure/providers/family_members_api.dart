// lib/infrastructure/providers/family_members_api.dart

import 'package:dio/dio.dart';
import '../dtos/miembro_familia_dto.dart';

class FamilyMembersApi {
  final Dio dio;

  FamilyMembersApi(this.dio);

  /// Obtener miembros de familia por vivienda_id
  /// GET /api/v1/miembros/{vivienda_id}
  Future<List<MiembroFamiliaDTO>> obtenerMiembrosPorVivienda(int viviendaId) async {
    try {
      final response = await dio.get('/miembros/$viviendaId');
      final data = response.data;
      
      List<Map<String, dynamic>> miembrosData = [];
      
      // Si la respuesta es un mapa con una lista dentro
      if (data is Map<String, dynamic>) {
        if (data['miembros'] is List) {
          miembrosData = List<Map<String, dynamic>>.from(data['miembros']);
        }
        // Si la respuesta es un mapa con resultado
        else if (data['resultado'] is List) {
          miembrosData = List<Map<String, dynamic>>.from(data['resultado']);
        }
      }
      
      // Si la respuesta es directamente una lista
      else if (data is List) {
        miembrosData = List<Map<String, dynamic>>.from(data);
      }
      
      // Convertir Maps a DTOs
      return miembrosData.map((m) => MiembroFamiliaDTO.fromJson(m)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener miembros activos de familia por vivienda_id
  /// Filtra automáticamente por estado = 'activo'
  Future<List<MiembroFamiliaDTO>> obtenerMiembrosActivosPorVivienda(int viviendaId) async {
    try {
      final miembros = await obtenerMiembrosPorVivienda(viviendaId);
      return miembros.where((m) => m.estado == 'activo').toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Contar miembros activos de familia por vivienda_id
  Future<int> contarMiembrosActivosPorVivienda(int viviendaId) async {
    try {
      final miembros = await obtenerMiembrosActivosPorVivienda(viviendaId);
      return miembros.length;
    } catch (e) {
      rethrow;
    }
  }
}

import '../../domain/entities/qr_code.dart';
import '../../domain/ports/qr_repository.dart';
import '../providers/qr_api.dart';
import '../dtos/qr_dto.dart';

class QrRepositoryImpl implements QrRepository {
  final QrApi qrApi;

  QrRepositoryImpl(this.qrApi);

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$year-$month-$day';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Future<QrCode> generateSelf({
    required int personaId,
    required DateTime validFrom,
    required int durationHours,
    int? maxUses,
  }) async {
    try {

      final response = await qrApi.generarQRPropio(
        personaId: personaId,
        duracionHoras: durationHours,
        fechaAcceso: _formatDate(validFrom),
        horaInicio: _formatTime(validFrom),
      );

      final qrDTO = QRResponseDTO.fromJson(response);

      return QrCode(
        value: qrDTO.token,
        createdAt: qrDTO.fechaCreado,
        validFrom: qrDTO.horaInicio,
        expiresAt: qrDTO.horaFin,
        durationHours: durationHours,
        maxUses: maxUses,
        type: 'propio',
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<QrCode> generateVisit({
    required int personaId,
    required String visitorId,
    required String visitorName,
    required DateTime validFrom,
    required int durationHours,
    int? maxUses,
  }) async {
    try {
      // Separar nombres y apellidos (asumiendo formato "Nombres Apellidos")
      final parts = visitorName.split(' ');
      final nombres = parts.isNotEmpty ? parts.first : visitorName;
      final apellidos = parts.length > 1 ? parts.sublist(1).join(' ') : '';

      final response = await qrApi.generarQRVisita(
        personaId: personaId,
        visitaIdentificacion: visitorId,
        visitaNombres: nombres,
        visitaApellidos: apellidos,
        motivoVisita: 'Visita',
        duracionHoras: durationHours,
        fechaAcceso: _formatDate(validFrom),
        horaInicio: _formatTime(validFrom),
      );

      final qrDTO = QRResponseDTO.fromJson(response);

      return QrCode(
        value: qrDTO.token,
        createdAt: qrDTO.fechaCreado,
        validFrom: qrDTO.horaInicio,
        expiresAt: qrDTO.horaFin,
        durationHours: durationHours,
        maxUses: maxUses,
        type: 'visita',
      );
    } catch (e) {
      rethrow;
    }
  }
}

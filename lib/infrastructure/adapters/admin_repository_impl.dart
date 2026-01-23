import '../../domain/entities/admin_metrics.dart';
import '../../domain/entities/account.dart';
import '../../domain/ports/admin_repository.dart';
import '../providers/admin_api.dart';
import '../dtos/admin_metrics_dto.dart';
import '../dtos/perfil_usuario_dto.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminApi adminApi;

  AdminRepositoryImpl(this.adminApi);

  @override
  Future<AdminMetrics> getAdminMetrics() async {
    try {
      // Obtener métricas ficticias (backend aún no implementa)
      final response = await adminApi.getAdminMetrics();
      final adminMetricsDTO = AdminMetricsDTO.fromJson(response);
      return _dtoToEntity(adminMetricsDTO);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Account>> getResidents({
    int page = 1,
    int pageSize = 20,
    String? searchQuery,
    String? statusFilter,
  }) async {
    try {
      // Usar endpoint documentado: GET /api/v1/residentes
      final response = await adminApi.getResidents(
        page: page,
        pageSize: pageSize,
        searchQuery: searchQuery,
        statusFilter: statusFilter,
      );

      final residents = (response)
          .map((item) => PerfilUsuarioDTO.fromJson(item as Map<String, dynamic>))
          .map((dto) => _residentDtoToAccount(dto))
          .toList();

      return residents;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Account>> getFamilyMembers({
    int page = 1,
    int pageSize = 20,
    String? searchQuery,
  }) async {
    try {
      // Usar endpoint documentado: GET /api/v1/miembros-familia
      final response = await adminApi.getFamilyMembers(
        page: page,
        pageSize: pageSize,
        searchQuery: searchQuery,
      );

      final members = (response)
          .map((item) => PerfilUsuarioDTO.fromJson(item as Map<String, dynamic>))
          .map((dto) => _residentDtoToAccount(dto))
          .toList();

      return members;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Account>> getOwners({
    int page = 1,
    int pageSize = 20,
    String? searchQuery,
  }) async {
    try {
      // Usar endpoint documentado: GET /api/v1/propietarios
      final response = await adminApi.getOwners(
        page: page,
        pageSize: pageSize,
        searchQuery: searchQuery,
      );

      final owners = (response)
          .map((item) => PerfilUsuarioDTO.fromJson(item as Map<String, dynamic>))
          .map((dto) => _residentDtoToAccount(dto))
          .toList();

      return owners;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateAccountStatus(int personaId, String newStatus) async {
    try {
      // Endpoint no documentado aún - usar mock
      await adminApi.updateAccountStatus(personaId, newStatus);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> blockAccount(int personaId, String reason) async {
    try {
      // Endpoint no documentado aún - usar mock
      await adminApi.blockAccount(personaId, reason);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> unblockAccount(int personaId, String reason) async {
    try {
      // Endpoint no documentado aún - usar mock
      await adminApi.unblockAccount(personaId, reason);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteAccount(int personaId) async {
    try {
      // Endpoint no documentado aún - usar mock
      await adminApi.deleteAccount(personaId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Account> getAccountDetails(int personaId) async {
    try {
      // Endpoint no documentado aún - usar mock
      final response = await adminApi.getAccountDetails(personaId);
      final dto = PerfilUsuarioDTO.fromJson(response);
      return _residentDtoToAccount(dto);
    } catch (e) {
      rethrow;
    }
  }

  /// Convierte AdminMetricsDTO a AdminMetrics entity
  AdminMetrics _dtoToEntity(AdminMetricsDTO dto) {
    return AdminMetrics(
      totalAccess: dto.totalAccess,
      successfulAccess: dto.successfulAccess,
      deniedAccess: dto.deniedAccess,
      visitors: dto.visitors,
      recentActivity: dto.recentActivity
          .map((activity) => RecentActivity(
                personName: activity.personName,
                personRole: activity.personRole,
                accessType: activity.accessType,
                relatedPerson: activity.relatedPerson,
                timestamp: activity.timestamp,
                entryPoint: activity.entryPoint,
                isSuccessful: activity.status == 'success',
              ))
          .toList(),
    );
  }

  /// Convierte PerfilUsuarioDTO a Account entity
  Account _residentDtoToAccount(PerfilUsuarioDTO dto) {
    final vivienda = dto.vivienda ?? ViviendaDTO(viviendaId: null, manzana: '', villa: '');

    return Account(
      firebaseUid: '',
      personaId: dto.personaId ?? 0,
      identificacion: dto.identificacion ?? '',
      nombres: dto.nombres,
      apellidos: dto.apellidos,
      rol: dto.rol,
      estado: dto.estado,
      correo: dto.correo,
      celular: dto.celular,
      parentesco: dto.parentesco,
      vivienda: Vivienda(
        viviendaId: vivienda.viviendaId ?? 0,
        manzana: vivienda.manzana,
        villa: vivienda.villa,
      ),
      fechaCreado: DateTime.now(),
    );
  }
}

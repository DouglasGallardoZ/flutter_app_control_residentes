import '../../domain/entities/admin_metrics.dart';
import '../../domain/entities/account.dart';
import '../../domain/ports/admin_repository.dart';
import '../../domain/ports/metrics/admin_metrics_api_port.dart';
import '../../domain/ports/person_management/resident_api_port.dart';
import '../../domain/ports/person_management/owner_api_port.dart';
import '../../domain/ports/person_management/family_member_api_port.dart';
import '../../domain/ports/account_management/account_management_api_port.dart';
import '../dtos/admin_metrics_dto.dart';
import '../dtos/perfil_usuario_dto.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminMetricsApiPort metricsApi;
  final ResidentApiPort residentApi;
  final OwnerApiPort ownerApi;
  final FamilyMemberApiPort familyMemberApi;
  final AccountManagementApiPort accountManagementApi;

  AdminRepositoryImpl({
    required this.metricsApi,
    required this.residentApi,
    required this.ownerApi,
    required this.familyMemberApi,
    required this.accountManagementApi,
  });

  @override
  Future<AdminMetrics> getAdminMetrics({
    String? fechaInicio,
    String? fechaFin,
  }) async {
    try {
      final response = await metricsApi.getAdminMetrics(
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
      );
      final adminMetricsDTO = AdminMetricsDTO.fromJson(response);
      return _dtoToEntity(adminMetricsDTO);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getAccessHistory({
    int page = 1,
    int pageSize = 50,
    String? fechaInicio,
    String? fechaFin,
    String? tipo,
    String? resultado,
  }) async {
    try {
      final response = await metricsApi.getAccessHistory(
        page: page,
        pageSize: pageSize,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
        tipo: tipo,
        resultado: resultado,
      );
      return response;
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
      final response = await residentApi.getResidents(
        page: page,
        pageSize: pageSize,
        searchQuery: searchQuery,
        statusFilter: statusFilter,
      );

      final residents = (response)
          .map(
              (item) => PerfilUsuarioDTO.fromJson(item as Map<String, dynamic>))
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
      final response = await familyMemberApi.getFamilyMembers(
        page: page,
        pageSize: pageSize,
        searchQuery: searchQuery,
      );

      final members = (response)
          .map(
              (item) => PerfilUsuarioDTO.fromJson(item as Map<String, dynamic>))
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
      final response = await ownerApi.getOwners(
        page: page,
        pageSize: pageSize,
        searchQuery: searchQuery,
      );

      final owners = (response)
          .map(
              (item) => PerfilUsuarioDTO.fromJson(item as Map<String, dynamic>))
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
      await accountManagementApi.updateAccountStatus(personaId, newStatus);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> blockAccount(int personaId, String reason) async {
    try {
      // Endpoint no documentado aún - usar mock
      await accountManagementApi.blockAccount(personaId, reason);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> unblockAccount(int personaId, String reason) async {
    try {
      // Endpoint no documentado aún - usar mock
      await accountManagementApi.unblockAccount(personaId, reason);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteAccount(int personaId) async {
    try {
      // Endpoint no documentado aún - usar mock
      await accountManagementApi.deleteAccount(personaId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Account> getAccountDetails(int personaId) async {
    try {
      // Endpoint no documentado aún - usar mock
      final response = await accountManagementApi.getAccountDetails(personaId);
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
    // Usar el método toEntity del DTO con un firebaseUid vacío para compatibilidad
    return dto.toEntity('');
  }
}

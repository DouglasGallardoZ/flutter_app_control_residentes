import '../entities/admin_metrics.dart';
import '../entities/account.dart';

abstract class AdminRepository {
  /// Obtiene las métricas del dashboard del administrador
  Future<AdminMetrics> getAdminMetrics();

  /// Obtiene lista de residentes con filtros opcionales
  Future<List<Account>> getResidents({
    int page = 1,
    int pageSize = 20,
    String? searchQuery,
    String? statusFilter, // 'activo', 'inactivo'
  });

  /// Obtiene lista de miembros de familia
  Future<List<Account>> getFamilyMembers({
    int page = 1,
    int pageSize = 20,
    String? searchQuery,
  });

  /// Obtiene lista de propietarios
  Future<List<Account>> getOwners({
    int page = 1,
    int pageSize = 20,
    String? searchQuery,
  });

  /// Cambia el estado de una cuenta
  Future<void> updateAccountStatus(int personaId, String newStatus);

  /// Bloquea una cuenta
  Future<void> blockAccount(int personaId, String reason);

  /// Desbloquea una cuenta
  Future<void> unblockAccount(int personaId, String reason);

  /// Elimina una cuenta (soft delete)
  Future<void> deleteAccount(int personaId);

  /// Obtiene detalles de una cuenta específica
  Future<Account> getAccountDetails(int personaId);
}

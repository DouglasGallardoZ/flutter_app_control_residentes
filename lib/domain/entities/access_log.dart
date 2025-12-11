class AccessLog {
  final String personId;
  final String personName;
  final String roleLabel;
  final DateTime timestamp;
  final bool success;
  final String? reason;
  final String? referencedBy;

  AccessLog({
    required this.personId,
    required this.personName,
    required this.roleLabel,
    required this.timestamp,
    required this.success,
    this.reason,
    this.referencedBy,
  });

  factory AccessLog.fromMap(Map<String, dynamic> m) => AccessLog(
        personId: m['personId'],
        personName: m['personName'] ?? '',
        roleLabel: m['roleLabel'] ?? 'residente',
        timestamp: DateTime.parse(m['timestamp']),
        success: m['success'] ?? false,
        reason: m['reason'],
        referencedBy: m['referencedBy'],
      );

  /// ✅ Nuevo getter para mostrar detalle
  String get detailMessage {
    if (success) return 'Acceso exitoso';
    return 'Acceso rechazado: ${reason ?? 'motivo desconocido'}';
  }
}

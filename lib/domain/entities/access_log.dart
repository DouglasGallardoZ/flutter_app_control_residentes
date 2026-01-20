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

  factory AccessLog.fromMap(Map<String, dynamic> map) => AccessLog(
        personId: map['personId'],
        personName: map['personName'] ?? '',
        roleLabel: map['roleLabel'] ?? 'residente',
        timestamp: DateTime.parse(map['timestamp']),
        success: map['success'] ?? false,
        reason: map['reason'],
        referencedBy: map['referencedBy'],
      );

  /// getter para mostrar detalle
  String get detailMessage {
    if (success) return 'Acceso exitoso';
    return 'Acceso rechazado: ${reason ?? 'motivo desconocido'}';
  }
}

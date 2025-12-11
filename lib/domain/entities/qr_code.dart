class QrCode {
  final String value; // contenido QR (string)
  final DateTime createdAt;
  final DateTime? expiresAt;
  final int? maxUses;
  final String type; // self | visit

  QrCode({
    required this.value,
    required this.createdAt,
    this.expiresAt,
    this.maxUses,
    required this.type,
  });

  factory QrCode.fromMap(Map<String, dynamic> m) => QrCode(
        value: m['value'],
        createdAt: DateTime.parse(m['createdAt']),
        expiresAt: m['expiresAt'] != null ? DateTime.parse(m['expiresAt']) : null,
        maxUses: m['maxUses'],
        type: m['type'],
      );

  Map<String, dynamic> toMap() => {
        'value': value,
        'createdAt': createdAt.toIso8601String(),
        'expiresAt': expiresAt?.toIso8601String(),
        'maxUses': maxUses,
        'type': type,
      };
}

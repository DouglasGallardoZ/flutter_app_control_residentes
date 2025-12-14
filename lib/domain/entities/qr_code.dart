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

  factory QrCode.fromMap(Map<String, dynamic> map) => QrCode(
        value: map['value'],
        createdAt: DateTime.parse(map['createdAt']),
        expiresAt: map['expiresAt'] != null ? DateTime.parse(map['expiresAt']) : null,
        maxUses: map['maxUses'],
        type: map['type'],
      );

  Map<String, dynamic> toMap() => {
        'value': value,
        'createdAt': createdAt.toIso8601String(),
        'expiresAt': expiresAt?.toIso8601String(),
        'maxUses': maxUses,
        'type': type,
      };
}

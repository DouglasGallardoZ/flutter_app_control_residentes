class QrCode {
  final String value;
  final DateTime createdAt;
  final DateTime validFrom;
  final DateTime expiresAt;
  final int? durationHours;
  final int? maxUses;
  final String type; // self | visit
  const QrCode({
    required this.value,
    required this.createdAt,
    required this.validFrom,
    required this.expiresAt,
    this.durationHours,
    this.maxUses,
    required this.type,
  });
}

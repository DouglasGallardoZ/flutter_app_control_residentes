class Visit {
  final String id;
  final String residentId;
  final String visitorName;
  final DateTime visitDate;
  final String motivo;
  final String qrCode;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Visit({
    required this.id,
    required this.residentId,
    required this.visitorName,
    required this.visitDate,
    required this.motivo,
    required this.qrCode,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'residentId': residentId,
    'visitorName': visitorName,
    'visitDate': visitDate.toIso8601String(),
    'motivo': motivo,
    'qrCode': qrCode,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Visit.fromJson(Map<String, dynamic> json) => Visit(
    id: json['id'] as String,
    residentId: json['residentId'] as String,
    visitorName: json['visitorName'] as String,
    visitDate: DateTime.parse(json['visitDate'] as String),
    motivo: json['motivo'] as String,
    qrCode: json['qrCode'] as String,
    status: json['status'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  Visit copyWith({
    String? id,
    String? residentId,
    String? visitorName,
    DateTime? visitDate,
    String? motivo,
    String? qrCode,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Visit(
    id: id ?? this.id,
    residentId: residentId ?? this.residentId,
    visitorName: visitorName ?? this.visitorName,
    visitDate: visitDate ?? this.visitDate,
    motivo: motivo ?? this.motivo,
    qrCode: qrCode ?? this.qrCode,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}

class AccessEvent {
  final String id;
  final String? userId;
  final String? visitId;
  final String eventType;
  final String accessMethod;
  final DateTime timestamp;
  final bool isAuthorized;
  final String? notes;

  AccessEvent({
    required this.id,
    this.userId,
    this.visitId,
    required this.eventType,
    required this.accessMethod,
    required this.timestamp,
    required this.isAuthorized,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'visitId': visitId,
    'eventType': eventType,
    'accessMethod': accessMethod,
    'timestamp': timestamp.toIso8601String(),
    'isAuthorized': isAuthorized,
    'notes': notes,
  };

  factory AccessEvent.fromJson(Map<String, dynamic> json) => AccessEvent(
    id: json['id'] as String,
    userId: json['userId'] as String?,
    visitId: json['visitId'] as String?,
    eventType: json['eventType'] as String,
    accessMethod: json['accessMethod'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    isAuthorized: json['isAuthorized'] as bool,
    notes: json['notes'] as String?,
  );

  AccessEvent copyWith({
    String? id,
    String? userId,
    String? visitId,
    String? eventType,
    String? accessMethod,
    DateTime? timestamp,
    bool? isAuthorized,
    String? notes,
  }) => AccessEvent(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    visitId: visitId ?? this.visitId,
    eventType: eventType ?? this.eventType,
    accessMethod: accessMethod ?? this.accessMethod,
    timestamp: timestamp ?? this.timestamp,
    isAuthorized: isAuthorized ?? this.isAuthorized,
    notes: notes ?? this.notes,
  );
}

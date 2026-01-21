class AdminMetricsDTO {
  final int totalAccess;
  final int successfulAccess;
  final int deniedAccess;
  final int visitors;
  final List<RecentActivityDTO> recentActivity;

  AdminMetricsDTO({
    required this.totalAccess,
    required this.successfulAccess,
    required this.deniedAccess,
    required this.visitors,
    required this.recentActivity,
  });

  factory AdminMetricsDTO.fromJson(Map<String, dynamic> json) {
    return AdminMetricsDTO(
      totalAccess: json['total_access'] ?? 0,
      successfulAccess: json['successful_access'] ?? 0,
      deniedAccess: json['denied_access'] ?? 0,
      visitors: json['visitors'] ?? 0,
      recentActivity: (json['recent_activity'] as List<dynamic>?)
              ?.map((item) => RecentActivityDTO.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'total_access': totalAccess,
        'successful_access': successfulAccess,
        'denied_access': deniedAccess,
        'visitors': visitors,
        'recent_activity': recentActivity.map((a) => a.toJson()).toList(),
      };
}

class RecentActivityDTO {
  final String personName;
  final String personRole;
  final String accessType; // 'own' o 'visitor'
  final String relatedPerson; // Visitante o referenciado por
  final DateTime timestamp;
  final String entryPoint; // 'Entrada Principal', 'Entrada Lateral', etc.
  final String status; // 'success' o 'denied'

  RecentActivityDTO({
    required this.personName,
    required this.personRole,
    required this.accessType,
    required this.relatedPerson,
    required this.timestamp,
    required this.entryPoint,
    required this.status,
  });

  factory RecentActivityDTO.fromJson(Map<String, dynamic> json) {
    return RecentActivityDTO(
      personName: json['person_name'] ?? '',
      personRole: json['person_role'] ?? '',
      accessType: json['access_type'] ?? 'own',
      relatedPerson: json['related_person'] ?? '',
      timestamp: json['timestamp'] is String
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      entryPoint: json['entry_point'] ?? 'Entrada Principal',
      status: json['status'] ?? 'success',
    );
  }

  Map<String, dynamic> toJson() => {
        'person_name': personName,
        'person_role': personRole,
        'access_type': accessType,
        'related_person': relatedPerson,
        'timestamp': timestamp.toIso8601String(),
        'entry_point': entryPoint,
        'status': status,
      };
}

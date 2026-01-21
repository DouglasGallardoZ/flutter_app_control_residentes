class AdminMetrics {
  final int totalAccess;
  final int successfulAccess;
  final int deniedAccess;
  final int visitors;
  final List<RecentActivity> recentActivity;

  AdminMetrics({
    required this.totalAccess,
    required this.successfulAccess,
    required this.deniedAccess,
    required this.visitors,
    required this.recentActivity,
  });

  factory AdminMetrics.fromMap(Map<String, dynamic> map) => AdminMetrics(
        totalAccess: map['totalAccess'] ?? 0,
        successfulAccess: map['successfulAccess'] ?? 0,
        deniedAccess: map['deniedAccess'] ?? 0,
        visitors: map['visitors'] ?? 0,
        recentActivity: (map['recentActivity'] as List<dynamic>?)
                ?.map((item) => RecentActivity.fromMap(item as Map<String, dynamic>))
                .toList() ??
            [],
      );

  Map<String, dynamic> toMap() => {
        'totalAccess': totalAccess,
        'successfulAccess': successfulAccess,
        'deniedAccess': deniedAccess,
        'visitors': visitors,
        'recentActivity': recentActivity.map((a) => a.toMap()).toList(),
      };

  /// getter for dashboard display
  int get deniedPercentage {
    if (totalAccess == 0) return 0;
    return ((deniedAccess / totalAccess) * 100).toInt();
  }

  int get successPercentage {
    if (totalAccess == 0) return 0;
    return ((successfulAccess / totalAccess) * 100).toInt();
  }
}

class RecentActivity {
  final String personName;
  final String personRole;
  final String accessType; // 'own' o 'visitor'
  final String relatedPerson; // Visitante o referenciado por
  final DateTime timestamp;
  final String entryPoint; // 'Entrada Principal', 'Entrada Lateral', etc.
  final bool isSuccessful;

  RecentActivity({
    required this.personName,
    required this.personRole,
    required this.accessType,
    required this.relatedPerson,
    required this.timestamp,
    required this.entryPoint,
    required this.isSuccessful,
  });

  factory RecentActivity.fromMap(Map<String, dynamic> map) => RecentActivity(
        personName: map['personName'] ?? '',
        personRole: map['personRole'] ?? '',
        accessType: map['accessType'] ?? 'own',
        relatedPerson: map['relatedPerson'] ?? '',
        timestamp: map['timestamp'] is String
            ? DateTime.parse(map['timestamp'])
            : DateTime.now(),
        entryPoint: map['entryPoint'] ?? 'Entrada Principal',
        isSuccessful: map['isSuccessful'] ?? true,
      );

  Map<String, dynamic> toMap() => {
        'personName': personName,
        'personRole': personRole,
        'accessType': accessType,
        'relatedPerson': relatedPerson,
        'timestamp': timestamp.toIso8601String(),
        'entryPoint': entryPoint,
        'isSuccessful': isSuccessful,
      };

  String get displayLabel {
    if (accessType == 'visitor') {
      return 'Visitante: $relatedPerson';
    }
    return 'Acceso propio';
  }

  String get shortTime {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) {
      return 'Hace unos segundos';
    } else if (diff.inMinutes < 60) {
      return 'Hace ${diff.inMinutes} min';
    } else if (diff.inHours < 24) {
      return 'Hace ${diff.inHours} h';
    } else {
      return '${timestamp.day} ${_monthName(timestamp.month)} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  String _monthName(int month) {
    const months = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
    return months[month - 1];
  }
}

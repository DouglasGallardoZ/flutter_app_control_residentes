// lib/domain/entities/visitor.dart
class Visitor {
  final String id;
  final String name;

  Visitor({required this.id, required this.name});

  factory Visitor.fromMap(Map<String, dynamic> m) => Visitor(id: m['id'], name: m['name']);
  Map<String, dynamic> toMap() => {'id': id, 'name': name};
}

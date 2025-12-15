// lib/domain/entities/visitor.dart
class Visitor {
  final String id;           // identificación
  final String name;
  final String? phone;
  final int visitCount;
  final DateTime? lastVisitAt;

  const Visitor({
    required this.id,
    required this.name,
    this.phone,
    this.visitCount = 0,
    this.lastVisitAt,
  });

  Visitor incVisit(DateTime when) => Visitor(
    id: id, name: name, phone: phone,
    visitCount: visitCount + 1, lastVisitAt: when,
  );
}

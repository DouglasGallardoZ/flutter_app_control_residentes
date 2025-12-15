// lib/infrastructure/adapters/visitor_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/visitor.dart';
import '../../domain/ports/visitor_repository.dart';
import '../providers/firestore_provider.dart';

class VisitorRepositoryImpl implements VisitorRepository {
  final FirestoreProvider store;
  VisitorRepositoryImpl(this.store);

  @override
  Future<List<Visitor>> listByResidence(String residenceId) async {
    final snap = await store.db.collection('visitors')
      .where('residenceId', isEqualTo: residenceId)
      .orderBy('visitCount', descending: true)
      .get();
    return snap.docs.map((d) {
      final m = d.data();
      return Visitor(
        id: m['id'],
        name: m['name'],
        phone: m['phone'],
        visitCount: (m['visitCount'] ?? 0) as int,
        lastVisitAt: m['lastVisitAt'] != null ? DateTime.parse(m['lastVisitAt']) : null,
      );
    }).toList();
  }

  @override
  Future<Visitor?> findById(String id, String residenceId) async {
    final snap = await store.db.collection('visitors')
      .where('id', isEqualTo: id)
      .where('residenceId', isEqualTo: residenceId)
      .limit(1)
      .get();
    if (snap.docs.isEmpty) return null;
    final m = snap.docs.first.data();
    return Visitor(
      id: m['id'], name: m['name'], phone: m['phone'],
      visitCount: (m['visitCount'] ?? 0) as int,
      lastVisitAt: m['lastVisitAt'] != null ? DateTime.parse(m['lastVisitAt']) : null,
    );
  }

  @override
  Future<Visitor> upsert(String residenceId, Visitor visitor) async {
    final ref = store.db.collection('visitors').doc('$residenceId-${visitor.id}');
    await ref.set({
      'residenceId': residenceId,
      'id': visitor.id,
      'name': visitor.name,
      'phone': visitor.phone,
      'visitCount': visitor.visitCount,
      'lastVisitAt': visitor.lastVisitAt?.toIso8601String(),
    }, SetOptions(merge: true));
    return visitor;
  }
}

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Proveedor de Firestore para notificaciones en tiempo real.
///
/// El backend sincroniza notificaciones en la colección:
///   notifications/{personaId}/items/{notificacionId}
///
/// Cada documento tiene el campo `leido: bool`.
class FirestoreProvider {
  final FirebaseFirestore db;

  FirestoreProvider(this.db);

  static FirestoreProvider create() =>
      FirestoreProvider(FirebaseFirestore.instance);

  /// Retorna un stream con el conteo de notificaciones no leídas
  /// para un usuario específico. Se actualiza en tiempo real
  /// cuando el backend crea/modifica notificaciones.
  Stream<int> contarNoLeidas(String personaId) {
    try {
      return db
          .collection('notifications')
          .doc(personaId)
          .collection('items')
          .where('leido', isEqualTo: false)
          .snapshots()
          .map((snapshot) => snapshot.docs.length)
          .handleError((error) {
        return 0;
      });
    } catch (_) {
      return Stream.value(0);
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreProvider {
  final FirebaseFirestore db;
  FirestoreProvider(this.db);

  static FirestoreProvider create() => FirestoreProvider(FirebaseFirestore.instance);
}
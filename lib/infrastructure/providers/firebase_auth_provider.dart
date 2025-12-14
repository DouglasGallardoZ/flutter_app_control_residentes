import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthProvider {
  final FirebaseAuth auth;
  FirebaseAuthProvider(this.auth);

  static FirebaseAuthProvider create() => FirebaseAuthProvider(FirebaseAuth.instance);
}
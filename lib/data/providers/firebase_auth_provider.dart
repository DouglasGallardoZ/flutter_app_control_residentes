import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthProvider {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential> signInWithEmail(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> updateEmail(String newEmail) async {
    final user = _auth.currentUser;
    // if (user != null) await user.updateEmail(newEmail);
  }

  Future<void> signOut() => _auth.signOut();
}

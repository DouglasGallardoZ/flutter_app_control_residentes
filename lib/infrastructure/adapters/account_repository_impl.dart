import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/ports/account_repository.dart';
import '../../domain/entities/account.dart';
import '../providers/firestore_provider.dart';

class AccountRepositoryImpl implements AccountRepository {
  final FirestoreProvider store;
  AccountRepositoryImpl(this.store);

  @override
  Future<Account> register(Account account) async {
    final ref = store.db.collection('users').doc(account.uid);
    await ref.set({
      'uid': account.uid,
      'id': account.id,
      'role': account.role,
      'status': account.status,
      'email': account.email,
      'name': account.name,
    }, SetOptions(merge: true));
    return account;
  }

  @override
  Future<Account?> getById(String id) async {
    final snap = await store.db.collection('users').where('id', isEqualTo: id).limit(1).get();
    if (snap.docs.isEmpty) return null;
    final m = snap.docs.first.data();
    return Account(
      uid: m['uid'] ?? '',
      id: m['id'] ?? '',
      role: m['role'] ?? 'resident',
      status: m['status'] ?? 'activo',
      email: m['email'],
      name: m['name'],
    );
  }

  @override
  Future<void> updateEmail(String id, String newEmail) async {
    final snap = await store.db.collection('users').where('id', isEqualTo: id).limit(1).get();
    if (snap.docs.isEmpty) throw Exception('Usuario no encontrado');
    await snap.docs.first.reference.update({'email': newEmail});
  }
}

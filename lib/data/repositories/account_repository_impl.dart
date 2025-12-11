import '../../domain/entities/account.dart';
import '../../domain/repositories/account_repository.dart';
import '../providers/firestore_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountRepositoryImpl implements AccountRepository {
  final FirestoreProvider db;
  AccountRepositoryImpl({required this.db});

  @override
  Future<Account> register(Account account) async {
    final ref = db.db.collection('users').doc(account.uid);
    await ref.set(account.toMap(), SetOptions(merge: true));
    return account;
  }

  @override
  Future<Account?> getById(String id) async {
    final snap = await db.db.collection('users').where('id', isEqualTo: id).limit(1).get();
    if (snap.docs.isEmpty) return null;
    return Account.fromMap(snap.docs.first.data());
  }

  @override
  Future<void> updateEmail(String id, String newEmail) async {
    final snap = await db.db.collection('users').where('id', isEqualTo: id).limit(1).get();
    if (snap.docs.isEmpty) throw Exception('Usuario no encontrado');
    await snap.docs.first.reference.update({'email': newEmail});
  }
}

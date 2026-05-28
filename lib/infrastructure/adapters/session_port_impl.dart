import '../../domain/ports/session_port.dart';
import '../../domain/ports/auth_repository.dart';
import '../../domain/ports/account_repository.dart';
import '../../domain/entities/auth_session.dart';

class SessionPortImpl implements SessionPort {
  final AuthRepository authRepo;
  final AccountRepository accountRepo;

  SessionPortImpl({required this.authRepo, required this.accountRepo});

  @override
  Future<AuthSession?> getCurrentSession() async {
    final currentUser = authRepo.currentUser;
    if (currentUser == null || currentUser['uid'] == null) return null;

    final uid = currentUser['uid'] as String;
    final email = currentUser['email'] as String?;
    final account = await accountRepo.getById(uid);
    if (account == null) return null;

    final idToken = await authRepo.getIdToken(forceRefresh: false);

    return AuthSession(
      uid: uid,
      email: email ?? account.correo ?? '',
      idToken: idToken,
      account: account,
      createdAt: DateTime.now(),
      expiresAt: null,
    );
  }
}

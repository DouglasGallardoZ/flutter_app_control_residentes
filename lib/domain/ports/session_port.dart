import '../entities/auth_session.dart';

abstract class SessionPort {
  Future<AuthSession?> getCurrentSession();
}

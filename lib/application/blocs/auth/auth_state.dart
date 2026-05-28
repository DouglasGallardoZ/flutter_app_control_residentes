import '../../../domain/entities/auth_session.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final AuthSession session;
  AuthSuccess(this.session);

  /// Para compatibilidad con código existente
  /// @deprecated Usar session.account en su lugar
  Map<String, dynamic> get user {
    final account = session.account;
    final vivienda = account.vivienda;
    return {
      'uid': session.uid,
      'email': session.email,
      'idToken': session.idToken,
      'personaId': account.personaId,
      'identificacion': account.identificacion,
      'nombres': account.nombres,
      'apellidos': account.apellidos,
      'rol': account.rol,
      'estado': account.estado,
      'correo': account.correo,
      'celular': account.celular,
      'parentesco': account.parentesco,
      'vivienda': {
        'manzana': vivienda.manzana,
        'villa': vivienda.villa,
        'vivienda_id': vivienda.viviendaId,
        'viviendaId': vivienda.viviendaId,
      },
      'residence_id': vivienda.viviendaId,
      'residence': '${vivienda.manzana}-${vivienda.villa}',
      'name': account.nombreCompleto,
    };
  }
}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}

class UserCreated extends AuthState {
  final String uid;
  final String email;

  UserCreated({required this.uid, required this.email});
}

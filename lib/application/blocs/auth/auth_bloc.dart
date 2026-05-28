import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/login_usecase.dart';
import '../../../domain/ports/auth_repository.dart';
import '../../../domain/ports/account_repository.dart';
import '../../../domain/entities/auth_session.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase login;
  final AuthRepository authRepo;
  final AccountRepository accountRepo;

  AuthBloc({
    required this.login,
    required this.authRepo,
    required this.accountRepo,
  }) : super(AuthInitial()) {
    on<LoginSubmitted>((event, emit) async {
      emit(AuthLoading());
      try {
        final session = await login(
          email: event.email,
          password: event.password,
        );
        emit(AuthSuccess(session));
      } catch (ex) {
        // Extraer mensaje de error legible para el usuario
        String errorMessage = _extractErrorMessage(ex);
        emit(AuthFailure(errorMessage));
      }
    });

    on<LogoutRequested>((event, emit) async {
      try {
        await authRepo.logout();
        emit(AuthInitial());
      } catch (ex) {
        emit(AuthFailure('Error al cerrar sesión: ${ex.toString()}'));
      }
    });

    on<CheckAuthStatus>((event, emit) async {
      try {
        final currentUserBasic = authRepo.currentUser;
        if (currentUserBasic != null && currentUserBasic['uid'] != null) {
          final uid = currentUserBasic['uid'] as String;
          final email = currentUserBasic['email'] as String?;

          // Obtener datos completos del perfil usando el uid (Firebase UID)
          final account = await accountRepo.getById(uid);
          if (account != null) {
            // Obtener token de Firebase
            final idToken = await authRepo.getIdToken(forceRefresh: false);

            // Crear sesión de autenticación
            final session = AuthSession(
              uid: uid,
              email: email ?? account.correo ?? '',
              idToken: idToken,
              account: account,
              createdAt: DateTime.now(),
              expiresAt: null,
            );

            emit(AuthSuccess(session));
            return;
          }
        }
        emit(AuthInitial());
      } catch (ex) {
        emit(AuthInitial());
      }
    });

    on<CreateFirebaseAccountSubmitted>((event, emit) async {
      emit(AuthLoading());
      try {
        final credential = await authRepo.signUpWithEmail(
          event.email,
          event.password,
        );
        emit(FirebaseAccountCreated(
          uid: credential.uid,
          email: credential.email ?? event.email,
        ));
      } catch (ex) {
        emit(AuthFailure(_extractErrorMessage(ex)));
      }
    });
  }

  /// Extrae un mensaje de error legible del objeto excepción
  String _extractErrorMessage(Object ex) {
    final message = ex.toString();

    // Remover prefijo "Exception: " si existe
    if (message.startsWith('Exception: ')) {
      final cleanMessage = message.substring('Exception: '.length);
      // El mensaje ya está traducido por Firebase o API, solo retornarlo
      return cleanMessage;
    }

    // Si aún contiene patrones sin traducir, intentar mapearlos
    if (message.contains('user-not-found')) {
      return 'Usuario no encontrado';
    }
    if (message.contains('wrong-password')) {
      return 'Contraseña incorrecta';
    }
    if (message.contains('invalid-credential')) {
      return 'Correo o contraseña incorrectos';
    }
    if (message.contains('too-many-requests')) {
      return 'Demasiados intentos de acceso. Intente más tarde';
    }
    if (message.contains('user-disabled')) {
      return 'Esta cuenta ha sido deshabilitada';
    }
    if (message.contains('network-request-failed')) {
      return 'Error de conexión. Verifique su internet';
    }

    // Retornar mensaje como está si no coincide con ningún patrón
    return message.isEmpty ? 'Error en autenticación' : message;
  }
}

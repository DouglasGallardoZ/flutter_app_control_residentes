import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/login_usecase.dart';
import '../../../domain/usecases/logout_usecase.dart';
import '../../../domain/usecases/get_current_user_usecase.dart';
import '../../../domain/usecases/get_id_token_usecase.dart';
import '../../../domain/usecases/sign_up_usecase.dart';
import '../../../domain/ports/account_repository.dart';
import '../../../domain/entities/auth_session.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase login;
  final LogoutUseCase logout;
  final GetCurrentUserUseCase getCurrentUser;
  final GetIdTokenUseCase getIdToken;
  final SignUpUseCase signUp;
  final AccountRepository accountRepo;

  AuthBloc({
    required this.login,
    required this.logout,
    required this.getCurrentUser,
    required this.getIdToken,
    required this.signUp,
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
        String errorMessage = _extractErrorMessage(ex);
        emit(AuthFailure(errorMessage));
      }
    });

    on<LogoutRequested>((event, emit) async {
      try {
        await logout.execute();
        emit(AuthInitial());
      } catch (ex) {
        emit(AuthFailure('Error al cerrar sesión: ${ex.toString()}'));
      }
    });

    on<CheckAuthStatus>((event, emit) async {
      try {
        final currentUserBasic = getCurrentUser.execute();
        if (currentUserBasic != null && currentUserBasic['uid'] != null) {
          final uid = currentUserBasic['uid'] as String;
          final email = currentUserBasic['email'] as String?;

          final account = await accountRepo.getById(uid);
          if (account != null) {
            final idToken =
                await getIdToken.execute(forceRefresh: false);

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

    on<CreateUserSubmitted>((event, emit) async {
      emit(AuthLoading());
      try {
        final credential = await signUp.execute(
          event.email,
          event.password,
        );
        emit(UserCreated(
          uid: credential.uid,
          email: credential.email ?? event.email,
        ));
      } catch (ex) {
        emit(AuthFailure(_extractErrorMessage(ex)));
      }
    });
  }

  String _extractErrorMessage(Object ex) {
    final message = ex.toString();

    if (message.startsWith('Exception: ')) {
      final cleanMessage = message.substring('Exception: '.length);
      return cleanMessage;
    }

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

    return message.isEmpty ? 'Error en autenticación' : message;
  }
}

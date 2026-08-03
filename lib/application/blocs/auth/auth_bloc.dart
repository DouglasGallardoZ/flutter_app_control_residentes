import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/login_usecase.dart';
import '../../../domain/usecases/logout_usecase.dart';
import '../../../domain/usecases/get_current_user_usecase.dart';
import '../../../domain/usecases/get_id_token_usecase.dart';
import '../../../domain/usecases/sign_up_usecase.dart';
import '../../../domain/ports/account_repository.dart';
import '../../../domain/ports/firebase_auth_provider_port.dart';
import '../../../domain/ports/camera_port.dart';
import '../../../domain/entities/auth_result.dart';
import '../../../domain/entities/auth_session.dart';
import '../../../injection.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase login;
  final LogoutUseCase logout;
  final GetCurrentUserUseCase getCurrentUser;
  final GetIdTokenUseCase getIdToken;
  final SignUpUseCase signUp;
  final AccountRepository accountRepo;
  final FirebaseAuthProviderPort authProvider;

  bool _isLoggingOut = false;
  StreamSubscription<AuthResult?>? _authStateSubscription;

  AuthBloc({
    required this.login,
    required this.logout,
    required this.getCurrentUser,
    required this.getIdToken,
    required this.signUp,
    required this.accountRepo,
    required this.authProvider,
  }) : super(AuthInitial()) {
    _listenAuthStateChanges();

    on<LoginSubmitted>((event, emit) async {
      emit(AuthLoading());
      try {
        final session = await login(
          email: event.email,
          password: event.password,
        );

        if (_accesoWebRestringido(session.rol)) {
          _isLoggingOut = true;
          try {
            await authProvider.logout();
          } catch (_) {}
          _isLoggingOut = false;
          emit(AuthRestrictedWeb());
          return;
        }

        emit(AuthSuccess(session));
      } catch (ex) {
        String errorMessage = _extractErrorMessage(ex);
        emit(AuthFailure(errorMessage));
      }
    });

    on<LogoutRequested>((event, emit) async {
      _isLoggingOut = true;
      try {
        await logout.execute();
        emit(AuthInitial());
      } catch (ex) {
        emit(AuthFailure(
            'Error al cerrar sesión: ${ex.toString()}'));
      } finally {
        _isLoggingOut = false;
      }
    });

    on<CheckAuthStatus>((event, emit) async {
      if (_isLoggingOut) return;
      try {
        final currentUserBasic = getCurrentUser.execute();
        if (currentUserBasic != null &&
            currentUserBasic['uid'] != null) {
          final uid = currentUserBasic['uid'] as String;
          final email = currentUserBasic['email'] as String?;

          final account = await accountRepo.getById(uid);
          if (account != null) {
            if (_accesoWebRestringido(account.rol)) {
              _isLoggingOut = true;
              try {
                await authProvider.logout();
              } catch (_) {}
              _isLoggingOut = false;
              emit(AuthRestrictedWeb());
              return;
            }

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
        try {
          await authProvider.logout();
        } catch (_) {}
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

  void _listenAuthStateChanges() {
    _authStateSubscription =
        authProvider.authStateChanges.listen((user) {
      print(
          ' AUTH SYNC: authStateChanges emitido -> usuario=${user?.uid ?? 'null'}, _isLoggingOut=$_isLoggingOut');

      if (_isLoggingOut) {
        print(
            ' AUTH SYNC: ignorando emisión durante logout');
        return;
      }

      if (user == null) {
        print(
            ' AUTH SYNC: usuario deslogueado detectado -> emitiendo AuthInitial');
        if (!isClosed) add(CheckAuthStatus());
        return;
      }

      print(
          ' AUTH SYNC: usuario autenticado detectado (${user.uid}) -> despachando CheckAuthStatus');
      if (!isClosed) add(CheckAuthStatus());
    });
  }

  bool _accesoWebRestringido(String rol) {
    if (!kIsWeb) return false;
    final rolLower = rol.toLowerCase();
    return rolLower != 'admin' && rolLower != 'administrador';
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

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/login_usecase.dart';
import '../../../domain/ports/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase login;
  final AuthRepository authRepo;

  AuthBloc({
    required this.login,
    required this.authRepo,
  }) : super(AuthInitial()) {
    on<LoginSubmitted>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await login(
          email: event.email,
          password: event.password,
        );
        emit(AuthSuccess(user));
      } catch (ex) {
        emit(AuthFailure(
          'Error en autenticación: ${ex.toString()}',
        ));
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
  }
}

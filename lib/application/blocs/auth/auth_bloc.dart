import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/login_usecase.dart';
import '../../../domain/ports/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase login;
  final AuthRepository authRepo;
  AuthBloc({required this.login, required this.authRepo}) : super(AuthInitial()) {
    on<LoginSubmitted>((e, emit) async {
      emit(AuthLoading());
      try {
        final user = await login(identification: e.id, password: e.password);
        emit(AuthSuccess(user));
      } catch (ex) {
        emit(AuthFailure('Credenciales inválidas o cuenta no encontrada'));
      }
    });

    on<LogoutRequested>((e, emit) async {
      await authRepo.logout();
      emit(AuthInitial());
    });
  }
}

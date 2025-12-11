import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../core/validations/cv_validators.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repo;
  AuthBloc(this.repo) : super(AuthInitial()) {
    on<LoginSubmitted>((e, emit) async {
      final idErr = CvValidators.cv01IdEcuador(e.id, isEcuador: true);
      if (idErr != null) { emit(AuthFailure(idErr)); return; }
      emit(AuthLoading());
      try {
        final user = await repo.login(id: e.id, password: e.password);
        emit(AuthSuccess(user));
      } catch (ex) {
        emit(AuthFailure(ex.toString().replaceAll('Exception: ', '')));
      }
    });
  }
}

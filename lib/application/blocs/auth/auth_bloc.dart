import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/login_usecase.dart';
import '../../../domain/ports/auth_repository.dart';
import '../../../domain/ports/account_repository.dart';
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
        final user = await login(
          email: event.email,
          password: event.password,
        );
        emit(AuthSuccess(user));
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
          // Obtener datos completos del perfil usando el uid (Firebase UID)
          final account = await accountRepo.getById(currentUserBasic['uid'] as String);
          if (account != null) {
            // Convertir Account a formato compatible con AuthSuccess
            emit(AuthSuccess({
              'uid': account.firebaseUid,
              'email': account.correo,
              'personaId': account.personaId,
              'identificacion': account.identificacion,
              'nombres': account.nombres,
              'apellidos': account.apellidos,
              'rol': account.rol,
              'estado': account.estado,
              'celular': account.celular,
              'residence': '${account.vivienda.manzana}-${account.vivienda.villa}',
              'residence_id': account.vivienda.viviendaId,
              'vivienda': {
                'manzana': account.vivienda.manzana,
                'villa': account.vivienda.villa,
                'viviendaId': account.vivienda.viviendaId,
              },
              'parentesco': account.parentesco,
            }));
            return;
          }
        }
        emit(AuthInitial());
      } catch (ex) {
        emit(AuthInitial());
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

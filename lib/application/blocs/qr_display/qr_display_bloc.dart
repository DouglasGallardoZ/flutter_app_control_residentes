import 'package:flutter_bloc/flutter_bloc.dart';
import '../auth/auth_bloc.dart';
import '../auth/auth_state.dart';
import 'qr_display_event.dart';
import 'qr_display_state.dart';

class QrDisplayBloc extends Bloc<QrDisplayEvent, QrDisplayState> {
  final AuthBloc authBloc;

  QrDisplayBloc({required this.authBloc}) : super(QrDisplayInitial()) {
    on<InitializeQrDisplay>(_onInitialize);
    on<NavigateToScreen>(_onNavigateToScreen);
    on<NavigateBack>(_onNavigateBack);
  }

  /// Extrae datos del usuario desde AuthBloc
  Future<void> _onInitialize(InitializeQrDisplay event, Emitter<QrDisplayState> emit) async {
    try {
      final authState = authBloc.state;
      if (authState is! AuthSuccess) {
        emit(QrDisplayError('No hay sesión activa'));
        return;
      }

      final userData = _extractUserData(authState);
      if (userData == null) {
        emit(QrDisplayError('Datos de usuario incompletos'));
        return;
      }

      emit(QrDisplayLoaded(userData));
    } catch (e) {
      emit(QrDisplayError('Error al cargar datos: ${e.toString()}'));
    }
  }

  /// Navega a una pantalla específica
  Future<void> _onNavigateToScreen(NavigateToScreen event, Emitter<QrDisplayState> emit) async {
    try {
      final currentState = state;
      if (currentState is! QrDisplayLoaded) {
        emit(QrDisplayError('Datos de usuario no disponibles'));
        return;
      }

      final userData = currentState.userDataForDisplay;
      
      switch (event.screenIndex) {
        case 0:
          emit(NavigationRequested(
            userData.homeRoute,
            arguments: {
              'personaId': int.tryParse(userData.userId) ?? 0,
              'identificacion': userData.identificacion,
              'residenceId': userData.residenceId,
              'userName': userData.userName,
            },
          ));
          break;
        case 2:
          emit(NavigationRequested(
            '/accessHistory',
            arguments: {
              'personaId': int.tryParse(userData.userId) ?? 0,
              'identificacion': userData.identificacion,
              'residenceId': userData.residenceId,
            },
          ));
          break;
        case 3:
          emit(NavigationRequested(
            '/members',
            arguments: {
              'personaId': int.tryParse(userData.userId) ?? 0,
              'identificacion': userData.identificacion,
              'residenceId': userData.residenceId,
            },
          ));
          break;
        case 4:
          emit(NavigationRequested(
            '/profile',
            arguments: {
              'personaId': int.tryParse(userData.userId) ?? 0,
              'identificacion': userData.identificacion,
              'residenceId': userData.residenceId,
            },
          ));
          break;
      }
    } catch (e) {
      emit(QrDisplayError('Error en navegación: ${e.toString()}'));
    }
  }

  /// Navega de vuelta al home
  Future<void> _onNavigateBack(NavigateBack event, Emitter<QrDisplayState> emit) async {
    try {
      final currentState = state;
      if (currentState is! QrDisplayLoaded) {
        emit(QrDisplayError('Datos de usuario no disponibles'));
        return;
      }

      final userData = currentState.userDataForDisplay;
      emit(NavigationRequested(
        userData.homeRoute,
        arguments: {
          'personaId': int.tryParse(userData.userId) ?? 0,
          'identificacion': userData.identificacion,
          'residenceId': userData.residenceId,
          'userName': userData.userName,
        },
      ));
    } catch (e) {
      emit(QrDisplayError('Error al regresar: ${e.toString()}'));
    }
  }

  /// Extrae y procesa datos del usuario desde AuthSuccess
  UserDataForDisplay? _extractUserData(AuthSuccess authState) {
    try {
      final userId = (authState.user['personaId']?.toString() ?? authState.user['uid'])?.toString();
      final identificacion = authState.user['identificacion'] as String?;
      final role = authState.user['rol'] as String?;

      if (userId == null || identificacion == null) {
        return null;
      }

      // Determinar si es miembro de familia
      final isFamilyMember = role?.toLowerCase() == 'miembro_familia' ||
          role?.toLowerCase() == 'family' ||
          role?.toLowerCase() == 'miembro de familia';

      // Extraer nombre completo (nombres + apellidos)
      final nombres = (authState.user['nombres'] ?? '') as String;
      final apellidos = (authState.user['apellidos'] ?? '') as String;
      final fullName = '$nombres $apellidos'.trim();
      final userName = fullName.isNotEmpty ? fullName : 'Usuario';

      // Extraer residencia desde vivienda
      String residenceId = '';
      try {
        if (authState.user['vivienda'] != null) {
          final vivienda = authState.user['vivienda'] as Map<String, dynamic>;
          final manzana = vivienda['manzana'] ?? '';
          final villa = vivienda['villa'] ?? '';
          if (manzana.isNotEmpty && villa.isNotEmpty) {
            residenceId = 'Manzana $manzana, Villa $villa';
          }
        }
        if (residenceId.isEmpty) {
          residenceId = (authState.user['residence'] as String?) ?? '';
        }
      } catch (e) {
        residenceId = (authState.user['residence'] as String?) ?? '';
      }

      final homeRoute = isFamilyMember ? '/familyDashboard' : '/residentDashboard';

      return UserDataForDisplay(
        userId: userId,
        userName: userName,
        identificacion: identificacion,
        residenceId: residenceId,
        isFamilyMember: isFamilyMember,
        homeRoute: homeRoute,
      );
    } catch (e) {
      return null;
    }
  }
}

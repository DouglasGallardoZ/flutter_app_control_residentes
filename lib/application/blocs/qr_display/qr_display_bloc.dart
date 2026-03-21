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
  Future<void> _onInitialize(
      InitializeQrDisplay event, Emitter<QrDisplayState> emit) async {
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
  Future<void> _onNavigateToScreen(
      NavigateToScreen event, Emitter<QrDisplayState> emit) async {
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
  Future<void> _onNavigateBack(
      NavigateBack event, Emitter<QrDisplayState> emit) async {
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
      final account = authState.session.account;
      final userId = account.personaId > 0
          ? account.personaId.toString()
          : account.firebaseUid;
      final identificacion = account.identificacion;
      final role = account.rol;

      if (userId.isEmpty || identificacion.isEmpty) {
        return null;
      }

      // Determinar si es miembro de familia
      final isFamilyMember = role.toLowerCase() == 'miembro_familia' ||
          role.toLowerCase() == 'family' ||
          role.toLowerCase() == 'miembro de familia';

      // Extraer nombre completo (nombres + apellidos)
      final fullName = account.nombreCompleto;
      final userName = fullName.isNotEmpty ? fullName : 'Usuario';

      // Extraer residencia desde vivienda
      String residenceId = '';
      final vivienda = account.vivienda;
      final manzana = vivienda.manzana;
      final villa = vivienda.villa;
      if (manzana.isNotEmpty && villa.isNotEmpty) {
        residenceId = 'Manzana $manzana, Villa $villa';
      }

      final homeRoute =
          isFamilyMember ? '/familyDashboard' : '/residentDashboard';

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

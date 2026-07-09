import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../domain/ports/notificacion_push_handler_port.dart';
import '../../domain/usecases/registrar_token_fcm_usecase.dart';
import '../../domain/usecases/obtener_notificaciones_usecase.dart';
import '../../application/blocs/auth/auth_bloc.dart';
import '../../application/blocs/auth/auth_state.dart';
import '../services/navigation_service.dart';
import '../../injection.dart';

class FcmProvider
    implements NotificacionPushHandlerPort {
  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;

  FcmProvider(
      this._messaging, this._localNotifications);

  @override
  Future<void> inicializar(String usuarioId) async {
    await _messaging.requestPermission(
        alert: true, badge: true, sound: true);

    await _configurarNotificacionesLocales();

    final token = await _messaging.getToken();
    if (token != null) {
      print('🔑 Token FCM: $token');
      await _registrarToken(usuarioId, token);
    }

    _messaging.onTokenRefresh
        .listen((nuevoToken) {
      _registrarToken(usuarioId, nuevoToken);
    });

    FirebaseMessaging.onMessage.listen((message) {
      manejarNotificacionEnPrimerPlano(
          message.data);
      _mostrarNotificacionLocal(message);
    });

    FirebaseMessaging.onMessageOpenedApp
        .listen((message) {
      manejarTapEnNotificacion(message.data);
    });

    final initialMessage =
        await _messaging.getInitialMessage();
    if (initialMessage != null) {
      Future.delayed(
          const Duration(milliseconds: 500), () {
        manejarTapEnNotificacion(
            initialMessage.data);
      });
    }
  }

  @override
  Future<String?> obtenerToken() async {
    return await _messaging.getToken();
  }

  @override
  Stream<String> get onTokenRefresh =>
      _messaging.onTokenRefresh;

  @override
  void manejarTapEnNotificacion(
      Map<String, dynamic> data) {
    print('📩 Tap en notificación: $data');

    final tipo = data['tipo'] as String?;
    final notificacionId =
        data['notificacion_id'] as String?;
    final rutaAccion =
        data['ruta_accion'] as String?;

    if (tipo == 'solicitud_miembro') {
      if (rutaAccion != null) {
        NavigationService.navigateTo(
            rutaAccion,
            arguments: data);
      } else {
        NavigationService.navigateTo(
            '/aprobacionMiembro',
            arguments: data);
      }
      return;
    }

    if (tipo == 'notificacion' &&
        notificacionId != null) {
      _navegarADetalleNotificacion(
          int.parse(notificacionId));
    } else if (rutaAccion != null &&
        rutaAccion.isNotEmpty) {
      NavigationService.navigateTo(rutaAccion,
          arguments: data);
    } else {
      NavigationService
          .navigateTo('/notificaciones');
    }
  }

  @override
  void manejarNotificacionEnPrimerPlano(
      Map<String, dynamic> data) {
    print(
        '📩 Notificación en primer plano: $data');
  }

  Future<void> _navegarADetalleNotificacion(
      int notificacionId) async {
    try {
      final authBloc = sl<AuthBloc>();
      final userId = (authBloc.state
                  is AuthSuccess)
              ? (authBloc.state as AuthSuccess)
                  .user['personaId']
                  ?.toString()
              : null
          as String?;
      if (userId == null) return;

      final obtenerNotificaciones =
          sl<ObtenerNotificacionesUseCase>();
      final notificaciones =
          await obtenerNotificaciones
              .execute(userId);

      final notificacion = notificaciones
          .firstWhere(
              (n) => n.id == notificacionId);

      NavigationService.navigateTo(
        '/notificaciones/detalle',
        arguments: notificacion,
      );
    } catch (e) {
      print(
          '❌ Error navegando a detalle: $e');
      NavigationService
          .navigateTo('/notificaciones');
    }
  }

  Future<void> _mostrarNotificacionLocal(
      RemoteMessage message) async {
    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Guardin',
      message.notification?.body ?? '',
      NotificationDetails(
        android:
            AndroidNotificationDetails(
          'guardin_channel',
          'Notificaciones Guardin',
          channelDescription:
              'Canal de notificaciones de Guardin',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: message
          .data['notificacion_id'],
    );
  }

  Future<void>
      _configurarNotificacionesLocales() async {
    const androidSettings =
        AndroidInitializationSettings(
            '@mipmap/ic_launcher');
    const iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings);
    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse:
          (response) {
        final notificacionId =
            response.payload;
        if (notificacionId != null) {
          _navegarADetalleNotificacion(
              int.parse(notificacionId));
        }
      },
    );
  }

  Future<void> _registrarToken(
      String usuarioId, String token) async {
    try {
      final useCase =
          sl<RegistrarTokenFCMUseCase>();
      await useCase.execute(
        usuarioId,
        token,
        Platform.isAndroid ? 'android' : 'ios',
      );
      print(
          '✅ Token FCM registrado en backend');
    } catch (e) {
      print(
          '❌ Error registrando token FCM: $e');
    }
  }
}

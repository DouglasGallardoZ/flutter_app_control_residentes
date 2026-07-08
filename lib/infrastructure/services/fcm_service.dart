import 'dart:io' show Platform;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../injection.dart';
import '../../domain/usecases/registrar_token_fcm_usecase.dart';
import 'app_navigator.dart';

class FcmService {
  final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> inicializar(String usuarioId) async {
    if (kIsWeb) return;

    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    await _configurarNotificacionesLocales();

    final token = await _messaging.getToken();
    if (token != null) {
      print('🔑 Token FCM: $token');
      await _registrarToken(usuarioId, token);
    }

    _messaging.onTokenRefresh.listen((nuevoToken) {
      print('🔄 Token FCM actualizado: $nuevoToken');
      _registrarToken(usuarioId, nuevoToken);
    });

    FirebaseMessaging.onMessage
        .listen(_manejarNotificacionForeground);

    FirebaseMessaging.onMessageOpenedApp
        .listen(_manejarTapNotificacion);

    final initialMessage =
        await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _manejarTapNotificacion(initialMessage);
    }
  }

  Future<void> _configurarNotificacionesLocales() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        final ruta = response.payload;
        if (ruta != null && ruta.isNotEmpty) {
          AppNavigator.navigateTo(ruta);
        }
      },
    );
  }

  void _manejarNotificacionForeground(
      RemoteMessage message) {
    print(
        '📩 Notificación en foreground: ${message.notification?.title}');

    _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Guardin',
      message.notification?.body ?? '',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'guardin_channel',
          'Notificaciones Guardin',
          channelDescription:
              'Canal de notificaciones de Guardin',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: message.data['ruta_accion'],
    );
  }

  void _manejarTapNotificacion(
      RemoteMessage message) {
    print('📩 Tap en notificación: ${message.data}');
    final ruta = message.data['ruta_accion'];
    if (ruta != null && ruta.isNotEmpty) {
      AppNavigator.navigateTo(ruta);
    }
  }

  Future<void> _registrarToken(
      String usuarioId, String token) async {
    try {
      final useCase = sl<RegistrarTokenFCMUseCase>();
      final plataforma =
          Platform.isAndroid ? 'android' : 'ios';
      await useCase.execute(
          usuarioId, token, plataforma);
      print('✅ Token FCM registrado en backend');
    } catch (e) {
      print('❌ Error registrando token FCM: $e');
    }
  }
}

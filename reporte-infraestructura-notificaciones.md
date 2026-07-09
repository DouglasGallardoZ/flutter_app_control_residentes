# Reporte: Capa de Infraestructura — Notificaciones y Solicitudes de Miembro

**Fecha:** 2026-07-08
**Proyecto:** Guardin

---

## 1. CLIENTE HTTP BASE

### `infrastructure/providers/http_client.dart` (76 líneas)

```dart
class ApiHttpClient {
  final Dio dio;                    // ← Instancia de Dio expuesta directamente
  final FirebaseAuth firebaseAuth;
  String? _jwtToken;

  // Constructor: configura baseUrl, contentType, timeouts
  // Interceptor: agrega Bearer token Firebase en cada request
  // Maneja error 401

  void setJwtToken(String token);   // setToken alias
  void clearJwtToken();             // clearToken alias
  String? getJwtToken();            // getToken alias
}
```

**API:** Todos los providers usan `_cliente.dio.get()`, `_cliente.dio.post()`, `_cliente.dio.put()`, `_cliente.dio.delete()` — no hay wrappers tipo `_cliente.get()`.

---

## 2. API PROVIDERS

### 2.1 `providers/solicitud_miembro_api_provider.dart` (51 líneas)

| Método | HTTP | Endpoint | Propósito |
|--------|------|----------|-----------|
| `solicitarRegistro()` | POST | `/miembros/solicitar` | Enviar solicitud al titular |
| `consultarEstado()` | GET | `/miembros/solicitudes/estado/{identificacion}` | Consultar estado |

**Faltante:** métodos `aprobarSolicitud(id)` y `rechazarSolicitud(id, motivo)`.

### 2.2 `providers/notificacion_api_provider.dart` (53 líneas)

| Método | HTTP | Endpoint |
|--------|------|----------|
| `obtenerNotificaciones()` | GET | `/notificaciones?pagina=&tamano_pagina=` |
| `obtenerNoLeidas()` | GET | `/notificaciones/no-leidas` |
| `marcarComoLeida()` | PUT | `/notificaciones/{id}/leer` |
| `marcarTodasComoLeidas()` | PUT | `/notificaciones/leer-todas` |
| `eliminarNotificacion()` | DELETE | `/notificaciones/{id}` |
| `registrarTokenFCM()` | POST | `/notificaciones/token` |

### 2.3 `providers/admin_notificaciones_api_provider.dart` (79 líneas)

| Método | HTTP | Endpoint |
|--------|------|----------|
| `obtenerDestinatarios()` | GET | `/notificaciones/destinatarios?busqueda=&manzana=&villa=` |
| `obtenerManzanas()` | GET | `/notificaciones/manzanas` |
| `enviarNotificacion()` | POST | `/notificaciones/enviar` |

### 2.4 `providers/fcm_provider.dart` (203 líneas)

```dart
class FcmProvider implements NotificacionPushHandlerPort {
  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;

  inicializar(usuarioId):
    → requestPermission → getToken → _configurarNotificacionesLocales
    → onTokenRefresh → onMessage → onMessageOpenedApp → getInitialMessage

  manejarTapEnNotificacion(data):
    → tipo == 'notificacion' → obtener notificación → navegar a /notificaciones/detalle
    → rutaAccion != null → NavigationService.navigateTo(rutaAccion)
    → default → navegar a /notificaciones

  _navegarADetalleNotificacion(notificacionId):
    → sl<AuthBloc>() → get userId → sl<ObtenerNotificacionesUseCase>() → execute(userId)
    → find notification by id → NavigationService.navigateTo('/notificaciones/detalle')
}
```

---

## 3. ADAPTADORES (Repository Implementations)

### 3.1 `adapters/solicitud_miembro_repository_impl.dart` (51 líneas)

```dart
class SolicitudMiembroRepositoryImpl implements SolicitudMiembroRepositoryPort {
  final SolicitudMiembroApiProvider _apiProvider;

  solicitarRegistro(...) → apiProvider.solicitarRegistro(...) → return data['notificacion_id']
  consultarEstado(identificacion) → apiProvider.consultarEstado(...) → EstadoSolicitudResponse.fromJson(data)
}
```

### 3.2 `adapters/notificacion_repository_impl.dart` (61 líneas)

```dart
class NotificacionRepositoryImpl implements NotificacionRepositoryPort {
  final NotificacionApiProvider _apiProvider;

  obtenerNotificaciones() → apiProvider.obtenerNotificaciones() → map NotificacionItem.fromJson
  obtenerNoLeidas() → apiProvider.obtenerNoLeidas()
  marcarComoLeida() → apiProvider.marcarComoLeida()
  marcarTodasComoLeidas() → apiProvider.marcarTodasComoLeidas()
  eliminarNotificacion() → apiProvider.eliminarNotificacion()
  registrarTokenFCM() → apiProvider.registrarTokenFCM()
}
```

### 3.3 `adapters/admin_notificaciones_repository_impl.dart` (54 líneas)

```dart
class AdminNotificacionesRepositoryImpl implements AdminNotificacionesRepositoryPort {
  final AdminNotificacionesApiProvider _apiProvider;

  obtenerDestinatarios() → apiProvider.obtenerDestinatarios() → map Destinatario.fromJson
  obtenerManzanas() → apiProvider.obtenerManzanas()
  enviarNotificacion() → apiProvider.enviarNotificacion()
}
```

---

## 4. INYECCIÓN DE DEPENDENCIAS — `injection.dart` (829 líneas)

### Registros relacionados con notificaciones y solicitudes

| Línea | Tipo | Registro |
|-------|------|----------|
| 312 | Provider | `NotificacionApiProvider` |
| 313-315 | Provider | `NotificacionRepositoryPort` → `NotificacionRepositoryImpl` |
| 729-752 | Use Cases | 6 use cases de notificaciones (LazySingleton) |
| 754-763 | BLoC | `NotificacionesBloc` (Factory) |
| 766-768 | Provider | `AdminNotificacionesApiProvider` |
| 770-773 | Puerto | `AdminNotificacionesRepositoryPort` → `AdminNotificacionesRepositoryImpl` |
| 775-778 | BLoC | `AdminNotificacionesBloc` (Factory) |
| 781-785 | Services | `FlutterLocalNotificationsPlugin` |
| 788-791 | Provider | `FcmProvider` |
| 793-797 | Puerto | `NotificacionPushHandlerPort` → `NotificacionPushHandlerImpl` |
| 800-802 | Provider | `SolicitudMiembroApiProvider` |
| 804-807 | Puerto | `SolicitudMiembroRepositoryPort` → `SolicitudMiembroRepositoryImpl` |
| 810-813 | Use Case | `SolicitarRegistroMiembroUseCase` |
| 815-818 | Use Case | `ConsultarEstadoSolicitudUseCase` |
| 821-828 | BLoC | `AutorizacionMiembroBloc` (Factory) |

### Flujo de registro de dependencias

```
SolicitudMiembroApiProvider
  └── solicita ApiHttpClient (línea 801)

SolicitudMiembroRepositoryPort
  └── SolicitudMiembroRepositoryImpl
        └── solicita SolicitudMiembroApiProvider (línea 806)

SolicitarRegistroMiembroUseCase
  └── solicita SolicitudMiembroRepositoryPort (línea 812)

ConsultarEstadoSolicitudUseCase
  └── solicita SolicitudMiembroRepositoryPort (línea 817)

AutorizacionMiembroBloc
  ├── solicita SolicitarRegistroMiembroUseCase (línea 824)
  └── solicita ConsultarEstadoSolicitudUseCase (línea 826)
```

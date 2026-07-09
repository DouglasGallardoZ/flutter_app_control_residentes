# Reporte: Capa de Dominio — Notificaciones y Solicitudes de Miembro

**Fecha:** 2026-07-08
**Proyecto:** Guardin

---

## 1. ENTIDADES (`lib/domain/entities/`)

### 1.1 `notificacion_item.dart` (73 líneas)

```dart
class NotificacionItem {
  final int id;
  final String titulo;
  final String cuerpo;
  final String tipo;
  final String prioridad;     // 'alta', 'normal', 'baja'
  final String categoria;     // 'general', 'visita', 'seguridad', 'pago', 'evento'
  final bool leido;
  final DateTime? fechaCreacion;
  final String? rutaAccion;            // ← Ruta para "Ver más" en detalle
  final Map<String, dynamic>? datosAccion; // ← Argumentos para la ruta

  const NotificacionItem({...});
  factory NotificacionItem.fromJson(Map<String, dynamic> json);
  bool get esPrioridadAlta;
  bool get esPrioridadNormal;
  bool get esPrioridadBaja;
  String get tiempoTranscurrido;
}
```

### 1.2 `estado_solicitud.dart` (45 líneas)

```dart
enum EstadoSolicitud {
  pendiente,
  aprobado,
  rechazado,
  noEncontrado,
}

class EstadoSolicitudResponse {
  final EstadoSolicitud estado;
  final int? personaId;       // ← Asignado cuando se aprueba
  final int? miembroId;
  final String? motivo;       // ← Razón de rechazo

  EstadoSolicitudResponse({...});
  factory EstadoSolicitudResponse.fromJson(Map<String, dynamic> json);
}
```

### 1.3 `solicitud_miembro.dart` (48 líneas)

```dart
class SolicitudMiembro {
  final int notificacionId;
  final String nombres;
  final String apellidos;
  final String identificacion;
  final String parentesco;
  final String? parentescoOtroDesc;
  final String manzana;
  final String villa;
  final String? fechaSolicitud;

  SolicitudMiembro({...});
  factory SolicitudMiembro.fromJson(Map<String, dynamic> json);
  String get nombreCompleto;
  String get direccion;
}
```

### 1.4 `destinatario.dart` (37 líneas)

*Nota: Usado en admin para seleccionar destinatarios de notificaciones.*

```dart
class Destinatario {
  final int personaId;
  final String nombreCompleto;
  final String identificacion;
  final String? manzana;
  final String? villa;
  final String tipo;         // 'residente' o 'miembro_familia'
  bool seleccionado;

  Destinatario({...});
  factory Destinatario.fromJson(Map<String, dynamic> json);
  String get direccion;
}
```

---

## 2. PUERTOS (`lib/domain/ports/`)

### 2.1 `notificacion_repository_port.dart` (22 líneas)

```dart
abstract class NotificacionRepositoryPort {
  Future<List<NotificacionItem>> obtenerNotificaciones(
    String usuarioId, {int pagina = 1, int tamanoPagina = 20});
  Future<int> obtenerNoLeidas(String usuarioId);
  Future<void> marcarComoLeida(String usuarioId, int notificacionId);
  Future<void> marcarTodasComoLeidas(String usuarioId);
  Future<void> eliminarNotificacion(String usuarioId, int notificacionId);
  Future<void> registrarTokenFCM(String usuarioId, String token, String plataforma);
}
```

### 2.2 `admin_notificaciones_repository_port.dart` (22 líneas)

```dart
abstract class AdminNotificacionesRepositoryPort {
  Future<List<Destinatario>> obtenerDestinatarios({
    String? busqueda, String? manzana, String? villa,
  });
  Future<List<String>> obtenerManzanas();
  Future<void> enviarNotificacion({
    required String titulo, required String mensaje,
    required String prioridad, required String categoria,
    required List<int> destinatarioIds, required bool enviarATodos,
    String? rutaAccion, Map<String, dynamic>? datosAccion,
  });
}
```

### 2.3 `solicitud_miembro_repository_port.dart` (20 líneas)

```dart
abstract class SolicitudMiembroRepositoryPort {
  Future<int> solicitarRegistro({
    required String identificacionResidente,
    required String manzana, required String villa,
    required String identificacion, required String nombres,
    required String apellidos, required String fechaNacimiento,
    required String parentesco,
    String? parentescoOtroDesc, String? correo, String? celular,
  });
  Future<EstadoSolicitudResponse> consultarEstado(String identificacion);
}
```

### 2.4 `notificacion_push_handler_port.dart` (8 líneas)

```dart
abstract class NotificacionPushHandlerPort {
  Future<void> inicializar(String usuarioId);
  Future<String?> obtenerToken();
  Stream<String> get onTokenRefresh;
  void manejarTapEnNotificacion(Map<String, dynamic> data);
  void manejarNotificacionEnPrimerPlano(Map<String, dynamic> data);
}
```

---

## 3. CASOS DE USO (`lib/domain/usecases/`)

### 3.1 Notificaciones (6 archivos)

| Archivo | Líneas | Método | Llama a |
|---------|--------|--------|---------|
| `obtener_notificaciones_usecase.dart` | 14 | `execute(usuarioId, {pagina})` | `NotificacionRepositoryPort.obtenerNotificaciones()` |
| `obtener_no_leidas_usecase.dart` | 11 | `execute(usuarioId)` | `NotificacionRepositoryPort.obtenerNoLeidas()` |
| `marcar_notificacion_leida_usecase.dart` | 13 | `execute(usuarioId, notificacionId)` | `NotificacionRepositoryPort.marcarComoLeida()` |
| `marcar_todas_leidas_usecase.dart` | 11 | `execute(usuarioId)` | `NotificacionRepositoryPort.marcarTodasComoLeidas()` |
| `eliminar_notificacion_usecase.dart` | 13 | `execute(usuarioId, notificacionId)` | `NotificacionRepositoryPort.eliminarNotificacion()` |
| `registrar_token_fcm_usecase.dart` | 13 | `execute(usuarioId, token, plataforma)` | `NotificacionRepositoryPort.registrarTokenFCM()` |

### 3.2 Solicitudes de Miembro (2 archivos)

| Archivo | Líneas | Método | Llama a |
|---------|--------|--------|---------|
| `solicitar_registro_miembro_usecase.dart` | 36 | `execute({...11 params})` → `Future<int>` | `SolicitudMiembroRepositoryPort.solicitarRegistro()` |
| `consultar_estado_solicitud_usecase.dart` | 14 | `execute(identificacion)` → `Future<EstadoSolicitudResponse>` | `SolicitudMiembroRepositoryPort.consultarEstado()` |

---

## 4. DIAGRAMA DE RELACIONES

```
────────────────────────────────────────────────────────────────────────
 NOTIFICACIONES
────────────────────────────────────────────────────────────────────────
ObtenerNotificacionesUseCase
  └── NotificacionRepositoryPort
        └── NotificacionRepositoryImpl
              └── NotificacionApiProvider (Dio)
                    └── GET /notificaciones?pagina=1

ObtenerNoLeidasUseCase
  └── NotificacionRepositoryPort
        └── NotificacionApiProvider
              └── GET /notificaciones/no-leidas

MarcarNotificacionLeidaUseCase
  └── NotificacionRepositoryPort
        └── NotificacionApiProvider
              └── PUT /notificaciones/{id}/leer

────────────────────────────────────────────────────────────────────────
 ADMIN NOTIFICACIONES
────────────────────────────────────────────────────────────────────────
AdminNotificacionesRepositoryPort
  └── AdminNotificacionesRepositoryImpl
        └── AdminNotificacionesApiProvider
              └── GET /notificaciones/destinatarios?manzana=&villa=
              └── POST /notificaciones/enviar

────────────────────────────────────────────────────────────────────────
 SOLICITUDES DE MIEMBRO
────────────────────────────────────────────────────────────────────────
SolicitarRegistroMiembroUseCase
  └── SolicitudMiembroRepositoryPort
        └── SolicitudMiembroRepositoryImpl
              └── SolicitudMiembroApiProvider
                    └── POST /miembros/solicitar

ConsultarEstadoSolicitudUseCase
  └── SolicitudMiembroRepositoryPort
        └── SolicitudMiembroApiProvider
              └── GET /miembros/solicitudes/estado/{id}

────────────────────────────────────────────────────────────────────────
 PUSH NOTIFICATIONS
────────────────────────────────────────────────────────────────────────
NotificacionPushHandlerPort (puerto)
  └── NotificacionPushHandlerImpl (adaptador)
        └── FcmProvider (implementación concreta)
              └── FirebaseMessaging
              └── FlutterLocalNotificationsPlugin
```

## 5. LO QUE FALTA: Aprobación/Rechazo desde la app del titular

El puerto `SolicitudMiembroRepositoryPort` actualmente solo tiene:

| Método | Estado |
|--------|--------|
| `solicitarRegistro()` | ✅ Implementado |
| `consultarEstado()` | ✅ Implementado |
| **`aprobarSolicitud(int solicitudId)`** | ❌ No existe |
| **`rechazarSolicitud(int solicitudId, String? motivo)`** | ❌ No existe |
| **`listarSolicitudesPendientes()`** | ❌ No existe |

Estos métodos faltantes son necesarios para que el titular pueda aprobar/rechazar desde la app. El backend ya tiene los endpoints:
- `PUT /api/v1/miembros/solicitudes/{id}/aprobar`
- `PUT /api/v1/miembros/solicitudes/{id}/rechazar`
- `GET /api/v1/miembros/solicitudes/pendientes`

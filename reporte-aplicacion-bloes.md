# Reporte: Capa de Aplicación — BLoCs

**Fecha:** 2026-07-08
**Proyecto:** Guardin

---

## BLoC 1: `NotificacionesBloc` — Notificaciones del residente/miembro

**Archivos:** `application/blocs/notificaciones/` (3 archivos, patrón `part`)

### Dependencias (use cases)

| Inyectado | Tipo |
|-----------|------|
| `ObtenerNotificacionesUseCase` | `final` |
| `ObtenerNoLeidasUseCase` | `final` |
| `MarcarNotificacionLeidaUseCase` | `final` |
| `MarcarTodasLeidasUseCase` | `final` |
| `EliminarNotificacionUseCase` | `final` |

### Eventos (5)

| Evento | Campos | Handler |
|--------|--------|---------|
| `NotificacionesIniciadas` | `usuarioId` | `_onIniciadas` → `_cargarNotificaciones` |
| `NotificacionesRefrescadas` | — | `_onRefrescadas` → `_cargarNotificaciones` |
| `NotificacionMarcadaLeida` | `notificacionId` | `_onMarcarLeida` → actualiza estado local |
| `TodasNotificacionesMarcadasLeidas` | — | `_onMarcarTodasLeidas` → recarga |
| `NotificacionEliminada` | `notificacionId` | `_onEliminar` → recarga |

### Estados (5)

| Estado | Campos |
|--------|--------|
| `NotificacionesCargando` | — |
| `NotificacionesCargadas` | `notificaciones`, `noLeidas` |
| `NotificacionesVacias` | — |
| `NotificacionesError` | `mensaje` |
| `NotificacionesOperacionExitosa` | `mensaje` |

### `close()` behavior

```dart
// Sin StreamSubscription, no requiere close explícito
```

---

## BLoC 2: `AdminNotificacionesBloc` — Admin: envío de notificaciones

**Archivos:** `application/blocs/admin/admin_notificaciones_*` (3 archivos, patrón `part`)

### Dependencias

| Inyectado | Tipo |
|-----------|------|
| `AdminNotificacionesRepositoryPort` | Puerto (inyectado directo, sin use case) |

### Eventos (7)

| Evento | Campos | Handler |
|--------|--------|---------|
| `AdminDestinatariosSolicitados` | `busqueda` | `_onCargarDestinatarios` → carga destinatarios + manzanas |
| `AdminDestinatarioSeleccionado` | `personaId` | `_onSeleccionarDestinatario` → toggle check |
| `AdminSeleccionarTodos` | — | `_onSeleccionarTodos` |
| `AdminDeseleccionarTodos` | — | `_onDeseleccionarTodos` |
| `AdminNotificacionEnviada` | `titulo, mensaje, prioridad, categoria, enviarATodos` | `_onEnviarNotificacion` |
| `AdminFiltroManzanaCambiado` | `manzana` | `_onFiltroManzanaCambiado` |
| `AdminFiltroVillaCambiado` | `villa` | `_onFiltroVillaCambiado` |

### Estados (6)

| Estado | Campos |
|--------|--------|
| `AdminNotificacionesInicial` | — |
| `AdminNotificacionesCargando` | — |
| `AdminDestinatariosCargados` | `destinatarios`, `seleccionados`, `manzanas`, `manzanaSeleccionada`, `villaSeleccionada`, getter `destinatariosSeleccionados` |
| `AdminNotificacionEnviando` | — |
| `AdminNotificacionEnviadaExito` | `enviados`, `mensaje` |
| `AdminNotificacionesError` | `mensaje` |

### Funcionalidades extra

| Helper | Propósito |
|--------|-----------|
| `_cargadosCon(prev, nuevos)` | Preserva `manzanas`, `manzanaSeleccionada`, `villaSeleccionada` al emitir nuevo estado de selección |
| `.timeout(15s)` | Timeout en llamadas a `obtenerDestinatarios` |
| `.timeout(30s)` | Timeout en `enviarNotificacion` |

---

## BLoC 3: `AutorizacionMiembroBloc` — Autorización del titular

**Archivos:** `application/blocs/autorizacion_miembro/` (3 archivos, patrón `part`)

### Dependencias (use cases)

| Inyectado | Tipo |
|-----------|------|
| `SolicitarRegistroMiembroUseCase` | `final` |
| `ConsultarEstadoSolicitudUseCase` | `final` |

### Eventos (3)

| Evento | Campos | Handler |
|--------|--------|---------|
| `SolicitudEnviada` | `identificacionResidente`, `manzana`, `villa`, `identificacion`, `nombres`, `apellidos`, `fechaNacimiento`, `parentesco`, opcionales: `parentescoOtroDesc`, `correo`, `celular` | `_onSolicitudEnviada` → POST solicitud → inicia polling |
| `EstadoSolicitudConsultada` | — | `_onConsultarEstado` → GET estado → aprueba/rechaza/sigue esperando |
| `SolicitudCancelada` | — | `_onCancelar` → cancela timer, estado inicial |

### Estados (6)

| Estado | Campos | Trigger |
|--------|--------|---------|
| `AutorizacionMiembroInicial` | — | Estado inicial |
| `SolicitudEnviando` | — | Mientras se envía POST |
| `EsperandoAutorizacion` | `mensaje`, `notificacionId` | Solicitud enviada, polling activo |
| `AutorizacionAprobada` | `personaId`, `miembroId` | Titular aprobó (polling detecta) |
| `AutorizacionRechazada` | `motivo` | Titular rechazó (polling detecta) |
| `AutorizacionMiembroError` | `mensaje` | Error de red/API |

### Manejo especial de 409

```dart
catch (e) {
  if (errorMsg.contains('409') || errorMsg.contains('solicitud pendiente')) {
    // Ya existe solicitud → iniciar polling directamente
    emit(EsperandoAutorizacion(...));  // ← con mensaje "Ya tienes una solicitud pendiente"
    _iniciarPolling();
  } else {
    emit(AutorizacionMiembroError(...));
  }
}
```

### Lifecycle

```dart
_iniciarPolling() → Timer.periodic(5s) → add(EstadoSolicitudConsultada())
close() → _pollingTimer?.cancel() → super.close()
```

---

## BLoC 4: `MemberBloc` — Gestión de miembros (admin)

**Archivos:** `application/blocs/member/` (3 archivos, eventos y estados con `Equatable`)

### Dependencias (use cases + puerto directo)

| Inyectado | Tipo |
|-----------|------|
| `LoadMembersByLocationUseCase` | `final` |
| `DeactivateMemberUseCase` | `final` |
| `ReactivateMemberUseCase` | `final` |
| `DeleteMemberUseCase` | `final` |
| `CreateMemberUseCase` | `final` |
| `MemberRepository` | Puerto (directo) |

### Eventos (5)

| Evento | Campos | Handler |
|--------|--------|---------|
| `LoadMembersByLocationEvent` | `manzana`, `villa` | `_onLoadMembersByLocation` |
| `DeactivateMemberEvent` | `memberId`, `reason` | `_onDeactivateMember` + auto-refresh |
| `ReactivateMemberEvent` | `memberId`, `reason` | `_onReactivateMember` + auto-refresh |
| `DeleteMemberEvent` | `memberId` | `_onDeleteMember` + auto-refresh |
| `CreateMemberEvent` | `residenteId`, `identificacion`, `tipoIdentificacion`, `nombres`, `apellidos`, `fechaNacimiento`, `manzana`, `villa`, `parentesco`, opcionales: `nacionalidad`, `correo`, `celular`, `direccionAlternativa`, `parentescoOtroDesc`, `usuarioCreado` | `_onCreateMember` |

### Estados (8)

| Estado | Campos | Evento que lo causa |
|--------|--------|-------------------|
| `MemberInitial` | — | Inicial |
| `MemberLoading` | — | Cualquier operación |
| `MembersByLocationLoaded` | `members`, `manzana`, `villa` | `LoadMembersByLocationEvent` |
| `MemberDeactivated` | `message`, `reason` | `DeactivateMemberEvent` |
| `MemberReactivated` | `message`, `reason` | `ReactivateMemberEvent` |
| `MemberDeleted` | `message` | `DeleteMemberEvent` |
| `MemberCreated` | `message`, `member` (Map) | `CreateMemberEvent` |
| `MemberError` | `message` | Cualquier error |

### Auto-refresh

```dart
// Después de desactivar/reactivar/eliminar:
if (state is MembersByLocationLoaded) {
  final currentState = state as MembersByLocationLoaded;
  add(LoadMembersByLocationEvent(manzana: currentState.manzana, villa: currentState.villa));
}
```

---

## Tabla comparativa

| Característica | NotificacionesBloc | AdminNotificacionesBloc | AutorizacionMiembroBloc | MemberBloc |
|---------------|-------------------|----------------------|----------------------|-----------|
| **Patrón** | `part` | `part` | `part` | Archivos separados |
| **Eventos** | 5 | 7 | 3 | 5 |
| **Estados** | 5 | 6 | 6 | 8 |
| **Equatable** | ❌ | ❌ | ❌ | ✅ |
| **Timer interno** | ❌ | ❌ | ✅ (5s polling) | ❌ |
| **Timeout HTTP** | ❌ | ✅ (15s/30s) | ❌ | ❌ |
| **Auto-refresh** | ❌ | ❌ | ❌ | ✅ (en CRUD) |
| **Registro DI** | Factory | Factory | Factory | Factory |
| **Consume puerto directo** | ❌ (usa use cases) | ✅ | ❌ (usa use cases) | ✅ (tiene puerto extra) |
| **close() overridden** | ❌ | ❌ | ✅ (cancela timer) | ❌ |

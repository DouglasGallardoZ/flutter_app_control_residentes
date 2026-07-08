# Diagnóstico: Módulo Admin de Notificaciones

**Fecha:** 2026-07-08
**Proyecto:** Guardin
**Archivos analizados:** 7
**Problemas reportados:** 3

---

## Resumen de archivos

| # | Archivo | Líneas | Rol |
|---|---------|--------|-----|
| 1 | `presentation/pages/admin/admin_notificaciones_page.dart` | 720 | UI completa (formulario + panel destinatarios + filtros) |
| 2 | `application/blocs/admin/admin_notificaciones_bloc.dart` | 241 | BLoC con 7 handlers |
| 3 | `application/blocs/admin/admin_notificaciones_event.dart` | 50 | 7 eventos |
| 4 | `application/blocs/admin/admin_notificaciones_state.dart` | 52 | 6 estados |
| 5 | `infrastructure/providers/admin_notificaciones_api_provider.dart` | 79 | 3 endpoints API |
| 6 | `infrastructure/adapters/admin_notificaciones_repository_impl.dart` | 54 | Adaptador del puerto |
| 7 | `domain/ports/admin_notificaciones_repository_port.dart` | 22 | Interfaz abstracta |

---

## Archivo 1: `admin_notificaciones_page.dart`

```dart
// lib/presentation/pages/admin/admin_notificaciones_page.dart (720 líneas)
```

### Secciones clave

| Líneas | Componente | Descripción |
|--------|-----------|-------------|
| 1-4 | Imports | `flutter/material.dart`, `flutter_bloc`, BLoC, injection |
| 14-30 | State | 3 controllers + 4 state vars (`_prioridad`, `_categoria`, `_enviarATodos`, `_busqueda`) |
| 32-37 | `_recargarDestinatarios` | Dispatch `AdminDestinatariosSolicitados(busqueda: busqueda ?? _busqueda)` |
| 39-94 | `build()` | `BlocProvider(create: sl<AdminNotificacionesBloc>()..add(AdminDestinatariosSolicitados()))` + `BlocConsumer` con layout responsive |
| 96-132 | Layout | Desktop: Row flex(3:form, 2:panel). Mobile: SingleChildScrollView columna |
| 134-286 | `_buildFormulario` | Título, mensaje multilínea, dropdowns categoría+prioridad, Switch "Enviar a todos", botón enviar con loading |
| 288-451 | `_buildPanelDestinatarios` | Filtros → búsqueda → contador + botones → ListView checkboxes |
| 453-650 | `_buildFiltrosUbicacion` | Dropdown manzana + TextField villa + chip filtro activo + botón seleccionar todos |
| 652-720 | `_enviar()` + `_limpiarFormulario()` | Validación, dispatch, limpieza |

---

## Archivo 2: `admin_notificaciones_bloc.dart`

```dart
// lib/application/blocs/admin/admin_notificaciones_bloc.dart (241 líneas)
```

```dart
class AdminNotificacionesBloc extends Bloc<AdminNotificacionesEvent, AdminNotificacionesState> {
  final AdminNotificacionesRepositoryPort _repository;

  AdminNotificacionesBloc(this._repository) : super(AdminNotificacionesInicial()) {
    on<AdminDestinatariosSolicitados>(_onCargarDestinatarios);
    on<AdminDestinatarioSeleccionado>(_onSeleccionarDestinatario);
    on<AdminSeleccionarTodos>(_onSeleccionarTodos);
    on<AdminDeseleccionarTodos>(_onDeseleccionarTodos);
    on<AdminNotificacionEnviada>(_onEnviarNotificacion);
    on<AdminFiltroManzanaCambiado>(_onFiltroManzanaCambiado);
    on<AdminFiltroVillaCambiado>(_onFiltroVillaCambiado);
  }
```

### Handlers

| Handler | Líneas | Comportamiento |
|---------|--------|----------------|
| `_onCargarDestinatarios` | 29-58 | `Future.wait` para destinatarios (sin filtro) + manzanas. **NO preserva manzanaSeleccionada/villaSeleccionada** |
| `_onSeleccionarDestinatario` | 60-75 | Toggle check en destinatario, usa `_cargadosCon` |
| `_onSeleccionarTodos` | 77-90 | Marca todos, usa `_cargadosCon` |
| `_onDeseleccionarTodos` | 92-105 | Desmarca todos, usa `_cargadosCon` |
| `_cargadosCon` helper | 107-119 | Preserva manzanas, manzanaSeleccionada, villaSeleccionada |
| `_onFiltroManzanaCambiado` | 121-158 | Filtra por manzana, preserva villa si manzana no es null |
| `_onFiltroVillaCambiado` | 160-194 | Filtra por villa, preserva manzana |
| `_onEnviarNotificacion` | 196-240 | Emit Enviando → await repository → emit Exito/Error |

---

## Archivo 3: `admin_notificaciones_event.dart`

```dart
// lib/application/blocs/admin/admin_notificaciones_event.dart (50 líneas)
```

| Evento | Campos | Propósito |
|--------|--------|-----------|
| `AdminDestinatariosSolicitados` | `String? busqueda` | Carga inicial o búsqueda |
| `AdminDestinatarioSeleccionado` | `int personaId` | Toggle checkbox |
| `AdminSeleccionarTodos` | — | Marcar todos |
| `AdminDeseleccionarTodos` | — | Desmarcar todos |
| `AdminNotificacionEnviada` | `titulo, mensaje, prioridad, categoria, enviarATodos` | Enviar notificación |
| `AdminFiltroManzanaCambiado` | `String? manzana` | Filtrar por manzana |
| `AdminFiltroVillaCambiado` | `String? villa` | Filtrar por villa |

---

## Archivo 4: `admin_notificaciones_state.dart`

```dart
// lib/application/blocs/admin/admin_notificaciones_state.dart (52 líneas)
```

```
AdminNotificacionesInicial
AdminNotificacionesCargando
AdminDestinatariosCargados
├── List<Destinatario> destinatarios
├── int seleccionados
├── List<String> manzanas
├── String? manzanaSeleccionada
├── String? villaSeleccionada
└── List<int> get destinatariosSeleccionados
AdminNotificacionEnviando
AdminNotificacionEnviadaExito
├── int enviados
└── String mensaje
AdminNotificacionesError ─── String mensaje
```

---

## Archivo 5: `admin_notificaciones_api_provider.dart`

```dart
// lib/infrastructure/providers/admin_notificaciones_api_provider.dart (79 líneas)
```

| Método | HTTP | Endpoint | Params query |
|--------|------|----------|--------------|
| `obtenerDestinatarios` | GET | `/notificaciones/destinatarios` | `busqueda`, `manzana`, `villa` |
| `obtenerManzanas` | GET | `/notificaciones/manzanas` | — |
| `enviarNotificacion` | POST | `/notificaciones/enviar` | Body: `titulo`, `mensaje`, `prioridad`, `categoria`, `destinatario_ids`, `enviar_a_todos` |

---

## Archivo 6: `admin_notificaciones_repository_impl.dart`

```dart
// lib/infrastructure/adapters/admin_notificaciones_repository_impl.dart (54 líneas)
```

Adaptador simple que delega cada método del puerto al `AdminNotificacionesApiProvider`:

- `obtenerDestinatarios(busqueda, manzana, villa)` → apiProvider.obtenerDestinatarios() → map toEntity
- `obtenerManzanas()` → apiProvider.obtenerManzanas()
- `enviarNotificacion(...)` → apiProvider.enviarNotificacion()

---

## Archivo 7: `admin_notificaciones_repository_port.dart`

```dart
// lib/domain/ports/admin_notificaciones_repository_port.dart (22 líneas)

import '../entities/destinatario.dart';

abstract class AdminNotificacionesRepositoryPort {
  Future<List<Destinatario>> obtenerDestinatarios({
    String? busqueda,
    String? manzana,
    String? villa,
  });

  Future<List<String>> obtenerManzanas();

  Future<void> enviarNotificacion({
    required String titulo,
    required String mensaje,
    required String prioridad,
    required String categoria,
    required List<int> destinatarioIds,
    required bool enviarATodos,
    String? rutaAccion,
    Map<String, dynamic>? datosAccion,
  });
}
```

---

## Diagnóstico de problemas

### 🔴 Problema 1: Fondo blanco en "Filtrar por ubicación"

**Archivo:** `admin_notificaciones_page.dart`
**Líneas:** 453-459

```dart
Widget _buildFiltrosUbicacion(BuildContext context, AdminNotificacionesState state) {
  if (state is! AdminDestinatariosCargados) {
    return const SizedBox.shrink();  // ← OCULTA TODO cuando está cargando
  }
```

**Causa raíz:** Durante el estado `AdminNotificacionesCargando` (emitido al enviar→recargar), el método `_buildFiltrosUbicacion` retorna `SizedBox.shrink()`. El `Container` padre (`_buildPanelDestinatarios` línea 292) no tiene color de fondo definido (no hay `color:` en `BoxDecoration`), por lo que se ve blanco.

**Ciclo:** `Enviar` → `_onEnviarNotificacion` emite `AdminNotificacionEnviando()` → listener captura éxito → `_recargarDestinatarios()` → `_onCargarDestinatarios` emite `AdminNotificacionesCargando()` → `_buildFiltrosUbicacion` retorna `SizedBox.shrink()` → no se ve el fondo gris.

---

### 🔴 Problema 2: Filtro no se recarga después de enviar

**Archivo:** `admin_notificaciones_bloc.dart`
**Líneas:** 29-58

```dart
Future<void> _onCargarDestinatarios(
  AdminDestinatariosSolicitados event,
  Emitter<AdminNotificacionesState> emit,
) async {
  emit(AdminNotificacionesCargando());
  try {
    final resultados = await Future.wait([
      _repository.obtenerDestinatarios(busqueda: event.busqueda),
      _repository.obtenerManzanas(),
    ]);

    emit(AdminDestinatariosCargados(
      destinatarios: destinatarios,
      seleccionados: 0,
      manzanas: manzanas,     // ← FALTA: manzanaSeleccionada y villaSeleccionada
    ));
```

**Causa raíz:** `_onCargarDestinatarios` no preserva `manzanaSeleccionada` ni `villaSeleccionada` del estado anterior. Siempre emite con esos campos en `null`. Aunque el usuario tuviera un filtro activo, al recargar (después de enviar o al buscar por texto) se pierde.

**Ciclo:** Usuario filtra por Manzana A → estado tiene `manzanaSeleccionada: "A"` → envía notificación → listener captura éxito → `_recargarDestinatarios()` → `_onCargarDestinatarios` emite `AdminDestinatariosCargados(manzanaSeleccionada: null)` → **el filtro se resetea**.

---

### 🔴 Problema 3: Carga infinita después de enviar

**Archivo:** `admin_notificaciones_page.dart` + `admin_notificaciones_bloc.dart`
**Líneas:** 217-235 (BLoC), 389-446 (UI)

**Flujo que causa el problema:**
1. Usuario hace clic en "Enviar"
2. `_onEnviarNotificacion` → `emit(AdminNotificacionEnviando())` (línea 217)
3. UI muestra `CircularProgressIndicator` en botón (línea 267-273)
4. `await _repository.enviarNotificacion(...)` **se ejecuta**
5. Si OK → `emit(AdminNotificacionEnviadaExito(...))` (línea 229)
6. Listener UI captura éxito → `_recargarDestinatarios(null)` → dispatch `AdminDestinatariosSolicitados`
7. BLoC → `emit(AdminNotificacionesCargando())` (línea 33)
8. UI: `ListView.builder` desaparece porque `state is! AdminDestinatariosCargados`
9. En su lugar muestra `CircularProgressIndicator` (línea 439-442)
10. `Future.wait` (línea 35-38) carga destinatarios + manzanas
11. Si **la API falla** o tarda demasiado → `CircularProgressIndicator` se queda indefinidamente

**Causa raíz:** No hay manejo de timeout en `Future.wait`. Si la API de destinatarios o manzanas falla, el catch captura el error y emite `AdminNotificacionesError`. Pero si la API simplemente no responde, `Future.wait` se queda colgada para siempre y el spinner nunca desaparece.

---

## Resumen de causas

| # | Problema | Archivo | Línea(s) | Causa |
|---|----------|---------|----------|-------|
| 1 | Fondo blanco en filtros | `admin_notificaciones_page.dart` | 457-458 | `SizedBox.shrink()` durante `Cargando` oculta el contenedor gris |
| 2 | Filtro se resetea al recargar | `admin_notificaciones_bloc.dart` | 48-52 | `_onCargarDestinatarios` no preserva `manzanaSeleccionada` ni `villaSeleccionada` |
| 3 | Spinner infinito tras enviar | `admin_notificaciones_bloc.dart` | 33-38 + 439-442 | `Future.wait` sin timeout; si la API no responde, nunca se sale del estado `Cargando` |

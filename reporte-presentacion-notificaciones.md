# Reporte: Capa de Presentación — Notificaciones y Solicitudes de Miembro

**Fecha:** 2026-07-08
**Proyecto:** Guardin

---

## 1. ÁRBOL DE LA CARPETA `presentation/`

```
lib/presentation/
├── pages/
│   ├── access_history_page.dart
│   ├── admin_access_history_page.dart
│   ├── admin_accounts_page.dart
│   ├── admin_create_member_page.dart
│   ├── admin_create_owner_page.dart
│   ├── admin_create_resident_page.dart
│   ├── admin_dashboard_page.dart
│   ├── admin_facial_enrollment_page.dart
│   ├── admin_members_page.dart
│   ├── admin_owners_page.dart
│   ├── admin_profile_page.dart
│   ├── admin_residents_page.dart
│   ├── admin_users_page.dart
│   ├── admin/              ← admin_notificaciones_page.dart
│   ├── create_spouse_dialog.dart
│   ├── credentials_miembro_page.dart
│   ├── credentials_residente_page.dart
│   ├── facial_verification_page.dart
│   ├── family_dashboard_page.dart
│   ├── login_page.dart
│   ├── member_create_registration_page.dart
│   ├── member_facial_enrollment_page.dart
│   ├── members_page.dart
│   ├── miembros/           ← esperar_autorizacion_page.dart (1 archivo)
│   ├── notificaciones/     ← notificacion_detalle_page.dart + notificaciones_lista_page.dart (2 archivos)
│   ├── profile_page.dart
│   ├── prospecto_miembro_page.dart
│   ├── prospecto_residente_page.dart
│   ├── qr_display_page.dart / qr_list_page.dart / qr_self_page.dart / qr_view_page.dart / qr_visit_page.dart
│   ├── register_option_page.dart
│   ├── resident_dashboard_page.dart
│   └── spouse_list_widget.dart
├── routes/
│   └── app_routes.dart           ← Router principal (483 líneas)
├── theme/
│   ├── app_theme.dart
│   └── theme_controller.dart
└── widgets/
    ├── activity_item.dart
    ├── admin_scaffold.dart
    ├── app_scaffold.dart
    ├── camera_facial_view.dart
    ├── facial_capture/ (3 archivos)
    ├── form_fields.dart
    ├── insignia_notificaciones.dart  ← Badge de notificaciones (122 líneas)
    ├── list_items.dart
    ├── metric_card.dart
    ├── navigation_helpers.dart
    ├── qr_list_card.dart / qr_preview.dart
    ├── responsive_layout.dart
    └── tarjeta_notificacion.dart    ← Card de notificación (141 líneas)
```

---

## 2. PÁGINAS DE NOTIFICACIONES

### 2.1 `notificacion_detalle_page.dart` (195 líneas)

| Sección | Líneas | Descripción |
|---------|--------|-------------|
| Constructor | 4-10 | Recibe `NotificacionItem notificacion` |
| AppBar | 14-31 | Título "Detalle de Notificación". Botón "Ver más" en actions SI `rutaAccion != null` → `Navigator.pushNamed(context, notificacion.rutaAccion!, arguments: notificacion.datosAccion)` |
| Ícono categoría | 39-41 | `_buildIconoCategoria()`: círculo 80px con ícono según categoría |
| Prioridad alta | 43-64 | Badge "Prioridad Alta" si `esPrioridadAlta` |
| Título | 66-74 | `headlineSmall`, bold |
| Fecha + categoría | 76-108 | Row con ícono reloj + tiempo transcurrido + chip de categoría |
| Cuerpo | 112-118 | `bodyLarge` con `height: 1.6` |
| Botón acción | 120-137 | Si `rutaAccion != null`, botón "Ir a la acción relacionada" → `Navigator.pushNamed` |

**NO tiene lógica condicional por tipo.** Solo usa `rutaAccion` y `datosAccion` que vienen del backend.

### 2.2 `notificaciones_lista_page.dart` (160 líneas)

| Sección | Líneas | Descripción |
|---------|--------|-------------|
| Constructor | 8-14 | Recibe `String usuarioId` |
| `BlocProvider` | 18-20 | Crea `NotificacionesBloc` via `sl<...>()` y dispatch `NotificacionesIniciadas` |
| AppBar | 22-42 | Título "Notificaciones". Botón "Leer todas" si hay > 0 no leídas |
| `BlocConsumer` | 44-156 | Listener: SnackBar en `NotificacionesOperacionExitosa` |
| Estado Cargando | 56-60 | `CircularProgressIndicator` |
| Estado Vacías | 63-85 | Icono `notifications_off` + "No tienes notificaciones" |
| Estado Cargadas | 88-144 | `RefreshIndicator` + `ListView.builder` con `TarjetaNotificacion` |
| `onTap` | 106-131 | Marca como leída + `Navigator.push(NotificacionDetallePage)` + refresh al regresar |
| `onDelete` | 133-140 | Dispatch `NotificacionEliminada` |

---

## 3. PÁGINAS DE MIEMBROS

### 3.1 `miembros/esperar_autorizacion_page.dart` (253 líneas)

| Sección | Líneas | Descripción |
|---------|--------|-------------|
| Constructor | 6-35 | 10 required params + 2 opcionales |
| `BlocProvider` | 41-58 | Crea `AutorizacionMiembroBloc` via `sl<...>()` y dispatch `SolicitudEnviada(...)` con todos los datos |
| AppBar | 60-63 | Título "Autorización Pendiente" |
| `BlocListener` | 65-110 | **Navegación:** `AutorizacionAprobada` → `pushReplacementNamed('/memberFacialEnrollment')`. `AutorizacionRechazada` → diálogo → `pushNamedAndRemoveUntil('/login')` |
| `BlocBuilder` | 111-218 | UI según estado: `SolicitudEnviando` → spinner. `EsperandoAutorizacion` → reloj + Card info. `AutorizacionMiembroError` → error icon |
| Card info | 167-198 | Muestra nombre completo, parentesco, dirección en formato `Mz X, Villa Y` |
| Polling status | 199-210 | Muestra "Revisando cada 5 segundos..." durante `EsperandoAutorizacion` |
| `_getMensaje()` | 224-236 | Helper que extrae mensaje según estado |
| `_buildInfoRow()` | 238-252 | Helper Row con icono + texto |

---

## 4. WIDGETS REUTILIZABLES

### 4.1 `tarjeta_notificacion.dart` (141 líneas)

```dart
class TarjetaNotificacion extends StatelessWidget {
  final NotificacionItem notificacion;
  final VoidCallback onTap;       // Al hacer tap
  final VoidCallback onDelete;     // Al deslizar para eliminar
```

| Funcionalidad | Líneas | Descripción |
|---------------|--------|-------------|
| `Dismissible` | 18-52 | Swipe-to-delete con confirmación (`showDialog`) |
| `ListTile` | 53-87 | `leading`: CircleAvatar con ícono según categoría. `title`: título (bold si no leído). `subtitle`: cuerpo (max 2 líneas) + timestamp. `trailing`: indicador de no leído + flag de prioridad alta |
| `_buildIcono()` | 90-120 | CircleAvatar con color según categoría: seguridad→red, visita→blue, pago→green, evento→purple, default→orange |
| `_buildIndicadores()` | 122-140 | Punto azul si no leído + flag rojo si prioridad alta |

### 4.2 `insignia_notificaciones.dart` (122 líneas)

```dart
class InsigniaNotificaciones extends StatefulWidget {
  final String usuarioId;
  final VoidCallback? onTap;  // Si null, navega a /notificaciones
```

| Funcionalidad | Líneas | Descripción |
|---------------|--------|-------------|
| `WidgetsBindingObserver` | 23, 30, 40 | Observa lifecycle → refresca al `resumed` |
| `Timer.periodic(30s)` | 32-35 | Polling cada 30s para actualizar badge |
| `_cargarNoLeidas()` | 60-71 | Llama `ObtenerNoLeidasUseCase.execute(usuarioId)` |
| `build()` | 73-121 | `Stack`: IconButton + badge rojo circular con conteo (99+ max) |

**Navegación por defecto:** `Navigator.pushNamed(context, '/notificaciones', arguments: widget.usuarioId)`

---

## 5. SISTEMA DE RUTAS (`app_routes.dart` — 483 líneas)

### Constantes (37 rutas)

| Grupo | Rutas |
|-------|-------|
| **Auth/Login** | `/login`, `/registerOption` |
| **Registro** | `/prospectoResidente`, `/prospectoMiembro`, `/facialVerification`, `/credentialsResidente`, `/credentialsMiembro` |
| **Miembro** | `/memberCreateRegistration`, `/memberFacialEnrollment`, `/esperarAutorizacion` |
| **Residente** | `/residentDashboard`, `/qrSelf`, `/qrVisit`, `/qrList`, `/accessHistory`, `/profile`, `/members`, `/notificaciones`, `/notificaciones/detalle` |
| **Admin** | `/adminDashboard`, `/adminAccessHistory`, `/adminUsers`, `/adminResidents`, `/adminOwners`, `/adminMembers`, `/adminAccounts`, `/adminCreateResident`, `/adminCreateOwner`, `/adminCreateMember`, `/adminFacialEnrollment`, `/adminProfile`, `/adminNotificaciones` |
| **Familia** | `/familyDashboard` |

### Generador de rutas (`onGenerateRoute`)

Usa `switch(settings.name)` con 37 cases. Los argumentos se pasan via `settings.arguments`:

- **Tipos primitivos**: `arguments as String?` (identificacion, usuarioId)
- **Mapas tipados**: `arguments as Map<String, dynamic>?` (args con personaId, identificacion, etc.)
- **Objetos de dominio**: `arguments as ProspectoResidente`, `arguments as NotificacionItem`
- **BLoC providers**: Algunas rutas envuelven la página con `BlocProvider` (ej: `ProspectoValidationBloc`, `RegistroResidenteBloc`, `QrListBloc`)
- **Transiciones**: `_fadeRoute()` usa FadeTransition (150ms) para páginas principales. `MaterialPageRoute` para formularios/modal pages. `_errorRoute()` para rutas inválidas.

### Argumentos que fluyen entre páginas

```
/memberFacialEnrollment → { personaId, nombres, apellidos, type }
/esperarAutorizacion   → { identificacion, nombres, apellidos, parentesco, manzana, villa, fechaNacimiento, correo, celular, identificacionResidente }
/facialVerification   → ProspectoResidente como argument (no Map)
/notificaciones/detalle → NotificacionItem como argument (no Map)
/notificaciones       → String usuarioId como argument
/credentialsMiembro   → Map { prospecto, imagePath }
/memberCreateRegistration → String identificacion como argument
```

---

## 6. RESUMEN DE FLUJO DE PRESENTACIÓN

### Flujo de notificación desde tap

```
InsigniaNotificaciones (badge)
  → Navigator.pushNamed('/notificaciones', usuarioId)
  → NotificacionesListaPage (BlocProvider)
    → TarjetaNotificacion (onTap)
      → NotificacionDetallePage (if rutaAccion != null → Navigator.pushNamed(rutaAccion, datosAccion))
```

### Flujo de autorización (nuevo)

```
ProspectoMiembroPage → MemberCreateRegistrationPage(requiereAutorizacion: true)
  → EsperarAutorizacionPage (BlocProvider)
    → BlocListener: AutorizacionAprobada → /memberFacialEnrollment
    → BlocListener: AutorizacionRechazada → diálogo → /login
    → BlocBuilder: spinner / reloj / error según estado
```

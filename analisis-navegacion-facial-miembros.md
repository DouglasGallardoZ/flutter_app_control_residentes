# Análisis: Navegación a Facial en Registro de Miembros

**Fecha:** 2026-07-08
**Proyecto:** Guardin

---

## Puntos de navegación encontrados

### 1. `prospecto_miembro_page.dart` — 2 puntos de navegación

| Línea | Ruta destino | Condición | Estado actual |
|-------|-------------|-----------|---------------|
| **46** | `MemberCreateRegistrationPage` (inline) | Miembro NO encontrado en validación → diálogo "Registrarme" | ✅ Crea persona vía API, luego navega a `/memberFacialEnrollment` (línea **202** de member_create_registration_page) |
| **92** | `/esperarAutorizacion` (navegación nombrada) | Miembro SÍ encontrado en validación | ✅ Ya modificado para ir a autorización del titular |

### 2. `member_create_registration_page.dart` — 1 punto de navegación

| Línea | Ruta destino | Condición | Estado actual |
|-------|-------------|-----------|---------------|
| **202** | `MemberFacialEnrollmentPage` (inline, con `FacialEnrollmentBloc`) | Creación de miembro exitosa (`MemberCreated` state) | ✅ Correcto: ocurre DESPUÉS de crear la persona |

### 3. `esperar_autorizacion_page.dart` — 1 punto de navegación

| Línea | Ruta destino | Condición | Estado actual |
|-------|-------------|-----------|---------------|
| **99** | `/memberFacialEnrollment` (navegación nombrada con `pushReplacementNamed`) | Estado `aprobado` del titular | ✅ Correcto: ocurre DESPUÉS de que el titular autorice |

---

## Flujo completo después de cambios

### Flujo A: Miembro encontrado (solicitud de registro)

```
ProspectoMiembroPage
├── Valida cédula → ProspectoMiembroValidado
├── Navega a /esperarAutorizacion (línea 92)
│   ├── POST /miembros/solicitar → notifica al titular
│   ├── Polling 5s:
│   │   ├── pendiente → esperar
│   │   ├── aprobado → Navega a /memberFacialEnrollment ✓
│   │   └── rechazado → dialogo → /login
│   └── NO hay facial antes de autorización ✓
```

### Flujo B: Miembro no encontrado (registro nuevo)

```
ProspectoMiembroPage
├── Valida cédula → error "no encontrado"
├── Dialogo → "¿Deseas registrarte?" → MemberCreateRegistrationPage (línea 46)
│   ├── Formulario: nombres, apellidos, fecha nacimiento, parentesco, etc.
│   ├── Envía POST para crear persona → MemberCreated
│   ├── Navega a MemberFacialEnrollmentPage (línea 202)
│   │   └── Captura facial + enrolla rostro
│   └── NO hay facial antes de crear persona ✓
```

---

## Conclusión

**No hay facial antes de autorización.** Ambos flujos están correctamente secuenciados:

| Flujo | ¿Facial antes de autorización? |
|-------|-------------------------------|
| A (miembro encontrado) | ❌ No. Facial ocurre DESPUÉS de que el titular apruebe |
| B (miembro no encontrado) | ❌ No. Facial ocurre DESPUÉS de crear la persona |

Los cambios realizados previamente (navegar a `/esperarAutorizacion` en vez de `/facialVerification`) ya resolvieron el problema para el Flujo A. No se requieren cambios adicionales.

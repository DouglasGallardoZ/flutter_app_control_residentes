# Reporte: ANR en ProspectoMiembroPage

**Fecha:** 2026-07-08

---

## 1. `prospecto_miembro_page.dart` (263 líneas)

| Sección | Líneas | Descripción |
|---------|--------|-------------|
| Constructor | 12-17 | Sin parámetros, `const` |
| State fields | 19-21 | `cedulaCtrl` (TextEditingController), `formKey` (GlobalKey) |
| `dispose()` | 23-27 | Solo dispose del controller |
| `_showCreateMemberDialog()` | 29-64 | Diálogo "Miembro No Registrado" → `push(MemberCreateRegistrationPage)` con `BlocProvider<MemberBloc>` |
| `_navegarConDialogoInformativo()` | 66-106 | Diálogo informativo + `pushReplacementNamed(memberFacialEnrollment)` |
| **`build()`** | 108-262 | Scaffold → Container(gradient) → Card → BlocListener → Form → TextFormField → Button |

### UI

```dart
Scaffold
  └── Container (LinearGradient full-screen)
        └── Center
              └── ConstrainedBox (maxWidth: 420)
                    └── Card (elevation: 6, borderRadius: 16)
                          └── Padding(24)
                                └── BlocListener<ProspectoValidationBloc>
                                      └── BlocBuilder
                                            └── Form
                                                  ├── Icon(Icons.badge, 48px)
                                                  ├── Text('Validar Identidad')
                                                  ├── TextField (cédula)
                                                  └── ElevatedButton('Validar')
```

---

## 2. `prospecto_validation_bloc.dart` (62 líneas)

```dart
class ProspectoValidationBloc {
  final ValidarProspectoResidenteUseCase validarResidente;
  final ValidarProspectoMiembroUseCase validarMiembro;

  // 3 eventos: ValidarProspectoResidente, ValidarProspectoMiembro, LimpiarValidacion
  // 4 estados: Initial, Loading, ResidenteValidado, MiembroValidado, Error

  // Sin StreamSubscription
  // Sin Timer
  // Sin close() override
}
```

### `prospecto_validation_event.dart` (13 líneas)

```dart
abstract class ProspectoValidationEvent {}
class ValidarProspectoResidente extends ProspectoValidationEvent { String identificacion; }
class ValidarProspectoMiembro extends ProspectoValidationEvent { String identificacion; }
class LimpiarValidacion extends ProspectoValidationEvent {}
```

### `prospecto_validation_state.dart` (22 líneas)

```dart
abstract class ProspectoValidationState {}
class ProspectoValidationInitial extends ProspectoValidationState {}
class ProspectoValidationLoading extends ProspectoValidationState {}
class ProspectoResidenteValidado extends ProspectoValidationState { ProspectoResidente prospecto; }
class ProspectoMiembroValidado extends ProspectoValidationState { ProspectoMiembro prospecto; }
class ProspectoValidationError extends ProspectoValidationState { String message; }
```

---

## 3. `register_option_page.dart` (125 líneas)

`StatelessWidget` con 2 botones + 1 botón "Volver". Sin BLoC, sin listeners, sin streams.

---

## 4. `auth_bloc.dart` (180 líneas) — Auth SYNC

### StreamSubscription activo (líneas 120-143)

```dart
StreamSubscription<AuthResult?>? _authStateSubscription;

void _listenAuthStateChanges() {
  _authStateSubscription = authProvider.authStateChanges.listen((user) {
    print(' AUTH SYNC: authStateChanges emitido -> usuario=${user?.uid}');
    
    if (_isLoggingOut) return;
    
    if (user == null) {
      if (!isClosed) add(CheckAuthStatus());
      return;
    }
    
    if (!isClosed) add(CheckAuthStatus());
  });
}
```

- **Se suscribe en el constructor** (línea 38) — nunca se cancela hasta que el BLoC se cierra
- **AuthBloc es LazySingleton** — vive toda la app
- **`CheckAuthStatus`** hace `getCurrentUser.execute()` + `accountRepo.getById(uid)` que son llamadas HTTP
- **Se dispara en CADA cambio de auth state** (login, logout, token refresh, app resume)

### ¿El ANR durante escritura podría ser causado por esto?

| Condición | ¿Dispara authStateChanges? |
|-----------|---------------------------|
| Usuario escribiendo en TextField | ❌ No |
| Usuario presiona "Validar" | ❌ No (solo event local) |
| Token Firebase expira/refresca | ✅ Sí (pero es infrecuente) |
| App pasa a background/resume | ✅ Sí (Firebase re-verifica auth) |

**No es la causa del ANR durante escritura.** Pero podría contribuir si el token expira justo mientras se escribe.

---

## 5. Diagnóstico del ANR

El ANR ocurre mientras el usuario ESCRIBE su cédula. Sin llamadas HTTP, sin cámara, sin BLoC events. Solo:
1. `TextFormField` con `keyboardType: TextInputType.number` → teclado numérico abierto
2. `LinearGradient` en el Container de fondo
3. `Card(elevation: 6)` con sombra
4. Formulario con validación en cada keystroke

### Causa más probable

| Factor | Impacto en Mali GPU |
|--------|---------------------|
| `LinearGradient` full-screen | Cada keystroke → setState → rebuild → gradient re-renderizado |
| `Card(elevation: 6)` | Sombra compleja que Impeller procesa con `cancelAndRedraw` |
| TextFormField + teclado | Cambia layout → invalida toda la escena → Impeller reinicia pipeline |
| **GPU Mali saturación** | 200+ cancelAndRedraw/frame → driver timeout → ANR |

### Solución

Simplificar la UI para reducir la carga de GPU:

1. **Reemplazar `LinearGradient`** con un color sólido `Color(0xFF04345C)` o eliminar el Container decorativo
2. **Reducir `elevation`** de 6 a 1 o usar `elevation: 0` con `shape` solo
3. **Convertir a `SingleChildScrollView`** si hay overflow (el teclado comprime el layout)
4. **Deshabilitar Impeller** en AndroidManifest.xml si no está ya hecho

# Verificación de Consistencia y Checklist de Pruebas — Guardin Logout

**Fecha:** Julio 2026

---

## 1. Verificación de Consistencia de Dependencias

### 1.1 Cadena de logout

```
UI (_confirmLogout)
  ├── LogoutRequested (AuthBloc)                ← línea 145 profile, 64 admin, 112 login
  ├── SessionTerminated (SecuritySessionBloc)    ← línea 146 profile, 67 admin, 113 login
  └── pushNamedAndRemoveUntil('/login')          ← línea 148 profile, 69 admin

AuthBloc.on<LogoutRequested>
  ├── _isLoggingOut = true
  ├── logout.execute()
  │   ├── performFullLogout.execute()            ← PerformFullLogoutUseCase (SIEMPRE)
  │   │   └── sessionCleanup.clearAllSessions()  ← SessionCleanupPort
  │   │       ├── POST /auth/logout (backend 8080)
  │   │       ├── firebaseProvider.logout() (reintentos 2x)
  │   │       ├── generalHttpClient.clearToken()
  │   │       ├── biometryHttpClient.clearToken()
  │   │       └── waitPropagation(100ms)
  │   └── authRepository.logout()               ← Firebase signOut (compatibilidad)
  ├── emit(AuthInitial())
  └── [500ms delay] → _isLoggingOut = false

SecuritySessionBloc.on<SessionTerminated>
  └── _cancelTtlTimer() → emit(SecuritySessionLocked)

AuthBloc._listenAuthStateChanges
  ├── authStateChanges emite null → _isLoggingOut? true → IGNORADO
  └── [500ms después] → _isLoggingOut = false → dispuesto a escuchar
```

### 1.2 Registro en injection.dart

| Dependencia | Tipo | Estado |
|---|---|---|
| `AuthBloc` | `registerLazySingleton` | ✅ Con `authProvider: sl<FirebaseAuthProviderPort>()` |
| `LogoutUseCase` | `registerLazySingleton` | ✅ Con `performFullLogout: sl<PerformFullLogoutUseCase>()` |
| `PerformFullLogoutUseCase` | `registerLazySingleton` | ✅ Con `sessionCleanup: sl<SessionCleanupPort>()` |
| `SessionCleanupPort` → `SessionCleanupImpl` | `registerLazySingleton` | ✅ Con `authProvider`, `generalHttpClient`, `biometryHttpClient` |
| `SecuritySessionBloc` | `registerLazySingleton` | ✅ Handler `SessionTerminated` registrado |
| `ApiHttpClient` (general) | `registerLazySingleton` | ✅ Con `clearToken()` |
| `ApiHttpClient` (biometry) | `registerLazySingleton` (named) | ✅ Con `clearToken()` |

### 1.3 Orden de operaciones en los 3 caminos de logout

| Paso | profile_page.dart | admin_profile_page.dart | login_page.dart |
|---|---|---|---|
| 1. Diálogo confirmación | ✅ showDialog | ✅ showDialog | N/A (automático) |
| 2. LogoutRequested | ✅ línea 145 | ✅ línea 64 | ✅ línea 112 |
| 3. SessionTerminated | ✅ línea 146 | ✅ línea 67 | ✅ línea 114 |
| 4. pushNamedAndRemoveUntil('/login') | ✅ línea 148 | ✅ línea 69 | N/A (ya en /login) |
| 5. FocusScope.unfocus() | N/A | N/A | ✅ línea 111 |
| 6. SnackBar informativo | N/A | N/A | ✅ línea 115 |

### 1.4 Consistencia de eventos por página

**`profile_page.dart`:**
```dart
LogoutRequested                     // ← AuthBloc
SessionTerminated                   // ← SecuritySessionBloc
pushNamedAndRemoveUntil('/login')    // ← navegación
```
✅ Ordene correcto. Ambos eventos despachados antes de navegar.

**`admin_profile_page.dart`:**
```dart
LogoutRequested                     // ← AuthBloc
SessionTerminated                   // ← SecuritySessionBloc
pushNamedAndRemoveUntil('/login')    // ← navegación
```
✅ Ordene correcto.

**`login_page.dart`:**
```dart
_isNavigating = false              // ← reset del flag
FocusScope.unfocus()               // ← limpia teclado
LogoutRequested                     // ← AuthBloc
SessionTerminated                   // ← SecuritySessionBloc
```
✅ No necesita navegación (ya está en /login).

### 1.5 Conflictos potenciales — Verificados

| Escenario | Resultado |
|---|---|
| `authStateChanges` emite null durante logout | ✅ `_isLoggingOut = true` → ignorado |
| `authStateChanges` emite User durante logout | ✅ `_isLoggingOut = true` → ignorado por 500ms |
| Backend `/auth/logout` no responde | ✅ `SessionCleanupImpl` captura error y continúa |
| Firebase signOut falla | ✅ 2 reintentos con 500ms delay |
| AuthBloc emite AuthFailure en logout | ✅ Navegación a /login ya ocurrió antes del error |
| TTL timer activo durante logout | ✅ `SessionTerminated` → `_cancelTtlTimer()` |
| Dio interceptor mantiene token | ✅ `clearToken()` en ambos clientes |
| Doble logout (dos taps rápidos) | ✅ `_isLoggingOut = true` bloquea listener |

---

## 2. Checklist de Pruebas Manuales

### MOBILE

- [ ] **Login normal → dashboard → logout → /login**  
  *Esperado: Formulario de login visible, interactivo, sin datos residuales.*

- [ ] **Logout → cerrar y reabrir app → debe mostrar /login**  
  *Esperado: La app NO hace auto-login. Muestra el formulario de login.*

- [ ] **Logout sin conexión a internet → limpieza local**  
  *Esperado: Cierra sesión localmente. Muestra SnackBar de advertencia si backend no accesible, pero completa el logout local.*

- [ ] **Login → agregar miembros → logout → login con otra cuenta → sin datos residuales**  
  *Esperado: El nuevo usuario ve SOLO sus datos. No hay miembros, QR, o accesos de la sesión anterior.*

- [ ] **Logout desde admin → login residente → sin confusión de roles**  
  *Esperado: El residente ve su dashboard, NO el panel admin. Los BLoCs de admin no interfieren.*

### WEB

- [ ] **Login → logout → F5 refrescar → /login**  
  *Esperado: La página NO hace auto-login. Muestra formulario.*

- [ ] **Login → logout → abrir nueva pestaña → /login**  
  *Esperado: La nueva pestaña muestra formulario de login, NO redirige al dashboard.*

- [ ] **Login en pestaña 1 + login en pestaña 2 → logout pestaña 1 → pestaña 2 detecta sesión cerrada**  
  *Esperado: Pestaña 2 debería eventualmente redirigir a /login cuando `authStateChanges` emita null. Puede tardar unos segundos por la propagación de Firebase.*

- [ ] **Logout → F12 → Application → Local Storage → sin tokens**  
  *Esperado: No hay keys relacionadas con `firebase:authUser:`, `user_session`, `auth_token`, `user_role`, `user_email`.*

- [ ] **Logout → F12 → Application → Cookies → sin sesión Firebase**  
  *Esperado: No hay cookies de sesión activas de Firebase Auth.*

---

## 3. Resumen de Archivos Creados/Modificados

### Archivos creados (4)

| Archivo | Propósito |
|---|---|
| `lib/domain/ports/session_cleanup_port.dart` | Puerto de limpieza de sesión |
| `lib/domain/ports/http_client_port.dart` | Puerto del cliente HTTP |
| `lib/domain/usecases/perform_full_logout_usecase.dart` | Caso de uso para limpieza completa |
| `lib/infrastructure/adapters/session_cleanup_impl.dart` | Adaptador de limpieza de sesión |

### Archivos modificados (9)

| Archivo | Cambio |
|---|---|
| `lib/application/blocs/auth/auth_bloc.dart` | +51 líneas: `authStateChanges` listener + `_isLoggingOut` flag + `authProvider` dependency |
| `lib/application/blocs/security_session/security_session_event.dart` | +4 líneas: `SessionTerminated` event |
| `lib/application/blocs/security_session/security_session_bloc.dart` | +10 líneas: `_onTerminated` handler |
| `lib/domain/usecases/logout_usecase.dart` | +11 líneas: `PerformFullLogoutUseCase` dependency |
| `lib/infrastructure/providers/http_client.dart` | +26 líneas: `clearToken()` / `setToken()` / logs |
| `lib/injection.dart` | +50 líneas: registros de puertos, use cases, y dependencias |
| `lib/presentation/pages/admin_profile_page.dart` | 1 línea: `LockSessionRequested` → `SessionTerminated` |
| `lib/presentation/pages/login_page.dart` | 1 línea: `LockSessionRequested` → `SessionTerminated` |
| `lib/presentation/pages/profile_page.dart` | 1 línea: `LockSessionRequested` → `SessionTerminated` |

---

## 4. Test de Integración Automatizado (Opcional)

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:guardin/application/blocs/auth/auth_bloc.dart';
import 'package:guardin/application/blocs/auth/auth_event.dart';
import 'package:guardin/application/blocs/auth/auth_state.dart';

void main() {
  group('AuthBloc - Logout', () {
    late AuthBloc authBloc;

    // Configurar mocks para LoginUseCase, LogoutUseCase, etc.
    // ...

    test('LogoutRequested deve emitir AuthInitial e executar limpeza', () {
      // Arrange
      authBloc.emit(AuthSuccess(mockSession));

      // Act
      authBloc.add(LogoutRequested());
      await expectLater(
        authBloc.stream,
        emitsInOrder([AuthInitial()]),
      );

      // Assert
      // Verificar que SessionCleanupImpl.clearAllSessions() fue llamado
      // Verificar que AuthRepository.logout() fue llamado
    });
  });
}
```

*Nota: Para pruebas completas se requiere mock de BLoC, Firestore, y otros servicios.*

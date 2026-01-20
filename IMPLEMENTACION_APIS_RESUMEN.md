# Implementación de APIs Backend - Resumen de Cambios

## 📋 Resumen Ejecutivo

Se ha completado la migración del proyecto de **Firestore a APIs REST** manteniendo la **arquitectura hexagonal** y los **patrones BLoC**. El sistema ahora utiliza:

- ✅ **Firebase Auth** para autenticación
- ✅ **APIs REST** para datos de negocio
- ✅ **JWT de Firebase** para autenticación en requests
- ✅ **Email/Password** en lugar de cédula/identificación
- ✅ **UUID** (Firebase UID) como identificador principal

---

## 🔄 Cambios Principales por Capa

### 1. **Capa Domain (Sin cambios de puertos públicos)**

#### Entities:
- `Account`: Actualizada para usar `firebaseUid`, `personaId`, `correo`, `vivienda` (con manzana/villa)
- Nueva entity `Vivienda` con información de la residencia

#### Puertos (Interfaces):
- `AuthRepository`: Añadido `Stream<Map?> authStateChanges` y `Future<String?> getIdToken()`
- `AccessHistoryRepository`: Cambiado para aceptar parámetros de paginación sin `accountId`
- Mantienen la separación de concerns

#### Use Cases:
- `LoginUseCase`: Ahora retorna datos completos del perfil del usuario
- `LoadAccessHistoryUseCase`: Acepta parámetros de paginación
- `GenerateQrUseCase`: Sin cambios funcionales

---

### 2. **Capa Infrastructure**

#### Providers (Nuevos):
- **`ApiHttpClient`**: Cliente HTTP con interceptor de JWT de Firebase
  - Maneja tokens Firebase automáticamente
  - Configuración centralizada de headers y URL base

- **`ApiAuthProvider`**: Interfaz con endpoints de autenticación
  - `login()`: POST /auth/login
  - `obtenerPerfil()`: GET /cuentas/perfil/{firebaseUid}
  - `crearCuentaResidente()`: POST /cuentas/residente/firebase
  - `crearCuentaMiembro()`: POST /cuentas/miembro/firebase

- **`QrApi`**: Interfaz con endpoints QR
  - `generarQRPropio()`: POST /qr/generar-propio
  - `generarQRVisita()`: POST /qr/generar-visita
  - `listarQRs()`: GET /qr/cuenta/generados (con paginación)

- **`AccessHistoryApi`**: Interfaz con endpoints de acceso
  - `obtenerHistorial()`: GET /acceso/historial (con paginación)
  - `validarQR()`: POST /acceso/validar-qr

#### DTOs (Nuevos):
- **`PerfilUsuarioDTO`**: Mapea respuesta GET /cuentas/perfil/{uid}
- **`ViviendaDTO`**: Información de vivienda (manzana, villa)
- **`QRResponseDTO`**: Mapea respuestas de QR
- **`QRListResponseDTO`**: Respuestas paginadas de QR

#### Adapters (Actualizados):
- **`AuthRepositoryImpl`**: 
  - Integra Firebase Auth + API
  - Valida en Firebase y obtiene perfil del API
  - Maneja obtención de tokens

- **`AccountRepositoryImpl`**: 
  - Obtiene perfil desde GET /cuentas/perfil/{uid}
  - Crea cuentas en API después de registrarse en Firebase

- **`QrRepositoryImpl`**: 
  - Reemplaza Firestore por API
  - Formatea fechas sin dependencia de intl (formato manual)
  - Respeta cambios de parámetros

- **`AccessHistoryRepositoryImpl`**: 
  - Obtiene historial desde API
  - Mapea respuesta a entidades de dominio
  - Soporta paginación

---

### 3. **Capa Application (BLoCs)**

#### AuthBloc:
- `LoginSubmitted`: Cambiado de `(id, password)` a `(email, password)`
- Mantiene estados: `AuthInitial`, `AuthLoading`, `AuthSuccess`, `AuthFailure`
- Integra logout correctamente

#### AccessHistoryBloc:
- `LoadAccessHistory`: Sin parámetros, pero soporta paginación opcional
- Mantiene flujo de loading/loaded/error

---

### 4. **Capa Presentation**

#### LoginPage:
- Campo "Identificación" → Campo "Correo Electrónico"
- Validación por formato email en lugar de 10 dígitos
- Mantiene diseño visual existente (gradiente azul-morado)
- Controladores actualizados: `emailCtrl`, `passCtrl`

#### Rutas:
- Navegación post-login basada en `rol` (residente/miembro_familia/admin)
- Pasa `personaId` en lugar de `userId`
- Mantiene argumentos de `residenceId` y `userName`

---

## 📦 Inyección de Dependencias (injection.dart)

```dart
// Configuración centralizada
const String apiBaseUrl = 'http://localhost:8000/api/v1';

// Se registran en orden:
1. Firebase Auth
2. ApiHttpClient (con interceptor JWT)
3. Providers (FirebaseAuthProvider, ApiAuthProvider, QrApi, AccessHistoryApi)
4. Adapters (Repositories)
5. Use Cases
```

---

## 🔐 Flujo de Autenticación

```
1. Usuario ingresa email/password en LoginPage
2. AuthBloc emite LoginSubmitted
3. LoginUseCase llama a AuthRepository.login()
4. AuthRepositoryImpl:
   a. Autentica en Firebase (credenciales email/password)
   b. Obtiene ID Token de Firebase
   c. Llama GET /cuentas/perfil/{firebase_uid}
   d. Mapea respuesta a Account entity
5. Se retorna Map con todos los datos del usuario
6. LoginPage navega según rol
```

---

## 🛠️ Cambios de Configuración Necesarios

### Variables de Entorno:
```dart
// En injection.dart - Actualizar según ambiente:
const String apiBaseUrl = 'http://localhost:8000/api/v1';

// Producción:
const String apiBaseUrl = 'https://api.residencias.com/api/v1';
```

### Firebase Configuration:
- Mantener igual en `GoogleService-Info.plist` e `google-services.json`
- El proyecto debe estar configurado con email/password authentication

---

## ✅ Testing Manual

### Login Test:
```
Email: usuario@example.com
Password: SecurePass123!
```

### Verificaciones:
- [ ] Login con email funciona
- [ ] Se obtiene Firebase UID
- [ ] Se obtiene perfil del usuario desde API
- [ ] Navegación a dashboard según rol
- [ ] Generación de QR funciona
- [ ] Historial de acceso se carga
- [ ] Logout funciona

---

## ⚠️ Notas Importantes

1. **Cambio de ID**: Se usa `personaId` (int) en lugar de identificación (string)
2. **Email Obligatorio**: El flujo requiere email válido en Firebase
3. **Vivienda**: Estructura `{manzana, villa}` en lugar de string único
4. **Paginación**: APIs soportan paginación, pero valores por defecto son seguros
5. **Errores**: El manejo de errores es consistente a través de excepciones

---

## 🚀 Próximos Pasos

1. Configurar URLs de API según ambiente
2. Implementar endpoints faltantes en backend:
   - `GET /acceso/historial` 
   - `POST /acceso/validar-qr`
   - Otros endpoints de miembros de familia
3. Añadir refresh de tokens
4. Implementar biometría (si es requerido)
5. Testing en dispositivos reales
6. Manejo de errores específicos del API

---

## 📚 Referencia de Arquitectura

```
Presentation (Pages, Widgets)
    ↓
Application (BLoCs)
    ↓
Domain (Entities, UseCases, Ports/Interfaces)
    ↓
Infrastructure (Adapters/Repositories, Providers, DTOs)
```

Cada capa es independiente y se comunica a través de interfaces definidas en Domain.

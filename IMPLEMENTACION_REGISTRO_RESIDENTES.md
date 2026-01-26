# Implementación de Flujo de Registro de Residentes

## 📋 Resumen de Cambios

Se ha implementado un flujo completo de registro para nuevas cuentas de residentes directamente desde la pantalla de login. El flujo incluye:

1. **Opción de crear cuenta** en el login
2. **Validación de prospecto residente** (verificar que la cédula existe en el sistema)
3. **Verificación facial en vivo** (validación biométrica)
4. **Creación de credenciales** (correo y contraseña)
5. **Registro en Firebase Auth** y creación de cuenta en el backend

---

## 🏗️ Arquitectura

Se mantiene la **arquitectura hexagonal + patrón BLoC**:

### Capas de Dominio
- **Entidades** (`lib/domain/entities/`)
  - `ProspectoResidente`: Datos de residente validado
  - `ProspectoMiembro`: Datos de miembro validado
  - `ViviendaInfo`: Información de vivienda
  - `CuentaResponse`: Respuesta de creación de cuenta

### Capas de Aplicación
- **BLoCs** (`lib/application/blocs/`)
  - `ProspectoValidationBloc`: Valida si la cédula existe como residente
  - `RegistroResidenteBloc`: Gestiona el flujo completo de registro (pendiente para uso futuro)

### Capas de Infraestructura
- **Providers** (`lib/infrastructure/providers/`)
  - `AccountApiProvider`: Llamadas HTTP a endpoints de cuentas
  - `AdminApi.verificarFacial()`: Verificación facial contra API de biometría

- **Repositorios** (`lib/infrastructure/adapters/`)
  - `AccountRepositoryImpl`: Implementa métodos de validación y creación de cuentas

- **Puertos** (`lib/domain/ports/`)
  - `AccountRepository`: Interfaz de repositorio de cuentas

### Capas de Presentación
- **Páginas** (`lib/presentation/pages/`)
  1. `RegisterOptionPage`: Menú inicial (Residente / Miembro)
  2. `ProspectoResidentePage`: Entrada de cédula y validación
  3. `FacialVerificationPage`: Captura y verificación facial en vivo
  4. `CredentialsResidentePage`: Ingreso de correo y contraseña

- **Rutas** (`lib/presentation/routes/`)
  - Nuevas rutas agregadas a `AppRoutes`

---

## 🔄 Flujo de Registro

```
Login Page
    ↓
[Botón "Crear Cuenta"]
    ↓
RegisterOptionPage
    ↓
[Seleccionar "Residente"]
    ↓
ProspectoResidentePage
  • Usuario ingresa cédula
  • Valida contra API: GET /cuentas/prospecto/residente/{cedula}
  • Recupera: personaId, nombres, vivienda, etc.
    ↓
FacialVerificationPage
  • Captura foto con cámara frontal
  • Verifica contra API biometría: POST /verify
  • Compara con embedding almacenado
    ↓
CredentialsResidentePage
  • Usuario ingresa email y contraseña
  • Crea usuario en Firebase Auth
  • Crea cuenta en backend: POST /cuentas/residente/firebase
    ↓
ResidentDashboard
  • Usuario autenticado y redirigido
```

---

## 📱 Componentes Implementados

### 1. Entidades de Dominio
**Archivo:** `lib/domain/entities/prospecto_residente.dart`

```dart
class ProspectoResidente {
  final int personaId;
  final String identificacion;
  final String nombres;
  final String apellidos;
  final String tipoRegistro; // "residente" o "propietario"
  final ViviendaInfo vivienda;
  // ...
}

class ProspectoMiembro {
  final bool existe;
  final int personaId;
  final String parentesco;
  // ...
}

class ViviendaInfo {
  final int viviendaId;
  final String manzana;
  final String villa;
}

class CuentaResponse {
  final int id;
  final String firebaseUid;
  final int personaId;
  final String nombres;
}
```

### 2. Provider de API de Cuentas
**Archivo:** `lib/infrastructure/providers/account_api_provider.dart`

Expone métodos:
- `validarProspectoResidente(identificacion)` → `GET /cuentas/prospecto/residente/{id}`
- `validarProspectoMiembro(identificacion)` → `GET /cuentas/prospecto/miembro/{id}`
- `crearCuentaResidente({personaId, firebaseUid, username})` → `POST /cuentas/residente/firebase`
- `crearCuentaMiembro({...})` → `POST /cuentas/miembro/firebase`

### 3. Repositorio de Cuentas (actualizado)
**Archivo:** `lib/infrastructure/adapters/account_repository_impl.dart`

Implementa nuevos métodos del puerto:
```dart
@override
Future<ProspectoResidente> validarProspectoResidente(String identificacion);

@override
Future<ProspectoMiembro> validarProspectoMiembro(String identificacion);

@override
Future<CuentaResponse> crearCuentaResidente({...});

@override
Future<CuentaResponse> crearCuentaMiembro({...});
```

### 4. BLoCs de Validación y Registro

#### ProspectoValidationBloc
**Archivos:** `lib/application/blocs/prospecto_validation/`

**Eventos:**
- `ValidarProspectoResidente(identificacion)`
- `ValidarProspectoMiembro(identificacion)`
- `LimpiarValidacion()`

**Estados:**
- `ProspectoValidationInitial`
- `ProspectoValidationLoading`
- `ProspectoResidenteValidado(ProspectoResidente)`
- `ProspectoMiembroValidado(ProspectoMiembro)`
- `ProspectoValidationError(message)`

#### RegistroResidenteBloc
**Archivos:** `lib/application/blocs/registro_residente/`

Gestiona el flujo completo (pendiente para expansión futura)

### 5. Páginas de UI

#### RegisterOptionPage
- Botón para crear cuenta de Residente (habilitado)
- Botón para crear cuenta de Miembro (deshabilitado - próximamente)
- Botón para volver al login

#### ProspectoResidentePage
- Campo de entrada para cédula
- Botón de validación
- Muestra errores si la cédula no existe o ya tiene cuenta

#### FacialVerificationPage
- Preview de cámara frontal
- Botón de captura de foto
- Llamada automática a API de biometría (`/verify`)
- Valida si la foto coincide con el registro facial del sistema
- Navega a credenciales si es exitosa

#### CredentialsResidentePage
- Campo para correo
- Campo para contraseña
- Campo de confirmación de contraseña
- Integración con Firebase Auth
- Creación de cuenta en backend
- Redirección a ResidentDashboard

---

## 🔌 Inyección de Dependencias

**Archivo:** `lib/injection.dart`

Se registraron:
```dart
// Provider de cuentas
sl.registerLazySingleton<AccountApiProvider>(
  () => AccountApiProvider(dio: apiHttpClient.dio),
);

// Repositorio actualizado
sl.registerLazySingleton<AccountRepository>(
  () => AccountRepositoryImpl(
    sl<ApiAuthProvider>(),
    sl<FamilyMembersApi>(),
    sl<AccountApiProvider>(),  // ← Nuevo parámetro
  ),
);

// BLoCs nuevos
sl.registerLazySingleton<ProspectoValidationBloc>(
  () => ProspectoValidationBloc(sl<AccountRepository>()),
);

sl.registerLazySingleton<RegistroResidenteBloc>(
  () => RegistroResidenteBloc(sl<AccountRepository>()),
);
```

---

## 🛣️ Rutas Nuevas

**Archivo:** `lib/presentation/routes/app_routes.dart`

```dart
static const String registerOption = '/registerOption';
static const String prospectoResidente = '/prospectoResidente';
static const String facialVerification = '/facialVerification';
static const String credentialsResidente = '/credentialsResidente';
```

Casos en `onGenerateRoute()`:
- Cada ruta con su correspondiente `MaterialPageRoute`
- Manejo de argumentos (ej: `ProspectoResidente` pasado a FacialVerificationPage)

---

## 🔐 Integraciones con APIs

### Endpoints Utilizados

#### 1. Validar Prospecto Residente
```http
GET /api/v1/cuentas/prospecto/residente/{identificacion}

Response (200):
{
  "persona_id": 1,
  "identificacion": "1234567890",
  "nombres": "Juan",
  "apellidos": "Pérez",
  "vivienda": {
    "vivienda_id": 1,
    "manzana": "A",
    "villa": "101"
  },
  "puede_crear_cuenta": true
}

Error (404): "Prospecto no encontrado o no es residente"
Error (409): "Esta persona ya tiene una cuenta creada"
```

#### 2. Verificación Facial
```http
POST /verify  (BIOMETRY SERVICE: puerto 8090)

Request:
{
  "persona_id": 1,
  "image": <binary image file>
}

Response:
{
  "persona_id": 1,
  "match": true,
  "distance": 0.3245
}
```

#### 3. Crear Cuenta de Residente
```http
POST /api/v1/cuentas/residente/firebase

Request:
{
  "persona_id": 1,
  "firebase_uid": "xyz123",
  "username": "usuario@example.com",
  "usuario_creado": "flutter_app"
}

Response (201):
{
  "id": 42,
  "firebase_uid": "xyz123",
  "persona_id": 1,
  "nombres": "Juan Pérez",
  "mensaje": "Cuenta de residente creada exitosamente"
}
```

---

## 🎨 Diseño y Consistencia

Todas las páginas nuevas mantienen:
- **Gradiente dinámico** según tema (claro/oscuro)
- **Componentes Material 3** (ElevatedButton, TextFormField, etc.)
- **Validación en tiempo real** de formularios
- **Manejo de errores** con SnackBar
- **Loading states** con CircularProgressIndicator
- **Estilos consistentes** con el resto de la app (colores #04345C, etc.)

---

## 📱 Pantalla de Login Actualizada

Se agregaron dos nuevos elementos en `LoginPage`:
1. Divisor (Divider widget)
2. Texto: "¿No tienes cuenta?"
3. Botón `OutlinedButton.icon`: "Crear Cuenta"
   - Navega a `/registerOption`
   - Deshabilitado mientras hay petición en curso

---

## ⚙️ Miembro de Familia (Pendiente)

Actualmente deshabilitado en `RegisterOptionPage`. Cuando se implemente:

1. Crear `prospecto_miembro_page.dart`
2. Validación más flexible (miembro puede no existir aún en sistema)
3. Posible registro de datos adicionales (parentesco, etc.)
4. Flujo de verificación adaptado (determinar si requiere validación facial)
5. Endpoint: `POST /cuentas/miembro/firebase`

---

## ✅ Validaciones Implementadas

### Frontend
- ✓ Cédula: 10+ dígitos
- ✓ Email: formato válido con @
- ✓ Contraseña: mínimo 6 caracteres
- ✓ Confirmación: coincide con contraseña
- ✓ Validación de cámara disponible
- ✓ Validación de foto capturada correctamente

### Backend (vía API)
- ✓ Persona existe y es residente activo
- ✓ Persona no tiene cuenta previa (error 409)
- ✓ Firebase UID es único
- ✓ Rostro detectado en foto
- ✓ Distancia coseno < 0.6 para verificación facial

---

## 🚀 Próximos Pasos (Opcionales)

1. **Miembro de Familia**
   - Implementar el flujo similar pero sin validación facial obligatoria
   - Permitir registro con datos básicos

2. **Recuperación de Contraseña**
   - Agregar opción en LoginPage
   - Integrar con Firebase Auth password reset

3. **Validación de Email**
   - Agregar envío de link de verificación
   - Validar antes de activar cuenta

4. **Two-Factor Authentication (2FA)**
   - SMS o TOTP después de crear cuenta
   - Requerido al iniciar sesión

5. **Pruebas Automatizadas**
   - Tests unitarios de BLoCs
   - Tests de widgets de UI
   - Tests de integración con APIs

---

## 📚 Documentación de APIs

Ver: `API_DOCUMENTACION_COMPLETA.md` - Sección CUENTAS:
- Endpoints 9-10: Validar Prospecto Residente/Miembro
- Endpoint 1-2: Crear Cuenta de Residente/Miembro

Ver: `API_DOCUMENTACION_BIOMETRIC.md`:
- Endpoint `/verify`: Verificación facial

---

## 🔍 Notas de Implementación

1. **Biometry Service**: Se usa cliente HTTP separado (`biometryAdminApi`) con puerto 8090
2. **Error Handling**: Mensajes amigables al usuario, traducciones al español
3. **State Management**: ProspectoValidationBloc maneja validación, CredentialsResidentePage maneja Firebase directamente
4. **Seguridad**: Contraseña no se almacena localmente, Firebase maneja autenticación
5. **UX**: Deshabilitación de botones durante peticiones, feedback visual inmediato

---

**Fecha de Implementación:** 26 de Enero de 2026  
**Estado:** ✅ Completado - Listo para pruebas

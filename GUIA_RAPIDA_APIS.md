# Guía Rápida de Integración de APIs

## 📌 URL Base del API

```dart
// En lib/injection.dart
const String apiBaseUrl = 'http://localhost:8000/api/v1';
```

---

## 🔑 Flujo de Autenticación Completo

### 1️⃣ Cliente da email y password
```dart
// LoginPage emite
context.read<AuthBloc>().add(LoginSubmitted(email, password));
```

### 2️⃣ Firebase autentica y API obtiene perfil
```
Firebase Auth (signInWithEmailAndPassword)
      ↓
Obtiene Firebase UID + ID Token
      ↓
GET /cuentas/perfil/{firebase_uid}
      ↓
Retorna Account con personaId, rol, vivienda, etc.
```

### 3️⃣ Usuario autenticado
```dart
// Datos disponibles en AuthSuccess state:
{
  'uid': 'firebase_uuid',
  'email': 'usuario@example.com',
  'idToken': 'token_jwt_firebase',
  'personaId': 1,
  'nombres': 'Juan',
  'apellidos': 'Pérez',
  'rol': 'residente', // o 'miembro_familia'
  'vivienda': {'manzana': 'A', 'villa': '101'},
}
```

---

## 🎫 Generar QR

### QR Propio (Acceso Personal)
```dart
await generarQRPropio(
  duracionHoras: 8,
  fecha: DateTime(2024, 12, 25),
  hora: TimeOfDay(14, 30),
);

// API:
POST /qr/generar-propio
{
  "duracion_horas": 8,
  "fecha_acceso": "2024-12-25",
  "hora_inicio": "14:30",
  "usuario_creado": "flutter_app"
}

// Respuesta:
{
  "id": 15,
  "token": "aB3cDeFgHiJkLmNoPqRsTuVwXyZ123456",
  "hora_inicio": "2024-12-25T14:30:00",
  "hora_fin": "2024-12-25T22:30:00",
  "estado": "vigente"
}
```

### QR de Visita
```dart
await generarQRVisita(
  visitorId: '1234567890',
  visitorName: 'Carlos García',
  motivo: 'Revisión técnica',
  duracionHoras: 2,
  fecha: DateTime.now(),
  hora: TimeOfDay(10, 0),
);

// API:
POST /qr/generar-visita
{
  "visita_identificacion": "1234567890",
  "visita_nombres": "Carlos",
  "visita_apellidos": "García",
  "motivo_visita": "Revisión técnica",
  "duracion_horas": 2,
  "fecha_acceso": "2024-12-25",
  "hora_inicio": "10:00",
  "usuario_creado": "flutter_app"
}
```

---

## 📊 Listar QR Generados

```dart
// Con paginación y filtro
final qrs = await listarQRs(
  page: 1,
  pageSize: 10,
  tipoIngreso: 'all', // 'propio', 'visita', 'all'
);

// API:
GET /qr/cuenta/generados?page=1&page_size=10&tipo_ingreso=all

// Respuesta:
{
  "data": [
    {
      "qr_pk": 15,
      "token": "...",
      "estado": "vigente",
      "tipo_ingreso": "propio",
      "hora_inicio_vigencia": "2024-12-25T14:30:00",
      "hora_fin_vigencia": "2024-12-25T22:30:00"
    }
  ],
  "total": 25,
  "page": 1,
  "page_size": 10,
  "total_pages": 3,
  "has_next": true
}
```

---

## 📋 Historial de Acceso

```dart
// Con paginación
final logs = await loadAccessHistory(page: 1, pageSize: 20);

// API:
GET /acceso/historial?page=1&page_size=20

// Respuesta:
{
  "data": [
    {
      "id": 1,
      "persona_id": 1,
      "nombres": "Juan",
      "apellidos": "Pérez",
      "fecha_acceso": "2024-12-24T10:30:00",
      "tipo_qr": "propio",
      "estado": "permitido",
      "rol": "residente"
    }
  ],
  "total": 100,
  "page": 1,
  "page_size": 20,
  "has_next": true
}
```

---

## 🛡️ Manejo de Autenticación (JWT)

### Token automático en cada request
```dart
// El ApiHttpClient intercepta y añade:
GET /qr/cuenta/generados
  ↓
Authorization: Bearer {firebase_id_token}

// Se refresca automáticamente si expira
```

### Si token expira
```dart
// Se ejecuta automáticamente:
await firebaseAuth.currentUser?.getIdToken(true); // force refresh
// El interceptor lo usa en el siguiente request
```

---

## ❌ Manejo de Errores

```dart
try {
  await login(email, password);
} on FirebaseAuthException catch (e) {
  // Error en Firebase Auth
  print('Error Firebase: ${e.code}');
} catch (e) {
  // Error en API o red
  print('Error: ${e.toString()}');
}
```

### Códigos comunes:
- `user-not-found`: No existe cuenta en Firebase
- `wrong-password`: Contraseña incorrecta
- `invalid-email`: Email inválido
- `DioException`: Error de red o API

---

## 🔄 Cambios de Estado en BLoCs

### AuthBloc
```dart
LoginSubmitted(email, password)
    ↓
AuthLoading
    ↓
AuthSuccess(userMap)  // o AuthFailure(message)
```

### AccessHistoryBloc
```dart
LoadAccessHistory()
    ↓
AccessHistoryLoading
    ↓
AccessHistoryLoaded(logs)  // o AccessHistoryError(message)
```

### QrBloc
```dart
GenerateQREvent(...)
    ↓
QRLoading
    ↓
QRGenerated(qrCode)  // o QRError(message)
```

---

## 📱 Estructura de Datos Principales

### Account (Dominio)
```dart
Account {
  firebaseUid: String,      // UUID de Firebase
  personaId: int,           // ID en BD
  identificacion: String,   // Cédula
  nombres: String,
  apellidos: String,
  rol: String,              // 'residente' o 'miembro_familia'
  estado: String,           // 'activo'
  correo: String?,
  celular: String?,
  vivienda: Vivienda {
    manzana: String,        // 'A', 'B', etc.
    villa: String,          // '101', '102', etc.
  },
  parentesco: String?,      // Solo si rol='miembro_familia'
  fechaCreado: DateTime,
}
```

### QrCode (Dominio)
```dart
QrCode {
  value: String,            // Token QR
  createdAt: DateTime,
  validFrom: DateTime,
  expiresAt: DateTime,
  durationHours: int,
  maxUses: int?,
  type: String,             // 'propio' o 'visita'
}
```

---

## 🚀 Ejemplo Completo: Login → Dashboard

```dart
// 1. Usuario ingresa email/password
class LoginPage extends State {
  void _login() {
    context.read<AuthBloc>().add(
      LoginSubmitted(emailCtrl.text, passCtrl.text)
    );
  }
}

// 2. BLoC emite sucesos
class AuthBloc extends Bloc {
  on<LoginSubmitted>((event, emit) async {
    emit(AuthLoading());
    try {
      final user = await login(
        email: event.email,
        password: event.password,
      );
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  });
}

// 3. Use case orquesta lógica
class LoginUseCase {
  Future<Map<String, dynamic>> call({
    required String email,
    required String password,
  }) async {
    // Autentica en Firebase
    final loginResult = await auth.login(email, password);
    
    // Obtiene perfil del API
    final account = await accounts.getById(loginResult['uid']);
    
    // Retorna datos enriquecidos
    return {..., 'rol': account.rol};
  }
}

// 4. Repository integra Firebase + API
class AuthRepositoryImpl {
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    // Firebase Auth
    final cred = await firebaseProvider.signInWithEmail(email, password);
    final idToken = await cred.user?.getIdToken();
    
    // API obtiene perfil
    final perfil = await apiProvider.obtenerPerfil(cred.user!.uid);
    
    return {
      'uid': cred.user!.uid,
      'idToken': idToken,
      ...perfil
    };
  }
}

// 5. Page navega según rol
class LoginPage {
  listener: (ctx, state) {
    if (state is AuthSuccess) {
      if (state.user['rol'] == 'residente') {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.residentDashboard,
          arguments: state.user,
        );
      }
    }
  }
}
```

---

## 🧪 Testing de Endpoints

```bash
# Test login
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"usuario@example.com","password":"pass123"}'

# Test obtener perfil (requiere token)
curl -X GET http://localhost:8000/api/v1/cuentas/perfil/{firebase_uid} \
  -H "Authorization: Bearer {token}"

# Test generar QR
curl -X POST http://localhost:8000/api/v1/qr/generar-propio \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "duracion_horas": 8,
    "fecha_acceso": "2024-12-25",
    "hora_inicio": "14:30",
    "usuario_creado": "flutter_app"
  }'
```

---

## ⚡ Tips de Performance

1. **Cache de tokens**: Se cachea automáticamente por Firebase
2. **Paginación**: Siempre usar `page` y `page_size` para listas grandes
3. **Errores de red**: El cliente espera por defecto 30 segundos
4. **Logging**: Activar logs del Dio para debugging

```dart
// Activar logs en desarrollo
dio.interceptors.add(LoggingInterceptor());
```

---

## 📚 Archivos Principales

| Archivo | Propósito |
|---------|-----------|
| `lib/infrastructure/providers/http_client.dart` | Cliente HTTP con JWT |
| `lib/infrastructure/providers/firebase_auth_provider.dart` | Interfaz Firebase |
| `lib/infrastructure/providers/qr_api.dart` | Endpoints QR |
| `lib/infrastructure/adapters/auth_repository_impl.dart` | Lógica de login |
| `lib/domain/usecases/login_usecase.dart` | Orquestación de login |
| `lib/application/blocs/auth/auth_bloc.dart` | Estado de autenticación |
| `lib/presentation/pages/login_page.dart` | UI de login |

---

## 🐛 Debugging

```dart
// Ver logs de HTTP
void enableHttpLogging() {
  dio.interceptors.add(
    LoggingInterceptor(),
  );
}

// Ver estado de autenticación
authRepo.authStateChanges.listen((user) {
  print('Auth state: $user');
});

// Ver errores del API
try {
  // ...
} catch (e) {
  print('Error completo: $e');
  if (e is DioException) {
    print('Status: ${e.response?.statusCode}');
    print('Body: ${e.response?.data}');
  }
}
```

---

**Última actualización**: 2024-12-19
**Versión API**: 1.0.0
**Compatible con**: Flutter 3.0+

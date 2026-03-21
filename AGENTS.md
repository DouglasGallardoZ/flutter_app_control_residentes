# AGENTS.md - Guía de desarrollo para proyecto Guardin

## 1. Descripción del proyecto y arquitectura

**Guardin** es una aplicación Flutter para gestión de accesos en urbanizaciones, que permite a residentes controlar accesos mediante reconocimiento facial y códigos QR. La aplicación implementa una arquitectura Hexagonal (Puertos y Adaptadores) combinada con el patrón BLoC para la gestión de estado.

### Principios arquitectónicos:
- **Arquitectura Hexagonal**: Separación clara entre dominio, aplicación e infraestructura
- **Patrón Repository**: Abstraction sobre fuentes de datos (Firebase, APIs REST)
- **Inyección de dependencias**: GetIt para gestión de dependencias
- **Patrón BLoC**: Gestión de estado reactivo y predecible
- **Separación de APIs**: APIs generales y de biometría en servidores diferentes
- **Inversión de dependencias**: Depender de interfaces (puertos) no de implementaciones concretas
- **Interfaces de proveedores**: Crear puertos para servicios externos (FirebaseAuthProviderPort, ApiAuthProviderPort)
- **DTOs con conversión a entidades**: Todos los DTOs deben incluir método `toEntity()` para conversión a entidades de dominio
- **Sesiones de autenticación tipadas**: Usar `AuthSession` en lugar de `Map<String, dynamic>` para respuestas de autenticación

### Capas:
1. **Dominio**: Entidades, value objects, puertos (interfaces) y casos de uso
2. **Aplicación**: BLoCs, mapeo de DTOs a entidades
3. **Infraestructura**: Implementaciones de repositorios, providers HTTP, adaptadores
4. **Presentación**: Páginas, widgets, rutas y temas

## 2. Estructura de directorios

```
lib/
├── application/
│   ├── blocs/              # BLoCs organizados por funcionalidad
│   │   ├── auth/           # Autenticación
│   │   ├── admin/          # Funcionalidades de administrador
│   │   ├── resident/       # Gestión de residentes
│   │   ├── qr/            # Generación y gestión de QR
│   │   └── ...
│   └── ...
├── domain/
│   ├── entities/           # Entidades de negocio
│   ├── value_objects/      # Value objects (Email, Password, etc.)
│   ├── ports/             # Interfaces de repositorios
│   └── usecases/          # Casos de uso
├── infrastructure/
│   ├── adapters/          # Implementaciones de repositorios
│   ├── providers/         # Clientes HTTP y APIs
│   └── dtos/             # Objetos de transferencia de datos
├── presentation/
│   ├── pages/             # Pantallas de la aplicación
│   ├── widgets/           # Componentes reutilizables
│   ├── routes/            # Configuración de rutas
│   └── theme/             # Temas y estilos
├── injection.dart         # Configuración de GetIt
├── app.dart              # Widget raíz de la aplicación
└── main.dart             # Punto de entrada
```

## 3. Convenciones de código y nomenclatura

### Nombres en español:
- **Variables y clases**: Español (`identificacion`, `nombres`, `apellidos`)
- **Comentarios y documentación**: Español
- **Mensajes de error**: Español con acentos apropiados

### Nomenclatura de archivos:
- **Entidades**: `account.dart`, `owner_entity.dart`
- **DTOs**: `owner_dto.dart`, `resident_dto.dart`
- **Repositorios**: `auth_repository_impl.dart`, `account_repository.dart`
- **BLoCs**: `auth_bloc.dart`, `admin_dashboard_bloc.dart`
- **Páginas**: `login_page.dart`, `admin_dashboard_page.dart`
- **Widgets**: `qr_list_card.dart`, `camera_facial_view.dart`

### Estructura de clases:
```dart
// Entity
class Account {
  final String firebaseUid;
  final int personaId;
  // ... otros campos
  factory Account.fromMap(Map<String, dynamic> map) => ...;
  Map<String, dynamic> toMap() => ...;
}

// DTO
class OwnerDTO {
  final int propietarioId;
  final String nombres;
  // ... otros campos
  factory OwnerDTO.fromJson(Map<String, dynamic> json) => ...;
  Map<String, dynamic> toJson() => ...;
  OwnerEntity toEntity() => ...;
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase login;
  final AuthRepository authRepo;
  
  AuthBloc({required this.login, required this.authRepo}) : super(AuthInitial()) {
    on<LoginSubmitted>((event, emit) async { ... });
  }
}
```

### Reglas de formato:
- **Indentación**: 2 espacios (configuración estándar de Flutter)
- **Línea máxima**: 80 caracteres
- **Orden de imports**: Paquetes de Flutter, paquetes externos, imports relativos
- **Constructores nombrados**: Usar `factory` para fromMap/fromJson
- **Getters**: Usar para propiedades calculadas (`nombreCompleto`)

## 4. Configuración y dependencias

### Dependencias principales (pubspec.yaml):
- `flutter_bloc`: Gestión de estado
- `get_it`: Inyección de dependencias
- `dio`: Cliente HTTP
- `firebase_core`, `firebase_auth`, `cloud_firestore`: Autenticación y base de datos
- `qr_flutter`: Generación de códigos QR
- `camera`, `google_mlkit_face_detection`: Reconocimiento facial
- `equatable`: Comparación de objetos
- `intl`: Internacionalización

### Configuración de inyección (injection.dart):
```dart
final sl = GetIt.instance;

Future<void> inject() async {
  // Configuración de URLs
  const String apiBaseUrl = 'http://10.0.2.2:8080/api/v1';
  const String biometryBaseUrl = 'http://10.0.2.2:8000/api/v1';
  
  // Registro de dependencias
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<ApiHttpClient>(() => ApiHttpClient(...));
  // ... más registros
}
```

### Variables de entorno:
- **API general**: Puerto 8080 para operaciones CRUD
- **API de biometría**: Puerto 8000 para reconocimiento facial
- **Firebase**: Configuración mediante `firebase_options.dart`

## 5. Roles y funcionalidades

### Roles de usuario:
1. **Administrador**: Gestión completa de usuarios, visualización de métricas
2. **Residente**: Acceso a QR personal, historial de accesos, gestión de miembros familiares
3. **Miembro de Familia**: Acceso limitado, QR de visita, reconocimiento facial

### Funcionalidades por rol:

#### Administrador:
- Dashboard con métricas (usuarios activos, accesos recientes)
- Gestión de residentes, propietarios y miembros
- Historial de accesos por vivienda
- Registro facial de usuarios
- Bloqueo/desbloqueo de cuentas

#### Residente:
- Generación de QR personal y de visita
- Historial de accesos a su vivienda
- Gestión de miembros familiares
- Verificación facial para acceso
- Perfil y configuración

#### Miembro de Familia:
- QR de visita temporal
- Acceso mediante reconocimiento facial
- Visualización de perfil limitado

## 6. Seguridad y validación

### Autenticación:
- **Firebase Auth**: Autenticación principal con email/password
- **JWT Tokens**: Tokens Firebase usados para autorización en APIs
- **Interceptores**: Automática inclusión de token en headers HTTP

### Validación:
- **Value Objects**: `EmailAddress`, `Password`, `Identification` para validación centralizada
- **Validación en UI**: Formularios con validación inmediata
- **Validación en backend**: Respuestas de API con mensajes de error claros

### Seguridad de datos:
- **Tokens en memoria**: No almacenar tokens en almacenamiento persistente
- **Cifrado**: Uso de HTTPS para todas las comunicaciones
- **Permisos**: Verificación de roles en cada endpoint

### Manejo de errores:
```dart
String _extractErrorMessage(Object ex) {
  final message = ex.toString();
  
  if (message.contains('user-not-found')) {
    return 'Usuario no encontrado';
  }
  if (message.contains('wrong-password')) {
    return 'Contraseña incorrecta';
  }
  // ... más mapeos
  return message.isEmpty ? 'Error en autenticación' : message;
}
```

## 7. Testing y documentación

### Testing:
- **Pruebas unitarias**: Para casos de uso, value objects y lógica de negocio
- **Pruebas de widgets**: Para componentes de UI críticos
- **Pruebas de integración**: Para flujos completos de usuario

### Estructura de tests:
```
test/
├── unit/
│   ├── domain/
│   │   ├── entities/
│   │   └── usecases/
│   └── application/
│       └── blocs/
├── widget/
└── integration/
```

### Ejemplo de test BLoC:
```dart
void main() {
  group('AuthBloc', () {
    late AuthBloc authBloc;
    late MockLoginUseCase mockLoginUseCase;
    
    setUp(() {
      mockLoginUseCase = MockLoginUseCase();
      authBloc = AuthBloc(login: mockLoginUseCase, ...);
    });
    
    test('emits AuthLoading and AuthSuccess when login succeeds', () {
      // Arrange
      when(mockLoginUseCase(...)).thenAnswer(...);
      
      // Act & Assert
      expectLater(
        authBloc.stream,
        emitsInOrder([AuthLoading(), AuthSuccess(...)]),
      );
      
      authBloc.add(LoginSubmitted(email: 'test@example.com', password: 'password'));
    });
  });
}
```

### Documentación:
- **Comentarios**: Explicar lógica compleja, no lo obvio
- **Documentación pública**: Usar comentarios de documentación Dart (`///`)
- **README**: Mantener actualizado con instrucciones de configuración
- **AGENTS.md**: Este archivo como referencia para desarrolladores

## 8. Flujo de desarrollo

### 1. Configuración inicial:
```bash
# Clonar repositorio
git clone <repo-url>

# Instalar dependencias
flutter pub get

# Configurar Firebase
# Copiar google-services.json (Android) y GoogleService-Info.plist (iOS)

# Configurar URLs de API en injection.dart
const String apiBaseUrl = 'http://<tu-ip>:8080/api/v1';
const String biometryBaseUrl = 'http://<tu-ip>:8000/api/v1';
```

### 2. Desarrollo de nuevas funcionalidades:

#### a. Crear entidad en dominio:
```dart
// lib/domain/entities/nueva_entidad.dart
class NuevaEntidad {
  final String id;
  final String nombre;
  
  NuevaEntidad({required this.id, required this.nombre});
  
  factory NuevaEntidad.fromMap(Map<String, dynamic> map) => ...;
  Map<String, dynamic> toMap() => ...;
}
```

#### b. Crear puerto (interface):
```dart
// lib/domain/ports/nueva_repository.dart
abstract class NuevaRepository {
  Future<NuevaEntidad> obtenerPorId(String id);
  Future<List<NuevaEntidad>> listar();
}
```

#### c. Crear interfaces de proveedores para servicios externos (opcional):
```dart
// lib/domain/ports/nueva_api_provider_port.dart
abstract class NuevaApiProviderPort {
  Future<Map<String, dynamic>> obtenerDatos(String id);
  Future<void> enviarDatos(Map<String, dynamic> datos);
}
```

#### d. Implementar repositorio en infraestructura:
```dart
// lib/infrastructure/adapters/nueva_repository_impl.dart
class NuevaRepositoryImpl implements NuevaRepository {
  final NuevaApi nuevaApi;
  
  NuevaRepositoryImpl(this.nuevaApi);
  
  @override
  Future<NuevaEntidad> obtenerPorId(String id) async {
    final dto = await nuevaApi.obtenerPorId(id);
    return dto.toEntity();
  }
}
```

#### e. Crear caso de uso:
```dart
// lib/domain/usecases/obtener_nueva_entidad_usecase.dart
class ObtenerNuevaEntidadUseCase {
  final NuevaRepository repository;
  
  ObtenerNuevaEntidadUseCase(this.repository);
  
  Future<NuevaEntidad> execute(String id) async {
    return await repository.obtenerPorId(id);
  }
}
```

#### f. Crear BLoC:
```dart
// lib/application/blocs/nueva/nueva_bloc.dart
class NuevaBloc extends Bloc<NuevaEvent, NuevaState> {
  final ObtenerNuevaEntidadUseCase obtenerUseCase;
  
  NuevaBloc({required this.obtenerUseCase}) : super(NuevaInitial()) {
    on<ObtenerNuevaEntidad>((event, emit) async {
      emit(NuevaLoading());
      try {
        final entidad = await obtenerUseCase.execute(event.id);
        emit(NuevaCargada(entidad));
      } catch (e) {
        emit(NuevaError(e.toString()));
      }
    });
  }
}
```

#### g. Registrar dependencias en injection.dart:
```dart
// Providers
sl.registerLazySingleton<NuevaApi>(() => NuevaApi(sl<ApiHttpClient>().dio));

// Adapters
sl.registerLazySingleton<NuevaRepository>(() => NuevaRepositoryImpl(sl<NuevaApi>()));

// Use Cases
sl.registerLazySingleton<ObtenerNuevaEntidadUseCase>(
  () => ObtenerNuevaEntidadUseCase(sl<NuevaRepository>())
);

// BLoCs
sl.registerLazySingleton<NuevaBloc>(
  () => NuevaBloc(obtenerUseCase: sl<ObtenerNuevaEntidadUseCase>())
);
```

#### h. Crear página/widget en presentación:
```dart
// lib/presentation/pages/nueva_pagina.dart
class NuevaPagina extends StatelessWidget {
  const NuevaPagina({super.key});
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider<NuevaBloc>(
      create: (_) => sl<NuevaBloc>(),
      child: const _NuevaPaginaView(),
    );
  }
}
```

### 3. Pruebas:
```bash
# Ejecutar pruebas unitarias
flutter test

# Ejecutar pruebas de integración
flutter test integration_test/

# Ejecutar análisis estático
flutter analyze
```

### 4. Commit y push:
```bash
# Formato de commit: [tipo] Descripción breve
# Ejemplos: [feat] Agrega gestión de visitantes
#           [fix] Corrige error en validación de email
#           [refactor] Mejora estructura de repositorios

git add .
git commit -m "[feat] Agrega nueva funcionalidad"
git push origin feature/nueva-funcionalidad
```

### 5. Revisión de código:
- Verificar que sigue convenciones de nomenclatura
- Asegurar separación de capas
- Validar manejo de errores
- Confirmar cobertura de tests

## 9. Solución de problemas comunes

### Error: "Missing Firebase configuration"
- Verificar que `firebase_options.dart` existe y está configurado
- Ejecutar `flutterfire configure` si es necesario

### Error: "Connection refused" en APIs
- Verificar que los servidores de API están ejecutándose
- Actualizar URLs en `injection.dart` con la IP correcta

### Error: "Camera permission denied"
- Verificar permisos en `AndroidManifest.xml` y `Info.plist`
- Solicitar permisos en tiempo de ejecución

### Error: "Bloc not found in context"
- Asegurar que el BLoC está registrado en `injection.dart`
- Verificar que está provisto en el árbol de widgets con `BlocProvider`

## 10. Mejoras Arquitectónicas Recientes

### 10.1. Interfaces de Proveedores para Servicios Externos
Para mantener una inversión de dependencias adecuada, se han creado puertos específicos para servicios externos:

```dart
// Ejemplo: FirebaseAuthProviderPort
abstract class FirebaseAuthProviderPort {
  Future<UserCredential> signInWithEmail(String email, String password);
  Future<void> logout();
  User? get currentUser;
  Stream<User?> get authStateChanges;
  Future<String?> getIdToken({bool forceRefresh = false});
}
```

### 10.2. DTOs con Método `toEntity()`
Todos los DTOs deben implementar un método `toEntity()` que convierta el DTO a la entidad correspondiente:

```dart
class PerfilUsuarioDTO {
  // ... campos
  
  Account toEntity(String firebaseUid) {
    return Account(
      firebaseUid: firebaseUid,
      personaId: personaId ?? 0,
      identificacion: identificacion ?? '',
      nombres: nombres,
      apellidos: apellidos,
      rol: rol,
      estado: estado,
      correo: correo,
      celular: celular,
      vivienda: Vivienda(...),
      parentesco: parentesco,
      fechaCreado: fechaCreado,
    );
  }
}
```

### 10.3. Sesiones de Autenticación Tipadas
En lugar de usar `Map<String, dynamic>` para respuestas de autenticación, se creó la entidad `AuthSession`:

```dart
class AuthSession {
  final String uid;
  final String email;
  final String? idToken;
  final Account account;
  final DateTime createdAt;
  final DateTime? expiresAt;
  
  // Constructor, factory fromMap, toMap, getters
}
```

Los repositorios de autenticación ahora retornan `Future<AuthSession>` en lugar de `Future<Map<String, dynamic>>`.

### 10.4. Compatibilidad con Código Existente
Para facilitar la transición, se ha mantenido compatibilidad con el getter `user` en `AuthSuccess` que genera un Map a partir de la sesión. Sin embargo, se recomienda migrar gradualmente al uso directo de `session.account`.

---

## 11. Recursos útiles

- **Documentación de Flutter**: https://flutter.dev/docs
- **BLoC Library**: https://bloclibrary.dev
- **GetIt**: https://pub.dev/packages/get_it
- **Dio**: https://pub.dev/packages/dio
- **Firebase Flutter**: https://firebase.flutter.dev

---

*Última actualización: 20 de marzo de 2026*
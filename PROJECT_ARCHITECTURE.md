# Documentación Completa del Proyecto - Guardín

## 📋 Tabla de Contenidos
1. [Visión General](#visión-general)
2. [Estructura de Directorios](#estructura-de-directorios)
3. [Arquitectura](#arquitectura)
4. [Patrones de Diseño](#patrones-de-diseño)
5. [Guía de Estilo y Convenciones](#guía-de-estilo-y-convenciones)
6. [Módulos Principales](#módulos-principales)
7. [Flujos de Negocio](#flujos-de-negocio)
8. [Dependencias](#dependencias)
9. [Configuración](#configuración)
10. [Guía de Desarrollo](#guía-de-desarrollo)

---

## 🎯 Visión General

**Guardín** es una innovadora aplicación Flutter que redefine la seguridad en urbanizaciones. Permite a los residentes:
- Gestionar accesos con reconocimiento facial
- Generar y validar códigos QR
- Administrar visitantes y accesos
- Registrarse como residentes o miembros de familia

### Características Principales
- ✅ Autenticación con Firebase
- ✅ Validación facial con ML Kit
- ✅ Generación de QR dinámicos
- ✅ Gestión de visitantes
- ✅ Dashboard de acceso
- ✅ Roles múltiples (Residente, Propietario, Administrador, Miembro)

---

## 📁 Estructura de Directorios

```
lib/
├── main.dart                          # Punto de entrada de la aplicación
├── app.dart                           # Widget raíz de la app
├── firebase_options.dart              # Configuración de Firebase (generado)
├── injection.dart                     # Inyección de dependencias con GetIt
├── theme.dart                         # Temas y estilos globales
│
├── application/                       # Capa de Aplicación (BLoCs)
│   └── blocs/
│       ├── account/                   # BLoC para gestión de cuentas
│       ├── admin/                     # BLoC para funciones administrativas
│       ├── admin_account/             # BLoC para cuentas administrativas
│       ├── auth/                      # BLoC de autenticación
│       ├── email_verification/        # BLoC para verificación de email
│       ├── facial_enrollment/         # BLoC para captura facial
│       ├── history/                   # BLoC de historial de acceso
│       ├── member/                    # BLoC para registro de miembros
│       ├── owner/                     # BLoC para propietarios
│       ├── prospecto_validation/      # BLoC para validación de prospectos
│       ├── qr/                        # BLoC para generación de QR
│       ├── qr_display/                # BLoC para visualización de QR
│       ├── qr_list/                   # BLoC para lista de QR
│       ├── qr_visit/                  # BLoC para QR de visitas
│       ├── registro_residente/        # BLoC para registro de residentes
│       ├── resident/                  # BLoC para residentes
│       ├── session/                   # BLoC de sesión
│       └── visitor/                   # BLoC para visitantes
│
├── core/                              # Configuración Central
│   ├── config/
│   │   ├── brand_theme.dart          # Colores y estilos de marca
│   │   └── env.dart                  # Variables de entorno
│   ├── constants/
│   │   ├── api_constants.dart        # URLs y endpoints de API
│   │   └── roles.dart                # Definición de roles
│   ├── styles/
│   │   └── app_theme_builder.dart    # Constructor del tema
│   └── validations/
│       ├── cv_validators.dart        # Validadores de formularios
│       └── format_rules.dart         # Reglas de formato
│
├── domain/                            # Capa de Dominio (Lógica de Negocio)
│   ├── entities/                      # Modelos de datos principales
│   │   ├── access_log.dart
│   │   ├── account.dart
│   │   ├── admin_metrics.dart
│   │   ├── owner_entity.dart
│   │   ├── prospecto_residente.dart  # Prospectos de residentes y miembros
│   │   ├── qr_code.dart
│   │   ├── qr_generado.dart
│   │   ├── qr_list_response.dart
│   │   └── visitor.dart
│   ├── ports/                         # Interfaces de repositorios (abstracciones)
│   │   ├── access_history_repository.dart
│   │   ├── account_repository.dart
│   │   ├── admin_account_repository.dart
│   │   ├── admin_repository.dart
│   │   ├── auth_repository.dart
│   │   ├── face_repository.dart
│   │   ├── member_repository.dart
│   │   ├── owner_repository.dart
│   │   ├── qr_repository.dart
│   │   ├── resident_repository.dart
│   │   └── visitor_repository.dart
│   ├── usecases/                      # Casos de uso (lógica de negocio)
│   │   ├── block_account_usecase.dart
│   │   ├── create_member_usecase.dart
│   │   ├── create_resident_usecase.dart
│   │   ├── generate_qr_usecase.dart
│   │   ├── load_family_members_usecase.dart
│   │   ├── login_usecase.dart
│   │   ├── manage_visitor_usecase.dart
│   │   └── ... (más usecases)
│   └── value_objects/                 # Objetos de valor
│       └── email_address.dart
│
├── infrastructure/                    # Capa de Infraestructura
│   ├── adapters/                      # Implementación de repositorios
│   │   ├── auth_repository_impl.dart
│   │   ├── resident_repository_impl.dart
│   │   ├── member_repository_impl.dart
│   │   ├── qr_repository_impl.dart
│   │   └── ... (más implementaciones)
│   ├── dtos/                          # Data Transfer Objects
│   │   ├── resident_dto.dart
│   │   ├── visitor_dto.dart
│   │   └── ... (más DTOs)
│   └── providers/                     # Proveedores de API
│       ├── admin_api.dart            # API para administración
│       ├── auth_api.dart             # API de autenticación
│       ├── face_recognition_api.dart # API de reconocimiento facial
│       ├── qr_api.dart               # API de QR
│       ├── resident_api.dart         # API de residentes
│       ├── visitor_api.dart          # API de visitantes
│       └── ... (más APIs)
│
└── presentation/                      # Capa de Presentación (UI)
    ├── pages/                         # Pantallas/Páginas
    │   ├── login_page.dart
    │   ├── register_option_page.dart
    │   ├── prospecto_residente_page.dart
    │   ├── prospecto_miembro_page.dart
    │   ├── member_create_registration_page.dart
    │   ├── member_facial_enrollment_page.dart
    │   ├── facial_verification_page.dart
    │   ├── credentials_miembro_page.dart
    │   ├── credentials_residente_page.dart
    │   ├── resident_dashboard_page.dart
    │   ├── qr_self_page.dart
    │   ├── qr_visit_page.dart
    │   ├── qr_display_page.dart
    │   ├── qr_list_page.dart
    │   ├── access_history_page.dart
    │   ├── profile_page.dart
    │   ├── admin_dashboard_page.dart
    │   ├── admin_users_page.dart
    │   ├── admin_residents_page.dart
    │   ├── admin_create_resident_page.dart
    │   ├── admin_facial_enrollment_page.dart
    │   └── ... (más páginas)
    ├── routes/
    │   └── app_routes.dart            # Definición de rutas y navegación
    ├── theme/
    │   └── (Temas específicos de presentación)
    └── widgets/                       # Componentes reutilizables
        ├── app_scaffold.dart
        ├── camera_facial_view.dart
        ├── navigation_helpers.dart
        └── ... (más widgets)
```

---

## 🏗️ Arquitectura

### Patrón Hexagonal (Puertos y Adaptadores)

La aplicación sigue la **arquitectura hexagonal** con tres capas principales:

```
                    ┌─────────────────┐
                    │  PRESENTATION   │  ← Pages, Widgets, BLoCs
                    │   (Flutter UI)  │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │  APPLICATION    │  ← BLoCs, Events, States
                    │   (Business)    │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │  DOMAIN         │  ← Entities, UseCases, Ports
                    │  (Pure Logic)   │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │ INFRASTRUCTURE  │  ← Adapters, APIs, DTOs
                    │  (External)     │
                    └─────────────────┘
```

### Capas Explicadas

#### 1. **Domain** (Más Interna)
- **Pura lógica de negocio**, sin dependencias externas
- **Entities**: Objetos de dominio (Residente, Visitante, QR, etc.)
- **Ports**: Interfaces que definen contratos (no implementación)
- **UseCases**: Orquestación de la lógica de negocio

#### 2. **Application**
- **BLoCs**: Gestión de estado con event-driven architecture
- **Events**: Acciones del usuario → `ValidarProspectoMiembro`, `CreateMemberEvent`
- **States**: Resultados → `ProspectoMiembroValidado`, `MemberCreated`, `MemberError`
- Convierte UI events en domain logic

#### 3. **Infrastructure**
- **Adapters**: Implementan los "Ports" del domain
- **Providers**: Clientes HTTP para APIs externas
- **DTOs**: Modelos de transferencia de datos (para serialización JSON)

#### 4. **Presentation**
- **Pages**: Pantallas principales
- **Widgets**: Componentes reutilizables
- **Routes**: Navegación central en `app_routes.dart`
- Consume BLoCs para estado

---

## 🎨 Patrones de Diseño

### 1. **BLoC Pattern**
Usado para gestionar estado reactivamente:

```dart
// Event (Acción del usuario)
class ValidarProspectoMiembro extends ProspectoValidationEvent {
  final String identificacion;
  ValidarProspectoMiembro(this.identificacion);
}

// State (Resultado)
class ProspectoMiembroValidado extends ProspectoValidationState {
  final ProspectoMiembro prospecto;
  ProspectoMiembroValidado(this.prospecto);
}

// BLoC (Lógica)
class ProspectoValidationBloc extends Bloc<ProspectoValidationEvent, ProspectoValidationState> {
  final AccountRepository repo;
  
  ProspectoValidationBloc(this.repo) : super(ProspectoValidationInitial()) {
    on<ValidarProspectoMiembro>(_onValidarProspectoMiembro);
  }
  
  Future<void> _onValidarProspectoMiembro(
    ValidarProspectoMiembro event,
    Emitter<ProspectoValidationState> emit,
  ) async {
    emit(ProspectoValidationLoading());
    try {
      final prospecto = await repo.validarProspectoMiembro(event.identificacion);
      if (prospecto.existe) {
        emit(ProspectoMiembroValidado(prospecto));
      } else {
        emit(ProspectoValidationError('No encontrado'));
      }
    } catch (e) {
      emit(ProspectoValidationError(e.toString()));
    }
  }
}
```

### 2. **Inyección de Dependencias con GetIt**

En `injection.dart`:
```dart
final sl = GetIt.instance;

Future<void> inject() async {
  // Repositorios (Ports)
  sl.registerSingleton<AccountRepository>(AccountRepositoryImpl(...));
  
  // BLoCs
  sl.registerLazySingleton<ProspectoValidationBloc>(
    () => ProspectoValidationBloc(sl<AccountRepository>()),
  );
  
  // APIs
  sl.registerSingleton<AdminApi>(AdminApiImpl(...));
}
```

Uso en páginas:
```dart
BlocProvider<ProspectoValidationBloc>(
  create: (_) => GetIt.instance<ProspectoValidationBloc>(),
  child: ProspectoMiembroPage(),
)
```

### 3. **Repository Pattern**

**Port (Interfaz)** en `domain/ports/`:
```dart
abstract class AccountRepository {
  Future<ProspectoResidente> validarProspectoResidente(String identificacion);
  Future<ProspectoMiembro> validarProspectoMiembro(String identificacion);
}
```

**Adapter (Implementación)** en `infrastructure/adapters/`:
```dart
class AccountRepositoryImpl implements AccountRepository {
  final AccountApi api;
  
  @override
  Future<ProspectoMiembro> validarProspectoMiembro(String identificacion) async {
    try {
      final response = await api.validarMiembro(identificacion);
      return ProspectoMiembro.fromJson(response);
    } catch (e) {
      throw Exception('Error validando miembro: $e');
    }
  }
}
```

### 4. **Provider Pattern (APIs)**

```dart
class AdminApi {
  final Dio _dio;
  
  AdminApi(this._dio);
  
  Future<Map<String, dynamic>> verificarFacial({
    required int personaId,
    required String fotoPath,
  }) async {
    try {
      final response = await _dio.post(
        '/api/facial/verify',
        data: FormData.fromMap({
          'persona_id': personaId,
          'foto': await MultipartFile.fromFile(fotoPath),
        }),
      );
      return response.data;
    } catch (e) {
      throw Exception('Error en verificación facial: $e');
    }
  }
}
```

---

## 📝 Guía de Estilo y Convenciones

### 1. **Nomenclatura**

| Elemento | Convención | Ejemplo |
|----------|-----------|---------|
| Clases | PascalCase | `ProspectoMiembroPage`, `MemberBloc` |
| Variables | camelCase | `cedulaCtrl`, `useCustomDateTime` |
| Constantes | camelCase con const | `const kPrimaryColor = Color(0xFF04345C)` |
| Métodos privados | prefijo _ | `_pickDate()`, `_onValidarProspectoMiembro()` |
| Archivos | snake_case | `member_create_registration_page.dart` |
| Eventos (BLoC) | PascalCase, sustantivo + verbo | `ValidarProspectoMiembro`, `CreateMemberEvent` |
| Estados (BLoC) | PascalCase, sustantivo + resultado | `ProspectoMiembroValidado`, `MemberError` |

### 2. **Imports**

Orden estándar:
```dart
// 1. Imports del SDK
import 'dart:io';
import 'dart:async';

// 2. Packages externas
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

// 3. Imports relativos (del proyecto)
import '../../domain/entities/prospecto_residente.dart';
import '../../application/blocs/prospecto_validation/prospecto_validation_bloc.dart';
import '../routes/app_routes.dart';
```

### 3. **Comentarios y Documentación**

```dart
/// Valida la identidad del miembro contra el backend
/// 
/// Retorna [ProspectoMiembro] si existe en el sistema
/// Lanza [Exception] si hay error en la validación
Future<ProspectoMiembro> validarProspectoMiembro(String cedula) async {
  // Implementación...
}
```

### 4. **Manejo de Errores**

```dart
// ✅ Bien: Capturar, procesar y emitir estado
try {
  final prospecto = await repo.validarProspectoMiembro(identificacion);
  emit(ProspectoMiembroValidado(prospecto));
} catch (e) {
  final message = e.toString().replaceAll('Exception: ', '');
  emit(ProspectoValidationError(message));
}

// ❌ Mal: Ignorar errores
final prospecto = await repo.validarProspectoMiembro(identificacion);
emit(ProspectoMiembroValidado(prospecto));
```

### 5. **Widgets Stateless vs Stateful**

Usar **StatelessWidget** cuando sea posible:
```dart
// ✅ Preferido
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});
  
  @override
  Widget build(BuildContext context) => // UI
}

// Usa BLoC para estado complejo
class MyPage extends StatefulWidget {
  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  late TextEditingController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

---

## 🔄 Módulos Principales

### 1. **Autenticación (auth/)**
- **Flujo**: LoginPage → AuthBloc → Firebase Auth → ResidentDashboard
- **Archivos clave**:
  - `auth_bloc.dart`: Maneja SignIn, SignUp, SignOut
  - `auth_repository.dart`: Interface para Firebase Auth
  - `auth_repository_impl.dart`: Implementación con Firebase

### 2. **Registro de Residentes (registro_residente/)**
- **Flujo**: ProspectoResidentePage → FacialVerificationPage → CredentialsResidentePage → Dashboard
- **Archivos clave**:
  - `registro_residente_bloc.dart`: Orquesta todo el registro
  - `resident_repository.dart`: CRUD de residentes

### 3. **Registro de Miembros de Familia (member/)**
- **Flujo**: ProspectoMiembroPage → MemberCreateRegistrationPage → MemberFacialEnrollmentPage → FacialVerificationPage → CredentialsMiembroPage
- **Archivos clave**:
  - `member_bloc.dart`: CreateMemberEvent, UpdateMemberEvent
  - `member_repository.dart`: Operaciones de miembros

### 4. **Validación de Prospectos (prospecto_validation/)**
- Valida identidades de residentes y miembros
- BLoC: `ProspectoValidationBloc`
- Estados: `ProspectoResidenteValidado`, `ProspectoMiembroValidado`, `ProspectoValidationError`

### 5. **Generación de QR (qr/ y qr_visit/)**
- **QR Propios**: ResidentsQRPage genera QR de acceso
- **QR de Visitas**: QrVisitPage genera QR para visitantes
- **QR Frecuentes**: Guardados en historial
- BLoCs: `QrBloc`, `QrVisitBloc`

### 6. **Verificación Facial (facial_enrollment/)**
- Captura 3 imágenes en diferentes ángulos
- Valida contra API de biometría
- Usa `google_mlkit_face_detection` para detección local

### 7. **Gestión de Visitantes (visitor/)**
- Crear, actualizar, eliminar visitantes
- Asignar accesos con fecha/hora
- VisitorBloc: Maneja estado de visitantes

---

## 📊 Flujos de Negocio

### Flujo 1: Registro de Residente Nuevo

```
┌─────────────────────────────────────────────────────────────┐
│                 REGISTRO CUENTA DE RESIDENTE                │
└─────────────────────────────────────────────────────────────┘

1. RegisterOptionPage
   └─> Usuario selecciona "Crear Cuenta de Residente"

2. ProspectoResidentePage
   └─> Ingresa cédula
   └─> API valida si existe (AccountRepository.validarProspectoResidente)
   └─> Si no existe:
       ├─> emit ProspectoValidationError
       └─> Muestra opción de crear perfil

3. AdminCreateResidentPage (o AdminResidentsPage)
   └─> Completa formulario con datos del residente
   └─> Selecciona vivienda (manzana, villa)
   └─> CreateResidentEvent → RegistroResidenteBloc

4. AdminFacialEnrollmentPage (o MemberFacialEnrollmentPage)
   └─> Captura 3 fotos faciales en ángulos diferentes
   └─> FaceDetected events → FacialEnrollmentBloc
   └─> emit FacialEnrollmentSuccess

5. FacialVerificationPage
   └─> Verifica el rostro contra API
   └─> VerificacionFacialCompleta event
   └─> Si coincide → navigate to credentials

6. CredentialsResidentePage
   └─> Ingresa email y contraseña
   └─> CrearCuentaResidente event → RegistroResidenteBloc
   └─> Firebase Auth.createUserWithEmailAndPassword()
   └─> Guarda datos en Firestore

7. ResidentDashboard
   └─> Usuario creado exitosamente
   └─> Puede generar QR y gestionar accesos
```

### Flujo 2: Registro de Miembro de Familia

```
┌──────────────────────────────────────────────────────────────┐
│           REGISTRO CUENTA DE MIEMBRO DE FAMILIA              │
└──────────────────────────────────────────────────────────────┘

1. RegisterOptionPage
   └─> Usuario selecciona "Crear Cuenta de Miembro"

2. ProspectoMiembroPage
   └─> Ingresa cédula
   └─> API valida si existe (AccountRepository.validarProspectoMiembro)
   └─> Si no existe:
       ├─> emit ProspectoValidationError('no encontrado')
       └─> Muestra diálogo: "¿Deseas registrarte?"

3. MemberCreateRegistrationPage
   └─> Completa formulario con:
       ├─> Datos personales (nombres, apellidos, email)
       ├─> Residente titular (quien es responsable)
       ├─> Ubicación (manzana, villa, apto)
   └─> CreateMemberEvent → MemberBloc
   └─> API.crearMiembro() → retorna persona_id

4. MemberFacialEnrollmentPage
   └─> Captura 3 fotos faciales
   └─> FaceDetected events → FacialEnrollmentBloc
   └─> emit FacialEnrollmentSuccess
   └─> Crea ProspectoMiembro con persona_id obtenido

5. FacialVerificationPage
   └─> Verifica rostro (misma lógica que residentes)
   └─> Si coincide → navigate to CredentialsMiembroPage

6. CredentialsMiembroPage
   └─> Ingresa email y contraseña
   └─> CrearCuentaMiembro event → RegistroResidenteBloc
   └─> Firebase Auth + Firestore
   └─> Vincula cuenta a persona_id

7. ResidentDashboard (como miembro)
   └─> Usuario creado como miembro
   └─> Puede generar QR según permisos del residente titular
```

### Flujo 3: Generación de QR de Visita

```
┌─────────────────────────────────────────────────────┐
│         GENERAR QR PARA VISITANTE                  │
└─────────────────────────────────────────────────────┘

1. QrVisitPage (ResidentDashboard → QR de Visitas)

2. Modo "Visitante Guardado"
   └─> Selecciona de lista de visitantes frecuentes
   └─> Opción 1: Usar fecha/hora actual
   └─> Opción 2: Personalizar fecha/hora con toggle
       ├─> Si toggle DESACTIVADO:
       │   └─> validFrom = now()
       │   └─> validUntil = now() + durationHours
       └─> Si toggle ACTIVADO:
           ├─> Selecciona fecha de inicio
           ├─> Selecciona hora de inicio
           └─> validUntil = selectedDateTime + durationHours

3. Modo "Visitante Nuevo"
   └─> Ingresa datos del visitante (nombre, cédula)
   └─> Mismo toggle de fecha/hora personalizada
   └─> ManageVisitorUseCase.createVisitor()
   └─> Crea registro en base de datos

4. Confirmación
   └─> Modal con resumen de datos
   └─> GenerateVisitQrUseCase.execute()
   └─> QrApi.generateQR(persona_id, validFrom, validUntil)

5. QrDisplayPage
   └─> Muestra código QR
   └─> Opciones: Compartir, Descargar, Copiar
   └─> Historial de QR guardado
```

---

## 📦 Dependencias

### Dependencias Principales (pubspec.yaml)

```yaml
dependencies:
  flutter_bloc: ^9.1.1          # Estado reactivo con BLoC pattern
  get_it: ^9.2.0                # Inyección de dependencias
  dio: ^5.5.0                   # Cliente HTTP
  qr_flutter: ^4.1.0            # Generación de códigos QR
  share_plus: ^12.0.1           # Compartir archivos
  google_fonts: ^6.3.3          # Fuentes de Google
  path_provider: ^2.1.3         # Acceso al sistema de archivos
  camera: ^0.11.3               # Acceso a cámara
  google_mlkit_face_detection: ^0.13.1  # Detección de rostros
  firebase_core: ^4.2.1         # Inicialización Firebase
  firebase_auth: ^6.1.2         # Autenticación Firebase
  cloud_firestore: ^6.1.0       # Base de datos Firestore
```

### Propósito de Cada Dependencia

| Paquete | Propósito |
|---------|----------|
| `flutter_bloc` | Gestión de estado reactiva |
| `get_it` | Service locator para DI |
| `dio` | HTTP client para APIs REST |
| `qr_flutter` | Generación y rendering de QR |
| `camera` | Acceso a hardware de cámara |
| `google_mlkit_face_detection` | ML Kit para detección facial |
| `firebase_auth` | Autenticación y gestión de usuarios |
| `cloud_firestore` | Base de datos en tiempo real |

---

## ⚙️ Configuración

### 1. **Firebase (firebase_options.dart)**

Generado automáticamente con `flutterfire configure`:
```dart
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Platform no soportada');
    }
  }
  
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIza...',
    appId: '1:...:android:...',
    messagingSenderId: '...',
    projectId: 'guarddin-...',
    databaseURL: 'https://guarddin-....firebaseio.com',
  );
  // ... más configuraciones
}
```

### 2. **Inyección de Dependencias (injection.dart)**

```dart
final sl = GetIt.instance;

Future<void> inject() async {
  // APIs
  sl.registerSingleton<Dio>(
    Dio(BaseOptions(
      baseUrl: 'https://api.ejemplo.com',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    )),
  );
  
  // Repositorios (Implementaciones de Ports)
  sl.registerSingleton<AccountRepository>(
    AccountRepositoryImpl(sl<AccountApi>()),
  );
  
  // BLoCs
  sl.registerLazySingleton<ProspectoValidationBloc>(
    () => ProspectoValidationBloc(sl<AccountRepository>()),
  );
  
  // UseCases
  sl.registerLazySingleton<CreateResidentUseCase>(
    () => CreateResidentUseCase(sl<ResidentRepository>()),
  );
}
```

### 3. **Temas (theme.dart y BrandTheme)**

```dart
// core/config/brand_theme.dart
class BrandTheme {
  static const Color primaryColor = Color(0xFF04345C);      // Azul oscuro
  static const Color secondaryColor = Color(0xFF10B981);    // Verde
  static const Color accentColor = Color(0xFFFF6B6B);       // Rojo
  
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      fontFamily: 'GoogleSans',
    );
  }
  
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),
    );
  }
}
```

### 4. **Rutas (app_routes.dart)**

```dart
class AppRoutes {
  static const String login = '/login';
  static const String registerOption = '/registerOption';
  static const String prospectoResidente = '/prospectoResidente';
  static const String prospectoMiembro = '/prospectoMiembro';
  static const String memberCreateRegistration = '/memberCreateRegistration';
  static const String memberFacialEnrollment = '/memberFacialEnrollment';
  static const String facialVerification = '/facialVerification';
  static const String credentialsResidente = '/credentialsResidente';
  static const String credentialsMiembro = '/credentialsMiembro';
  static const String residentDashboard = '/residentDashboard';
  static const String qrSelf = '/qrSelf';
  static const String qrVisit = '/qrVisit';
  static const String adminDashboard = '/adminDashboard';
  
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      
      case prospectoMiembro:
        return MaterialPageRoute(builder: (_) => const ProspectoMiembroPage());
      
      case memberCreateRegistration:
        final cedula = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => BlocProvider<MemberBloc>(
            create: (_) => GetIt.instance<MemberBloc>(),
            child: MemberCreateRegistrationPage(identificacion: cedula ?? ''),
          ),
        );
      
      // ... más rutas
      
      default:
        return _errorRoute('Ruta no encontrada: ${settings.name}');
    }
  }
}
```

---

## 🚀 Guía de Desarrollo

### 1. **Crear una Nueva Funcionalidad**

Ejemplo: Crear endpoint para crear un nuevo visitante

#### Paso 1: Definir la Entity (domain/entities/)
```dart
class Visitor {
  final String id;
  final String nombre;
  final String identificacion;
  final DateTime? registeredAt;
  
  Visitor({
    required this.id,
    required this.nombre,
    required this.identificacion,
    this.registeredAt,
  });
}
```

#### Paso 2: Crear el Port (domain/ports/)
```dart
abstract class VisitorRepository {
  Future<Visitor> createVisitor(String nombre, String identificacion);
  Future<List<Visitor>> getVisitors();
}
```

#### Paso 3: Crear el UseCase (domain/usecases/)
```dart
class CreateVisitorUseCase {
  final VisitorRepository repo;
  
  CreateVisitorUseCase(this.repo);
  
  Future<Visitor> call(String nombre, String identificacion) async {
    // Validar datos
    if (nombre.isEmpty) throw Exception('Nombre requerido');
    if (identificacion.isEmpty) throw Exception('Identificación requerida');
    
    // Llamar repositorio
    return repo.createVisitor(nombre, identificacion);
  }
}
```

#### Paso 4: Implementar el Adapter (infrastructure/adapters/)
```dart
class VisitorRepositoryImpl implements VisitorRepository {
  final VisitorApi api;
  
  VisitorRepositoryImpl(this.api);
  
  @override
  Future<Visitor> createVisitor(String nombre, String identificacion) async {
    try {
      final response = await api.createVisitor(nombre, identificacion);
      return Visitor.fromJson(response);
    } catch (e) {
      throw Exception('Error creando visitante: $e');
    }
  }
}
```

#### Paso 5: Crear el API Provider (infrastructure/providers/)
```dart
class VisitorApi {
  final Dio _dio;
  
  VisitorApi(this._dio);
  
  Future<Map<String, dynamic>> createVisitor(
    String nombre,
    String identificacion,
  ) async {
    final response = await _dio.post(
      '/api/visitors',
      data: {
        'nombre': nombre,
        'identificacion': identificacion,
      },
    );
    return response.data;
  }
}
```

#### Paso 6: Crear BLoC (application/blocs/)
```dart
class VisitorEvent extends Equatable {}

class CreateVisitorEvent extends VisitorEvent {
  final String nombre;
  final String identificacion;
  
  CreateVisitorEvent(this.nombre, this.identificacion);
  
  @override
  List<Object?> get props => [nombre, identificacion];
}

class VisitorState extends Equatable {}

class VisitorLoading extends VisitorState {
  @override
  List<Object?> get props => [];
}

class VisitorCreated extends VisitorState {
  final Visitor visitor;
  VisitorCreated(this.visitor);
  
  @override
  List<Object?> get props => [visitor];
}

class VisitorError extends VisitorState {
  final String message;
  VisitorError(this.message);
  
  @override
  List<Object?> get props => [message];
}

class VisitorBloc extends Bloc<VisitorEvent, VisitorState> {
  final CreateVisitorUseCase createVisitorUseCase;
  
  VisitorBloc(this.createVisitorUseCase) : super(VisitorLoading()) {
    on<CreateVisitorEvent>(_onCreate);
  }
  
  Future<void> _onCreate(
    CreateVisitorEvent event,
    Emitter<VisitorState> emit,
  ) async {
    emit(VisitorLoading());
    try {
      final visitor = await createVisitorUseCase(
        event.nombre,
        event.identificacion,
      );
      emit(VisitorCreated(visitor));
    } catch (e) {
      emit(VisitorError(e.toString()));
    }
  }
}
```

#### Paso 7: Registrar en DI (injection.dart)
```dart
Future<void> inject() async {
  // Existente...
  
  // Nuevo
  sl.registerSingleton<VisitorApi>(VisitorApi(sl<Dio>()));
  
  sl.registerSingleton<VisitorRepository>(
    VisitorRepositoryImpl(sl<VisitorApi>()),
  );
  
  sl.registerLazySingleton<CreateVisitorUseCase>(
    () => CreateVisitorUseCase(sl<VisitorRepository>()),
  );
  
  sl.registerLazySingleton<VisitorBloc>(
    () => VisitorBloc(sl<CreateVisitorUseCase>()),
  );
}
```

#### Paso 8: Crear la UI (presentation/pages/)
```dart
class CreateVisitorPage extends StatefulWidget {
  @override
  State<CreateVisitorPage> createState() => _CreateVisitorPageState();
}

class _CreateVisitorPageState extends State<CreateVisitorPage> {
  final nombreCtrl = TextEditingController();
  final cedulaCtrl = TextEditingController();
  
  @override
  void dispose() {
    nombreCtrl.dispose();
    cedulaCtrl.dispose();
    super.dispose();
  }
  
  void _submit() {
    context.read<VisitorBloc>().add(
      CreateVisitorEvent(nombreCtrl.text, cedulaCtrl.text),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Visitante')),
      body: BlocListener<VisitorBloc, VisitorState>(
        listener: (context, state) {
          if (state is VisitorCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Visitante creado exitosamente')),
            );
            Navigator.of(context).pop();
          } else if (state is VisitorError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
          }
        },
        child: BlocBuilder<VisitorBloc, VisitorState>(
          builder: (context, state) {
            final loading = state is VisitorLoading;
            
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: nombreCtrl,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                  ),
                  TextField(
                    controller: cedulaCtrl,
                    decoration: const InputDecoration(labelText: 'Cédula'),
                  ),
                  ElevatedButton(
                    onPressed: loading ? null : _submit,
                    child: const Text('Crear'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
```

### 2. **Estructura de un BLoC**

Siempre mantener esta estructura:
```
bloc_name/
├── bloc_name_bloc.dart      # BLoC principal
├── bloc_name_event.dart     # Events
└── bloc_name_state.dart     # States
```

### 3. **Testing**

```dart
void main() {
  group('VisitorBloc', () {
    late MockCreateVisitorUseCase mockUseCase;
    late VisitorBloc visitorBloc;
    
    setUp(() {
      mockUseCase = MockCreateVisitorUseCase();
      visitorBloc = VisitorBloc(mockUseCase);
    });
    
    tearDown(() {
      visitorBloc.close();
    });
    
    test('emits [VisitorLoading, VisitorCreated] cuando exitoso', () async {
      final visitor = Visitor(id: '1', nombre: 'John', identificacion: '123');
      
      when(mockUseCase.call('John', '123'))
        .thenAnswer((_) async => visitor);
      
      expect(
        visitorBloc.stream,
        emitsInOrder([
          VisitorLoading(),
          VisitorCreated(visitor),
        ]),
      );
      
      visitorBloc.add(CreateVisitorEvent('John', '123'));
    });
  });
}
```

### 4. **Mejores Prácticas**

#### ✅ Haz
- Mantener lógica en domain/usecases, no en páginas
- Usar BLoC para todo estado complejo
- Validar datos en usecases, no en UI
- Capturar errores y emitir estados de error
- Usar const constructors en widgets
- Documentar funciones públicas

#### ❌ No Hagas
- Llamadas directas a API desde páginas
- Lógica en build()
- Variable state en páginas (excepto en BLoC)
- Widgets gigantes (refactorizar en sub-widgets)
- Ignorar disposición de recursos
- Hacer inyección en rutas (hacerlo en DI)

---

## 📚 Convenciones de Nombres

### Eventos
- `ValidarProspectoMiembro`
- `CreateMemberEvent`
- `UpdateResidentEvent`
- `DeleteVisitorEvent`

### Estados
- `ProspectoMiembroValidado`
- `MemberCreated`
- `MemberLoading`
- `MemberError`

### Métodos privados en BLoC
- `_onValidarProspectoMiembro()`
- `_onCreate()`
- `_onUpdate()`
- `_onDelete()`

### Variables de Control UI
- `isLoading`, `isSubmitting`
- `useCustomDateTime`, `showPassword`
- `selectedDate`, `selectedTime`

---

## 🔗 Conexiones Clave del Proyecto

```
LoginPage
    ↓
    → AuthBloc (AuthRepository)
    ↓
ResidentDashboard
    ↓
    ├─→ QrSelfPage (QrBloc)
    ├─→ QrVisitPage (QrVisitBloc, VisitorBloc)
    ├─→ AccessHistoryPage (HistoryBloc)
    └─→ ProfilePage

RegisterOptionPage
    ↓
    ├─→ ProspectoResidentePage
    │   ↓
    │   → ProspectoValidationBloc
    │   → AdminCreateResidentPage (RegistroResidenteBloc)
    │   → AdminFacialEnrollmentPage (FacialEnrollmentBloc)
    │   → FacialVerificationPage
    │   → CredentialsResidentePage
    │
    └─→ ProspectoMiembroPage
        ↓
        → ProspectoValidationBloc
        → MemberCreateRegistrationPage (MemberBloc)
        → MemberFacialEnrollmentPage (FacialEnrollmentBloc)
        → FacialVerificationPage
        → CredentialsMiembroPage

AdminDashboard
    ↓
    ├─→ AdminUsersPage
    ├─→ AdminResidentsPage
    ├─→ AdminMembersPage
    ├─→ AdminOwnersPage
    └─→ AdminAccountsPage
```

---

## 📞 Contacto y Referencias

- **Framework**: Flutter 3.x+
- **Lenguaje**: Dart 3.0+
- **Estado**: BLoC pattern con `flutter_bloc`
- **Testing**: Requiere extensión con mocktail/mockito
- **CI/CD**: Preparado para integración continua

---

## Notas Importantes

1. **Seguridad**: Las credenciales de Firebase están en `firebase_options.dart`
2. **APIs**: Los endpoints están en `core/constants/api_constants.dart`
3. **Roles**: Los roles disponibles están en `core/constants/roles.dart`
4. **Validaciones**: Ver `core/validations/` para reglas de validación
5. **Temas**: Colores y estilos en `core/config/brand_theme.dart`

---

**Última actualización**: 27 de Enero, 2026
**Versión del proyecto**: 1.0.0

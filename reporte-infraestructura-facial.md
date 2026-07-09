# Reporte: Infraestructura Facial

**Fecha:** 2026-07-08

---

## 1. Providers de Biometría

### 1.1 `biometrics/facial_enrollment_api_impl.dart` (64 líneas)

```dart
class FacialEnrollmentApiImpl implements FacialEnrollmentApiPort {
  final Dio dio;

  enrollFacialData({personaId, imagenesBytes, usuarioCreado}) async {
    // POST /enroll (MultipartFormData)
    // Fields: persona_id, usuario_creado
    // Files: images (x3, una por ángulo)
  }
}
```

**Endpoint:** `POST /enroll` (servicio de biometría, puerto 8000), `MultipartFile.fromBytes`.

### 1.2 `biometrics/facial_verification_api_impl.dart` (63 líneas)

```dart
class FacialVerificationApiImpl implements FacialVerificationApiPort {
  final Dio dio;

  verificarFacial({personaId, fotoBytes}) async {
    // POST /verify (MultipartFormData)
    // Fields: persona_id
    // Files: image (1 foto)
    // Returns: {match, distance, persona_id}
  }
}
```

**Endpoint:** `POST /verify` (servicio de biometría, puerto 8000).

### 1.3 `biometrics/face_detection_mobile_impl.dart` (86 líneas)

```dart
class FaceDetectionMobileImpl implements FaceDetectionPort {
  late FaceDetector _faceDetector;  // google_mlkit_face_detection

  FaceDetectionMobileImpl() {
    _faceDetector = FaceDetector(options: FaceDetectorOptions(
      enableLandmarks: true, enableClassification: true, enableTracking: true,
      performanceMode: FaceDetectorMode.fast,
    ));
  }

  processImage({bytes, width, height, rotation, bytesPerRow}) async {
    // Convierte bytes a InputImage (NV21)
    // Ejecuta _faceDetector.processImage()
    // Retorna List<DetectedFace> con ángulos Euler y probabilidades
  }

  close() async { await _faceDetector.close(); }
}
```

**ML Kit:** Esta clase instancia `FaceDetector` al crearse. Consume ~40MB de RAM. `close()` debe llamarse para liberar recursos.

### 1.4 `biometrics/face_detection_web_impl.dart` (50 líneas)

```dart
class FaceDetectionWebImpl implements FaceDetectionPort {
  final Dio dio;

  processImage({bytes, width, height, rotation, bytesPerRow}) async {
    // POST /detect-face (JSON con base64)
    // Retorna faces parsed via DetectedFace.fromMap()
  }

  close() async {}  // No-op
}
```

### 1.5 `providers/face_api.dart` (22 líneas)

```dart
class FaceApi {
  final Dio client;
  validate({accountId, capturePath}) async {
    await Future.delayed(300ms);
    return true;  // Placeholder
  }
}
```

### 1.6 `providers/face_local.dart` (7 líneas)

```dart
class FaceLocal {
  validate({accountId, capturePath}) async { return true; }  // Placeholder
}
```

---

## 2. Adapters

### 2.1 `adapters/face_repository_impl.dart` (19 líneas)

```dart
class FaceRepositoryImpl implements FaceRepository {
  final FaceMode mode;  // api o local
  final FaceApi api;
  final FaceLocal local;

  validateFace({accountId, capturePath}) async {
    if (mode == FaceMode.api) return api.validate(...);
    return local.validate(...);
  }
}
```

**Nota:** `FaceRepository` no se usa en el flujo de enrollment/verificación actual. Es legacy.

---

## 3. Injection.dart — Registros faciales

### Cliente HTTP de biometría (líneas 204-210)

```dart
final biometryHttpClient = ApiHttpClient(
    baseUrl: biometryBaseUrl,     // localhost:8000/api/v1
    firebaseAuth: firebaseAuth,
);
sl.registerLazySingleton<ApiHttpClient>(
    () => biometryHttpClient, instanceName: 'biometryClient',
);
```

### Puerto → Provider (líneas 255-273)

| Puerto | Provider | Endpoint | Condición |
|--------|----------|----------|-----------|
| `FacialEnrollmentApiPort` | `FacialEnrollmentApiImpl` | `/enroll` | Siempre |
| `FacialVerificationApiPort` | `FacialVerificationApiImpl` | `/verify` | Siempre |
| `FaceDetectionPort` | `FaceDetectionWebImpl` | `/detect-face` | `kIsWeb` |
| `FaceDetectionPort` | `FaceDetectionMobileImpl` | ML Kit local | No web |

### BLoCs (líneas 642-655)

```dart
sl.registerFactory<FacialEnrollmentBloc>(
    () => FacialEnrollmentBloc(
        enrollmentApi: sl<FacialEnrollmentApiPort>(),
        authProvider: sl<FirebaseAuthProviderPort>(),
    ),
);

sl.registerFactory<FacialVerificationBloc>(
    () => FacialVerificationBloc(
        verificationApi: sl<FacialVerificationApiPort>(),
        generarRetos: sl<GenerarRetosLivenessUseCase>(),
        authProvider: sl<FirebaseAuthProviderPort>(),
    ),
);
```

**No hay registro de `CameraController` en GetIt.** Siempre se crea localmente en el State.

---

## 4. Entidades faciales

### 4.1 `detected_face.dart` (48 líneas)

```dart
class DetectedFace {
  final double? headEulerAngleX, headEulerAngleY, headEulerAngleZ;
  final double? smilingProbability;
  final double? leftEyeOpenProbability, rightEyeOpenProbability;

  factory DetectedFace.fromMap(Map<String, dynamic> map);
  Map<String, dynamic> toMap();
}
```

### 4.2 `prospecto_residente.dart` — `ProspectoMiembro` (líneas 39-87)

Campo clave para el flujo facial:

```dart
final bool? tieneFacialEnrolado;  // ← Controla si va a enrollment o verification
```

---

## 5. Diagrama de dependencias

```
FacialEnrollmentBloc (factory)
  ├── FacialEnrollmentApiPort
  │     └── FacialEnrollmentApiImpl (Dio → POST /enroll)
  └── FirebaseAuthProviderPort

FacialVerificationBloc (factory)
  ├── FacialVerificationApiPort
  │     └── FacialVerificationApiImpl (Dio → POST /verify)
  ├── GenerarRetosLivenessUseCase
  └── FirebaseAuthProviderPort

FaceDetectionPort (singleton, condicional)
  ├── FaceDetectionMobileImpl (ML Kit, ~40MB)
  │     └── FaceDetector (google_mlkit_face_detection)
  └── FaceDetectionWebImpl (Dio → POST /detect-face)

FacialCaptureMobile / FacialCaptureView
  └── FaceDetectionPort (sl<FaceDetectionPort>())
```

# Reporte: MemberFacialEnrollment y FacialEnrollmentBloc

**Fecha:** 2026-07-08

---

## 1. `member_facial_enrollment_page.dart` (750 líneas)

| Sección | Líneas | Descripción |
|---------|--------|-------------|
| Imports | 1-12 | `dart:typed_data`, `flutter`, `flutter_bloc`, `camera`, BLoC, widgets, `CredentialsMiembroPage` |
| `MemberFacialEnrollmentPage` | 14-45 | Fachada StatelessWidget: campos `personaId`, `nombres`, `apellidos`, `type`, `origen`, `prospectoCompleto` |
| `_MemberFacialEnrollmentView` | 48-68 | StatefulWidget wrapper |
| `_MemberFacialEnrollmentViewState` | 70-542 | State principal con cámara, diálogos, builders |
| `_initializeCamera()` | 99-143 | `availableCameras()` → `CameraController(ResolutionPreset.high)` → `EnrollmentStarted` |
| `_disposeCamera()` | 82-97 | Guard `_cameraDisposeInProgress`, logs `[ENROLL]` |
| `_onFaceCaptured()` | 145-149 | Dispatch `FaceCaptured(bytes, angle)` |
| `_mostrarDialogoExito()` | 157-214 | **Fire-and-forget** `_disposeCamera()`, `await showDialog`, `500ms delay`, `pushReplacement(CredentialsMiembroPage)` |
| `_mostrarDialogoError()` | 216-256 | `await showDialog<String>()` → `cancelar`(pop) o `reintentar`(EnrollmentResubmit) |
| `build()` | 258-272 | `BlocConsumer` con listener+`_buildContent` |
| `_buildContent()` | 274-346 | Spinner→Submitting→Success→camera+side panel |
| `_buildDesktopLayout()` | 348-366 | Row: camera + side panel |
| `_buildMobileLayout()` | 368-431 | Stack: camera + overlays |
| `_EnrollmentSidePanel` | 544-749 | Side panel con pose steps + instrucción + progreso |

---

## 2. `facial_enrollment_bloc.dart` (221 líneas)

| Dependencia | Puerto/Uso |
|-------------|-----------|
| `FacialEnrollmentApiPort enrollmentApi` | `enrollFacialData(personaId, imagenesBytes)` |
| `FirebaseAuthProviderPort authProvider` | `currentUser?.email` |

### Estados emitidos

```
Inicial → InProgress → PhotoCaptured → InProgress/PhotoCaptured → Submitting → Success
   ↓                                                                              ↓
   └────────────────────────────────────────────────────────────────────── Error → Submitting o InProgress
```

### Timer interno

- Ninguno. No requiere `close()` sobreescrito.
- Capturas con `await Future.delayed(500ms)` entre cada foto.

---

## 3. `facial_enrollment_event.dart` (50 líneas)

| Evento | Campos | Propósito |
|--------|--------|-----------|
| `EnrollmentStarted` | `personaId` | Inicia captura |
| `FaceCaptured` | `bytes`, `angle` | Foto capturada desde cámara |
| `EnrollmentSubmitted` | `usuarioCreado` | Auto-evento: 3 fotos listas → enviar |
| `EnrollmentRetried` | — | Reiniciar captura desde 0 |
| `EnrollmentResubmit` | — | Reintentar envío |

---

## 4. `facial_enrollment_state.dart` (136 líneas)

| Estado | Campos | Métodos |
|--------|--------|---------|
| `FacialEnrollmentInitial` | — | — |
| `FacialEnrollmentInProgress` | `imagenes`, `poseActual`, `instruccion` | `inicial()`, `conCaptura(angle, bytes)`, getter `completo`, `rutasBytes`, `fotosCapturadas` |
| `FacialPhotoCaptured` | `fotoNumero`, `rutaImagen`, `angulo` | — |
| `FacialEnrollmentSubmitting` | — | — |
| `FacialEnrollmentSuccess` | `mensaje`, `enrollmentId` | — |
| `FacialEnrollmentError` | `mensaje` | — |
| `FacialEnrollmentWaiting` | `mensaje` | — |

---

## 5. Puertos (3 archivos)

### 5.1 `facial_enrollment_api_port.dart` (16 líneas)

```dart
abstract class FacialEnrollmentApiPort {
  Future<Map<String, dynamic>> enrollFacialData({
    required String personaId,
    required List<Uint8List> imagenesBytes,
    String? usuarioCreado,
  });
}
```

### 5.2 `facial_verification_api_port.dart` (14 líneas)

```dart
abstract class FacialVerificationApiPort {
  Future<Map<String, dynamic>> verificarFacial({
    required int personaId,
    required Uint8List fotoBytes,
  });
}
```

### 5.3 `face_detection_port.dart` (13 líneas)

```dart
abstract class FaceDetectionPort {
  Future<List<DetectedFace>> processImage({
    required List<int> bytes, required int width,
    required int height, required int rotation,
    int? bytesPerRow,
  });
  Future<void> close();
}
```

---

## 6. Use Cases (1 archivo)

### 6.1 `generar_retos_liveness_usecase.dart` (22 líneas)

```dart
class GenerarRetosLivenessUseCase {
  List<LivenessReto> execute() {
    final todos = LivenessReto.values.toList();
    todos.shuffle(_random);
    final cantidad = _random.nextInt(2) + 2; // 2 o 3 retos
    return todos.take(cantidad).toList();
  }
}
```

---

## 7. Diagrama de flujo completo

```
MemberFacialEnrollmentPage
├── initState → _initializeCamera()
│     └── CameraController(high) → initialize() → EnrollmentStarted
│
├── _onFaceCaptured(bytes, angle)
│     └── BLoC: FaceCaptured → FacialEnrollmentInProgress.conCaptura()
│           ├── completo=false → emit(InProgress)
│           └── completo=true
│                 └── EnrollmentSubmitted (evento interno)
│                       └── _enviarAlServidor()
│                             ├── POST /biometria/inscribir (Dio)
│                             ├── OK → FacialEnrollmentSuccess
│                             │     └── _mostrarDialogoExito()
│                             │           ├── _disposeCamera() fire-and-forget
│                             │           ├── showDialog → user presses Continue
│                             │           ├── await 500ms
│                             │           └── pushReplacement(CredentialsMiembroPage)
│                             └── ERROR → FacialEnrollmentError
│                                   └── _mostrarDialogoError()
│                                         ├── Cancelar → pop
│                                         └── Reintentar → EnrollmentResubmit
│
└── dispose() → _disposeCamera() (guarded)
```

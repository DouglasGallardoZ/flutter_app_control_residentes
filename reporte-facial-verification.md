# Reporte: FacialVerificationPage y componentes asociados

**Fecha:** 2026-07-08

---

## 1. `facial_verification_page.dart` (439 líneas)

| Sección | Líneas | Descripción |
|---------|--------|-------------|
| Imports | 1-19 | `dart:typed_data`, `flutter/material`, `flutter_bloc`, `camera`, BLoCs, widgets, `injection` |
| `VerificationMode` enum | 21 | `createCredentials`, `unlockApp` |
| `FacialVerificationPage` (StatelessWidget) | 23-41 | Fachada: `BlocProvider<FacialVerificationBloc>` con `IniciarVerificacionLiveness` + `_FacialVerificationView` |
| `_FacialVerificationView` (StatefulWidget) | 43-52 | Wrapper con `prospecto` (dynamic) y `mode` |
| `_FacialVerificationViewState` | 54-439 | State con `CameraController`, `_cameraError`, liveness, 6 métodos privados |
| `_initializeCamera()` | 120-152 | `availableCameras()` → `CameraController(ResolutionPreset.high)` → `initialize()` → `setState` |
| `_enviarFotoAlServidor()` | 154-185 | Captura foto, envía `VerifyFaceSubmitted(personaId, fotoBytes)` al BLoC |
| `_mostrarResultado()` | 195-262 | Diálogo éxito/fallo → si éxito: `/credentialsMiembro` o `/credentialsResidente` |
| `build()` | 288-438 | `BlocConsumer` con 5 estados, `FacialCaptureView` o spinner o error |

### Estados manejados en el listener

| Estado | Acción |
|--------|--------|
| `LivenessExitoCaptura` | `_detenerStreamCamara()` + `_enviarFotoAlServidor()` |
| `LivenessErrorTimeout` | SnackBar + `IniciarVerificacionLiveness` |
| `FacialVerificationSuccess(match: false)` | Si `unlockApp` → `Navigator.pop(false)`. Si `createCredentials` → diálogo reintentar |
| `FacialVerificationSuccess(match: true)` | `unlockApp` → pop(true). `createCredentials` → añade VerificacionFacialCompleta + diálogo |
| `FacialVerificationFailure` | `unlockApp` → pop(false). `createCredentials` → SnackBar + reiniciar |

---

## 2. `facial_verification_bloc.dart` (159 líneas)

| Dependencia | Puerto/Uso |
|-------------|-----------|
| `FacialVerificationApiPort verificationApi` | `verificarFacial(personaId, fotoBytes)` |
| `GenerarRetosLivenessUseCase generarRetos` | `execute()` → `List<LivenessReto>` |
| `FirebaseAuthProviderPort authProvider` | `currentUser` check |

### Eventos manejados

| Evento | Handler | Efecto |
|--------|---------|--------|
| `VerifyFaceSubmitted` | `_onVerifyFace` | API verification → `FacialVerificationSuccess/Error` |
| `IniciarVerificacionLiveness` | `_onIniciarVerificacionLiveness` | Genera retos → `LivenessRetoPresentado` o `LivenessExitoCaptura` |
| `ProcesarFrameCamara` | `_onProcesarFrameCamara` | Evalúa reto actual → avanza si cumplido |
| `RetoTiempoExpirado` | `_onRetoTiempoExpirado` | `LivenessErrorTimeout` |
| `VerificationCancelada` | `_onCancelada` | Cancela timer |

### Timer interno

```dart
_temporizadorReto = Timer(
  const Duration(seconds: _duracionRetoSegundos),  // 5s
  () => add(RetoTiempoExpirado()),
);
```

---

## 3. `facial_verification_event.dart` (41 líneas)

| Evento | Campos |
|--------|--------|
| `VerifyFaceSubmitted` | `personaId`, `fotoBytes` |
| `IniciarVerificacionLiveness` | — |
| `ProcesarFrameCamara` | `eulerX`, `eulerY`, `smilingProb`, `leftEyeOpenProb`, `rightEyeOpenProb` |
| `RetoTiempoExpirado` | — |
| `VerificationCancelada` | — |

---

## 4. `facial_verification_state.dart` (61 líneas)

| Estado | Campos |
|--------|--------|
| `FacialVerificationInitial` | — |
| `FacialVerificationLoading` | — |
| `FacialVerificationSuccess` | `match`, `distance` |
| `FacialVerificationFailure` | `mensaje` |
| `LivenessInicial` | — |
| `LivenessRetoPresentado` | `retoActual`, `indiceReto`, `totalRetos`, `segundosRestantes`, getter `instruccion` |
| `LivenessErrorTimeout` | `mensaje` |
| `LivenessExitoCaptura` | — |

---

## 5. `facial_capture/` widgets (3 archivos)

### 5.1 `facial_capture_view.dart` (54 líneas)

Fachada: si `kIsWeb` → `FacialCaptureWeb`, si no → `FacialCaptureMobile`.

**Props:** `CameraController`, `FaceDetectionPort`, `onFaceCaptured`, `onFrameProcessed`, liveness props, `navigatingAway`.

### 5.2 `facial_capture_mobile.dart` (345 líneas)

| Componente | Líneas | Descripción |
|-----------|--------|-------------|
| `FrameLivenessData` | 35-49 | Data class con euler angles + probabilidades |
| `FacialCaptureMobileState` | 51-345 | State con `_cameraController` local, `_isProcessing`, `_isDisposing` |
| `initState()` | 88-95 | Almacena `widget.controller`, arranca image stream en post-frame |
| `_startImageStream()` | 97-104 | `startImageStream` con throttle de 100ms |
| `_processCameraImage()` | 106-171 | ML Kit face detection, liveness frame dispatch, captura con throttle 800ms |
| `_despacharFrameLiveness()` | 173-192 | Envía `onFrameProcessed()` con `FrameLivenessData` |
| `_captureBytes()` | 194-203 | `takePicture()` + `readAsBytes()` |
| `dispose()` | 218-229 | Solo `stopImageStream()` — NO `dispose()` del controller (lo hace el padre) |
| `build()` | 231-254 | `CameraPreview` o banner si `_modoLiveness` |

### 5.3 `facial_capture_web.dart` (140 líneas)

Captura manual con botón. `_secuenciaAngulos: [front, left, right]`, 3 fotos, instrucciones, progress indicator.

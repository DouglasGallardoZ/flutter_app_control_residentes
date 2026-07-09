# Diagnóstico: Ciclo de vida del CameraController

**Fecha:** 2026-07-08

---

## 1. ¿Quién crea el CameraController?

**En `member_facial_enrollment_page.dart`:**

```dart
// State: _MemberFacialEnrollmentViewState (líneas 72-76)
CameraController? _cameraController;          // ← PROPIETARIO
bool _isCameraInitialized = false;
bool _cameraDisposeInProgress = false;

// initState() → _initializeCamera() → crea (líneas 118-124):
_cameraController = CameraController(camera, ResolutionPreset.high, enableAudio: false);
await _cameraController!.initialize();
```

**EL `CameraController` es propiedad EXCLUSIVA de `_MemberFacialEnrollmentViewState`.** No se comparte vía GetIt, no se pasa al BLoC.

## 2. El CameraController NO se pasa al BLoC

**`FacialEnrollmentBloc` recibe solo bytes** (Uint8List) de las fotos capturadas, nunca al `CameraController`:

```dart
// En _onFaceCaptured (page:144-148):
context.read<FacialEnrollmentBloc>().add(
    FaceCaptured(bytes: bytes, angle: angle),  // ← solo bytes
);

// En _enviarAlServidor (bloc:108):
final response = await enrollmentApi.enrollFacialData(
    personaId: _personaId,
    imagenesBytes: _rutasPendientes,           // ← solo bytes
    usuarioCreado: usuario,
);
```

## 3. ¿Dónde se podría disponer el CameraController?

| Punto | Archivo:Línea | ¿Llama dispose? |
|-------|---------------|----------------|
| `_disposeCamera()` del state | page:83-96 | ✅ `await _cameraController!.dispose()` — SOLO llama si `_cameraDisposeInProgress == false` |
| `dispose()` del state | page:150-154 | ✅ Llama a `_disposeCamera()` — pero `_cameraDisposeInProgress` impide re-ejecución |
| `FacialCaptureMobile.dispose()` | capture_mobile:219-229 | ❌ **NO** llama a `dispose()` — solo `stopImageStream()` + `_cameraController = null` (local) |

## 4. ¿Hay doble dispose? NO — análisis línea por línea

### Secuencia normal (éxito):

```
1. initState() → _initializeCamera() → CameraController creado (line 118)
2. Builder: FacialCaptureView → FacialCaptureMobile → starts image stream
3. _onFaceCaptured × 3 → BLoC completa → FacialEnrollmentSubmitting
4. Builder: spinner "PROCESANDO BIOMETRÍA..." → FacialCaptureMobile SALE del árbol
   └→ FacialCaptureMobile.dispose() → stopImageStream() → NO dispose camera
   └→ CameraController SIGUE VIVO en _MemberFacialEnrollmentViewState

5. BLoC: _enviarAlServidor completa → FacialEnrollmentSuccess emitido
6. Builder: SizedBox.shrink()
7. Listener: _mostrarDialogoExito() → await _disposeCamera() ← PRIMERA Y ÚNICA dispose
   └→ _cameraDisposeInProgress = false → true
   └→ await _cameraController!.dispose() ← EJECUTADO
   └→ _cameraController = null, _isCameraInitialized = false

8. await showDialog (dialogo de éxito)
9. pushReplacement → Flutter llama a dispose() del state
   └→ _disposeCamera() → _cameraDisposeInProgress == true → RETORNA INMEDIATAMENTE
```

**Conclusión: No hay doble dispose.** La cámara se dispone 1 vez (en `_mostrarDialogoExito`), y el guard `_cameraDisposeInProgress` previene cualquier re-ejecución en `dispose()`.

## 5. Si el ANR persiste, no es por doble dispose

| Causa potencial | Explicación |
|----------------|-------------|
| `await _cameraController!.dispose()` lento | En algunos dispositivos Android, `camera.dispose()` puede tomar >5s si el driver de la cámara no libera recursos rápidamente. |
| `_enviarAlServidor` con timeout | 3 fotos en `ResolutionPreset.high` pueden ser ~15-20MB. Si el backend tarda en procesar, el BLoC se queda en `Submitting` por mucho tiempo. |
| `showDialog` usa `context` del listener | El listener se ejecuta en medio del procesamiento del BLoC. El `context` podría no ser seguro para `showDialog`. |
| **El ANR podría no ser de este archivo** | El error "Lost connection to device" también puede ocurrir por OutOfMemoryError en otras partes de la app. |

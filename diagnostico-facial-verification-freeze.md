# Diagnóstico: FacialVerificationPage se congela sin abrir cámara

**Fecha:** 2026-07-08

---

## 1. `facial_verification_page.dart` (417 líneas)

### Arquitectura

```
FacialVerificationPage (StatelessWidget) ← modo fachada
  └── build(): BlocProvider<FacialVerificationBloc>()
        create: sl<FacialVerificationBloc>()
          ..add(IniciarVerificacionLiveness())  ← BLoC arranca INMEDIATAMENTE
        child: _FacialVerificationView(StatefulWidget)
          └── State.initState()
                ├── _facialVerificationBloc = context.read()
                ├── Auth check (pop if not logged in)
                └── _initializeCamera() ← async, crea CameraController
```

### _initializeCamera() (líneas 121-162) — ANR aquí

```dart
Future<void> _initializeCamera() async {
  try {
    final cameras = await availableCameras();      // ← 1. Enumera hardware (lento en MediaTek)
    ...
    _cameraController = CameraController(
      camera,
      ResolutionPreset.high,                        // ← 2. Resolución ALTA (consume ~40MB GPU)
      enableAudio: false,
    );
    await _cameraController!.initialize();           // ← 3. Abre sesión de cámara (ANR en OPPO)
    if (mounted) setState(() => _isCameraInitialized = true);
  }
}
```

### build() (líneas 386-414)

```dart
body: _isCameraInitialized
    ? FacialCaptureView(
        controller: _cameraController!,            // ← Solo se renderiza si camera inició
        faceDetection: sl<FaceDetectionPort>(),      // ← ML Kit (~40MB adicional)
        ...
      )
    : const Center(child: CircularProgressIndicator()),  // ← Spinner MIENTRAS camera inicia
```

### Causa raíz del ANR

| Llamada | Problema | Tiempo estimado |
|---------|----------|-----------------|
| `availableCameras()` | Enumera hardware de cámara. En OPPO/MediaTek puede tardar si el driver está en un estado inconsistente. | 500ms-3s |
| `ResolutionPreset.high` + `initialize()` | Abre sesión de cámara con alta resolución. Asigna buffers de GPU. En dispositivos con RAM limitada (OPPO MediaTek ~4GB), esto compite con ML Kit (~40MB) y la UI. | 1s-5s |
| **Total sin respuesta en main thread** | Durante `await availableCameras()` e `initialize()`, el event loop NO se bloquea. Pero el `CameraController` internamente usa `PlatformChannel` que puede saturar el main thread si el driver no responde rápido → ANR. | >5s → ANR |

## 2. `facial_verification_bloc.dart` (159 líneas)

### Inicialización

```dart
FacialVerificationBloc({
  required this.verificationApi,
  required this.generarRetos,
  required this.authProvider,
}) : super(FacialVerificationInitial()) {
  on<IniciarVerificacionLiveness>(_onIniciarVerificacionLiveness);
```

### _onIniciarVerificacionLiveness (líneas 56-75)

```dart
Future<void> _onIniciarVerificacionLiveness(...) async {
  if (authProvider.currentUser == null) {           // ← Firebase Auth check
    emit(FacialVerificationFailure(mensaje: 'Sesión no iniciada.'));
    return;
  }
  _retos = generarRetos.execute();                   // ← Genera retos inmediatamente
  _indiceRetoActual = 0;
  if (_retos.isEmpty) {
    emit(LivenessExitoCaptura());                    // ← Si no hay retos → captura directa
    return;
  }
  _presentarRetoActual(emit);                        // ← Emite LivenessRetoPresentado + Timer(5s)
}
```

**El BLoC no tiene relación con la cámara.** No recibe ni crea `CameraController`. Su única interacción con la cámara es a través de los frames que la UI envía via `ProcesarFrameCamara`.

### Timer de liveness (líneas 97-101)

```dart
_temporizadorReto = Timer(
  const Duration(seconds: _duracionRetoSegundos),   // ← 5s
  () => add(RetoTiempoExpirado()),
);
```

## 3. No hay CameraController compartido

```
grep "CameraController" lib/ --include="*.dart" -l
→ Solo aparece en páginas, nunca en GetIt/injection
```

- ❌ No hay `GetIt.registerSingleton<CameraController>()`
- ❌ No hay `sl<CameraController>()` en ningún BLoC
- ❌ No hay `FacialVerificationBloc` que reciba un CameraController

## 4. Causa más probable

El ANR ocurre durante `_initializeCamera()` línea 147:
```dart
await _cameraController!.initialize();
```

En OPPO/MediaTek:
1. El driver de cámara aún está "caliente" después del enrolment anterior (si vino de `MemberFacialEnrollmentPage`)
2. `ResolutionPreset.high` solicita ~1920x1080 → ~8MB por frame + buffers GPU
3. ML Kit `FaceDetectionPort` se instancia en el builder (line 401) vía `sl<FaceDetectionPort>()`
4. **ML Kit + Cámara de alta resolución simultáneamente** pueden exceder la memoria disponible
5. El sistema mata el proceso → "Lost connection to device"

### Solución recomendada

Reducir `ResolutionPreset.high` a `ResolutionPreset.medium` en la línea 143:

```dart
_cameraController = CameraController(
  camera,
  ResolutionPreset.medium,     // ← medium en vez de high
  enableAudio: false,
);
```

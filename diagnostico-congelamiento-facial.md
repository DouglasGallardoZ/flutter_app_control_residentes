# Diagnóstico: Congelamiento tras enrolamiento facial exitoso

**Fecha:** 2026-07-08
**Proyecto:** Guardin

---

## Archivo 1: `member_facial_enrollment_page.dart` (716 líneas)

### Estructura del StatefulWidget

```
_MemberFacialEnrollmentViewState
├── Fields: CameraController?, _isCameraInitialized, _cameraDisposeInProgress
│
├── initState() → _initializeCamera()
│
├── _initializeCamera() → availableCameras() → _cameraController.initialize()
│   → setState → add(EnrollmentStarted(personaId))
│
├── _onFaceCaptured(bytes, angle) → add(FaceCaptured(bytes, angle))
│
├── dispose() → _disposeCamera()
│
├── _mostrarDialogoExito(FacialEnrollmentSuccess state)
│   ├── _disposeCamera()      ← ❌ NO SE AWAIT
│   └── showDialog(
│         PopScope(canPop: false),
│         botón "Continuar":
│           Navigator.of(ctx).pop()
│           Navigator.of(context).pushReplacement(   ← ❌ RACE CONDITION
│             MaterialPageRoute(
│               builder: (_) => FacialVerificationPage(prospecto: prospectoMiembro)
│             )
│           )
│       )
│
├── _mostrarDialogoError(FacialEnrollmentError state) → diálogo
│
└── build()
    └── BlocConsumer<FacialEnrollmentBloc, FacialEnrollmentState>
          listener:
            FacialEnrollmentSuccess → _mostrarDialogoExito(state)
            FacialEnrollmentError   → _mostrarDialogoError(state)
          builder:
            FacialEnrollmentSubmitting → spinner
            FacialEnrollmentSuccess    → SizedBox.shrink()
            FacialEnrollmentInProgress → FacialCaptureView + panel
            FacialEnrollmentError      → FacialCaptureView + panel + botón reintentar
```

### Causa raíz del congelamiento

**Problema 1: `_disposeCamera()` no es await en `_mostrarDialogoExito`**
Línea 157: `_disposeCamera();` — se inicia pero no se espera.
Línea 83-95: `_disposeCamera()` usa `await _cameraController!.dispose()`.
Esto crea una **carrera**:
1. `_disposeCamera()` comienza y cede el control en `await`
2. `showDialog()` se ejecuta inmediatamente
3. El builder del diálogo retorna
4. Cuando el usuario hace clic en "Continuar":
   - `Navigator.of(ctx).pop()` cierra el diálogo
   - `Navigator.of(context).pushReplacement(...)` intenta navegar
   - Pero el camera controller **aún no ha terminado de dispose()**
   - Flutter intenta liberar los recursos de la cámara durante el cambio de página
   - **ANR + "Lost connection to device"**

**Problema 2: `pushReplacement` dentro del callback del diálogo**
Después de `Navigator.of(ctx).pop()`, el contexto `ctx` (del diálogo) ya no es válido.
`Navigator.of(context)` usa el contexto del widget raíz, pero como el diálogo se está cerrando
y la página se está reemplazando simultáneamente, hay una **condición de carrera**.

---

## Archivo 2: `facial_enrollment_bloc.dart` (204 líneas)

| Evento | Handler | Descripción |
|--------|---------|-------------|
| `EnrollmentStarted` | `_onEnrollmentStarted` | Inicializa estado `InProgress` |
| `FaceCaptured` | `_onFaceCaptured` | Agrega foto, si completo → `EnrollmentSubmitted` |
| `EnrollmentSubmitted` | `_onSubmit` → `_enviarAlServidor` | Envía fotos al servidor |
| `EnrollmentResubmit` | `_onResubmit` → `_enviarAlServidor` | Reintentar envío |
| `EnrollmentRetried` | `_onRetry` | Reinicia captura desde 0 |

**Estados emitidos:**
```
Inicial → InProgress → PhotoCaptured (x3) → Submitting → Success
                                                    ↓
                                               Error → resubmit o retry
```

**`FacialEnrollmentSuccess`** (líneas 107-118):
```dart
class FacialEnrollmentSuccess extends FacialEnrollmentState {
  final String mensaje;
  final String? enrollmentId;
  const FacialEnrollmentSuccess({required this.mensaje, this.enrollmentId});
}
```
No tiene Timer, no tiene StreamSubscription, no necesita `close()` sobreescrito.

---

## Corrección necesaria

**Archivo:** `lib/presentation/pages/member_facial_enrollment_page.dart`

### Cambio 1: Hacer `_mostrarDialogoExito` async y await `_disposeCamera`

```dart
Future<void> _mostrarDialogoExito(FacialEnrollmentSuccess state) async {
  await _disposeCamera();  // ← AGREGAR await
  if (!mounted) return;     // ← AGREGAR guard

  await showDialog(...);     // ← AGREGAR await al showDialog

  // Navegar DESPUÉS de que el diálogo se cierre completamente
  final prospectoMiembro = widget.prospectoCompleto ?? ProspectoMiembro(...);
  if (mounted) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => FacialVerificationPage(prospecto: prospectoMiembro),
      ),
    );
  }
}
```

### Cambio 2: Mover la navegación fuera del builder del diálogo

```dart
Future<void> _mostrarDialogoExito(FacialEnrollmentSuccess state) async {
  await _disposeCamera();
  if (!mounted) return;

  // Mostrar diálogo y esperar que el usuario presione Continuar
  final continuar = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => PopScope(
      canPop: false,
      child: AlertDialog(
        title: const Text('¡Validación Facial Exitosa!'),
        content: Text(state.mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),  // ← pop con true
            child: const Text('Continuar'),
          ),
        ],
      ),
    ),
  );

  if (continuar == true && mounted) {
    final prospectoMiembro = widget.prospectoCompleto ?? ProspectoMiembro(...);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => FacialVerificationPage(prospecto: prospectoMiembro),
      ),
    );
  }
}
```

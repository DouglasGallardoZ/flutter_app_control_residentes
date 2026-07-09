# Diagnóstico: Estado actual del código post-fix

**Fecha:** 2026-07-08

---

## 1. `_disposeCamera()` en `member_facial_enrollment_page.dart`

### Definición (líneas 83-96)

```dart
Future<void> _disposeCamera() async {
  if (_cameraDisposeInProgress) return;      // ← guard: evita doble dispose
  _cameraDisposeInProgress = true;
  try {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      await _cameraController!.dispose();     // ← async, espera a que termine
    }
  } catch (e) {
    debugPrint('Error cerrando cámara: $e');
  } finally {
    _cameraController = null;                 // ← libera referencia
    _isCameraInitialized = false;
  }
}
```

### TODAS las llamadas a `_disposeCamera()` en el archivo

| Línea | Código | ¿Con await? | Contexto |
|-------|--------|-------------|----------|
| **152** | `_disposeCamera();` | ❌ **Sin await** | Dentro de `dispose()` (Flutter - no se puede await) |
| **158** | `await _disposeCamera();` | ✅ **Con await** | Dentro de `_mostrarDialogoExito()` |

### `_cameraDisposeInProgress` (línea 75)

```dart
bool _cameraDisposeInProgress = false;
```

Sirve como **guard** para evitar que `dispose()` (sin await) ejecute la lógica de dispose si `_mostrarDialogoExito` ya lo hizo con await. Cuando `_mostrarDialogoExito` ejecuta `await _disposeCamera()`, setea el flag a `true`. Si luego `dispose()` es llamado por Flutter, `_disposeCamera()` retorna inmediatamente sin volver a indisponer.

### `dispose()` del State (líneas 150-154)

```dart
@override
void dispose() {
  _disposeCamera();      // ← fire-and-forget (no se puede await en dispose)
  super.dispose();
}
```

## 2. `_mostrarDialogoExito()` ACTUAL (líneas 156-201)

```dart
Future<void> _mostrarDialogoExito(
    FacialEnrollmentSuccess state) async {
  await _disposeCamera();                   // ✅ await correcto
  if (!mounted) return;                      // ✅ guard post-await

  final continuar = await showDialog<bool>(  // ✅ await showDialog
    context: context,
    barrierDismissible: false,
    builder: (ctx) => PopScope(
      canPop: false,
      child: AlertDialog(
        title: const Text('¡Validación Facial Exitosa!'),
        content: Text(state.mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Continuar'),
          ),
        ],
      ),
    ),
  );

  if (continuar == true && mounted) {        // ✅ navegación DESPUÉS del diálogo
    final prospectoMiembro = widget.prospectoCompleto ?? ProspectoMiembro(
      existe: true,
      personaId: widget.personaId,
      nombres: widget.nombres,
      apellidos: widget.apellidos,
    );
    Navigator.of(context).pushReplacement(   // ✅ pop + pushReplacement NO están en misma callback
      MaterialPageRoute(
        builder: (_) => FacialVerificationPage(prospecto: prospectoMiembro),
      ),
    );
  }
}
```

## 3. `_mostrarDialogoError()` ACTUAL (líneas 204-244)

```dart
Future<void> _mostrarDialogoError(FacialEnrollmentError state) async {
  final accion = await showDialog<String>(   // ✅ await showDialog
    context: context,
    barrierDismissible: false,
    builder: (ctx) => PopScope(
      canPop: false,
      child: AlertDialog(
        ...
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('cancelar'),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop('reintentar'),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    ),
  );

  if (!mounted) return;

  if (accion == 'cancelar') {
    Navigator.of(context).pop();             // ✅ navegación DESPUÉS del diálogo
  } else if (accion == 'reintentar') {
    context.read<FacialEnrollmentBloc>().add(const EnrollmentResubmit());
  }
}
```

## 4. El fix está aplicado correctamente

✅ `_disposeCamera()` con await en `_mostrarDialogoExito`  
✅ `await showDialog<bool>` — no más navegación en callback del botón  
✅ Navegación (`pushReplacement`) DESPUÉS del `await showDialog`  
✅ `_cameraDisposeInProgress` protege contra doble dispose  
✅ `_mostrarDialogoError` también usa `await showDialog<String>`  

## 5. Si el ANR persiste, probables causas no relacionadas con este fix

| Causa | Explicación |
|-------|-------------|
| **Camera controller dispose tarda demasiado** | `await _cameraController!.dispose()` en algunos dispositivos puede tomar >5 segundos. Si el BLoC timeout no lo maneja, la app se congela. |
| **`ResolutionPreset.high`** (línea 120) | Alta resolución en la captura facial puede consumir mucha memoria. Después de capturar 3 fotos + enviar al servidor, el GC puede causar pausas largas. |
| **`_enviarAlServidor` con muchas imágenes** | El BLoC envía 3 fotos en formato `Uint8List` sin compresión. Si las imágenes son grandes (>5MB cada una), el upload puede saturar. |
| **Main thread bloqueado por el builder** | Cuando `FacialEnrollmentSuccess` es emitido, el builder retorna `SizedBox.shrink()`. Pero si hay widgets complejos en el árbol, la reconstrucción puede tomar tiempo. |

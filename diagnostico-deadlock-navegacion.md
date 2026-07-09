# Diagnóstico: Deadlock de navegación tras enrolamiento facial

**Fecha:** 2026-07-08

---

## 1. TODAS las llamadas a Navigator en `member_facial_enrollment_page.dart`

| Línea | Código | Contexto | ¿Bug? |
|-------|--------|----------|-------|
| **169** | `Navigator.of(ctx).pop()` | Dentro de `_mostrarDialogoExito()`, en onPressed de "Continuar". Cierra el diálogo. | ⚠️ |
| **181** | `Navigator.of(context).pushReplacement(MaterialPageRoute(...))` | **INMEDIATAMENTE DESPUÉS de pop()** en la misma callback. Navega a FacialVerificationPage. | **🔴 DEADLOCK** |
| 210 | `Navigator.of(ctx).pop()` | Dentro de `_mostrarDialogoError`, onPressed "Cancelar". Cierra el diálogo. | ✅ |
| 211 | `Navigator.of(context).pop()` | **INMEDIATAMENTE DESPUÉS** — cierra la página. | ⚠️ |
| 217 | `Navigator.of(ctx).pop()` | Dentro de `_mostrarDialogoError`, onPressed "Reintentar". Solo cierra diálogo. | ✅ |
| 295 | `Navigator.of(context).pop()` | En `onCerrar` del side panel. Cierra la página normalmente. | ✅ |
| 321 | `Navigator.of(context).pop()` | Botón "Atrás" en AppBar (desktop). | ✅ |
| 348 | `Navigator.of(context).pop()` | Botón "Atrás" en AppBar (mobile). | ✅ |
| 374 | `Navigator.of(context).pop()` | Botón flotante de cerrar (mobile). | ✅ |

## 2. La llamada problemática (líneas 169 + 181)

```dart
void _mostrarDialogoExito(FacialEnrollmentSuccess state) {
    _disposeCamera();                                              // ← async, sin await
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          ...
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();                           // ← 1. Cierra diálogo
                final prospectoMiembro = ...;
                Navigator.of(context).pushReplacement(             // ← 2. Navega INMEDIATAMENTE
                  MaterialPageRoute(
                    builder: (_) => FacialVerificationPage(...),
                  ),
                );
              },
              child: const Text('Continuar'),
            ),
          ],
        ),
      ),
    );
  }
```

**Causa del deadlock:**

1. `_disposeCamera()` se llama sin await — comienza dispose asíncrono pero no espera
2. `showDialog()` se ejecuta inmediatamente
3. Usuario presiona "Continuar"
4. `Navigator.of(ctx).pop()` — solicita cerrar el diálogo (se encola en la cola de microtareas)
5. `Navigator.of(context).pushReplacement(...)` — solicita reemplazar la página INMEDIATAMENTE
6. Flutter intenta procesar AMBAS operaciones de navegación en el mismo frame
7. El diálogo no ha terminado de cerrarse cuando se inicia el reemplazo de página
8. El widget de la página se elimina mientras el diálogo aún está activo
9. **ANR + "Lost connection to device"**

## 3. Análisis BlocListener

```dart
BlocConsumer<FacialEnrollmentBloc, FacialEnrollmentState>(
  listener: (context, state) {
    if (state is FacialEnrollmentSuccess) {
      _mostrarDialogoExito(state);       // ← Se dispara 1 vez (estado no se repite)
    } else if (state is FacialEnrollmentError) {
      _mostrarDialogoError(state);
    }
  },
```

- No tiene `listenWhen` — se dispara en cada cambio de estado
- `FacialEnrollmentSuccess` se emite solo una vez → no hay doble disparo
- El listener no dispara navegación directamente. Llama a `_mostrarDialogoExito` que MUESTRA un diálogo y espera input del usuario. Esto es correcto.

## 4. `NavigationService` (no usado aquí)

```dart
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static Future<dynamic>? navigateTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState?.pushNamed(routeName, arguments: arguments);
  }
  static void goBack() {
    navigatorKey.currentState?.pop();
  }
}
```

**No interfiere con el bug.** Se usa solo en `FcmProvider` y `app.dart` para el navigatorKey. `member_facial_enrollment_page.dart` no usa `NavigationService`.

## 5. Corrección

**Archivo:** `lib/presentation/pages/member_facial_enrollment_page.dart`
**Método:** `_mostrarDialogoExito`

```dart
// ANTES (bug): pop y pushReplacement en la misma callback
onPressed: () {
  Navigator.of(ctx).pop();
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (_) => FacialVerificationPage(...)),
  );
},

// DESPUÉS (corregido): navegar después de que el diálogo se cierre
onPressed: () => Navigator.of(ctx).pop(true),  // ← pop con resultado
```

Y mover `pushReplacement` fuera del builder, después de `await showDialog`:

```dart
Future<void> _mostrarDialogoExito(FacialEnrollmentSuccess state) async {
  await _disposeCamera();
  if (!mounted) return;

  final continuar = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => PopScope(
      canPop: false,
      child: AlertDialog(
        ...
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Continuar'),
          ),
        ],
      ),
    ),
  );

  if (continuar == true && mounted) {
    final prospectoMiembro = widget.prospectoCompleto ?? ProspectoMiembro(
      existe: true,
      personaId: widget.personaId,
      nombres: widget.nombres,
      apellidos: widget.apellidos,
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => FacialVerificationPage(prospecto: prospectoMiembro),
      ),
    );
  }
}
```

**Regla:** Nunca llamar a `Navigator.pushReplacement` inmediatamente después de `Navigator.pop()`. Siempre usar `await showDialog` y navegar en el código que sigue.

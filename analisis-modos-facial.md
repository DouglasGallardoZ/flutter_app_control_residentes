# Análisis: Modos unlockApp vs createCredentials

**Fecha:** 2026-07-08

---

## 1. Lugares donde se usa FacialVerificationPage

| Origen | Línea | `mode` | Tipo prospecto | Navegación |
|--------|-------|--------|---------------|------------|
| `login_page.dart` | 130-133 | **`unlockApp`** | `ProspectoResidente` | `Navigator.push<bool>()` |
| `family_dashboard_page.dart` | 62-65 | **`unlockApp`** | `ProspectoResidente` | `Navigator.push<bool>()` |
| `resident_dashboard_page.dart` | 64-67 | **`unlockApp`** | `ProspectoResidente` | `Navigator.push<bool>()` |
| Routes `/facialVerification` | 116-121 | **`createCredentials` (default)** | `settings.arguments` | `Navigator.pushNamed` |
| `VerificationSplashPage` | inline | **`createCredentials` (default)** | `ProspectoMiembro` | `pushReplacement` |
| `member_facial_enrollment_page.dart` (histórico) | inline | **`createCredentials` (default)** | `ProspectoMiembro` | `pushReplacement` |

## 2. Diferencia en el listener

### `unlockApp` (login/dashboard) — pop(bool)

```dart
// FacialVerificationSuccess match=false → (línea 308-332)
if (widget.mode == VerificationMode.unlockApp) {
    _disposeCamera();
    WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop(false);  // ← solo pop
    });
}

// FacialVerificationSuccess match=true → (línea 325-341)
if (widget.mode == VerificationMode.unlockApp) {
    SecuritySession.unlock();
    _disposeCamera();
    WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop(true);  // ← solo pop
    });
}

// FacialVerificationFailure → (línea 347-370)
if (widget.mode == VerificationMode.unlockApp) {
    _disposeCamera();
    WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop(false);
    });
}
```

### `createCredentials` (prospecto) — diálogo + pushNamed

```dart
// FacialVerificationSuccess match=false → (línea 308-331)
if (widget.mode == createCredentials) {
    _mostrarResultado(exitosa: false, ...);  // ← diálogo con reintentar
}

// FacialVerificationSuccess match=true → (línea 343-353)
_disposeCamera();
context.read<RegistroResidenteBloc>().add(VerificacionFacialCompleta(...));
_mostrarResultado(exitosa: true, ...);       // ← diálogo → /credentialsMiembro

// FacialVerificationFailure → (línea 370-381)
SnackBar + IniciarVerificacionLiveness();    // ← reinicia liveness
```

## 3. La cámara se inicializa IGUAL en ambos modos

`facial_verification_page.dart:120-152`:

```dart
Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(
        camera, ResolutionPreset.high, enableAudio: false,
    );
    await _cameraController!.initialize();
    ...
}
```

**No hay diferencia de resolución, configuración ni timing entre ambos modos.** El `CameraController` se crea idénticamente.

## 4. El BLoC se crea IGUAL en ambos modos

```dart
// lines 35-38 — build() de FacialVerificationPage
return BlocProvider<FacialVerificationBloc>(
    create: (_) => sl<FacialVerificationBloc>()
        ..add(IniciarVerificacionLiveness()),  // ← mismo evento siempre
    child: _FacialVerificationView(...),
);
```

El BLoC no recibe el `mode`. Solo la `_FacialVerificationView` lo recibe.

## 5. Stack de rutas — la diferencia clave

| Escenario | Stack | Profundidad |
|-----------|-------|-------------|
| **Login → unlockApp** | LoginPage → FacialVerificationPage | **2 rutas** ✅ |
| **Dashboard → unlockApp** | Dashboard → FacialVerificationPage | **2 rutas** ✅ |
| **Prospecto → createCredentials** (directo) | LoginPage → RegisterOptionPage → ProspectoMiembroPage → FacialVerificationPage | **4 rutas** ❌ |
| **Prospecto → createCredentials** (con splash) | LoginPage → RegisterOptionPage → VerificationSplashPage → FacialVerificationPage | **3 rutas** ⚠️ |

## 6. Configuración de Android/Impeller

### `build.gradle.kts`

```kotlin
compileSdk = flutter.compileSdkVersion  // ~35
minSdk = flutter.minSdkVersion          // ~23
// No hay enableImpeller ni configuración de renderizador
```

### `AndroidManifest.xml`

```xml
<activity android:launchMode="singleTop" android:theme="@style/LaunchTheme" ... />
```

**No hay configuración de Impeller, Vulkan ni OpenGL.** El dispositivo OPPO CPH2639 usa Mali GPU que puede tener problemas con el renderizador por defecto (Impeller Vulkan en Android 14+).

## 7. Conclusión

El problema NO es el `mode`. El problema es que **la GPU Mali no puede manejar la transición de rutas acumuladas + apertura de cámara**:

| Factor | `unlockApp` | `createCredentials` |
|--------|-------------|---------------------|
| Stack de rutas | 2 páginas | 3-4 páginas |
| Rutas previas en memoria | LoginPage | RegisterOptionPage + ProspectoMiembroPage + splash |
| GPU pressure | Baja (solo Dashboard/Login) | Alta (widgets complejos acumulados) |
| Funciona | ✅ Sí | ❌ ANR |

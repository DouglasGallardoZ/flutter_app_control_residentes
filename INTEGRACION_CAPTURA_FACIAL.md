# Guía de Integración: Captura Facial en Arquitectura Hexagonal

## 📋 Resumen de Implementación

Se ha implementado el flujo completo de captura facial seguiendo arquitectura hexagonal y patrón BLoC:

```
AdminCreateResidentPage (Formulario)
    ↓
    Registra residente exitosamente
    ↓
    Navega a AdminFacialEnrollmentPage
    ↓
    Captura 3 fotos automáticas (frente, izquierda, derecha)
    ↓
    Envía a servidor biometría (puerto 8000)
    ↓
    Vuelve a AdminResidentsPage
```

---

## 📁 Archivos Creados

### 1. **BLoC para Captura Facial**
- `lib/application/blocs/facial_enrollment/facial_enrollment_event.dart` - Eventos
- `lib/application/blocs/facial_enrollment/facial_enrollment_state.dart` - Estados
- `lib/application/blocs/facial_enrollment/facial_enrollment_bloc.dart` - Lógica

### 2. **UI**
- `lib/presentation/pages/admin_facial_enrollment_page.dart` - Página principal
- `lib/presentation/widgets/camera_facial_view.dart` - Widget de cámara con ML Kit

### 3. **API**
- Método `enrollFacialData()` agregado en `AdminApi`
- Autorredirige a puerto 8000 dinámicamente

---

## 🔗 Integración en AdminCreateResidentPage

Después de registrar exitosamente el residente, navega a la captura facial:

```dart
// En _registerResident(), reemplaza:
Navigator.of(context).pop();

// Con:
if (mounted && response['residente_id'] != null) {
  Navigator.of(context).pushNamed(
    '/adminFacialEnrollment',
    arguments: {
      'personaId': response['residente_id'],
      'nombres': _nombresController.text,
      'apellidos': _apellidosController.text,
    },
  );
}
```

---

## 📍 Ruta para app_routes.dart

Agregar en el switch de rutas:

```dart
case '/adminFacialEnrollment':
  final args = settings.arguments as Map<String, dynamic>;
  return MaterialPageRoute(
    builder: (_) => AdminFacialEnrollmentPage(
      personaId: args['personaId'] as int,
      nombres: args['nombres'] as String,
      apellidos: args['apellidos'] as String,
    ),
  );
```

---

## 🔧 Configuración del BLoC en DI

En tu `injection.dart` o servicio de localización:

```dart
// Registrar el BLoC
GetIt.I.registerSingleton<FacialEnrollmentBloc>(
  FacialEnrollmentBloc(adminApi: GetIt.I<AdminApi>()),
);
```

---

## 📦 Dependencias Requeridas (pubspec.yaml)

```yaml
dependencies:
  flutter_bloc: ^8.1.4
  camera: ^0.11.3
  google_mlkit_face_detection: ^0.13.1
  path_provider: ^2.1.2
  equatable: ^2.0.5
  get_it: ^7.6.4
  dio: ^5.4.0
```

**Ejecutar:**
```bash
flutter pub get
```

---

## ⚙️ Permisos Necesarios

### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.INTERNET" />
```

### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSCameraUsageDescription</key>
<string>Necesitamos acceso a la cámara para registro biométrico</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Necesitamos acceso para guardar fotos de biometría</string>
```

---

## 🎯 Flujo de Estados BLoC

```
FacialEnrollmentInitial
    ↓
InitiateFacialEnrollment (evento)
    ↓
FacialEnrollmentInProgress (esperando frente)
    ↓
FaceDetected → captura 1ª foto
    ↓
FacialPhotoCaptured
    ↓
FacialEnrollmentInProgress (esperando izquierda)
    ↓
FaceDetected → captura 2ª foto
    ↓
FacialPhotoCaptured
    ↓
FacialEnrollmentInProgress (esperando derecha)
    ↓
FaceDetected → captura 3ª foto
    ↓
FacialPhotoCaptured
    ↓
SubmitFacialEnrollment (evento)
    ↓
FacialEnrollmentSubmitting
    ↓
FacialEnrollmentSuccess o FacialEnrollmentError
```

---

## 📐 Ángulos de Detección

- **FRENTE**: -15° ≤ ángulo ≤ 15°
- **IZQUIERDA**: ángulo < -15°
- **DERECHA**: ángulo > 15°

---

## 🐛 Testing Local

### Con Emulador/Dispositivo
1. Navega a registrar residente
2. Completa formulario
3. Sistema navega a captura facial
4. Sigue instrucciones en pantalla
5. Captura automática de 3 fotos
6. Envío a `http://localhost:8000/enroll`

### Logs de Debug
```dart
// En BLoC:
debugPrint('📸 Foto capturada: ${_imagenesCapturadas.length}/3');
debugPrint('📐 Ángulo detectado: $angulo°');
debugPrint('📤 Enviando al servidor...');
```

---

## ✅ Checklist de Implementación

- [ ] Agregar dependencias en pubspec.yaml
- [ ] Crear archivos de BLoC (eventos, estados, bloc)
- [ ] Crear página AdminFacialEnrollmentPage
- [ ] Crear widget CameraFacialView
- [ ] Agregar método enrollFacialData en AdminApi
- [ ] Registrar BLoC en DI (GetIt)
- [ ] Agregar ruta en app_routes.dart
- [ ] Actualizar AdminCreateResidentPage para navegar
- [ ] Agregar permisos en Android/iOS
- [ ] Probar captura en dispositivo real o emulador

---

## 🚀 Flujo Completo Usuario

1. Admin abre AdminResidentsPage
2. Click en botón "Registrar"
3. Se abre AdminCreateResidentPage (formulario)
4. Completa datos del residente
5. Click "Registrar Residente"
6. API retorna residente_id exitosamente
7. Navega a AdminFacialEnrollmentPage
8. Se abre cámara frontal
9. Sistema guía automáticamente:
   - "MIRE AL FRENTE" → captura 1ª
   - "GIRE A LA IZQUIERDA" → captura 2ª
   - "GIRE A LA DERECHA" → captura 3ª
10. Envía 3 fotos a `localhost:8000/enroll`
11. Muestra "¡Registro Facial Exitoso!"
12. Vuelve a AdminResidentsPage

---

## 📝 Notas Importantes

- ✅ **Sin parámetros extra**: Solo `user_id` e `images` en FormData
- ✅ **Puert 8000**: Detectado dinámicamente desde base URL
- ✅ **Arquitectura**: Hexagonal + BLoC
- ✅ **Autodetección**: Captura automática sin botones
- ✅ **Throttling**: 800ms entre capturas
- ✅ **3 fotos**: Exactamente frente + izquierda + derecha

---

## 🔄 Reutilización para Miembros de Familia

El mismo BLoC y página se pueden usar para registrar miembros:

```dart
// Crear método similar en AdminApi
Future<Map<String, dynamic>> enrollFamilyMemberFacial({
  required String personaId,
  required List<String> imagenesRutas,
}) async {
  // Similar a enrollFacialData pero para endpoint diferente
}

// Reutilizar AdminFacialEnrollmentPage con navegación diferente
```

---

## 💡 Consideraciones de Escalabilidad

1. **Backend**: Servicio de biometría procesa en background
2. **Reintentos**: Botón de reintentar si falla captura
3. **Fallback**: Si no hay cámara, mostrar error
4. **Logging**: Todos los pasos se registran para debugging


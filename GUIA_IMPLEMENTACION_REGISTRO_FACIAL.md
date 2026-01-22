# Guía de Implementación: Registro Facial con Múltiples Capturas

## 📋 Resumen del Flujo

```
Usuario completa formulario → Página de Captura Facial → 
Captura 3 fotos (frente, izquierda, derecha) → 
Envía fotos + ID al API → Respuesta exitosa
```

---

## 🏗️ Arquitectura Utilizada

**Clean Architecture + BLoC Pattern**

```
Presentation (BLoC + Pages + Widgets)
    ↓
Domain (Entities + Repository Interfaces)
    ↓
Data (Repository Implementation + DataSources + Models)
```

---

## 📦 Dependencias Necesarias

```yaml
dependencies:
  flutter_bloc: ^8.1.4
  equatable: ^2.0.5
  camera: ^0.11.3
  google_mlkit_face_detection: ^0.13.1
  path_provider: ^2.1.2
  dio: ^5.4.0
  dartz: ^0.10.1
  get_it: ^7.6.4
```

---

## 🎯 Componentes Principales

### 1. **Entidad de Dominio** (`DatosRegistro`)

```dart
// lib/domain/entities/biometric_entities.dart

class DatosRegistro extends Equatable {
  final String idUsuario;
  final List<String> rutasImagenes; // Rutas de las 3 fotos
  final DateTime fechaCreacion;

  const DatosRegistro({
    required this.idUsuario,
    required this.rutasImagenes,
    required this.fechaCreacion,
  });

  @override
  List<Object?> get props => [idUsuario, rutasImagenes, fechaCreacion];
}

class ResultadoBiometrico extends Equatable {
  final bool exitoso;
  final String mensaje;
  final String? idRegistro;

  const ResultadoBiometrico({
    required this.exitoso,
    required this.mensaje,
    this.idRegistro,
  });

  @override
  List<Object?> get props => [exitoso, mensaje, idRegistro];
}
```

---

### 2. **Repositorio (Interfaz)**

```dart
// lib/domain/repositories/biometric_repository.dart

abstract class IRepositorioBiometrico {
  Future<Either<Failure, ResultadoBiometrico>> registrarUsuario(
    DatosRegistro datos,
  );
}
```

---

### 3. **Implementación del Repositorio**

```dart
// lib/data/repositories/biometric_repository_impl.dart

class ImplementacionRepositorioBiometrico implements IRepositorioBiometrico {
  final FuenteDatosRemotaBiometrica fuenteDatosRemota;

  ImplementacionRepositorioBiometrico({required this.fuenteDatosRemota});

  @override
  Future<Either<Failure, ResultadoBiometrico>> registrarUsuario(
    DatosRegistro datos,
  ) async {
    try {
      final modelo = await fuenteDatosRemota.registrarUsuario(datos);
      return Right(modelo.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
```

---

### 4. **DataSource (Llamada al API)**

```dart
// lib/data/datasources/biometric_remote_datasource.dart

class ImplementacionFuenteDatosRemotaBiometrica 
    implements FuenteDatosRemotaBiometrica {
  final Dio dio;

  ImplementacionFuenteDatosRemotaBiometrica({required this.dio});

  @override
  Future<ModeloResultadoBiometrico> registrarUsuario(
    DatosRegistro datos,
  ) async {
    // Crear FormData con múltiples imágenes
    final formData = FormData();
    
    // Agregar ID de usuario
    formData.fields.add(MapEntry('user_id', datos.idUsuario));
    
    // Agregar cada imagen
    for (int i = 0; i < datos.rutasImagenes.length; i++) {
      final archivo = await MultipartFile.fromFile(
        datos.rutasImagenes[i],
        filename: 'face_$i.jpg',
      );
      formData.files.add(MapEntry('images', archivo));
    }

    // Enviar al API
    final respuesta = await dio.post(
      '/enroll',  // Tu endpoint
      data: formData,
    );

    return ModeloResultadoBiometrico.fromJson(respuesta.data);
  }
}
```

---

### 5. **BLoC - Eventos**

```dart
// lib/presentation/blocs/enrollment/enrollment_event.dart

abstract class EventoRegistro extends Equatable {
  const EventoRegistro();
  @override
  List<Object?> get props => [];
}

class EventoIniciarRegistro extends EventoRegistro {
  final String idUsuario;
  const EventoIniciarRegistro({required this.idUsuario});
  @override
  List<Object?> get props => [idUsuario];
}

class EventoRostroDetectado extends EventoRegistro {
  final double anguloEulerY;  // Para detectar dirección
  final String rutaImagen;
  
  const EventoRostroDetectado({
    required this.anguloEulerY,
    required this.rutaImagen,
  });
  
  @override
  List<Object?> get props => [anguloEulerY, rutaImagen];
}

class EventoEnviarRegistro extends EventoRegistro {
  final List<String> rutasImagenes;
  const EventoEnviarRegistro({required this.rutasImagenes});
  @override
  List<Object?> get props => [rutasImagenes];
}
```

---

### 6. **BLoC - Estados**

```dart
// lib/presentation/blocs/enrollment/enrollment_state.dart

abstract class EstadoRegistro extends Equatable {
  const EstadoRegistro();
  @override
  List<Object?> get props => [];
}

class RegistroInicial extends EstadoRegistro {
  const RegistroInicial();
}

class RegistroEnProgreso extends EstadoRegistro {
  final int fotosCapturadas;
  final String instruccion;
  final String faseActual; // 'MirandoAlFrente', 'MirandoIzquierda', 'MirandoDerecha'
  
  const RegistroEnProgreso({
    required this.fotosCapturadas,
    required this.instruccion,
    required this.faseActual,
  });
  
  @override
  List<Object?> get props => [fotosCapturadas, instruccion, faseActual];
}

class FotoCapturada extends EstadoRegistro {
  final int numeroFoto;
  final String rutaImagen;
  
  const FotoCapturada({
    required this.numeroFoto,
    required this.rutaImagen,
  });
  
  @override
  List<Object?> get props => [numeroFoto, rutaImagen];
}

class RegistroSubiendo extends EstadoRegistro {
  const RegistroSubiendo();
}

class RegistroExitoso extends EstadoRegistro {
  final String idRegistro;
  final String mensaje;
  
  const RegistroExitoso({
    required this.idRegistro,
    required this.mensaje,
  });
  
  @override
  List<Object?> get props => [idRegistro, mensaje];
}

class RegistroFallido extends EstadoRegistro {
  final String mensaje;
  const RegistroFallido({required this.mensaje});
  @override
  List<Object?> get props => [mensaje];
}
```

---

### 7. **BLoC - Lógica Principal**

```dart
// lib/presentation/blocs/enrollment/enrollment_bloc.dart

class BlocRegistro extends Bloc<EventoRegistro, EstadoRegistro> {
  final IRepositorioBiometrico repositorio;
  
  List<String> _imagenesCapturadas = [];
  String _idUsuario = '';
  bool _estaCapturando = false;

  BlocRegistro({required this.repositorio}) 
      : super(const RegistroInicial()) {
    on<EventoIniciarRegistro>(_alIniciarRegistro);
    on<EventoRostroDetectado>(_alDetectarRostro);
    on<EventoEnviarRegistro>(_alEnviarRegistro);
  }

  Future<void> _alIniciarRegistro(
    EventoIniciarRegistro evento,
    Emitter<EstadoRegistro> emit,
  ) async {
    _idUsuario = evento.idUsuario;
    _imagenesCapturadas.clear();
    
    emit(const RegistroEnProgreso(
      fotosCapturadas: 0,
      instruccion: 'MIRE AL FRENTE',
      faseActual: 'MirandoAlFrente',
    ));
  }

  Future<void> _alDetectarRostro(
    EventoRostroDetectado evento,
    Emitter<EstadoRegistro> emit,
  ) async {
    if (_estaCapturando) return;
    _estaCapturando = true;

    try {
      final angulo = evento.anguloEulerY;
      String? fase;
      String? instruccion;

      // Determinar qué foto capturar según el ángulo
      if (_imagenesCapturadas.isEmpty && angulo.abs() < 15) {
        // Foto 1: Mirando al frente
        fase = 'MirandoIzquierda';
        instruccion = 'GIRE A LA IZQUIERDA';
      } else if (_imagenesCapturadas.length == 1 && angulo < -15) {
        // Foto 2: Mirando a la izquierda
        fase = 'MirandoDerecha';
        instruccion = 'GIRE A LA DERECHA';
      } else if (_imagenesCapturadas.length == 2 && angulo > 15) {
        // Foto 3: Mirando a la derecha - completado
        fase = null;
        instruccion = null;
      }

      if (fase == null) {
        // Ya no necesitamos más fotos
        _estaCapturando = false;
        return;
      }

      // Guardar la imagen capturada
      _imagenesCapturadas.add(evento.rutaImagen);

      emit(FotoCapturada(
        numeroFoto: _imagenesCapturadas.length,
        rutaImagen: evento.rutaImagen,
      ));

      await Future.delayed(const Duration(milliseconds: 500));

      if (_imagenesCapturadas.length == 3) {
        // Todas las fotos capturadas, enviar al servidor
        add(EventoEnviarRegistro(rutasImagenes: _imagenesCapturadas));
      } else {
        emit(RegistroEnProgreso(
          fotosCapturadas: _imagenesCapturadas.length,
          instruccion: instruccion!,
          faseActual: fase,
        ));
      }
    } finally {
      _estaCapturando = false;
    }
  }

  Future<void> _alEnviarRegistro(
    EventoEnviarRegistro evento,
    Emitter<EstadoRegistro> emit,
  ) async {
    emit(const RegistroSubiendo());

    final datos = DatosRegistro(
      idUsuario: _idUsuario,
      rutasImagenes: evento.rutasImagenes,
      fechaCreacion: DateTime.now(),
    );

    final resultado = await repositorio.registrarUsuario(datos);

    resultado.fold(
      (fallo) => emit(RegistroFallido(mensaje: fallo.message)),
      (exitoso) => emit(RegistroExitoso(
        idRegistro: exitoso.idRegistro ?? '',
        mensaje: exitoso.mensaje,
      )),
    );
  }
}
```

---

### 8. **Widget de Cámara con ML Kit**

```dart
// lib/presentation/widgets/camera_smart_view.dart

class CameraSmartView extends StatefulWidget {
  final CameraController controller;
  final Function(List<Face>)? onFacesDetected;

  const CameraSmartView({
    super.key,
    required this.controller,
    this.onFacesDetected,
  });

  @override
  State<CameraSmartView> createState() => _CameraSmartViewState();
}

class _CameraSmartViewState extends State<CameraSmartView> {
  late FaceDetector _detectorRostros;
  List<Face> _rostros = [];
  bool _estaProcesando = false;

  @override
  void initState() {
    super.initState();
    _inicializarDetectorRostros();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _iniciarStreamImagenes();
    });
  }

  void _inicializarDetectorRostros() {
    final options = FaceDetectorOptions(
      enableLandmarks: true,
      performanceMode: FaceDetectorMode.fast,
    );
    _detectorRostros = FaceDetector(options: options);
  }

  void _iniciarStreamImagenes() {
    widget.controller.startImageStream((CameraImage image) {
      if (!_estaProcesando) {
        _estaProcesando = true;
        _procesarImagenCamara(image);
      }
    });
  }

  Future<void> _procesarImagenCamara(CameraImage image) async {
    if (!mounted) {
      _estaProcesando = false;
      return;
    }

    try {
      final inputImage = _convertirImagenCamara(image);
      if (inputImage == null) {
        _estaProcesando = false;
        return;
      }

      final rostros = await _detectorRostros.processImage(inputImage);

      if (mounted) {
        setState(() => _rostros = rostros);
        
        if (widget.onFacesDetected != null) {
          widget.onFacesDetected!(rostros);
        }
      }
    } catch (e) {
      debugPrint('Error procesando imagen: $e');
    } finally {
      if (mounted) {
        _estaProcesando = false;
      }
    }
  }

  InputImage? _convertirImagenCamara(CameraImage image) {
    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final sensorOrientation = 
          widget.controller.description.sensorOrientation;
      final imageRotation = _rotacionIntAImageRotation(sensorOrientation);

      final inputImageData = InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: imageRotation,
        format: InputImageFormat.nv21,
        bytesPerRow: image.planes[0].bytesPerRow,
      );

      return InputImage.fromBytes(bytes: bytes, metadata: inputImageData);
    } catch (e) {
      return null;
    }
  }

  InputImageRotation _rotacionIntAImageRotation(int rotation) {
    switch (rotation) {
      case 0: return InputImageRotation.rotation0deg;
      case 90: return InputImageRotation.rotation90deg;
      case 180: return InputImageRotation.rotation180deg;
      case 270: return InputImageRotation.rotation270deg;
      default: return InputImageRotation.rotation0deg;
    }
  }

  @override
  void dispose() {
    if (widget.controller.value.isStreamingImages) {
      widget.controller.stopImageStream();
    }
    _detectorRostros.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CameraPreview(widget.controller);
  }
}
```

---

### 9. **Página de Captura Facial**

```dart
// lib/presentation/pages/enrollment_page.dart

class EnrollmentPage extends StatefulWidget {
  final String userId; // Recibido del formulario anterior
  
  const EnrollmentPage({super.key, required this.userId});

  @override
  State<EnrollmentPage> createState() => _EnrollmentPageState();
}

class _EnrollmentPageState extends State<EnrollmentPage> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  DateTime? _lastCaptureTime;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      _cameraController = CameraController(
        cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => cameras.first,
        ),
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      
      if (mounted) {
        setState(() => _isCameraInitialized = true);
        
        // Iniciar el proceso de registro
        getIt<BlocRegistro>().add(
          EventoIniciarRegistro(idUsuario: widget.userId)
        );
      }
    }
  }

  Future<String> _captureImage() async {
    final image = await _cameraController!.takePicture();
    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = '${directory.path}/enrollment_$timestamp.jpg';
    await File(image.path).copy(path);
    return path;
  }

  void _onFacesDetected(List<Face> faces) async {
    if (faces.isEmpty) return;

    // Throttle: no capturar más frecuente que cada 800ms
    final now = DateTime.now();
    if (_lastCaptureTime != null &&
        now.difference(_lastCaptureTime!).inMilliseconds < 800) {
      return;
    }
    _lastCaptureTime = now;

    final face = faces[0];
    final angle = face.headEulerAngleY ?? 0.0;

    // Capturar imagen
    final imagePath = await _captureImage();
    
    if (imagePath.isNotEmpty && mounted) {
      getIt<BlocRegistro>().add(
        EventoRostroDetectado(
          anguloEulerY: angle,
          rutaImagen: imagePath,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<BlocRegistro>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('REGISTRO FACIAL')),
        body: BlocConsumer<BlocRegistro, EstadoRegistro>(
          listener: (context, state) {
            if (state is RegistroExitoso) {
              // Mostrar éxito y navegar
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('¡Registro Exitoso!'),
                  content: Text(state.mensaje),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Cerrar diálogo
                        Navigator.of(context).pop(); // Volver atrás
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            } else if (state is RegistroFallido) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.mensaje)),
              );
            }
          },
          builder: (context, state) {
            if (!_isCameraInitialized) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is RegistroSubiendo) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('PROCESANDO BIOMETRÍA...'),
                  ],
                ),
              );
            }

            // Mostrar cámara con instrucciones
            String instruction = 'MIRE AL FRENTE';
            int progress = 0;

            if (state is RegistroEnProgreso) {
              instruction = state.instruccion;
              progress = state.fotosCapturadas;
            } else if (state is FotoCapturada) {
              progress = state.numeroFoto;
            }

            return Stack(
              children: [
                CameraSmartView(
                  controller: _cameraController!,
                  onFacesDetected: _onFacesDetected,
                ),
                Positioned(
                  top: 20,
                  left: 16,
                  right: 16,
                  child: _buildProgressBar(progress),
                ),
                Positioned(
                  bottom: 40,
                  left: 16,
                  right: 16,
                  child: _buildInstructionBanner(instruction),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProgressBar(int progress) {
    return Row(
      children: List.generate(3, (index) => 
        Expanded(
          child: Container(
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: index < progress 
                  ? Colors.green 
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionBanner(String instruction) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.cyan, width: 2),
      ),
      child: Text(
        instruction,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }
}
```

---

### 10. **Configuración de Dependency Injection**

```dart
// lib/core/services/service_locator.dart

final getIt = GetIt.instance;

void configurarLocalizadorServicios() {
  // Network
  getIt.registerSingleton<Dio>(
    Dio(BaseOptions(
      baseUrl: 'https://tu-api.com',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    )),
  );

  // DataSources
  getIt.registerSingleton<FuenteDatosRemotaBiometrica>(
    ImplementacionFuenteDatosRemotaBiometrica(dio: getIt<Dio>()),
  );

  // Repositories
  getIt.registerSingleton<IRepositorioBiometrico>(
    ImplementacionRepositorioBiometrico(
      fuenteDatosRemota: getIt<FuenteDatosRemotaBiometrica>(),
    ),
  );

  // BLoCs
  getIt.registerSingleton<BlocRegistro>(
    BlocRegistro(repositorio: getIt<IRepositorioBiometrico>()),
  );
}
```

---

## 🔄 Flujo de Integración en Tu App

### Paso 1: Formulario de Registro

```dart
class FormularioRegistroPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de Usuario')),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre'),
              validator: (value) => 
                  value?.isEmpty ?? true ? 'Requerido' : null,
            ),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) => 
                  value?.isEmpty ?? true ? 'Requerido' : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Generar o obtener ID de usuario
                  final userId = _emailController.text;
                  
                  // Navegar a captura facial
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EnrollmentPage(userId: userId),
                    ),
                  );
                }
              },
              child: const Text('CONTINUAR A CAPTURA FACIAL'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 🎨 Consideraciones de UI/UX

### 1. **Feedback Visual**
- Barra de progreso (3 segmentos para 3 fotos)
- Efecto flash al capturar foto
- Borde del óvalo cambia de color al detectar rostro

### 2. **Instrucciones Claras**
```dart
const Map<String, String> INSTRUCCIONES = {
  'MirandoAlFrente': 'MIRE AL FRENTE',
  'MirandoIzquierda': 'GIRE A LA IZQUIERDA',
  'MirandoDerecha': 'GIRE A LA DERECHA',
};
```

### 3. **Throttling**
```dart
// Evitar capturas muy frecuentes
DateTime? _lastCaptureTime;

bool _puedeCapturar() {
  final now = DateTime.now();
  if (_lastCaptureTime != null &&
      now.difference(_lastCaptureTime!).inMilliseconds < 800) {
    return false;
  }
  _lastCaptureTime = now;
  return true;
}
```

---

## 📡 Formato de Request al API

### Request
```http
POST /api/enroll
Content-Type: multipart/form-data

{
  "user_id": "usuario@example.com",
  "images": [File, File, File]  // 3 archivos JPG
}
```

### Response Exitosa
```json
{
  "status": "success",
  "message": "Registro biométrico exitoso",
  "enrollment_id": "abc123xyz",
  "user_id": "usuario@example.com"
}
```

### Response Error
```json
{
  "status": "error",
  "message": "Error procesando imágenes"
}
```

---

## ⚙️ Configuración de Permisos

### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.INTERNET" />
```

### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSCameraUsageDescription</key>
<string>Necesitamos acceso a la cámara para captura facial</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Necesitamos acceso para guardar fotos</string>
```

---

## 🐛 Debugging Tips

### 1. **Logs del Proceso**
```dart
debugPrint('📸 Foto capturada #${_imagenesCapturadas.length}');
debugPrint('📐 Ángulo detectado: $angulo°');
debugPrint('📤 Enviando ${datos.rutasImagenes.length} imágenes');
```

### 2. **Verificar Detección**
```dart
void _onFacesDetected(List<Face> faces) {
  if (faces.isEmpty) {
    debugPrint('⚠️ No se detectó rostro');
    return;
  }
  
  final face = faces[0];
  debugPrint('✅ Rostro detectado - Ángulo: ${face.headEulerAngleY}°');
}
```

### 3. **Validar Rutas de Archivos**
```dart
final imagePath = await _captureImage();
final file = File(imagePath);
if (await file.exists()) {
  debugPrint('✅ Archivo existe: ${file.lengthSync()} bytes');
} else {
  debugPrint('❌ Archivo NO existe en: $imagePath');
}
```

---

## 📊 Rangos de Detección de Ángulos

```dart
// Mirando al frente: -15° a 15°
if (angulo.abs() < 15) {
  return 'MirandoAlFrente';
}

// Mirando a la izquierda: < -15°
if (angulo < -15) {
  return 'MirandoIzquierda';
}

// Mirando a la derecha: > 15°
if (angulo > 15) {
  return 'MirandoDerecha';
}
```

---

## ✅ Checklist de Implementación

- [ ] Agregar dependencias en `pubspec.yaml`
- [ ] Crear estructura de carpetas (domain/data/presentation)
- [ ] Implementar entidades y repositorio
- [ ] Configurar DataSource con Dio
- [ ] Crear BLoC (eventos, estados, lógica)
- [ ] Implementar widget de cámara con ML Kit
- [ ] Crear página de captura facial
- [ ] Configurar DI con GetIt
- [ ] Agregar permisos en Android/iOS
- [ ] Integrar navegación desde formulario
- [ ] Probar flujo completo

---

## 🚀 Siguiente Paso: Integración

1. **Copia la estructura de carpetas** del proyecto actual
2. **Adapta los endpoints** a tu API
3. **Personaliza el UI** según tu diseño
4. **Prueba el flujo** desde formulario → captura → envío

---

**Notas Importantes:**
- El proceso captura exactamente **3 fotos** (frente, izquierda, derecha)
- Usa **throttling** para evitar capturas excesivas
- La detección facial es en **tiempo real** con ML Kit
- Las imágenes se envían como **multipart/form-data**
- El usuario no necesita tocar botones, todo es **automático**

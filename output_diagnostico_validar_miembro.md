# Diagnóstico: validarProspectoMiembro — cadena completa

## 1. Use case — `lib/domain/usecases/validar_prospecto_miembro_usecase.dart`

```dart
import '../ports/account_repository.dart';
import '../entities/prospecto_residente.dart';

class ValidarProspectoMiembroUseCase {
  final AccountRepository repository;
  ValidarProspectoMiembroUseCase(this.repository);

  Future<ProspectoMiembro> execute(String identificacion) async {
    return await repository.validarProspectoMiembro(identificacion);
  }
}
```

## 2. Repository — `lib/infrastructure/adapters/account_repository_impl.dart`

```dart
  @override
  Future<ProspectoMiembro> validarProspectoMiembro(
      String identificacion) async {
    try {
      return await accountApiProvider.validarProspectoMiembro(identificacion);
    } catch (e) {
      rethrow;
    }
  }
```

## 3. API provider — `lib/infrastructure/providers/account_api_provider.dart`

```dart
  Future<ProspectoMiembro> validarProspectoMiembro(
      String identificacion) async {
    try {
      final response = await dio.get(
        '/cuentas/prospecto/miembro/$identificacion',
      );
      return ProspectoMiembro.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception(e.response?.data['detail'] ??
            'Esta persona ya tiene una cuenta creada');
      }
      rethrow;
    }
  }
```

## 4. Entidad — `lib/domain/entities/prospecto_residente.dart`

```dart
class ProspectoMiembro {
  final bool existe;
  final bool? personaEncontrada;
  final int? personaId;
  final String? identificacion;
  final String? nombres;
  final String? apellidos;
  final String? correo;
  final String? celular;
  final String? parentesco;
  final ViviendaInfo? vivienda;
  final bool? puedeCrearCuenta;
  final String? mensaje;
  final bool? tieneFacialEnrolado;

  ProspectoMiembro({
    required this.existe,
    this.personaEncontrada,
    this.personaId,
    this.identificacion,
    this.nombres,
    this.apellidos,
    this.correo,
    this.celular,
    this.parentesco,
    this.vivienda,
    this.puedeCrearCuenta,
    this.mensaje,
    this.tieneFacialEnrolado,
  });

  factory ProspectoMiembro.fromJson(Map<String, dynamic> json) {
    return ProspectoMiembro(
      existe: json['existe'] ?? false,
      personaEncontrada: json['persona_encontrada'],
      personaId: json['persona_id'],
      identificacion: json['identificacion'],
      nombres: json['nombres'],
      apellidos: json['apellidos'],
      correo: json['correo'],
      celular: json['celular'],
      parentesco: json['parentesco'],
      vivienda: json['vivienda'] != null ? ViviendaInfo.fromJson(json['vivienda']) : null,
      puedeCrearCuenta: json['puede_crear_cuenta'],
      mensaje: json['mensaje'],
      tieneFacialEnrolado: json['tiene_facial_enrolado'] as bool?,
    );
  }
}
```

## Comparación: Residente vs Miembro

| Aspecto | `validarProspectoResidente` | `validarProspectoMiembro` |
|---------|----------------------------|---------------------------|
| Catches 404 | ✅ `on DioException`: statusCode 404 → `throw Exception(...)` | ❌ **No maneja 404** |
| Catches 409 | ✅ `on DioException`: statusCode 409 → `throw Exception(...)` | ✅ `on DioException`: statusCode 409 → `throw Exception(...)` |
| Si backend retorna 200 con `existe: false` | N/A (no tiene campo `existe`) | ✅ Se parsea como `ProspectoMiembro` válido — **no lanza excepción** |

## Causa raíz del bug

**El backend probablemente retorna HTTP 200 con `{"existe": false}` en vez de HTTP 404.**

Cuando `existe: false`:
- `_validar()` recibe un `ProspectoMiembro` válido (sin excepción)
- No entra al `catch` que detecta `'no encontrado'` o `'404'`
- `_resultado = prospecto` con todos los campos `null` → se renderiza "Identidad Verificada" con nombres vacíos

**Solución:** En `ProspectoMiembroPage._validar()`, después de recibir el `ProspectoMiembro`, verificar `prospecto.existe`:

```dart
final prospecto = await useCase.execute(_cedulaCtrl.text.trim());
if (!prospecto.existe) {
  // Mostrar diálogo "Miembro No Registrado"
  _mostrarDialogoNoEncontrado();
  return;
}
```

(Opcional: también agregar el handler 404 en `AccountApiProvider.validarProspectoMiembro` como respaldo, similar al de residente.)

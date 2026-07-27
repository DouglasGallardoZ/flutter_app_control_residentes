# Traza Completa: Registro de Cónyuge (RF-P02)

---

## 1. Punto de Entrada

| Aspecto | Valor |
|---------|-------|
| **Página** | `CreateSpousePage` (definida en `create_spouse_dialog.dart`) |
| **Tipo** | Página completa (Scaffold + AppBar), a pesar del nombre "dialog" |
| **Acceso real** | **🔥 NINGUNO** — `CreateSpousePage` no es importada por ningún otro archivo ni tiene ruta definida en `app_routes.dart` |
| **Estado** | **Código muerto** — la funcionalidad de crear cónyuge existe en infraestructura/BLoC pero la UI no es accesible para el usuario |
| **Archivos que importan** | Ninguno (solo auto-importación) |

### ¿Dónde debería estar?
Idealmente debería abrirse desde `admin_owners_page.dart` en el `_OwnerDetailPage`, tipo:
- Botón "Agregar Cónyuge" en el AppBar o PopupMenu
- Sección de cónyuge con botón "+"

---

## 2. Formulario (dentro de `CreateSpousePage`)

| # | Campo | Controlador | Widget | Obligatorio | Validación | Líneas |
|---|-------|-------------|--------|:---:|------------|--------|
| 1 | Tipo de Identificación | `_tipoIdentificacionController` | Dropdown (Cedula/Pasaporte/Otro) | ✅ | No vacío | `:315-363` |
| 2 | Identificación | `_identificacionController` | TextField numérico | ✅ | `FormatRules.isValidId()` → "Cédula inválida (10 dígitos)" | `:366-394` |
| 3 | Nombres | `_nombreController` | TextField | ✅ | No vacío → "Los nombres son requeridos" | `:397-421` |
| 4 | Apellidos | `_apellidoController` | TextField | ✅ | No vacío → "Los apellidos son requeridos" | `:424-448` |
| 5 | Fecha de Nacimiento | `_fechaNacimientoController` | DatePicker (readOnly) | ✅ | `DateTime.tryParse` + futuro + ≥ 18 años → múltiples errores | `:451-523` |
| 6 | Nacionalidad | `_nacionalidadController` | TextField (default "Ecuador") | ❌ | Sin validador | `:526-541` |
| 7 | Correo Electrónico | `_correoController` | TextField (email keyboard) | ✅ | `FormatRules.isValidEmail()` → "Formato de correo inválido" | `:544-575` |
| 8 | Celular | `_celularController` | TextField (phone keyboard) | ✅ | `FilteringTextInputFormatter.digitsOnly` + `LengthLimiting(10)` + `FormatRules.isValidPhone()` → "Formato inválido: 09XXXXXXXX" | `:578-603` |
| 9 | Dirección Alternativa | `_direccionAlternativaController` | TextField (maxLines: 2) | ❌ | Sin validador | `:606-621` |

### Herencia de manzana/villa
| Aspecto | Detalle |
|---------|---------|
| **¿Se heredan del propietario?** | ✅ **Sí.** No hay campos manuales de manzana/villa en el formulario |
| **¿Se muestran?** | ✅ Texto informativo `"Manzana: {owner.manzana} \| Villa: {owner.villa}"` (`:281-288`) |
| **Nota al usuario** | Banner azul: `"Nota: La ubicación (Manzana y Villa) será heredada automáticamente del propietario."` (`:644-653`) |
| **Owner pasado como** | `widget.owner` (tipo `OwnerEntity`) recibido en constructor (`:14`) |

### Foto de rostro
| Aspecto | Detalle |
|---------|---------|
| **¿Hay campo de foto?** | ❌ **No.** No hay ImagePicker, cámara, ni ningún campo de foto en el formulario |
| **¿Obligatorio?** | N/A |

### Restricciones DatePicker
| Restricción | Implementación | Línea |
|-------------|----------------|-------|
| Requerido | `'La fecha de nacimiento es requerida'` | `:495` |
| Formato inválido | `DateTime.tryParse` → `'Formato de fecha inválido'` | `:499-500` |
| Fecha futura | `fecha.isAfter(hoy)` → `'La fecha no puede ser futura'` | `:504-506` |
| Edad ≥ 18 | Cálculo manual (`año >= 18`) → `'Debe ser mayor de 18 años'` | `:509-521` |
| DatePicker nativo | `showDatePicker(firstDate: 1950, lastDate: today)` | `:492-522` |

---

## 3. Llamada al Backend

### Cadena completa de llamadas

```
UI: CreateSpousePage._createSpouse()
  → OwnerBloc.CreateSpouseEvent
    → CreateSpouseUseCase.execute()
      → OwnerRepository.createSpouse()
        → SpouseApiImpl.addSpouse()
          → POST /propietarios/{ownerId}/conyuge
```

### Llamada HTTP real

| Aspecto | Valor |
|---------|-------|
| **Archivo** | `spouse_api_impl.dart:40-43` |
| **Dio** | `apiHttpClient.dio` (base URL: `http://192.168.1.18:8080/api/v1`) |
| **Método** | `POST` |
| **URL** | `/propietarios/$propietarioId/conyuge` → `POST /api/v1/propietarios/{id}/conyuge` |
| **Body (JSON)** | ```json { "identificacion": "...", "nombres": "...", "apellidos": "...", "fecha_nacimiento": "...", "correo": "...", "celular": "...", "usuario_creado": "flutter_app" } ``` |
| **Headers** | `Authorization: Bearer <Firebase ID Token>` (via interceptor en `http_client.dart`) |
| **Respuesta** | `response.data` como `Map<String, dynamic>` |
| **¿Incluye foto?** | ❌ No |

### Diferencias entre body vs formulario
| Campo en formulario | Campo en body | ¿Coincide? |
|-------------------|---------------|:----------:|
| `nombres` | `nombres` | ✅ |
| `apellidos` | `apellidos` | ✅ |
| `identificacion` | `identificacion` | ✅ |
| `fechaNacimiento` | `fecha_nacimiento` | ✅ |
| `correo` | `correo` (opcional) | ✅ |
| `celular` | `celular` (opcional) | ✅ |
| -- | `usuario_creado` | ✅ (hardcodeado como `'flutter_app'`) |
| `nacionalidad` | ❌ **No se envía** | ⚠️ Aunque el campo existe en formulario, `spouse_api_impl.dart:31-38` no lo incluye |
| `direccionAlternativa` | ❌ **No se envía** | ⚠️ Ídem |
| `tipoIdentificacion` | ❌ **No se envía** | ⚠️ Ídem |
| Fotos | ❌ No existen | N/A |

### Nota sobre `admin_api_spouse_extension.dart`
| Método | URL | ¿Se usa? |
|--------|-----|:--------:|
| `getOwnerWithSpouses` | `GET /propietarios/{id}/conyuge` (corregido) | ❌ No — `OwnerRepositoryImpl` lanza `UnimplementedError` (`owner_repository_impl.dart:174-175`) |
| `createSpouse` | `POST /propietarios/{id}/conyuge` | ❌ No — la ruta que se usa es `spouse_api_impl.dart:40`, no esta extensión |
| `getSpousesByOwner` | `GET /propietarios/{id}/conyuge` | ❌ No — `OwnerRepositoryImpl` usa `spouseApi.getSpouseByOwnerId()` (`:223`) |
| `deleteSpouse` | `DELETE /conyuges/{id}` | ❌ No — `OwnerRepositoryImpl` usa `spouseApi.deleteSpouse()` (`:240`) |
| `blockSpouse` | `PUT /conyuges/{id}` (corregido) | ❌ No — `OwnerRepositoryImpl` lanza `UnimplementedError` (`:251-252`) |

---

## 4. Flujo Post-Registro

| Paso | Acción | Archivo:Línea |
|------|--------|---------------|
| 1 | `_formKey.currentState!.validate()` | `create_spouse_dialog.dart:92-94` |
| 2 | Dispara `OwnerBloc` → `CreateSpouseEvent(ownerId, tipoIdentificacion, identificacion, nombre, apellido, fechaNacimiento, nacionalidad, correo, celular, usuarioCreado)` | `create_spouse_dialog.dart:97-136` |
| 3 | BLoC handler `_onCreateSpouse` → `SpouseCreating` | `owner_bloc.dart:193-217` |
| 4 | Use case → Repository → API → `POST /propietarios/{id}/conyuge` | `spouse_api_impl.dart:40` |
| 5 | Éxito → `SpouseCreated(ConyugeEntity)` + `LoadOwnerWithSpousesEvent` | `owner_bloc.dart:212-213` |
| 6 | UI listener → `Navigator.of(context).pop(true)` (cierra la página) | `create_spouse_dialog.dart:179` |
| 7 | La página anterior (`admin_owners_page.dart`) recarga si hay `BlocListener` | — |

### Mensajes de error/success

| Estado | Mensaje | Color |
|--------|---------|:-----:|
| `SpouseCreated` | (N/A — se cierra la página y vuelve con resultado) | N/A |
| `SpouseError` | `'Error al crear cónyuge: $e'` | Rojo (SnackBar en BLoC listener) |

---

## 5. BLoC — OwnerBloc

| Aspecto | Valor |
|---------|-------|
| **Evento** | `CreateSpouseEvent` (`owner_event.dart:122-163`) |
| **Handler** | `_onCreateSpouse` (`owner_bloc.dart:193-217`) |
| **Dependencia** | `CreateSpouseUseCase` → `OwnerRepository.createSpouse()` |
| **Estado loading** | `SpouseCreating` (sin spinner) |
| **Estado éxito** | `SpouseCreated(ConyugeEntity spouse)` (`owner_state.dart:111-118`) |
| **Estado error** | `SpouseError(String message)` (`owner_state.dart:139-144`) |
| **Post-éxito** | Dispara `LoadOwnerWithSpousesEvent(event.ownerId)` para refrescar vista |

---

## 6. ¿Cumple SRS RF-P02?

| Requisito SRS | Estado | Evidencia |
|---------------|:------:|-----------|
| **Asociado al propietario seleccionado** | ✅ | `widget.owner` pasado al constructor (`create_spouse_dialog.dart:14`) |
| **Manzana/villa heredadas (CV-17)** | ✅ | Sin campos manuales. Banner informativo. Body no incluye manzana/villa — se heredan vía `ownerId` |
| **Fecha nacimiento con restricciones (CV-16)** | ✅ | DatePicker + ≥ 18 años |
| **Fotos obligatorias** | ❌ | No hay ImagePicker ni campo de foto en el formulario |
| **Endpoint correcto** | ✅ | `POST /propietarios/{id}/conyuge` |
| **Validaciones ID/email/celular** | ✅ | `FormatRules.isValidId`, `isValidEmail`, `isValidPhone` |
| **Validación nombres/apellidos** | ✅ | `required` en ambos campos |
| **POST-registro a facial enrollment** | ❌ | No redirige a enrolamiento facial. Solo hace `Navigator.pop(true)` |
| **UI es accesible por el usuario** | ❌🔥 | `CreateSpousePage` no es importada por ningún archivo. **Código muerto.** No hay botón/ruta que lleve a esta página |

### 🔴 Issue crítico

> `CreateSpousePage` está definida pero **nunca es importada** por ningún otro archivo ni tiene ruta en `app_routes.dart`. El usuario NO puede acceder a la funcionalidad de registro de cónyuge desde la UI actual.

### ⚠️ Issues secundarios

1. **Campos no enviados al backend:** `nacionalidad`, `direccionAlternativa`, `tipoIdentificacion` existen en el formulario pero `spouse_api_impl.dart:31-38` no los incluye en el body
2. **Sin redirección a facial enrollment** después del registro exitoso
3. **`owner_repository_impl.dart:getOwnerWithSpouses`** lanza `UnimplementedError` (`:174-175`)
4. **`owner_repository_impl.dart:blockSpouse`** lanza `UnimplementedError` (`:251-252`)
5. **`admin_api_spouse_extension.dart`** es código muerto (no importado por nadie)

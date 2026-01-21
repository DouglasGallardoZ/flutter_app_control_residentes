# 🔧 CORRECCIÓN - Error "type null is not a subtype of type int"

**Fecha:** Enero 21, 2026  
**Error Original:** Line 33 de `auth_repository_impl.dart` - "type null is not a subtype of type int"  
**Status:** ✅ CORREGIDO

---

## 🎯 PROBLEMA IDENTIFICADO

Cuando se logueaba un **administrador**, el servidor **NO retornaba** ciertos campos:
- `persona_id` (null)
- `vivienda` (null)
- `identificacion` (null)

El código intentaba asignarlos directamente a campos tipados como `int` y `String`, causando error de tipo.

---

## ✅ SOLUCIONES IMPLEMENTADAS

### 1️⃣ PerfilUsuarioDTO - Campos Opcionales

**Archivo:** `lib/infrastructure/dtos/perfil_usuario_dto.dart`

**Antes:**
```dart
class PerfilUsuarioDTO {
  final int personaId;              // ❌ Required - causa error si null
  final String identificacion;      // ❌ Required
  final ViviendaDTO vivienda;       // ❌ Required
  ...
}
```

**Después:**
```dart
class PerfilUsuarioDTO {
  final int? personaId;             // ✅ Nullable
  final String? identificacion;     // ✅ Nullable
  final ViviendaDTO? vivienda;      // ✅ Nullable
  ...
}

// En fromJson():
personaId: json['persona_id'] != null 
  ? int.tryParse(json['persona_id'].toString()) 
  : null,
```

### 2️⃣ ViviendaDTO - Campos Opcionales

**Antes:**
```dart
class ViviendaDTO {
  final int viviendaId;       // ❌ Required
  ...
}
```

**Después:**
```dart
class ViviendaDTO {
  final int? viviendaId;      // ✅ Nullable
  ...
}

// En fromJson():
viviendaId: json['vivienda_id'] != null 
  ? int.tryParse(json['vivienda_id'].toString()) 
  : null,
```

### 3️⃣ AuthRepositoryImpl - Construcción Condicional

**Archivo:** `lib/infrastructure/adapters/auth_repository_impl.dart`

**Antes:**
```dart
return {
  'uid': user.uid,
  'personaId': perfil.personaId,      // ❌ Null crash aquí
  'vivienda': perfil.vivienda.toJson(),
};
```

**Después:**
```dart
final Map<String, dynamic> loginResponse = {
  'uid': user.uid,
  'email': user.email,
  'nombres': perfil.nombres,
  // Campos base (todos los usuarios)
};

// Agregar campos opcionales solo si no son null
if (perfil.personaId != null) {
  loginResponse['personaId'] = perfil.personaId;
}

if (perfil.vivienda != null) {
  loginResponse['vivienda'] = perfil.vivienda!.toJson();
}

return loginResponse;
```

### 4️⃣ AccountRepositoryImpl - Manejo de Valores por Defecto

**Archivo:** `lib/infrastructure/adapters/account_repository_impl.dart`

**Antes:**
```dart
return Account(
  personaId: perfilDTO.personaId,      // ❌ Null crash
  vivienda: Vivienda(
    viviendaId: perfilDTO.vivienda.viviendaId,  // ❌ Null crash
  ),
);
```

**Después:**
```dart
// Usar valores por defecto si son null (típico para admins)
final vivienda = perfilDTO.vivienda ?? ViviendaDTO(
  viviendaId: null,
  manzana: '',
  villa: '',
);

return Account(
  personaId: perfilDTO.personaId ?? 0,
  vivienda: Vivienda(
    viviendaId: vivienda.viviendaId ?? 0,
    manzana: vivienda.manzana,
    villa: vivienda.villa,
  ),
);
```

### 5️⃣ LoginUseCase - Simplificación

**Archivo:** `lib/domain/usecases/login_usecase.dart`

Ahora simplemente retorna lo que el `AuthRepository` retorna, sin procesamiento adicional:

```dart
class LoginUseCase {
  final AuthRepository auth;
  
  LoginUseCase(this.auth);

  Future<Map<String, dynamic>> call({
    required String email,
    required String password,
  }) async {
    return await auth.login(email: email, password: password);
  }
}
```

### 6️⃣ Inyección de Dependencias

**Archivo:** `lib/injection.dart`

```dart
sl.registerLazySingleton<LoginUseCase>(
  () => LoginUseCase(sl<AuthRepository>()),  // ✅ Solo AuthRepository
);
```

---

## 📊 COMPARATIVA: Antes vs Después

| Aspecto | Antes | Después |
|--------|-------|---------|
| **Admin personaId** | ❌ Null → Error | ✅ Null → Omitido |
| **Admin vivienda** | ❌ Null → Error | ✅ Null → Omitido |
| **Residente personaId** | ✅ Incluido | ✅ Incluido |
| **Residente vivienda** | ✅ Incluido | ✅ Incluido |
| **Tipo safety** | ❌ String? para todo | ✅ Map<String, dynamic> |

---

## ✅ VALIDACIONES

**Compilación:**
- ✅ `auth_repository_impl.dart` - Sin errores
- ✅ `account_repository_impl.dart` - Sin errores
- ✅ `login_usecase.dart` - Sin errores
- ✅ `perfil_usuario_dto.dart` - Sin errores
- ✅ `injection.dart` - Sin errores

---

## 🔄 FLUJO CORREGIDO

```
┌─────────────────────────────────────┐
│ Admin intenta loguear               │
├─────────────────────────────────────┤
│ Email: admin@email.com              │
│ Password: ****                      │
└─────────────────┬───────────────────┘
                  │
                  ├─► Firebase Auth ✅
                  │
                  ├─► API GET /perfil/{uid} 
                  │   ├─► persona_id: null    ← No viene
                  │   ├─► identificacion: null ← No viene
                  │   ├─► vivienda: null       ← No viene
                  │   ├─► rol: "admin"         ✅
                  │   ├─► nombres: "Carlos"    ✅
                  │   └─► email: "admin@..."   ✅
                  │
                  ├─► PerfilUsuarioDTO.fromJson()
                  │   ├─► personaId = null (nullable ✅)
                  │   ├─► identificacion = null (nullable ✅)
                  │   └─► vivienda = null (nullable ✅)
                  │
                  ├─► AuthRepository.login() construye response
                  │   ├─► loginResponse = Map<String, dynamic>
                  │   ├─► if (personaId != null) -> omitido
                  │   ├─► if (vivienda != null) -> omitido
                  │   └─► return loginResponse ✅
                  │
                  ├─► LoginUseCase retorna datos
                  │
                  ├─► AuthBloc.AuthSuccess
                  │
                  └─► ProfilePage muestra perfil admin ✅
                      (sin residencia, sin identificación)
```

---

## 🎯 RESULTADO FINAL

**Admin Login:**
✅ No hay error de tipo  
✅ Perfil se carga correctamente  
✅ ProfilePage muestra "Información de Administración"  
✅ No intenta mostrar residencia (no existe)

**Residente Login:**
✅ Sigue funcionando igual  
✅ Incluye personaId  
✅ Incluye identificación  
✅ Incluye vivienda  
✅ ProfilePage muestra "Información Personal" + Residencia

---

## 📁 ARCHIVOS MODIFICADOS

| Archivo | Cambios | Status |
|---------|---------|--------|
| `perfil_usuario_dto.dart` | Campos nullable | ✅ |
| `auth_repository_impl.dart` | Map<String, dynamic> | ✅ |
| `account_repository_impl.dart` | Valores por defecto | ✅ |
| `login_usecase.dart` | Simplificado | ✅ |
| `injection.dart` | Constructor actualizado | ✅ |

---

**Versión:** 1.0  
**Completado:** 21 Enero 2026  
**Status:** ✅ ERROR CORREGIDO

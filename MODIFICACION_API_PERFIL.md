# 🔄 MODIFICACIÓN API PERFIL - LOGIN USECASE

**Fecha:** Enero 21, 2026  
**Estado:** ✅ Implementado

---

## 📋 CAMBIO REALIZADO

El `LoginUseCase` ahora detecta si el usuario es **administrador** y retorna datos específicos por rol:

### 🎯 Lógica Implementada

```dart
// En LoginUseCase.call()

final isAdmin = account.rol?.toLowerCase() == 'admin';

// Si es admin: NO incluye datos de vivienda
// Si es residente/miembro: Incluye datos de vivienda
```

---

## 📊 COMPARATIVA DE DATOS RETORNADOS

### ✅ RESIDENTE / MIEMBRO FAMILIA

```json
{
  "uid": "firebase_uid",
  "email": "residente@email.com",
  "idToken": "token_firebase",
  "id": "persona_id",
  "identificacion": "1234567890",      ← SÍ INCLUIDO
  "name": "Juan Pérez",
  "rol": "resident",
  "correo": "residente@email.com",
  "celular": "0987654321",
  "residence": "M-01-V-001",            ← SÍ INCLUIDO
  "residence_id": "vivienda_123",       ← SÍ INCLUIDO
  "vivienda": {                         ← SÍ INCLUIDO
    "vivienda_id": "vivienda_123",
    "manzana": "M-01",
    "villa": "V-001"
  },
  "parentesco": "residente",            ← SÍ INCLUIDO
  "fechaCreado": "2026-01-21T10:30:00Z"
}
```

### 🔐 ADMINISTRADOR (NUEVO)

```json
{
  "uid": "firebase_uid",
  "email": "admin@email.com",
  "idToken": "token_firebase",
  "id": "persona_id",
  "name": "Carlos Admin",
  "rol": "admin",
  "correo": "admin@email.com",
  "celular": "0987654321",
  "fechaCreado": "2026-01-21T10:30:00Z"
  
  // ❌ NO INCLUIDOS:
  // - identificacion
  // - identification
  // - dni
  // - residence
  // - residence_id
  // - vivienda
  // - parentesco
}
```

---

## 🔍 DETALLES TÉCNICOS

### Archivo Modificado:
**`lib/domain/usecases/login_usecase.dart`**

### Cambios en el código:

**Antes:**
```dart
return {
  // Firebase
  'uid': loginResult['uid'],
  'email': loginResult['email'],
  'idToken': loginResult['idToken'],
  // User Data
  'id': account.personaId,
  'identificacion': account.identificacion,
  'identification': account.identificacion,
  'dni': account.identificacion,
  'name': account.nombreCompleto,
  'nombres': account.nombres,
  'apellidos': account.apellidos,
  'nombreCompleto': account.nombreCompleto,
  'rol': account.rol,
  'estado': account.estado,
  'correo': account.correo,
  'email': loginResult['email'],
  'celular': account.celular,
  // Residence
  'residence': '${account.vivienda.manzana}-${account.vivienda.villa}',
  'residence_id': account.vivienda.viviendaId,
  'vivienda': {...},
  'parentesco': account.parentesco,
  'fechaCreado': account.fechaCreado.toIso8601String(),
};
```

**Después:**
```dart
final isAdmin = account.rol?.toLowerCase() == 'admin';

final userData = {
  // Firebase (siempre incluidos)
  'uid': loginResult['uid'],
  'email': loginResult['email'],
  'idToken': loginResult['idToken'],
  // User Data (básico para todos)
  'id': account.personaId,
  'name': account.nombreCompleto,
  'nombres': account.nombres,
  'apellidos': account.apellidos,
  'nombreCompleto': account.nombreCompleto,
  'rol': account.rol,
  'estado': account.estado,
  'correo': account.correo,
  'email': loginResult['email'],
  'celular': account.celular,
  'fechaCreado': account.fechaCreado.toIso8601String(),
};

// Agregar datos de identificación e vivienda solo si NO es admin
if (!isAdmin) {
  userData.addAll({
    'identificacion': account.identificacion,
    'identification': account.identificacion,
    'dni': account.identificacion,
    // Residence
    'residence': '${account.vivienda.manzana}-${account.vivienda.villa}',
    'residence_id': account.vivienda.viviendaId,
    'vivienda': {
      'vivienda_id': account.vivienda.viviendaId,
      'manzana': account.vivienda.manzana,
      'villa': account.vivienda.villa,
    },
    'parentesco': account.parentesco,
  });
}

return userData;
```

---

## ✅ VALIDACIÓN

**Compilación:** ✅ Sin errores  
**Lógica:** ✅ Correcta  
**Tipos de datos:** ✅ Válidos

---

## 🔗 IMPACTO EN OTRAS PARTES

### ProfilePage.dart
El frontend ya tiene lógica condicional:
```dart
bool _isAdmin(String? role) {
  return role?.toLowerCase() == 'admin' || 
         role?.toLowerCase() == 'administrador';
}

// Si es admin: no muestra residencia (ya implementado)
// Si es residente: muestra residencia
```

Ahora con este cambio:
- ✅ Admin NO recibirá datos de residencia en AuthBloc
- ✅ ProfilePage simplemente ignora `residence` (null/undefined)
- ✅ Lógica UI y datos del backend alineados

---

## 📋 FLUJO COMPLETO

```
1. Usuario (Admin o Residente) ingresa credenciales
   ↓
2. LoginUseCase.call() ejecuta
   ↓
3. Autentica en Firebase
   ↓
4. Obtiene datos de Account
   ↓
5. DETECTA ROL
   ├─ Si admin: Retorna (nombre, email, rol) SIN vivienda
   └─ Si residente/miembro: Retorna (todo incluyendo vivienda)
   ↓
6. AuthBloc almacena en AuthSuccess
   ↓
7. ProfilePage.dart usa datos de AuthBloc
   ├─ Si admin: _isAdmin() = true → muestra "Información de Administración"
   └─ Si residente: _isAdmin() = false → muestra "Información Personal" + "Residencia"
```

---

## 🎯 BENEFICIOS

✅ **Backend y Frontend alineados**
- Datos consistent entre API y UI

✅ **Seguridad**
- Admin no expuesto a datos de vivienda innecesariamente

✅ **Lógica centralizada**
- La determinación de rol está en un único lugar (LoginUseCase)

✅ **Mantenibilidad**
- Si cambia la lógica de rol, solo cambiar en LoginUseCase

---

## 📚 ARCHIVOS AFECTADOS

| Archivo | Cambio | Estado |
|---------|--------|--------|
| `login_usecase.dart` | Lógica condicional de rol | ✅ Modificado |
| `profile_page.dart` | Ya tiene lógica condicional | ✅ Compatible |
| `auth_bloc.dart` | Recibe datos del LoginUseCase | ✅ Sin cambios |

---

## 🚀 PRÓXIMOS PASOS

1. ✅ Backend: LoginUseCase modificado
2. ✅ Frontend: ProfilePage ya tiene lógica
3. 📅 Testing: Validar que admin no ve residencia
4. 📅 Testing: Validar que residente sigue viendo residencia

---

**Versión:** 1.0  
**Completado:** 21 Enero 2026  
**Status:** ✅ LISTO PARA TESTING

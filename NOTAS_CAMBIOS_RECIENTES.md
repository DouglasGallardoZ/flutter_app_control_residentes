# 📝 NOTAS DE CAMBIOS RECIENTES

**Fecha:** Enero 21, 2026  
**Versión:** 3.0  

---

## ✅ CAMBIO 1: Omisión Temporal del Registro de Fotos

### Decisión
Se ha decidido **omitir de momento el registro de fotos** para propietarios, residentes y miembros de familia. Los APIs no recibirán fotos en esta fase inicial.

### Archivos Actualizados

#### 1. **API_DOCUMENTACION_PROPIETARIOS_CUENTAS.md**
**Cambios:**
- ❌ Removido campo `fotos_rostro` de RF-P01 (Crear Propietario)
- ❌ Removido validación: "Fotografías: JPG/PNG, no vacías, distintas resoluciones"
- ❌ Removido campo `foto_rostro` de RF-P02 (Registrar Cónyuge)
- ❌ Removido validación: "Foto rostro: JPG/PNG, nítida, sin obstrucciones"

**Endpoints afectados:**
- `POST /api/v1/admin/propietarios` - Request sin `fotos_rostro`
- `POST /api/v1/admin/propietarios/{id}/conyuges` - Request sin `foto_rostro`

#### 2. **MODULO_ADMINISTRACION_PROPUESTA.md**
**Cambios:**
- ❌ Removido "Cámara para fotos" de RF-P01
- ❌ Removido "fotos rostro" de RF-P03 (Actualizar)
- ❌ Removido "Fotografías de rostro (mín 2)" de campos principales
- ❌ Removido "Fotografía de rostro" de campos de Residentes
- ❌ Removido "Fotografía de rostro" de campos de Miembros de Familia
- ❌ Removido flujo de captura de fotos en "Flujo 1: Registrar Propietario"
- ❌ Removido endpoint `POST /api/v1/propietarios/{id}/fotos`
- ❌ Removido "Fotos" de la navegación

### Implicaciones
✅ **Simplifica:** Desarrollo del backend, Frontend (sin cámara), UX (formularios simples)  
⚠️ **Futuro (Fase 2):** Será reactivado mejorado

---

## ✅ CAMBIO 2: Perfil de Administrador Diferenciado

### Decisión
El administrador **no debe buscar perfil en base de datos** como residentes. Su perfil es genérico mostrando solo:
- Nombre
- Función: "Administración"
- Rol: "Administrador"
- Correo electrónico

**El admin NO verá:**
- ❌ Identificación
- ❌ Residencia (no tiene)
- ❌ Datos de residente/miembro

### Archivos Modificados

#### **lib/presentation/pages/profile_page.dart**

**Cambios implementados:**

1. ✅ Función detectora de admin:
```dart
bool _isAdmin(String? role) {
  return role?.toLowerCase() == 'admin' || 
         role?.toLowerCase() == 'administrador';
}
```

2. ✅ Variable en build():
```dart
final isAdmin = _isAdmin(role);
```

3. ✅ Tarjeta condicional (Información Personal vs Administración):
```dart
if (!isAdmin)
  // Muestra: Nombre + Identificación
else
  // Muestra: Función: "Administración" + Rol: "Administrador"
```

4. ✅ Ocultamiento de tarjeta Residencia para admins:
```dart
if (!isAdmin)
  // Muestra: Residencia (manzana, villa)
```

### Arquitectura

**Residente/Miembro:**
```
┌─────────────────────┐
│ Avatar + Nombre     │
│ Rol: Residente      │
├─────────────────────┤
│ Información Personal│
│ • Nombre            │
│ • Identificación    │
├─────────────────────┤
│ Correo (editable)   │
├─────────────────────┤
│ Residencia          │
│ • Manzana, Villa    │
└─────────────────────┘
```

**Administrador:**
```
┌─────────────────────┐
│ Avatar + Nombre     │
│ Rol: Administrador  │
├─────────────────────┤
│ Inf. Administración │
│ • Función: Admin    │
│ • Rol: Administrador│
├─────────────────────┤
│ Correo (editable)   │
│ (NO residencia)     │
└─────────────────────┘
```

### Beneficios
✅ Claridad de roles  
✅ No confunde admin con residentes  
✅ No expone datos innecesarios  
✅ UX diferenciada por rol  

---

## 📊 RESUMEN DE CAMBIOS

| Item | Cambio | Archivo | Estado |
|------|--------|---------|--------|
| Fotos | Removidas | API_DOCUMENTACION_PROPIETARIOS_CUENTAS.md | ✅ |
| Fotos | Removidas | MODULO_ADMINISTRACION_PROPUESTA.md | ✅ |
| Perfil Admin | Implementado | profile_page.dart | ✅ |
| Documentación | Creada | PERFIL_USUARIO_ARQUITECTURA.md | ✅ |

---

## 📋 PRÓXIMOS PASOS

1. ✅ Frontend: Profile Page - HECHO
2. 📅 Backend: Endpoint GET /profile retorna datos específicos por rol
3. 📅 Testing: Validar que admin no ve datos de residencia
4. 📅 Testing: Validar que residente no ve datos de admin

---

**Estado:** ✅ Ambos cambios implementados y documentados

### Impacto en Requerimientos

| RF | Antes | Después | Estado |
|---|---|---|---|
| RF-P01 | Incluía 2+ fotos | Solo datos + documento | ✅ Simplificado |
| RF-P02 | Incluía 1 foto | Solo datos | ✅ Simplificado |
| RF-P03 | Actualización de fotos | Solo email, celular | ✅ Simplificado |
| RF-R01 | Incluía 1 foto | Solo datos + autorización | ✅ Simplificado |
| RF-R02 | Incluía 1 foto | Solo datos | ✅ Simplificado |

**Total de cambios:** 5 requerimientos simplificados

### Próximos Pasos

1. ✅ **Documentación actualizada** - HECHO
2. 📅 **Backend:** Remover validaciones de fotos en endpoints
3. 📅 **Frontend:** Remover campos de foto de formularios
4. 📅 **Tests:** Actualizar test cases sin fotos
5. 📅 **Fase 2 (Futuro):** Reactivar con mejor arquitectura

---

## 📋 Checklist de Validación

- [x] API_DOCUMENTACION_PROPIETARIOS_CUENTAS.md actualizada
- [x] MODULO_ADMINISTRACION_PROPUESTA.md actualizada
- [ ] Backend endpoints actualizados
- [ ] Frontend formularios actualizados
- [ ] Tests actualizados
- [ ] Equipo notificado

---

**Estado:** ✅ Documentación Sincronizada

---

## ✅ CAMBIO 3: API de Perfil Detecta Admin (Backend)

### Decisión
El `LoginUseCase` ahora **detecta si es admin** y retorna datos específicos:
- Admin: Solo nombre, email, rol (SIN vivienda/identificación)
- Residente/Miembro: Nombre, email, rol + vivienda + identificación

### Archivo Modificado

#### **lib/domain/usecases/login_usecase.dart**

**Lógica implementada:**

```dart
final isAdmin = account.rol?.toLowerCase() == 'admin';

// Si es admin: Retorna solo datos base
// Si es residente: Retorna datos base + vivienda + identificación
if (!isAdmin) {
  userData.addAll({
    'identificacion': account.identificacion,
    'residence': '${account.vivienda.manzana}-${account.vivienda.villa}',
    'vivienda': {...},
  });
}
```

### Datos Retornados

**Admin:** (SIN vivienda/identificación)
```json
{
  "id": "persona_id",
  "name": "Carlos Admin",
  "rol": "admin",
  "email": "admin@email.com",
  "correo": "admin@email.com",
  "fechaCreado": "2026-01-21..."
}
```

**Residente/Miembro:** (CON vivienda/identificación)
```json
{
  "id": "persona_id",
  "name": "Juan Pérez",
  "rol": "resident",
  "email": "residente@email.com",
  "identificacion": "1234567890",
  "residence": "M-01-V-001",
  "vivienda": {...},
  "fechaCreado": "2026-01-21..."
}
```

### Alineación Frontend-Backend

| Capa | Comportamiento | Status |
|------|---|---|
| **Backend (LoginUseCase)** | Detecta rol, retorna datos condicionales | ✅ |
| **Frontend (ProfilePage)** | UI condicional basada en rol | ✅ |
| **AuthBloc** | Almacena datos del LoginUseCase | ✅ |

**Compilación:** ✅ Sin errores

# 👤 ARQUITECTURA DEL PERFIL DE USUARIO

**Documento:** Especificación de datos de perfil por rol  
**Fecha:** Enero 21, 2026  
**Versión:** 1.0

---

## 📋 PRINCIPIO CLAVE

El perfil de usuario debe mostrar **solo información relevante para cada rol**. El administrador no tiene residencia ni datos de residente, por lo que su perfil es genérico.

---

## 🏛️ PERFILES POR ROL

### 1️⃣ RESIDENTE

**Ubicación:** `lib/presentation/pages/profile_page.dart`

**Información mostrada:**
```
┌─────────────────────────────────┐
│  Avatar (Inicial del nombre)    │
│  Nombre Completo                │
│  Residente                      │
├─────────────────────────────────┤
│ INFORMACIÓN PERSONAL            │
│ • Nombre Completo: [Juan Pérez] │
│ • Identificación: [1234567890]  │
├─────────────────────────────────┤
│ CORREO ELECTRÓNICO              │
│ juan.perez@email.com [Edit]     │
├─────────────────────────────────┤
│ RESIDENCIA                      │
│ Manzana M-01, Villa V-001       │
├─────────────────────────────────┤
│ ⚙️ NOTIFICACIONES       [ON/OFF] │
│ [Cerrar Sesión]                 │
└─────────────────────────────────┘
```

**Campos visibles:**
- ✅ Nombre Completo
- ✅ Identificación
- ✅ Correo Electrónico (editable)
- ✅ Residencia (manzana, villa)
- ✅ Toggle notificaciones
- ✅ Botón cerrar sesión

---

### 2️⃣ MIEMBRO DE FAMILIA

**Ubicación:** `lib/presentation/pages/profile_page.dart`

**Información mostrada:**
```
┌─────────────────────────────────┐
│  Avatar (Inicial del nombre)    │
│  Nombre Completo                │
│  Miembro de Familia             │
├─────────────────────────────────┤
│ INFORMACIÓN PERSONAL            │
│ • Nombre Completo: [María Pérez]│
│ • Identificación: [0987654321]  │
├─────────────────────────────────┤
│ CORREO ELECTRÓNICO              │
│ maria.perez@email.com [Edit]    │
├─────────────────────────────────┤
│ RESIDENCIA                      │
│ Manzana M-01, Villa V-001       │
├─────────────────────────────────┤
│ ⚙️ NOTIFICACIONES       [ON/OFF] │
│ [Cerrar Sesión]                 │
└─────────────────────────────────┘
```

**Campos visibles:**
- ✅ Nombre Completo
- ✅ Identificación
- ✅ Correo Electrónico (editable)
- ✅ Residencia (manzana, villa)
- ✅ Toggle notificaciones
- ✅ Botón cerrar sesión

---

### 3️⃣ ADMINISTRADOR ⭐ (NUEVO)

**Ubicación:** `lib/presentation/pages/profile_page.dart`

**Información mostrada:**
```
┌─────────────────────────────────┐
│  Avatar (Inicial del nombre)    │
│  Nombre Completo                │
│  Administrador                  │
├─────────────────────────────────┤
│ INFORMACIÓN DE ADMINISTRACIÓN   │
│ • Función: Administración       │
│ • Rol: Administrador            │
├─────────────────────────────────┤
│ CORREO ELECTRÓNICO              │
│ admin@email.com [Edit]          │
├─────────────────────────────────┤
│ ⚙️ NOTIFICACIONES       [ON/OFF] │
│ [Cerrar Sesión]                 │
└─────────────────────────────────┘
```

**Campos visibles:**
- ✅ Nombre Completo
- ✅ Correo Electrónico (editable)
- ❌ Identificación (NO MOSTRADA)
- ❌ Residencia (NO MOSTRADA - no tiene)
- ✅ Función: "Administración"
- ✅ Rol: "Administrador"
- ✅ Toggle notificaciones
- ✅ Botón cerrar sesión

**¿Por qué es diferente?**
- El admin no tiene residencia asociada
- El admin no tiene datos de residente/miembro
- Solo gestiona la plataforma
- Información puramente administrativo-funcional

---

## 🔧 IMPLEMENTACIÓN EN CÓDIGO

### Cambios en `profile_page.dart`

#### 1. Función auxiliar para detectar admin:
```dart
bool _isAdmin(String? role) {
  return role?.toLowerCase() == 'admin' || 
         role?.toLowerCase() == 'administrador';
}
```

#### 2. Lógica condicional en build():
```dart
final isAdmin = _isAdmin(role);

// ... en el body

// Personal info card - Only for non-admin users
if (!isAdmin)
  Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Información Personal'),
          _infoRow(Icons.person, 'Nombre Completo', name),
          _infoRow(Icons.badge_outlined, 'Identificación', widget.identificacion),
        ],
      ),
    ),
  )
else
  Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Información de Administración'),
          _infoRow(Icons.admin_panel_settings, 'Función', 'Administración'),
          _infoRow(Icons.security, 'Rol', _roleName(role)),
        ],
      ),
    ),
  ),

// Residence card - Only for non-admin users
if (!isAdmin)
  Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: _infoRow(Icons.home_work_outlined, 'Residencia', residence),
    ),
  ),
```

---

## 📊 COMPARATIVA DE PERFILES

| Campo | Residente | Miembro | Admin |
|-------|-----------|--------|-------|
| Avatar + Nombre | ✅ | ✅ | ✅ |
| Rol (badge) | ✅ | ✅ | ✅ |
| **SECCIÓN PERSONAL** | | | |
| Nombre Completo | ✅ | ✅ | ❌ |
| Identificación | ✅ | ✅ | ❌ |
| **SECCIÓN ADMIN** | | | |
| Función | ❌ | ❌ | ✅ |
| Rol detallado | ❌ | ❌ | ✅ |
| **CONTACTO** | | | |
| Correo (editable) | ✅ | ✅ | ✅ |
| **UBICACIÓN** | | | |
| Residencia | ✅ | ✅ | ❌ |
| **PREFERENCIAS** | | | |
| Notificaciones | ✅ | ✅ | ✅ |
| Cerrar Sesión | ✅ | ✅ | ✅ |

---

## 🎨 ICONOGRAFÍA POR ROL

### Residente
```
👤 = Icons.person
🏠 = Icons.home_work_outlined
📧 = Icons.email_outlined
```

### Miembro de Familia
```
👥 = Icons.person (mismo)
🏠 = Icons.home_work_outlined (mismo)
📧 = Icons.email_outlined (mismo)
```

### Administrador
```
⚙️ = Icons.admin_panel_settings
🔐 = Icons.security
📧 = Icons.email_outlined
```

---

## 🔐 SEGURIDAD

✅ **Principio:**
- Los datos mostrados corresponden exactamente a la información que el usuario necesita
- No se exponen datos innecesarios
- Admin no ve datos de residencia (no tiene)
- Residente/Miembro no ven datos administrativos

✅ **Implementación:**
- Validación en frontend (UI condicional)
- Validación en backend (endpoint retorna solo datos permitidos)
- AuthBloc siempre es source of truth para determinar rol

---

## 📝 CAMBIOS REALIZADOS

**Archivo modificado:** `lib/presentation/pages/profile_page.dart`

**Cambios:**
1. ✅ Agregada función `_isAdmin(String? role)`
2. ✅ Agregada variable `isAdmin` en build()
3. ✅ Renderizado condicional de tarjeta "Información Personal" vs "Información de Administración"
4. ✅ Ocultamiento de tarjeta "Residencia" para admins
5. ✅ Iconografía específica para admin

**Estado:** ✅ Implementado

---

## 🚀 PRÓXIMOS PASOS

1. ✅ Frontend Profile Page - HECHO
2. 📅 Backend: Endpoint GET /profile retorna datos específicos por rol
3. 📅 Testing: Validar que admin no ve datos de residencia
4. 📅 Testing: Validar que residente no ve datos de admin

---

**Versión:** 1.0  
**Fecha:** 21 Enero 2026  
**Estado:** ✅ Documentado e Implementado

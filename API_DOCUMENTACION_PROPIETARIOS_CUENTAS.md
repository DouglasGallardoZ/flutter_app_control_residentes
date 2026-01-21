# 📱 ACTUALIZACIÓN API DOCUMENTACIÓN - ÉNFASIS EN PROPIETARIOS Y CUENTAS

**Documento:** Complemento de API Documentation  
**Enfoque:** Gestión de Propietarios y Control de Cuentas  
**Fecha:** Enero 2026  
**Versión:** 1.1  

---

## 📌 RESUMEN EJECUTIVO

Esta actualización enfatiza dos módulos críticos:
1. **Gestión de Propietarios** - RF-P01 a RF-P05 (5 requerimientos)
2. **Control de Cuentas** - RF-C05 a RF-C09 (5 requerimientos)

Total: **10 endpoints principales** + variantes para operaciones cascada

---

## 🏠 MÓDULO 1: GESTIÓN DE PROPIETARIOS

### Prefijo: `/api/v1/admin/propietarios`

#### 1️⃣ Crear Propietario (RF-P01)

**POST** `/admin/propietarios`

**Headers:**
```http
Authorization: Bearer {admin_token}
Content-Type: multipart/form-data
```

**Request Body:**
```json
{
  "identificacion": "1234567890",
  "nacionalidad": "Ecuador",
  "nombres": "Juan",
  "apellidos": "Pérez García",
  "fecha_nacimiento": "1980-05-15",
  "correo": "juan.perez@email.com",
  "celular": "0987654321",
  "manzana": "M-01",
  "villa": "V-001",
  "direccion_alternativa": "Calle Principal 123",
  "documento_propiedad": <file>,           // File: PDF
  "estado": "activo"
}
```

**Validaciones:**
```dart
✅ Identificación válida (RFC para Ecuador o internacional)
✅ Nacionalidad en lista predefinida
✅ Nombres y apellidos no vacíos (mínimo 3 caracteres)
✅ Fecha de nacimiento: mayor de 18 años, no futura
✅ Correo electrónico válido
✅ Celular ecuatoriano: 09XXXXXXXX (9 dígitos)
✅ Manzana y Villa existen en BD
✅ Solo 1 propietario ACTIVO por vivienda
✅ Documento de propiedad: PDF no vacío, máx 10MB
```

**Response 201 Created:**
```json
{
  "propietario_id": "prop_12345",
  "identificacion": "1234567890",
  "nombres": "Juan",
  "apellidos": "Pérez García",
  "vivienda": {
    "manzana": "M-01",
    "villa": "V-001",
    "direccion": "Manzana M-01, Villa V-001"
  },
  "estado": "activo",
  "fecha_creacion": "2026-01-21T10:30:00Z",
  "creado_por": "admin_user_id",
  "mensaje": "Propietario registrado correctamente"
}
```

**Response 400 Bad Request:**
```json
{
  "error": "VALIDACION_FALLIDA",
  "detalles": [
    {
      "campo": "celular",
      "mensaje": "Celular debe tener formato 09XXXXXXXX"
    },
    {
      "campo": "vivienda",
      "mensaje": "Esta vivienda ya tiene un propietario activo"
    }
  ]
}
```

**Response 422 Unprocessable Entity:**
```json
{
  "error": "PROPIETARIO_YA_EXISTE",
  "mensaje": "La identificación 1234567890 ya está registrada",
  "propietario_id": "prop_existing"
}
```

---

#### 2️⃣ Registrar Cónyuge (RF-P02)

**POST** `/admin/propietarios/{propietario_id}/conyuges`

**Headers:**
```http
Authorization: Bearer {admin_token}
Content-Type: multipart/form-data
```

**Request Body:**
```json
{
  "identificacion": "0987654321",
  "nombres": "María",
  "apellidos": "González López",
  "fecha_nacimiento": "1982-08-20",
  "correo": "maria.gonzalez@email.com",
  "celular": "0912345678",
  "estado": "activo"
}
```

**Validaciones:**
```dart
✅ Propietario exista y esté ACTIVO
✅ No existe cónyuge previo para este propietario
✅ Identificación única (no duplicada con propietario)
✅ Celular válido
✅ Manzana y Villa deben coincidir con propietario
```

**Response 201 Created:**
```json
{
  "conyugue_id": "conj_67890",
  "propietario_id": "prop_12345",
  "identificacion": "0987654321",
  "nombres": "María González López",
  "estado": "activo",
  "tipo": "miembro",
  "fecha_creacion": "2026-01-21T10:35:00Z",
  "mensaje": "Cónyuge registrado correctamente"
}
```

---

#### 3️⃣ Actualizar Propietario (RF-P03)

**PUT** `/admin/propietarios/{propietario_id}`

**Headers:**
```http
Authorization: Bearer {admin_token}
Content-Type: multipart/form-data
```

**Request Body:**
```json
{
  "correo": "juan.nuevo@email.com",
  "celular": "0987654322",
  "fotos_rostro": <file[]>,              // Opcional: nuevas fotos
  "direccion_alternativa": "Nueva calle 456"
}
```

**Restricciones:**
```dart
❌ NO se permite cambiar: identificación, nombres, apellidos, fechas, vivienda
✅ Solo se permite: correo, celular, fotos, dirección alternativa
```

**Response 200 OK:**
```json
{
  "propietario_id": "prop_12345",
  "identificacion": "1234567890",
  "correo": "juan.nuevo@email.com",
  "celular": "0987654322",
  "fecha_actualizacion": "2026-01-21T11:00:00Z",
  "actualizado_por": "admin_user_id",
  "mensaje": "Datos del propietario actualizados correctamente"
}
```

---

#### 4️⃣ Dar de Baja Propietario (RF-P04)

**DELETE** `/admin/propietarios/{propietario_id}`

**Headers:**
```http
Authorization: Bearer {admin_token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "motivo": "Cambio de propietario - venta de propiedad",
  "observaciones": "Nuevo propietario: Carlos López"
}
```

**Validaciones:**
```dart
✅ Propietario exista
✅ Propietario esté ACTIVO
✅ Motivo no vacío
✅ Cascada: baja también al cónyuge (si existe)
```

**Response 200 OK:**
```json
{
  "propietario_id": "prop_12345",
  "estado_anterior": "activo",
  "estado_nuevo": "inactivo",
  "fecha_baja": "2026-01-21T11:15:00Z",
  "motivo": "Cambio de propietario - venta de propiedad",
  "conyugue_baja": true,
  "mensaje": "Propietario dado de baja correctamente"
}
```

**Response 409 Conflict:**
```json
{
  "error": "PROPIETARIO_INACTIVO",
  "mensaje": "Solo se pueden dar de baja propietarios activos"
}
```

---

#### 5️⃣ Cambio de Propietario (RF-P05)

**POST** `/admin/propietarios/{propietario_id}/cambiar`

**Headers:**
```http
Authorization: Bearer {admin_token}
Content-Type: multipart/form-data
```

**Request Body (Wizard Step 1 - Confirmación):**
```json
{
  "razon_cambio": "Venta de propiedad - nuevo propietario ingresa",
  "confirmar_actuales": true
}
```

**Response:**
```json
{
  "paso": 1,
  "propietario_actual": {
    "propietario_id": "prop_12345",
    "nombres": "Juan Pérez",
    "identificacion": "1234567890"
  },
  "residente_actual": {
    "residente_id": "res_001",
    "nombres": "Juan Pérez",
    "es_mismo_propietario": true
  },
  "mensaje": "Confirmar datos actuales"
}
```

**Request Body (Wizard Step 2 - Nuevo Propietario):**
```json
{
  "paso": 2,
  "nuevo_propietario_identificacion": "9876543210",  // Si ya existe
  // O crear nuevo:
  "nuevo_propietario_data": {
    "identificacion": "9876543210",
    "nacionalidad": "Ecuador",
    "nombres": "Carlos",
    "apellidos": "López García",
    "fecha_nacimiento": "1975-03-10",
    "correo": "carlos.lopez@email.com",
    "celular": "0998765432",
    "fotos_rostro": <file[]>,
    "documento_propiedad": <file>
  }
}
```

**Response Final 200 OK:**
```json
{
  "paso": "finalizado",
  "propietario_anterior": {
    "id": "prop_12345",
    "estado": "inactivo"
  },
  "propietario_nuevo": {
    "id": "prop_new_789",
    "estado": "activo"
  },
  "residente_actualizado": {
    "id": "res_001",
    "propietario_id": "prop_new_789",
    "estado": "activo"
  },
  "cambio_registrado_en_bitacora": true,
  "fecha_cambio": "2026-01-21T11:30:00Z",
  "mensaje": "Cambio de propietario realizado correctamente"
}
```

**Validaciones Críticas:**
```dart
✅ Propietario actual ACTIVO
✅ Nuevo propietario cumple todas las validaciones RF-P01
✅ Si residente == propietario → nuevo propietario se asigna automáticamente
✅ Miembros familia NO se modifican automáticamente
✅ Genera bitácora con auditoría completa
```

---

#### 6️⃣ Listar Propietarios

**GET** `/admin/propietarios`

**Query Parameters:**
```
?estado=activo&manzana=M-01&villa=V-001&pagina=1&limite=10&busqueda=Juan
```

**Response 200 OK:**
```json
{
  "propietarios": [
    {
      "propietario_id": "prop_12345",
      "identificacion": "1234567890",
      "nombres": "Juan",
      "apellidos": "Pérez García",
      "vivienda": { "manzana": "M-01", "villa": "V-001" },
      "conyugue": {
        "conyugue_id": "conj_67890",
        "nombres": "María González López",
        "estado": "activo"
      },
      "estado": "activo",
      "fecha_creacion": "2026-01-20T09:00:00Z",
      "acciones": ["editar", "ver_detalle", "cambiar", "dar_baja"]
    }
  ],
  "paginacion": {
    "pagina": 1,
    "limite": 10,
    "total": 45,
    "total_paginas": 5,
    "tiene_siguiente": true
  }
}
```

---

## 🔐 MÓDULO 2: CONTROL DE CUENTAS

### Prefijo: `/api/v1/admin/cuentas`

#### 1️⃣ Bloquear Cuenta Individual (RF-C07)

**POST** `/admin/cuentas/{cuenta_id}/bloquear`

**Headers:**
```http
Authorization: Bearer {admin_token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "motivo": "Múltiples intentos fallidos de acceso",
  "observaciones": "Usuario reportó olvido de contraseña",
  "tipo_bloqueo": "temporal"  // temporal | permanente
}
```

**Response 200 OK:**
```json
{
  "cuenta_id": "cuenta_abc123",
  "usuario": "user@example.com",
  "tipo_usuario": "residente",
  "estado_anterior": "activo",
  "estado_nuevo": "bloqueado",
  "motivo": "Múltiples intentos fallidos de acceso",
  "fecha_bloqueo": "2026-01-21T12:00:00Z",
  "bloqueado_por": "admin_user_id",
  "mensaje": "Cuenta bloqueada correctamente"
}
```

**Response 409 Conflict:**
```json
{
  "error": "CUENTA_YA_BLOQUEADA",
  "mensaje": "La cuenta ya está bloqueada desde 2026-01-15",
  "bloqueada_desde": "2026-01-15T10:30:00Z"
}
```

---

#### 2️⃣ Bloquear Cuenta Residente + Familia (RF-C05)

**POST** `/admin/cuentas/familia/{residente_id}/bloquear`

**Headers:**
```http
Authorization: Bearer {admin_token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "motivo": "Vencimiento de contrato de residencia",
  "observaciones": "Mudanza fuera de la urbanización"
}
```

**Proceso Cascada:**
1. Obtiene residente
2. Identifica todos los miembros de familia activos
3. Bloquea cuenta del residente
4. Bloquea cuentas de TODOS los miembros de familia

**Response 200 OK:**
```json
{
  "operacion": "bloqueo_masivo_familia",
  "residente_id": "res_001",
  "usuario_residente": "juan.perez@email.com",
  "cuentas_bloqueadas": {
    "residente": {
      "cuenta_id": "cuenta_res_001",
      "estado_nuevo": "bloqueado",
      "timestamp": "2026-01-21T12:00:00Z"
    },
    "miembros_familia": [
      {
        "cuenta_id": "cuenta_mem_001",
        "usuario": "maria.perez@email.com",
        "tipo": "miembro_familia",
        "estado_nuevo": "bloqueado",
        "timestamp": "2026-01-21T12:00:01Z"
      },
      {
        "cuenta_id": "cuenta_mem_002",
        "usuario": "carlos.perez@email.com",
        "tipo": "miembro_familia",
        "estado_nuevo": "bloqueado",
        "timestamp": "2026-01-21T12:00:02Z"
      }
    ]
  },
  "total_cuentas_bloqueadas": 3,
  "motivo": "Vencimiento de contrato de residencia",
  "mensaje": "Residente y 2 miembros de familia bloqueados correctamente"
}
```

---

#### 3️⃣ Desbloquear Cuenta Individual (RF-C08)

**POST** `/admin/cuentas/{cuenta_id}/desbloquear`

**Headers:**
```http
Authorization: Bearer {admin_token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "motivo": "Usuario validó su identidad",
  "observaciones": "Presentó documento de identificación en portería"
}
```

**Response 200 OK:**
```json
{
  "cuenta_id": "cuenta_abc123",
  "usuario": "user@example.com",
  "estado_anterior": "bloqueado",
  "estado_nuevo": "activo",
  "desbloqueado_por": "admin_user_id",
  "fecha_desbloqueo": "2026-01-21T13:30:00Z",
  "mensaje": "Cuenta desbloqueada correctamente"
}
```

---

#### 4️⃣ Desbloquear Cuenta Residente + Familia (RF-C06)

**POST** `/admin/cuentas/familia/{residente_id}/desbloquear`

**Headers:**
```http
Authorization: Bearer {admin_token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "motivo": "Renovación de contrato de residencia"
}
```

**Proceso Cascada:**
1. Obtiene residente
2. Desbloquea cuenta residente
3. Desbloquea cuentas de TODOS los miembros de familia

**Response 200 OK:**
```json
{
  "operacion": "desbloqueo_masivo_familia",
  "residente_id": "res_001",
  "cuentas_desbloqueadas": {
    "residente": { "cuenta_id": "cuenta_res_001", "estado_nuevo": "activo" },
    "miembros_familia": [
      { "cuenta_id": "cuenta_mem_001", "estado_nuevo": "activo" },
      { "cuenta_id": "cuenta_mem_002", "estado_nuevo": "activo" }
    ]
  },
  "total_cuentas_desbloqueadas": 3,
  "mensaje": "Residente y 2 miembros de familia desbloqueados correctamente"
}
```

---

#### 5️⃣ Eliminar Cuenta Definitivamente (RF-C09)

**DELETE** `/admin/cuentas/{cuenta_id}`

**Headers:**
```http
Authorization: Bearer {admin_token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "motivo": "Usuario solicitó eliminación permanente de cuenta",
  "confirmar_eliminacion": true,
  "conservar_auditoria": true
}
```

**Validaciones:**
```dart
✅ Confirmación doble: confirmar_eliminacion = true
✅ Motivo obligatorio
✅ Soft Delete: cuenta marcada como eliminada, datos preservados
✅ Bitácora: se registra quién eliminó y cuándo
✅ No se puede recuperar directamente (requiere admin manual)
```

**Response 200 OK:**
```json
{
  "cuenta_id": "cuenta_abc123",
  "usuario": "user@example.com",
  "estado_anterior": "activo",
  "estado_nuevo": "eliminado",
  "tipo_eliminacion": "soft_delete",
  "data_preservada": true,
  "auditoria_preservada": true,
  "fecha_eliminacion": "2026-01-21T14:00:00Z",
  "eliminada_por": "admin_user_id",
  "motivo": "Usuario solicitó eliminación permanente de cuenta",
  "mensaje": "Cuenta eliminada correctamente (datos históricos preservados)"
}
```

**Response 400 Bad Request:**
```json
{
  "error": "ELIMINACION_NO_CONFIRMADA",
  "mensaje": "Debe confirmar la eliminación estableciendo confirmar_eliminacion = true"
}
```

---

#### 6️⃣ Listar Cuentas

**GET** `/admin/cuentas`

**Query Parameters:**
```
?estado=activo&tipo=residente&bloqueado_desde=2026-01-15&pagina=1&limite=20
```

**Response 200 OK:**
```json
{
  "cuentas": [
    {
      "cuenta_id": "cuenta_abc123",
      "usuario": "juan.perez@email.com",
      "tipo_usuario": "residente",
      "persona": {
        "persona_id": "per_001",
        "nombres": "Juan",
        "apellidos": "Pérez",
        "identificacion": "1234567890"
      },
      "estado": "activo",
      "ultimo_acceso": "2026-01-21T10:15:00Z",
      "bloqueado": false,
      "historial_bloqueos": [
        {
          "fecha": "2026-01-15T09:00:00Z",
          "accion": "bloqueado",
          "motivo": "Test"
        },
        {
          "fecha": "2026-01-15T10:00:00Z",
          "accion": "desbloqueado",
          "motivo": "Error administrativo"
        }
      ],
      "acciones": ["ver_detalle", "bloquear", "eliminar"]
    }
  ],
  "paginacion": { "pagina": 1, "limite": 20, "total": 150 }
}
```

---

#### 7️⃣ Historial de Bloqueos de Cuenta

**GET** `/admin/cuentas/{cuenta_id}/historial`

**Response 200 OK:**
```json
{
  "cuenta_id": "cuenta_abc123",
  "usuario": "juan.perez@email.com",
  "historial_completo": [
    {
      "evento_id": "evt_001",
      "fecha": "2026-01-15T09:00:00Z",
      "accion": "bloqueado",
      "motivo": "Múltiples intentos fallidos",
      "realizado_por": "admin_001",
      "tipo_bloqueo": "temporal"
    },
    {
      "evento_id": "evt_002",
      "fecha": "2026-01-15T10:00:00Z",
      "accion": "desbloqueado",
      "motivo": "Error administrativo",
      "realizado_por": "admin_002"
    },
    {
      "evento_id": "evt_003",
      "fecha": "2026-01-16T14:30:00Z",
      "accion": "acceso_exitoso",
      "ip": "192.168.1.100"
    }
  ],
  "total_eventos": 3
}
```

---

## 📊 MODELO UNIFICADO DE RESPUESTAS

### Estructura Estándar de Respuestas

**Éxito:**
```json
{
  "exito": true,
  "codigo": "OPERACION_EXITOSA",
  "datos": { /* respuesta específica */ },
  "mensaje": "Descripción amigable de qué sucedió",
  "timestamp": "2026-01-21T14:00:00Z",
  "metadata": {
    "usuario_id": "admin_001",
    "version_api": "1.1"
  }
}
```

**Error Validación:**
```json
{
  "exito": false,
  "codigo": "VALIDACION_FALLIDA",
  "errores": [
    {
      "campo": "celular",
      "mensaje": "Celular debe tener formato 09XXXXXXXX"
    }
  ],
  "mensaje": "Validación fallida en 2 campos",
  "timestamp": "2026-01-21T14:00:00Z"
}
```

**Error Autorización:**
```json
{
  "exito": false,
  "codigo": "NO_AUTORIZADO",
  "mensaje": "No tienes permisos para realizar esta acción",
  "requerido": "ADMIN",
  "timestamp": "2026-01-21T14:00:00Z"
}
```

---

## 🔐 Seguridad y Auditoría

### Auditoría Obligatoria

Cada operación en Propietarios y Cuentas DEBE registrar:

```json
{
  "bitacora_evento": {
    "evento_id": "evt_uuid",
    "timestamp": "2026-01-21T14:00:00Z",
    "usuario_id": "admin_001",
    "usuario_email": "admin@system.com",
    "tipo_entidad": "propietario|residente|cuenta",
    "entidad_id": "prop_12345",
    "accion": "crear|actualizar|eliminar|bloquear|cambiar",
    "cambios": {
      "antes": { /* valores anteriores */ },
      "despues": { /* valores nuevos */ }
    },
    "ip_origen": "192.168.1.100",
    "resultado": "exitoso|fallido",
    "motivo": "descripción por qué"
  }
}
```

### Restricciones por Rol

| Rol | Propietarios | Residentes | Cuentas | Notificaciones |
|-----|--------------|-----------|--------|---------------|
| Super Admin | ✅ Todo | ✅ Todo | ✅ Todo | ✅ Todo |
| Admin | ✅ Todo | ✅ Todo | ✅ Todo | ✅ Todo |
| Supervisor | ✅ Listar, Ver | ✅ Listar, Ver | ✅ Listar, Ver | ✅ Ver historial |
| Guardia | ❌ No | ❌ No | ✅ Ver estado | ✅ No |

---

## 📈 Métricas e Indicadores

### Dashboard Admin - KPIs

```json
{
  "propietarios": {
    "total": 125,
    "activos": 118,
    "inactivos": 7,
    "con_conyugue": 45,
    "cambios_mes": 3
  },
  "residentes": {
    "total": 320,
    "activos": 305,
    "inactivos": 15,
    "miembros_familia": 450
  },
  "cuentas": {
    "total": 750,
    "activas": 690,
    "bloqueadas": 45,
    "eliminadas": 15,
    "bloqueadas_semana": 12
  },
  "operaciones_semana": {
    "propietarios_registrados": 2,
    "residentes_registrados": 5,
    "cuentas_bloqueadas": 8,
    "cambios_propiedad": 1
  }
}
```

---

## 📝 Consideraciones Finales

✅ **Énfasis en Propietarios:**
- RFC-P01 a RFC-P05 completamente documentados
- Validaciones exhaustivas
- Flujo de cambio de propiedad con cascada automática
- Auditoría completa de cada operación

✅ **Énfasis en Cuentas:**
- RFC-C05 a RFC-C09 completamente documentados
- Bloqueo individual y masivo (cascada automática)
- Eliminación segura (soft delete)
- Historial de bloqueos/desbloqueos

✅ **Seguridad:**
- Confirmación doble para operaciones destructivas
- Auditoría inmutable
- Restricciones por rol
- Validaciones exhaustivas

✅ **Usabilidad:**
- Respuestas claras y amigables
- Mensajes de error específicos
- Estructura consistente de APIs
- Ejemplos de uso completados

---

**Documento completado:** Enero 2026  
**Versión:** 1.1  
**Estado:** Listo para implementación

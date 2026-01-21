# 📊 MÓDULO DE ADMINISTRACIÓN - PROPUESTA COMPLETA

**Documento:** Análisis y Propuesta del Módulo de Administración  
**Fecha:** Enero 2026  
**Versión:** 1.0  
**Basado en:** Requerimientos RF-C05 a RF-C09, RF-P01 a RF-P05, RF-R01 a RF-R06, RF-N01 a RF-N04

---

## 📋 ÍNDICE

1. [Visión General del Módulo](#visión-general)
2. [Análisis de Requerimientos](#análisis-de-requerimientos)
3. [Matriz de Funcionalidades](#matriz-de-funcionalidades)
4. [Arquitectura del Módulo](#arquitectura-del-módulo)
5. [Flujos Principales](#flujos-principales)
6. [Endpoints Requeridos](#endpoints-requeridos)
7. [Propuesta de Navegación](#propuesta-de-navegación)
8. [Cronograma de Implementación](#cronograma-de-implementación)

---

## 🎯 Visión General

El **Módulo de Administración** es la plataforma central desde la cual los administradores del sistema gestionan todos los aspectos de la urbanización:

- ✅ **Gestión de Propietarios:** Registro, actualización, cambios de propiedad
- ✅ **Gestión de Residentes:** Registro, desactivación, reactivación
- ✅ **Gestión de Miembros de Familia:** Registro y control
- ✅ **Control de Cuentas:** Bloqueo/desbloqueo, eliminación
- ✅ **Notificaciones:** Masivas e individuales
- ✅ **Auditoría:** Trazabilidad completa de operaciones

**Rol Objetivo:** Administrador del Sistema  
**Usuarios Objetivo:** Administrativos, Guardias de seguridad, Supervisores

---

## 🔍 Análisis de Requerimientos

### Requerimientos Funcionales Asignados al Administrador

| Código | Módulo | Descripción | Prioridad |
|--------|--------|-------------|-----------|
| **RF-P01** | Propietarios | Registro de propietario | 🔴 Alta |
| **RF-P02** | Propietarios | Registro de cónyuge | 🔴 Alta |
| **RF-P03** | Propietarios | Actualización de propietario | 🟡 Media |
| **RF-P04** | Propietarios | Baja de propietario | 🔴 Alta |
| **RF-P05** | Propietarios | Cambio de propietario | 🔴 Alta |
| **RF-R01** | Residentes | Registro de residente | 🔴 Alta |
| **RF-R02** | Residentes | Registro de miembro familia | 🔴 Alta |
| **RF-R03** | Residentes | Desactivación de residente | 🔴 Alta |
| **RF-R04** | Residentes | Desactivación de miembro | 🔴 Alta |
| **RF-R05** | Residentes | Reactivación de residente | 🟡 Media |
| **RF-R06** | Residentes | Reactivación de miembro | 🟡 Media |
| **RF-C05** | Cuentas | Bloquear cuenta residente+familia | 🔴 Alta |
| **RF-C06** | Cuentas | Desbloquear cuenta residente+familia | 🔴 Alta |
| **RF-C07** | Cuentas | Bloquear cuenta individual | 🔴 Alta |
| **RF-C08** | Cuentas | Desbloquear cuenta individual | 🔴 Alta |
| **RF-C09** | Cuentas | Eliminar cuenta definitivamente | 🔴 Alta |
| **RF-N01** | Notificaciones | Notificaciones masivas a residentes | 🟡 Media |
| **RF-N02** | Notificaciones | Notificaciones masivas a propietarios | 🟡 Media |
| **RF-N03** | Notificaciones | Notificación individual a residente | 🟡 Media |
| **RF-N04** | Notificación individual a propietario | Notificaciones | 🟡 Media |

**Total: 20 Requerimientos Funcionales**

---

## 🗂️ Matriz de Funcionalidades por Módulo

### 1️⃣ MÓDULO: Gestión de Propietarios (5 Requerimientos)

#### Panel Principal de Propietarios
```
┌─────────────────────────────────────────────────┐
│  Gestión de Propietarios                        │
├─────────────────────────────────────────────────┤
│ [Nuevo Propietario] [Buscar] [Filtros] [Excel]  │
├─────────────────────────────────────────────────┤
│ Manzana │ Villa │ Propietario │ Cónyuge │ Estado│ Acciones │
├─────────────────────────────────────────────────┤
│ M-01    │ V-001 │ Juan Pérez  │ María.. │ Activo│ [...] [+Cónyuge] │
│ M-02    │ V-010 │ Carlos L.   │ -       │ Inact │ [...] [Reactiv]  │
└─────────────────────────────────────────────────┘
```

#### Funcionalidades:

| Funcionalidad | RF | Acciones | UI Components |
|---------------|----|-----------| --------------|
| **Registrar Propietario** | RF-P01 | Crear nuevo registro con validaciones | Form modal |
| **Registrar Cónyuge** | RF-P02 | Agregar cónyuge a propietario existente | Quick action, Form embedded |
| **Actualizar Propietario** | RF-P03 | Editar email, celular | Edit form, Document upload |
| **Baja de Propietario** | RF-P04 | Desactivar propietario + cónyuge | Confirmation dialog, Motivo |
| **Cambio de Propietario** | RF-P05 | Transferir propiedad, actualizar residente | Wizard, Validaciones |

#### Campos Principales (Basado en RF-P01):
- Identificación (cédula/RUC) ✅
- Nacionalidad
- Nombres, Apellidos
- Fecha de nacimiento
- Correo electrónico
- Celular
- Manzana, Villa
- Dirección alternativa
- Documento de propiedad (PDF)
- Estado (activo/inactivo)

#### Validaciones Críticas:
- ✅ Cédula/RUC válidos para ecuatorianos
- ✅ Celular ecuatoriano: 09XXXXXXXX
- ✅ Correo electrónico válido
- ✅ Manzana y villa existen
- ✅ Solo 1 propietario activo por vivienda
- ✅ Documento de propiedad: PDF no vacío

---

### 2️⃣ MÓDULO: Gestión de Residentes (6 Requerimientos)

#### Panel Principal de Residentes
```
┌──────────────────────────────────────────────────────┐
│  Gestión de Residentes                              │
├──────────────────────────────────────────────────────┤
│ [Nuevo Residente] [Buscar] [Filtros] [Desactivados] │
├──────────────────────────────────────────────────────┤
│ ID │ Manzana │ Villa │ Residente │ Miembros │ Estado │
├──────────────────────────────────────────────────────┤
│ 1  │ M-01    │ V-001 │ J. Pérez  │ 2        │ Activo │
│ 2  │ M-02    │ V-010 │ C. López  │ 1        │ Inact  │
└──────────────────────────────────────────────────────┘
```

#### Funcionalidades:

| Funcionalidad | RF | Acciones | UI Components |
|---------------|----|-----------| --------------|
| **Registrar Residente** | RF-R01 | Crear residente con validación de autorización | Form modal, Doc. upload |
| **Registrar Miembro Familia** | RF-R02 | Agregar miembro a residente activo | Quick action, Sub-form |
| **Desactivar Residente** | RF-R03 | Desactivar residente + miembros automáticamente | Confirmation, Motivo |
| **Desactivar Miembro** | RF-R04 | Desactivar miembro específico | Individual action |
| **Reactivar Residente** | RF-R05 | Activar residente previamente desactivado | Quick action |
| **Reactivar Miembro** | RF-R06 | Activar miembro previamente desactivado | Quick action |

#### Campos Principales (Basado en RF-R01, RF-R02):

**Residente:**
- Identificación
- Nombres, Apellidos
- Fecha de nacimiento
- Correo electrónico
- Celular
- Manzana, Villa
- Autorización del propietario (PDF)
- Estado (activo)

**Miembro de Familia:**
- Identificación
- Nombres, Apellidos
- Fecha de nacimiento
- Correo electrónico
- Celular
- Relación con residente
- Estado

#### Validaciones Críticas:
- ✅ Autorización de propietario válida (PDF)
- ✅ Residente no puede estar en 2 viviendas
- ✅ Miembro debe pertenecer a misma vivienda
- ✅ Residente debe estar activo para miembros
- ✅ Desactivar residente → desactiva miembros automáticamente

---

### 3️⃣ MÓDULO: Gestión de Cuentas (5 Requerimientos)

#### Panel Principal de Cuentas
```
┌─────────────────────────────────────────────────────┐
│  Gestión de Cuentas                                 │
├─────────────────────────────────────────────────────┤
│ [Buscar] [Filtros: Bloqueadas, Activas] [Audit Log] │
├─────────────────────────────────────────────────────┤
│ Usuario │ Tipo │ Email │ Estado │ Bloques │ Acciones│
├─────────────────────────────────────────────────────┤
│ JPerez  │ Res  │ jp... │ Activo │ No      │ [...]   │
│ CLópez  │ Mem  │ cl... │ BLOQUEADO │ Sí  │ [...]   │
└─────────────────────────────────────────────────────┘
```

#### Funcionalidades:

| Funcionalidad | RF | Acción | UI Components | Cascada |
|---------------|----|---------| --------------|---------|
| **Bloquear Residente+Familia** | RF-C05 | Bloquear múltiples cuentas | Checkbox selector | ✅ Bloquea cuenta principal y miembros |
| **Desbloquear Residente+Familia** | RF-C06 | Desbloquear múltiples cuentas | Checkbox selector | ✅ Desbloquea ambas |
| **Bloquear Cuenta Individual** | RF-C07 | Bloquear 1 cuenta | Toggle / Confirmation | ✅ Solo esa cuenta |
| **Desbloquear Cuenta Individual** | RF-C08 | Desbloquear 1 cuenta | Toggle / Confirmation | ✅ Solo esa cuenta |
| **Eliminar Cuenta Definitivamente** | RF-C09 | Eliminación irreversible | Final confirmation | ⚠️ Datos históricos se conservan |

#### Estados de Cuenta:
- 🟢 **ACTIVO:** Puede acceder a la aplicación
- 🔴 **BLOQUEADO:** Intento de acceso denegado
- ⚪ **ELIMINADO:** Registro borrado (soft delete)
- 🟠 **PENDIENTE:** Esperando validación

#### Validaciones Críticas:
- ✅ No bloquear cuenta sin motivo registrado
- ✅ Bloqueo de residente → bloquea familia automáticamente
- ✅ Eliminación → soft delete, preserva auditoría
- ✅ Historial de bloqueos visible
- ✅ Confirmación doble para eliminación

---

### 4️⃣ MÓDULO: Notificaciones (4 Requerimientos)

#### Panel Principal de Notificaciones
```
┌────────────────────────────────────────────┐
│  Centro de Notificaciones                  │
├────────────────────────────────────────────┤
│ [Masivas] │ [Individuales] │ [Historial]   │
├────────────────────────────────────────────┤
│  MASIVAS A RESIDENTES                      │
│ Mensaje: [________________________]          │
│ [Seleccionar Residentes]                   │
│ [Enviar]  [Programar]  [Cancelar]         │
│                                             │
│  MASIVAS A PROPIETARIOS                    │
│ Mensaje: [________________________]          │
│ [Seleccionar Propietarios]                │
│ [Enviar]  [Programar]  [Cancelar]         │
└────────────────────────────────────────────┘
```

#### Funcionalidades:

| Funcionalidad | RF | Características | Filtros |
|---------------|----|-----------------| ---------|
| **Notificaciones Masivas Residentes** | RF-N01 | Push, Email, SMS | Por estado, manzana, villa |
| **Notificaciones Masivas Propietarios** | RF-N02 | Push, Email, SMS | Por estado, manzana, villa |
| **Notificación Individual Residente** | RF-N03 | Push, Email | Por identificación |
| **Notificación Individual Propietario** | RF-N04 | Push, Email | Por identificación |

#### Características Avanzadas:
- 📅 **Programación:** Envío en fecha/hora específica
- 📊 **Reportes:** Tasa de entrega, leída, no leída
- 🎯 **Segmentación:** Por rol, estado, ubicación
- 🔁 **Plantillas:** Mensajes predefinidos reutilizables
- 📝 **Borrador:** Guardar y editar antes de enviar
- 📋 **Historial:** Log completo de envíos

---

## 🏗️ Arquitectura del Módulo

### Estructura de Carpetas Propuesta

```
lib/
├── presentation/
│   ├── pages/
│   │   ├── admin/
│   │   │   ├── admin_dashboard_page.dart          # Panel principal
│   │   │   ├── propietarios/
│   │   │   │   ├── propietarios_list_page.dart
│   │   │   │   ├── propietario_form_page.dart
│   │   │   │   ├── propietario_detail_page.dart
│   │   │   │   └── conyugue_form_page.dart
│   │   │   ├── residentes/
│   │   │   │   ├── residentes_list_page.dart
│   │   │   │   ├── residente_form_page.dart
│   │   │   │   ├── residente_detail_page.dart
│   │   │   │   └── miembro_familia_form_page.dart
│   │   │   ├── cuentas/
│   │   │   │   ├── cuentas_list_page.dart
│   │   │   │   ├── cuenta_detail_page.dart
│   │   │   │   ├── bloquear_cuentas_page.dart
│   │   │   │   └── eliminar_cuenta_page.dart
│   │   │   └── notificaciones/
│   │   │       ├── notificaciones_page.dart
│   │   │       ├── notificacion_masiva_page.dart
│   │   │       ├── notificacion_individual_page.dart
│   │   │       └── historial_notificaciones_page.dart
│   │   └── widgets/
│   │       ├── admin_app_scaffold.dart
│   │       ├── propietario_card.dart
│   │       ├── residente_card.dart
│   │       └── cuenta_status_badge.dart
│
├── application/
│   ├── blocs/
│   │   ├── admin/
│   │   │   ├── propietario/
│   │   │   │   ├── propietario_bloc.dart
│   │   │   │   ├── propietario_event.dart
│   │   │   │   └── propietario_state.dart
│   │   │   ├── residente/
│   │   │   │   ├── residente_bloc.dart
│   │   │   │   ├── residente_event.dart
│   │   │   │   └── residente_state.dart
│   │   │   ├── cuenta/
│   │   │   │   ├── cuenta_bloc.dart
│   │   │   │   ├── cuenta_event.dart
│   │   │   │   └── cuenta_state.dart
│   │   │   └── notificacion/
│   │   │       ├── notificacion_bloc.dart
│   │   │       ├── notificacion_event.dart
│   │   │       └── notificacion_state.dart
│   │   └── admin_bloc.dart          # Coordinador general
│
├── domain/
│   ├── entities/
│   │   ├── propietario.dart
│   │   ├── residente.dart
│   │   ├── miembro_familia.dart
│   │   ├── cuenta.dart
│   │   ├── bloqueo_cuenta.dart
│   │   └── notificacion.dart
│   ├── ports/
│   │   ├── admin_repository.dart
│   │   ├── propietario_repository.dart
│   │   ├── residente_repository.dart
│   │   ├── cuenta_repository.dart
│   │   └── notificacion_repository.dart
│   └── usecases/
│       ├── propietario/
│       │   ├── registrar_propietario_usecase.dart
│       │   ├── actualizar_propietario_usecase.dart
│       │   ├── cambiar_propietario_usecase.dart
│       │   └── dar_baja_propietario_usecase.dart
│       ├── residente/
│       │   ├── registrar_residente_usecase.dart
│       │   ├── desactivar_residente_usecase.dart
│       │   └── reactivar_residente_usecase.dart
│       ├── cuenta/
│       │   ├── bloquear_cuenta_usecase.dart
│       │   ├── desbloquear_cuenta_usecase.dart
│       │   └── eliminar_cuenta_usecase.dart
│       └── notificacion/
│           ├── enviar_notificacion_masiva_usecase.dart
│           └── enviar_notificacion_individual_usecase.dart
│
└── infrastructure/
    ├── adapters/
    │   ├── admin_repository_impl.dart
    │   ├── propietario_repository_impl.dart
    │   ├── residente_repository_impl.dart
    │   ├── cuenta_repository_impl.dart
    │   └── notificacion_repository_impl.dart
    └── providers/
        ├── admin_api.dart
        ├── propietario_api.dart
        ├── residente_api.dart
        ├── cuenta_api.dart
        └── notificacion_api.dart
```

---

## 🔄 Flujos Principales

### Flujo 1: Registrar Propietario (RF-P01)

```
┌─────────────────┐
│ Administrador   │
└────────┬────────┘
         │
         ├─► [Dashboard] ─► [Propietarios] ─► [Nuevo Propietario]
         │
         ├─► Ingresa datos personales
         │   └─► Validar cédula/RUC
         │   └─► Validar celular formato 09XXXXXXXX
         │   └─► Validar correo electrónico
         │
         ├─► Selecciona Manzana y Villa
         │   └─► Validar que no exista propietario activo
         │
         ├─► Carga documento de propiedad (PDF)
         │   └─► Validar no vacío
         │
         ├─► Documenta propiedad (PDF)
         │
         ├─► Confirma registro
         │
         └─► Backend API
             ├─► POST /api/v1/propietarios
             ├─► Registra en tabla propietario_vivienda
             ├─► Crea entrada en persona
             ├─► Registra en bitácora
             └─► Retorna confirmación
```

**Endpoints necesarios:**
- `POST /api/v1/propietarios` - Crear propietario
- `POST /api/v1/propietarios/{id}/documentos` - Upload documento

---

### Flujo 2: Cambio de Propietario (RF-P05)

```
┌──────────────────────────────┐
│ Administrador                │
└──────────────┬───────────────┘
               │
               ├─► [Propietarios] ─► Selecciona vivienda ─► [Cambiar Propietario]
               │
               ├─► Sistema muestra propietario actual
               │   └─► Confirmar identidad
               │
               ├─► Ingresa razón del cambio
               │
               ├─► Ingresa datos nuevo propietario
               │   └─► Validar todas las restricciones RF-P05
               │
               ├─► Si residente == propietario actual
               │   └─► ✅ Nuevo propietario será residente automático
               │
               ├─► Confirma cambio
               │
               └─► Backend API
                   ├─► POST /api/v1/propietarios/{id}/cambiar
                   ├─► Desactiva propietario actual
                   ├─► Registra nuevo propietario
                   ├─► Actualiza relación con residente
                   ├─► Registra en bitácora
                   └─► Retorna confirmación
```

**Endpoints necesarios:**
- `POST /api/v1/propietarios/{id}/cambiar` - Cambiar propietario
- `GET /api/v1/residentes/por-vivienda` - Obtener residente de vivienda

---

### Flujo 3: Bloquear/Desbloquear Cuentas (RF-C05, RF-C06, RF-C07, RF-C08)

```
┌─────────────────────────┐
│ Administrador           │
└────────┬────────────────┘
         │
         ├─► [Cuentas] ─► Busca usuario/residente
         │
         ├─► Selecciona acción:
         │   ├─► BLOQUEAR RESIDENTE + FAMILIA (RF-C05)
         │   │   └─► Checkbox multiple selection
         │   │   └─► Backend bloquea: residente + todos sus miembros
         │   │
         │   ├─► DESBLOQUEAR RESIDENTE + FAMILIA (RF-C06)
         │   │   └─► Checkbox multiple selection
         │   │   └─► Backend desbloquea: residente + todos sus miembros
         │   │
         │   ├─► BLOQUEAR INDIVIDUAL (RF-C07)
         │   │   └─► Toggle específica
         │   │   └─► Backend bloquea solo esa cuenta
         │   │
         │   └─► DESBLOQUEAR INDIVIDUAL (RF-C08)
         │       └─► Toggle específica
         │       └─► Backend desbloquea solo esa cuenta
         │
         ├─► Ingresa motivo del bloqueo
         │
         ├─► Confirmación ("¿Estás seguro?")
         │
         └─► Backend API
             ├─► POST /api/v1/cuentas/{id}/bloquear
             ├─► POST /api/v1/cuentas/{id}/desbloquear
             ├─► Actualiza status en tabla cuenta
             ├─► Registra en bitácora con motivo
             └─► Retorna confirmación
```

**Endpoints necesarios:**
- `POST /api/v1/cuentas/{id}/bloquear` - Bloquear cuenta
- `POST /api/v1/cuentas/{id}/desbloquear` - Desbloquear cuenta
- `POST /api/v1/cuentas/familia/{id}/bloquear` - Bloquear residente+familia
- `POST /api/v1/cuentas/familia/{id}/desbloquear` - Desbloquear residente+familia

---

### Flujo 4: Enviar Notificación Masiva (RF-N01, RF-N02)

```
┌─────────────────────────┐
│ Administrador           │
└────────┬────────────────┘
         │
         ├─► [Notificaciones] ─► [Nueva Masiva]
         │
         ├─► Selecciona tipo:
         │   ├─► A RESIDENTES (RF-N01)
         │   │   └─► Filtra por: estado, manzana, villa
         │   │
         │   └─► A PROPIETARIOS (RF-N02)
         │       └─► Filtra por: estado, manzana, villa
         │
         ├─► Visualiza cuántos usuarios seleccionados
         │
         ├─► Ingresa mensaje/selecciona plantilla
         │
         ├─► Elige canales: Push, Email, SMS
         │
         ├─► Opción de programar o enviar ahora
         │   └─► Si programa: fecha/hora específica
         │
         ├─► Previsualización de notificación
         │
         ├─► Confirma envío
         │
         └─► Backend API
             ├─► POST /api/v1/notificaciones/masivas
             ├─► Crea registro en tabla notificacion
             ├─► Cola de envío a usuarios (Job Queue)
             ├─► Registra en bitácora
             └─► Retorna ID de campaña + ETA
```

**Endpoints necesarios:**
- `POST /api/v1/notificaciones/masivas` - Crear notificación masiva
- `POST /api/v1/notificaciones/individual` - Crear notificación individual
- `GET /api/v1/notificaciones/historial` - Historial de envíos
- `GET /api/v1/notificaciones/{id}/stats` - Estadísticas de campaña

---

## 📡 Endpoints Requeridos

### Base: `/api/v1/admin`

#### Propietarios
```
POST   /propietarios                      # Crear propietario (RF-P01)
GET    /propietarios                      # Listar propietarios (filtros, paginar)
GET    /propietarios/{id}                 # Detalle propietario
PUT    /propietarios/{id}                 # Actualizar propietario (RF-P03)
DELETE /propietarios/{id}                 # Baja propietario (RF-P04)
POST   /propietarios/{id}/cambiar         # Cambio de propietario (RF-P05)
POST   /propietarios/{id}/conyuges        # Registrar cónyuge (RF-P02)
PUT    /propietarios/{id}/conyuges/{cid}  # Actualizar cónyuge
DELETE /propietarios/{id}/conyuges/{cid}  # Dar de baja cónyuge
```

#### Residentes
```
POST   /residentes                        # Crear residente (RF-R01)
GET    /residentes                        # Listar residentes
GET    /residentes/{id}                   # Detalle residente
PUT    /residentes/{id}                   # Actualizar residente
POST   /residentes/{id}/desactivar        # Desactivar residente (RF-R03)
POST   /residentes/{id}/reactivar         # Reactivar residente (RF-R05)
POST   /residentes/{id}/miembros          # Crear miembro familia (RF-R02)
GET    /residentes/{id}/miembros          # Listar miembros
POST   /residentes/{rid}/miembros/{mid}/desactivar  # Desactivar miembro (RF-R04)
POST   /residentes/{rid}/miembros/{mid}/reactivar   # Reactivar miembro (RF-R06)
```

#### Cuentas
```
GET    /cuentas                           # Listar cuentas
GET    /cuentas/{id}                      # Detalle cuenta
POST   /cuentas/{id}/bloquear             # Bloquear cuenta individual (RF-C07)
POST   /cuentas/{id}/desbloquear          # Desbloquear cuenta individual (RF-C08)
POST   /cuentas/familia/{id}/bloquear     # Bloquear residente+familia (RF-C05)
POST   /cuentas/familia/{id}/desbloquear  # Desbloquear residente+familia (RF-C06)
DELETE /cuentas/{id}                      # Eliminar cuenta definitivamente (RF-C09)
GET    /cuentas/{id}/historial            # Historial de bloqueos
```

#### Notificaciones
```
POST   /notificaciones/masivas            # Crear notificación masiva (RF-N01/N02)
POST   /notificaciones/individual         # Crear notificación individual (RF-N03/N04)
GET    /notificaciones/historial          # Listar historial
GET    /notificaciones/{id}/stats         # Estadísticas de campaña
GET    /notificaciones/plantillas         # Listar plantillas predefinidas
POST   /notificaciones/plantillas         # Crear plantilla
```

#### Auditoría
```
GET    /auditoria/bitacora                # Bitácora completa
GET    /auditoria/bitacora/{entidad}      # Bitácora por entidad (propietario, residente, etc)
GET    /auditoria/usuario/{user_id}       # Acciones por usuario
```

---

## 🧭 Propuesta de Navegación

### Estructura de Navegación Admin

```
ADMIN DASHBOARD
├── 📊 DASHBOARD (Overview)
│   ├── Métricas: Total propietarios, residentes, miembros, cuentas bloqueadas
│   ├── Gráficos: Distribución por estado
│   └── Acciones rápidas
│
├── 🏠 GESTIÓN DE PROPIETARIOS
│   ├── 📋 Listado de Propietarios
│   │   ├── Búsqueda (manzana, villa, identificación, nombre)
│   │   ├── Filtros (estado, por propietario)
│   │   ├── Acciones: Ver detalle, Editar, Cambiar propietario, Baja
│   │   └── Bulk actions: Exportar a Excel
│   │
│   ├── ➕ Nuevo Propietario
│   │   └── Form: Datos personales → Vivienda → Documentos
│   │
│   ├── 👥 Cónyuges
│   │   ├── Listado de cónyuges
│   │   └── Agregar cónyuge a propietario
│   │
│   └── 🔄 Cambios de Propiedad
│       └── Historial de cambios
│
├── 👤 GESTIÓN DE RESIDENTES
│   ├── 📋 Listado de Residentes
│   │   ├── Búsqueda (vivienda, identificación, nombre)
│   │   ├── Filtros (estado, activos/inactivos)
│   │   ├── Acciones: Ver detalle, Editar, Desactivar/Reactivar
│   │   └── Bulk actions: Exportar
│   │
│   ├── ➕ Nuevo Residente
│   │   └── Form: Datos → Vivienda → Documento de autorización
│   │
│   ├── 👨‍👩‍👧 Miembros de Familia
│   │   ├── Listado de todos los miembros
│   │   ├── Búsqueda por residente/nombre
│   │   ├── Acciones: Ver detalle, Desactivar/Reactivar
│   │   └── Agregar miembro a residente
│   │
│   └── ⏸️ Inactivos
│       ├── Listado de residentes inactivos
│       └── Acciones: Reactivar
│
├── 🔐 GESTIÓN DE CUENTAS
│   ├── 📋 Listado de Cuentas
│   │   ├── Búsqueda (usuario, email, identificación)
│   │   ├── Filtros (estado: activo/bloqueado/eliminado)
│   │   ├── Acciones: Ver detalle, Bloquear, Desbloquear, Eliminar
│   │   └── Status badge: Activo (verde), Bloqueado (rojo), Eliminado (gris)
│   │
│   ├── 🔴 Bloquear Cuentas
│   │   ├── Individual: Toggle bloqueo + motivo
│   │   └── Masiva: Selector múltiple + motivo
│   │
│   ├── 🟢 Desbloquear Cuentas
│   │   ├── Individual: Toggle desbloqueo
│   │   └── Masiva: Selector múltiple
│   │
│   ├── ⚠️ Eliminar Cuenta
│   │   └── Confirmación doble + auditoría
│   │
│   └── 📊 Historial Bloqueos
│       ├── Timeline de bloqueos/desbloqueos
│       └── Motivos registrados
│
├── 📢 NOTIFICACIONES
│   ├── 📨 Crear Notificación Masiva
│   │   ├── Seleccionar destinatarios (residentes/propietarios)
│   │   ├── Filtros: estado, manzana, villa
│   │   ├── Mensaje + Canales (Push/Email/SMS)
│   │   ├── Programar o enviar inmediato
│   │   └── Previsualización
│   │
│   ├── 💬 Crear Notificación Individual
│   │   ├── Seleccionar usuario
│   │   ├── Mensaje + Canales
│   │   └── Enviar
│   │
│   ├── 📋 Historial de Notificaciones
│   │   ├── Tabla: Campaña, destinatarios, estado, fecha
│   │   └── Filtros: por rango de fechas, tipo
│   │
│   ├── 📊 Estadísticas
│   │   ├── Tasa de entrega
│   │   ├── Tasa de lectura
│   │   └─ Gráficos por canal
│   │
│   └── 📑 Plantillas
│       ├── Listado de plantillas
│       ├── Crear/Editar plantilla
│       └── Usar plantilla en campaña
│
└── 📖 AUDITORÍA Y REPORTES
    ├── 📝 Bitácora Completa
    │   ├── Listado de todas las operaciones
    │   ├── Filtros: usuario, entidad, fecha, acción
    │   └── Detalles: Quién, Qué, Cuándo, Por qué (motivo)
    │
    ├── 📊 Reportes
    │   ├── Propietarios: Total, activos, inactivos
    │   ├── Residentes: Total, distribución por manzana
    │   ├── Cuentas: Bloqueadas, activas, eliminadas
    │   └── Exportar: PDF, Excel, CSV
    │
    └── 🔍 Búsqueda de Auditoría
        ├── Por usuario
        ├── Por entidad
        └── Por fecha/período
```

---

## 📅 Cronograma de Implementación

### Fase 1: MVP (Semanas 1-2) - PRIORIDAD 🔴

**Objetivos:**
- Funcionalidades críticas de propietarios y residentes
- Gestión básica de cuentas
- Auditoría mínima

**Tasks:**
- [ ] Setup estructura de carpetas y archivos
- [ ] Crear BLoCs: PropietarioBLoC, ResidenteBLoC, CuentaBLoC
- [ ] Implementar endpoints backend para propietarios (CRUD)
- [ ] Implementar endpoints backend para residentes (CRUD)
- [ ] Crear UI: ListadoPropietarios, FormPropietario
- [ ] Crear UI: ListadoResidentes, FormResidente
- [ ] Crear UI: ListaCuentas, BloqueoCuentas
- [ ] Implementar validaciones críticas (RFC-P01 a RF-P05)
- [ ] Testing unitario de BLoCs
- [ ] Testing de integración con APIs

**Entregables:**
- ✅ CRUD completo de propietarios
- ✅ CRUD completo de residentes
- ✅ Gestión básica de cuentas (bloqueo/desbloqueo)
- ✅ Auditoría básica

---

### Fase 2: Notificaciones y Avances (Semanas 3-4) - PRIORIDAD 🟡

**Objetivos:**
- Sistema de notificaciones masivas e individuales
- Mejora de reportes
- Optimizaciones de UI/UX

**Tasks:**
- [ ] Crear NotificacionBLoC
- [ ] Implementar endpoints notificaciones (masivas/individual)
- [ ] Crear UI: CentroNotificaciones
- [ ] Implementar Job Queue para envíos programados
- [ ] Plantillas predefinidas
- [ ] Dashboard con estadísticas
- [ ] Reportes avanzados (gráficos)
- [ ] Exportación a Excel/PDF

**Entregables:**
- ✅ Sistema notificaciones completo
- ✅ Dashboard con métricas
- ✅ Reportes exportables

---

### Fase 3: Optimizaciones y Refinamiento (Semana 5+) - PRIORIDAD 🟡

**Objetivos:**
- Performance y escalabilidad
- UX mejorada
- Documentación completa

**Tasks:**
- [ ] Optimización de queries (índices BD)
- [ ] Caché local (SQLite)
- [ ] Paginación lazy loading
- [ ] Búsquedas en tiempo real (debounce)
- [ ] Dark mode para admin
- [ ] Accesibilidad (WCAG)
- [ ] Documentación técnica
- [ ] Manual de usuario
- [ ] Capacitación

**Entregables:**
- ✅ App optimizada y rápida
- ✅ Documentación completa
- ✅ Equipo capacitado

---

## 🎯 Consideraciones Finales

### Criterios de Éxito

✅ **Funcionalidad:**
- Todos los RF-C*, RF-P*, RF-R*, RF-N* implementados
- 100% cobertura de validaciones

✅ **Performance:**
- Listados cargan en < 2 segundos
- Búsquedas en < 1 segundo
- Notificaciones masivas sin bloqueo UI

✅ **Seguridad:**
- Solo admins pueden acceder
- Todas las operaciones auditadas
- Soft deletes preservan historial

✅ **UX:**
- Interfaz intuitiva
- Confirmaciones para acciones destructivas
- Feedback visual inmediato

### Riesgos y Mitigación

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|--------|-----------|
| Complejidad de validaciones | Media | Alto | Crear componentes reutilizables, testing exhaustivo |
| Performance con muchos usuarios | Media | Alto | Índices BD, caché, paginación lazy |
| Integración con Firebase Auth | Baja | Alto | Testing temprano, documentación Firebase |
| Cambios en requerimientos | Media | Medio | Comunicación frecuente con cliente |

---

## 📞 Contacto y Decisiones Pendientes

### Decisiones Necesarias del Cliente

1. **¿Notificaciones SMS?** Requiere integración con Twilio/similares
2. **¿Exportación a Excel?** Funcionalidad estándar o con templates personalizados
3. **¿Reportes avanzados?** Gráficos complejos, análisis predictivos
4. **¿Capacitación presencial?** Antes o después del MVP
5. **¿Ambiente de pruebas?** Staging server + datos de demo

### Próximas Acciones

1. Validación de propuesta con stakeholders
2. Ajustes según feedback
3. Inicio de Fase 1 MVP
4. Setup inicial de proyecto
5. Sesión de kickoff con equipo

---

**Documento preparado:** Enero 2026  
**Versión:** 1.0  
**Estado:** Propuesta en revisión

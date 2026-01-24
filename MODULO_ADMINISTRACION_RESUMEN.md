# Módulo de Administración - Resumen y Estructura

**Fecha de Documento:** Enero 24, 2026  
**Proyecto:** Sistema de Control Residencial - Urbanización Privada  
**Versión:** 1.0

---

## Tabla de Contenidos

1. [Descripción General](#descripción-general)
2. [Estructura Actual del Módulo](#estructura-actual-del-módulo)
3. [Requerimientos Funcionales por Categoría](#requerimientos-funcionales-por-categoría)
4. [Estado de Implementación](#estado-de-implementación)
5. [Tareas Pendientes Críticas](#tareas-pendientes-críticas)
6. [Recomendaciones para Continuación](#recomendaciones-para-continuación)

---

## Descripción General

El **Módulo de Administración** es la interfaz central para la gestión de propietarios, residentes, miembros de familia, cuentas de usuario y control de acceso en la urbanización privada. Es utilizado exclusivamente por el rol **Administrador del Sistema**.

### Alcance del Módulo

**Responsabilidades principales:**
- ✅ Registro y gestión de propietarios
- ✅ Registro y gestión de residentes  
- ✅ Registro y gestión de miembros de familia
- ⏳ Gestión completa de cuentas (bloqueo, desbloqueo, eliminación)
- ⏳ Historial de accesos consolidado
- ⏳ Dashboard avanzado con métricas

**Usuarios autorizados:** Administrador del Sistema (rol único)

---

## Estructura Actual del Módulo

### Rutas Disponibles

```
/adminDashboard          → Panel principal (métricas, estadísticas)
/adminAccessHistory      → Historial de accesos consolidado
/adminUsers              → Gestión de usuarios y cuentas
/adminProfile            → Perfil y configuración del administrador
/adminOwners             → Listado de propietarios
/adminCreateOwner        → Registro de nuevo propietario
/adminResidents          → Listado de residentes
/adminCreateResident     → Registro de nuevo residente
/adminMembers            → Listado de miembros de familia
/adminCreateMember       → Registro de nuevo miembro de familia
/adminAccounts           → Gestión de cuentas (bloq/desbloq)
/adminFacialEnrollment   → Captura de datos biométricos faciales
```

### Arquitectura de Archivos

```
lib/presentation/pages/
├── admin_dashboard_page.dart               (Dashboard principal)
├── admin_access_history_page.dart          (Historial consolidado)
├── admin_users_page.dart                   (Gestión de usuarios)
├── admin_profile_page.dart                 (Perfil del admin)
├── admin_owners_page.dart                  (Listado de propietarios)
├── admin_create_owner_page.dart            (Registro propietario)
├── admin_residents_page.dart               (Listado de residentes)
├── admin_create_resident_page.dart         (Registro residente)
├── admin_members_page.dart                 (Listado miembros)
├── admin_create_member_page.dart           (Registro miembro)
├── admin_accounts_page.dart                (Gestión de cuentas)
└── admin_facial_enrollment_page.dart       (Captura biométrica)
```

---

## Requerimientos Funcionales por Categoría

### 1. GESTIÓN DE PROPIETARIOS (4/5 implementados)

#### RF-P01: Registro de Propietario ✅ IMPLEMENTADO

**Estado:** Completamente funcional  
**Archivo:** `admin_create_owner_page.dart`  
**Campos:**
- Identificación (cédula/RUC)
- Nacionalidad (lista: Ecuador por defecto)
- Nombres, Apellidos
- Fecha de nacimiento (validación: mayor 18 años)
- Correo electrónico, Celular
- Manzana, Villa
- Dirección alternativa (opcional)
- Documento de propiedad (PDF)
- Fotos de rostro (mínimo 2, distintas resoluciones)
- Facial enrollment (captura biométrica)

**Flujo:**
1. Usuario ingresa datos del propietario
2. Validaciones de formato (cédula, correo, celular)
3. Validación de vivienda única por propietario activo
4. Envío de documento de propiedad
5. Captura de fotos de rostro
6. **[NUEVO]** Navegación a facial enrollment con `type: 'owner'`
7. Éxito: "Propietario registrado correctamente"

---

#### RF-P02: Registro de Cónyuge ❌ NO IMPLEMENTADO

**Estado:** Pendiente de implementación  
**Descripción:** Sistema permite registrar el cónyuge asociado a un propietario existente.

**Campos requeridos:**
- Identificación del cónyuge
- Nombres, Apellidos, Fecha de nacimiento
- Correo electrónico, Celular
- Fotos de rostro (mínimo 1)
- Manzana, Villa (deben coincidir con propietario)
- Dirección alternativa (opcional)

**Validaciones críticas:**
- Solo un cónyuge por propietario activo
- Cónyuge se registra como "miembro de familia" por defecto
- Fotos obligatorias sin obstrucciones
- Debe existir propietario activo en esa vivienda

**Tareas pendientes:**
- [ ] Crear página `admin_create_spouse_page.dart`
- [ ] Agregar opción en `/adminOwners` para registrar cónyuge
- [ ] Crear bloque de negocios y eventos
- [ ] Integrar validación de unicidad del cónyuge
- [ ] Agregar facial enrollment para cónyuge

---

#### RF-P03: Actualización de Información del Propietario ❌ PARCIALMENTE IMPLEMENTADO

**Estado:** Página listado existe, edición pendiente  
**Descripción:** Permite actualizar correo, celular y fotos de rostro de propietario existente.

**Campos editables:**
- ✅ Correo electrónico
- ✅ Celular
- ✅ Fotos de rostro (nuevas)

**Campos NO editables:**
- Identificación
- Nombres, Apellidos
- Fecha de nacimiento
- Manzana, Villa

**Tareas pendientes:**
- [ ] Agregar botón "Editar" en `/adminOwners`
- [ ] Crear flujo de edición en `admin_create_owner_page.dart`
- [ ] Modal/página para actualizar fotos de rostro
- [ ] Validación de propietario activo
- [ ] Registro en bitácora de cambios

---

#### RF-P04: Baja de Propietario ❌ PARCIALMENTE IMPLEMENTADO

**Estado:** Funcionalidad posible pero no hay interfaz clara  
**Descripción:** Desactiva propietario (estado = inactivo), registrando motivo.

**Acciones:**
- Cambiar estado propietario a inactivo
- Cambiar estado cónyuge a inactivo (si existe)
- Registrar motivo de baja
- Mantener historial (no eliminar)

**Tareas pendientes:**
- [ ] Crear diálogo de confirmación en `/adminOwners`
- [ ] Campo obligatorio: motivo de baja
- [ ] Validar propietario activo antes de desactivar
- [ ] Desactivar automáticamente cónyuge si existe
- [ ] Registro en bitácora

---

#### RF-P05: Cambio de Propietario de Vivienda ❌ NO IMPLEMENTADO

**Estado:** Pendiente de implementación - CRÍTICO

**Descripción:** Realiza cambio completo de propietario en una vivienda.

**Proceso paso a paso:**
1. Usuario ingresa Manzana y Villa
2. Sistema valida vivienda existente
3. Muestra propietario actual
4. Usuario ingresa motivo del cambio
5. Usuario ingresa datos del nuevo propietario
6. Sistema desactiva propietario anterior
7. Sistema registra/activa nuevo propietario
8. Si residente actual = propietario anterior:
   - Nuevo propietario se registra como residente automáticamente
9. Registra auditoría completa

**Validaciones críticas:**
- Una vivienda = un propietario activo
- Propietario anterior debe estar activo
- Propietario anterior queda inactivo
- Nuevo propietario cumple todas las validaciones de RF-P01
- Reasociación del residente principal obligatoria
- Miembros de familia NO se modifican automáticamente

**Tareas pendientes:**
- [ ] Crear página `admin_change_owner_page.dart`
- [ ] Agregar opción en `/adminOwners` o nuevo menú
- [ ] Flujo de múltiples pasos (wizard)
- [ ] Validación de propietario anterior activo
- [ ] Auto-registro como residente del nuevo propietario
- [ ] Registro completo en bitácora

**Relevancia:** ALTA - Operación común en urbanizaciones (ventas de viviendas)

---

### 2. GESTIÓN DE RESIDENTES (3/3 implementados)

#### RF-R01: Registro de Residente ✅ IMPLEMENTADO

**Estado:** Completamente funcional  
**Archivo:** `admin_create_resident_page.dart`  
**Campos:**
- Identificación
- Nombres, Apellidos, Fecha de nacimiento
- Correo electrónico, Celular
- Manzana, Villa
- Autorización de propietario (PDF)
- Fotos de rostro
- Facial enrollment (captura biométrica)

**Flujo actual:**
1. Usuario ingresa datos del residente
2. Validaciones (formato, vivienda única)
3. Verificación de autorización PDF
4. Captura de fotos de rostro
5. Navegación a facial enrollment con `type: null` (residente)
6. Éxito: "Residente registrado correctamente"

---

#### RF-R02: Registro de Miembro de Familia ✅ IMPLEMENTADO

**Estado:** Completamente funcional  
**Archivo:** `admin_create_member_page.dart`  
**Campos:**
- Identificación del miembro
- Identificación del residente (titular)
- Manzana, Villa
- Nombres, Apellidos, Fecha de nacimiento
- Correo electrónico, Celular
- Parentesco (dropdown): padre, madre, esposo, esposa, hijo, hija, otro
- Fotos de rostro
- Facial enrollment (captura biométrica)

**Validaciones implementadas:**
- ✅ Parentesco de 7 valores únicos
- ✅ Residente debe estar activo
- ✅ Validación de vivienda (manzana/villa)
- ✅ Datepicker para fecha de nacimiento
- ✅ Validación de unicidad de cónyuge y padres
- ✅ Descripción obligatoria para "otro"
- ✅ Facial enrollment con mensaje dinámico

**Flujo actual:**
1. Usuario busca residente titular por ID
2. Sistema valida residente activo
3. Usuario ingresa datos del miembro
4. Selecciona parentesco con validaciones
5. Si "otro": ingresa descripción
6. Captura de fotos de rostro
7. Navegación a facial enrollment con `type: 'member'`
8. Éxito: "Miembro de familia registrado correctamente"

---

#### RF-R03: Desactivación de Residente ⏳ FUNCIONALIDAD PARCIAL

**Estado:** Lógica backend disponible, interfaz no clara  
**Descripción:** Desactiva residente y todos sus miembros de familia automáticamente.

**Tareas pendientes:**
- [ ] Crear diálogo en `/adminResidents`
- [ ] Campo obligatorio: motivo de desactivación
- [ ] Confirmación visual de datos
- [ ] Auto-desactivación de miembros de familia
- [ ] Registro en bitácora

---

#### RF-R04 & RF-R05: Desactivación/Reactivación de Residente ⏳ PENDIENTE

**Tareas:**
- [ ] Implementar flujos en `/adminResidents`
- [ ] Validaciones de estado actual
- [ ] Registro de motivos
- [ ] Bitácora de auditoría

---

#### RF-R06: Reactivación de Miembro de Familia ⏳ PENDIENTE

**Tareas:**
- [ ] Crear interfaz en `/adminMembers`
- [ ] Validar que residente titular esté activo
- [ ] Cambio de estado a activo
- [ ] Registro en bitácora

---

### 3. GESTIÓN DE CUENTAS (1/9 implementados)

#### RF-C01: Crear Cuenta de Residente ❌ NO IMPLEMENTADO

**Estado:** No se encontró en interfaz administrativa  
**Descripción:** Residente crea su propia cuenta mediante facial recognition.

**Nota:** Este requerimiento es para que el RESIDENTE cree su cuenta (desde app residente), no es función del admin directamente. Sin embargo, el admin debe poder visualizar el estado de creación de cuentas.

---

#### RF-C02: Crear Cuenta de Miembro no Registrado ❌ NO IMPLEMENTADO

**Nota:** Similar a RF-C01, es función del MIEMBRO crear su propia cuenta. El admin no interviene en su creación.

---

#### RF-C05: Bloquear Cuenta (Residente y Miembros) ❌ NO IMPLEMENTADO

**Estado:** Pendiente de implementación - IMPORTANTE

**Descripción:** Admin bloquea cuenta de residente y automáticamente bloquea todos sus miembros de familia.

**Acciones:**
- Cambiar estado cuenta a inactivo
- Cambiar estado de todos los miembros asociados a inactivo
- Registrar motivo obligatorio
- Usuario bloqueado NO puede iniciar sesión

**Tareas pendientes:**
- [ ] Crear página `/adminAccounts` o agregar en `/adminUsers`
- [ ] Diálogo de confirmación
- [ ] Búsqueda por identificación
- [ ] Campo obligatorio: motivo de bloqueo
- [ ] Confirmación visual de datos
- [ ] Auto-bloqueo de miembros de familia
- [ ] Restricción de inicio de sesión
- [ ] Registro en bitácora

---

#### RF-C06: Desbloquear Cuenta (Residente y Miembros) ❌ NO IMPLEMENTADO

**Estado:** Pendiente de implementación - IMPORTANTE

**Similar a RF-C05 pero en sentido inverso:**
- Cambiar estado a activo
- Auto-desbloqueo de miembros de familia
- Motivo obligatorio
- Registro en bitácora

---

#### RF-C07: Bloquear Cuenta Individual ❌ NO IMPLEMENTADO

**Estado:** Pendiente de implementación

**Descripción:** Bloquea una sola cuenta (residente O miembro) sin afectar a otros.

**Diferencia con RF-C05:**
- RF-C05: Bloquea residente + TODOS sus miembros
- RF-C07: Bloquea solo UN usuario (residente O un miembro específico)

---

#### RF-C08: Desbloquear Cuenta Individual ❌ NO IMPLEMENTADO

**Similar a RF-C07 pero desbloquea.**

---

#### RF-C09: Eliminación Definitiva de Cuenta ❌ NO IMPLEMENTADO

**Estado:** Pendiente de implementación

**Descripción:** Elimina de forma PERMANENTE E IRREVERSIBLE una cuenta.

**Diferencia con desbloqueo:**
- Bloqueado: Se puede desbloquear (reversible)
- Eliminado: No se puede recuperar (irreversible)

**Acciones:**
- Marcar cuenta como "eliminado = true"
- Usuario eliminado NO puede iniciar sesión
- NO se puede reactivar
- Confirmación final obligatoria (Sí/No)
- Motivo obligatorio

---

### 4. HISTORIAL DE ACCESOS ⏳ PARCIALMENTE IMPLEMENTADO

#### Estado Actual

**Archivo:** `admin_access_history_page.dart`

**Funcionalidad disponible:**
- ✅ Listado de accesos
- ✅ Filtros básicos (por usuario, rango de fechas)
- ✅ Visualización de eventos de acceso

**Pendiente:**
- [ ] Historial consolidado por tipo de acceso (QR, facial, manual, etc.)
- [ ] Estadísticas de acceso por usuario/vivienda
- [ ] Exportación a reportes
- [ ] Filtros avanzados (por tipo de acceso, estado, resultado)
- [ ] Búsqueda por manzana/villa
- [ ] Visualización de intentos fallidos

---

### 5. DASHBOARD ⏳ PARCIALMENTE IMPLEMENTADO

#### Estado Actual

**Archivo:** `admin_dashboard_page.dart`

**Métricas actuales:**
- ✅ Total de propietarios activos
- ✅ Total de residentes activos
- ✅ Total de miembros de familia activos
- ✅ Total de accesos registrados hoy

**Pendiente:**
- [ ] Métricas por estatus (activos/inactivos/bloqueados)
- [ ] Gráficos de tendencias (accesos por hora)
- [ ] Alertas de seguridad
- [ ] Residentes/propietarios sin foto facial
- [ ] Cuentas bloqueadas
- [ ] Propietarios sin cónyuge (si aplica)
- [ ] Accesos denegados recientes
- [ ] Tasa de ocupación por manzana

---

## Estado de Implementación

### Matriz de Cumplimiento

| Requerimiento | Código | Estado | % Completitud |
|---|---|---|---|
| Registro de Propietario | RF-P01 | ✅ IMPLEMENTADO | 100% |
| Registro de Cónyuge | RF-P02 | ❌ NO IMPLEMENTADO | 0% |
| Actualización Propietario | RF-P03 | ⏳ PARCIAL | 30% |
| Baja de Propietario | RF-P04 | ⏳ PARCIAL | 40% |
| **Cambio de Propietario** | **RF-P05** | **❌ NO IMPLEMENTADO** | **0%** |
| Registro de Residente | RF-R01 | ✅ IMPLEMENTADO | 100% |
| Registro de Miembro | RF-R02 | ✅ IMPLEMENTADO | 100% |
| Desactivación Residente | RF-R03 | ⏳ PARCIAL | 30% |
| Desactivación Miembro | RF-R04 | ⏳ PARCIAL | 20% |
| Reactivación Residente | RF-R05 | ⏳ PARCIAL | 20% |
| Reactivación Miembro | RF-R06 | ⏳ PARCIAL | 20% |
| Crear Cuenta Residente | RF-C01 | ⚠️ RESIDENTE (no admin) | - |
| Crear Cuenta Miembro | RF-C02 | ⚠️ MIEMBRO (no admin) | - |
| Bloquear Cuenta (grupo) | RF-C05 | ❌ NO IMPLEMENTADO | 0% |
| Desbloquear Cuenta (grupo) | RF-C06 | ❌ NO IMPLEMENTADO | 0% |
| Bloquear Cuenta Individual | RF-C07 | ❌ NO IMPLEMENTADO | 0% |
| Desbloquear Cuenta Individual | RF-C08 | ❌ NO IMPLEMENTADO | 0% |
| Eliminar Cuenta | RF-C09 | ❌ NO IMPLEMENTADO | 0% |
| Historial de Accesos | - | ⏳ PARCIAL | 60% |
| Dashboard | - | ⏳ PARCIAL | 50% |

---

## Tareas Pendientes Críticas

### Prioridad 1: CRÍTICO (Bloquea otros módulos)

#### 1. **Cambio de Propietario de Vivienda (RF-P05)** 🔴

**Impacto:** Alto - Operación fundamental en urbanización (ventas/traspasos)

**Tareas:**
1. Crear página `admin_change_owner_page.dart`
   - Búsqueda de vivienda (manzana/villa)
   - Visualización de propietario actual
   - Ingreso de motivo del cambio
   - Formulario de nuevo propietario (igual a RF-P01)
   - Confirmación de cambio
   
2. Agregar opción en `/adminOwners`
   - Botón "Cambiar Propietario" por vivienda
   - Validación de propietario activo

3. Implementar lógica de negocio:
   - Desactivar propietario anterior
   - Registrar nuevo propietario
   - Si residente = propietario anterior: auto-registrar como residente
   - Actualizar relación vivienda-propietario
   - Registro completo en bitácora

4. Testing:
   - Caso: Cambio exitoso
   - Caso: Propietario anterior inactivo (error)
   - Caso: Residente se convierte automáticamente

---

#### 2. **Gestión de Bloqueo/Desbloqueo de Cuentas (RF-C05, C06, C07, C08)** 🔴

**Impacto:** Alto - Control de acceso crítico

**Subtareas:**

**A. Interfaz `/adminAccounts` mejorada**
   - Búsqueda por identificación/nombre
   - Filtros: (Todos | Activos | Inactivos | Bloqueados)
   - Listado con estado actual de cuenta
   - Acciones rápidas: Bloquear | Desbloquear | Eliminar

**B. Implementar RF-C05 (Bloquear grupo)**
   - Búsqueda de residente
   - Confirmación visual de datos
   - Campo obligatorio: motivo
   - Auto-bloqueo de todos los miembros
   - Restricción de login inmediata
   - Bitácora

**C. Implementar RF-C06 (Desbloquear grupo)**
   - Búsqueda de residente inactivo
   - Confirmación visual
   - Campo obligatorio: motivo
   - Auto-desbloqueo de miembros
   - Permiso de login restaurado
   - Bitácora

**D. Implementar RF-C07 (Bloquear individual)**
   - Similar a RF-C05 pero bloquea solo UN usuario
   - No afecta a otros miembros

**E. Implementar RF-C08 (Desbloquear individual)**
   - Similar a RF-C06 pero desbloquea solo UN usuario

**F. Implementar RF-C09 (Eliminar cuenta)**
   - Búsqueda del usuario
   - Confirmación visual
   - Advertencia: "Esta acción es PERMANENTE"
   - Campo obligatorio: motivo
   - Confirmación final (Sí/No)
   - Marcar como eliminado
   - Prevenir login
   - Bitácora

---

### Prioridad 2: IMPORTANTE (Mejora funcionalidad)

#### 3. **Registro de Cónyuge (RF-P02)** 🟡

**Tareas:**
1. Crear página `admin_create_spouse_page.dart`
2. Agregar opción "Registrar Cónyuge" en `/adminOwners` (después del registro del propietario)
3. Validación: solo un cónyuge por propietario activo
4. Fotos de rostro obligatorias
5. Facial enrollment automático
6. Registro en bitácora

---

#### 4. **Completar Actualización de Propietario (RF-P03)** 🟡

**Tareas:**
1. Agregar botón "Editar" en `/adminOwners`
2. Modal/página de edición para:
   - Correo electrónico
   - Celular
   - Fotos de rostro (reemplazar)
3. Validaciones de formato
4. Registro de cambios en bitácora
5. Confirmación de cambio exitoso

---

### Prioridad 3: MEJORA (Optimización)

#### 5. **Dashboard Avanzado** 🟢

**Enhancements:**
- Gráficos de accesos por hora/día
- Métricas de estado (activos/inactivos/bloqueados)
- Alertas de seguridad (múltiples intentos fallidos)
- Residentes sin foto facial
- Cuentas bloqueadas pendientes de revisión
- Topología de ocupación (residentes por manzana)

---

#### 6. **Historial de Accesos Avanzado** 🟢

**Enhancements:**
- Filtros por tipo de acceso (QR, facial, manual)
- Búsqueda por manzana/villa
- Estadísticas por usuario
- Intentos fallidos
- Exportación a CSV/PDF
- Gráficos de tendencias

---

#### 7. **Desactivación/Reactivación de Residentes y Miembros** 🟢

**Tareas:**
1. RF-R03 (Desactivación Residente): crear interfaz en `/adminResidents`
2. RF-R04 (Desactivación Miembro): crear interfaz en `/adminMembers`
3. RF-R05 (Reactivación Residente): agregar opción en `/adminResidents`
4. RF-R06 (Reactivación Miembro): agregar opción en `/adminMembers`
5. Todas con: confirmación, motivo obligatorio, bitácora

---

## Recomendaciones para Continuación

### 1. Orden Recomendado de Implementación

**Fase 1 (Semanas 1-2):** Críticas
```
1. RF-P05 (Cambio de propietario)
2. RF-C05, C06, C07, C08, C09 (Gestión de cuentas)
```

**Fase 2 (Semanas 3-4):** Importantes
```
3. RF-P02 (Registro de cónyuge)
4. RF-P03 (Actualización propietario)
```

**Fase 3 (Semana 5):** Mejoras
```
5. Dashboard avanzado
6. Historial avanzado
7. Desactivación/reactivación
```

---

### 2. Dependencias de Requerimientos

```
RF-P05 (Cambio propietario)
  ├── Requiere: RF-P01 (Registro propietario)
  ├── Requiere: RF-P04 (Baja propietario)
  └── Afecta: RF-R01 (Residente se convierte automáticamente)

RF-C05 & C06 (Bloquear/Desbloquear grupo)
  ├── Requiere: Cuentas existentes
  ├── Afecta: Inicio de sesión
  └── Requiere: Validación en AuthBloc

RF-P02 (Cónyuge)
  ├── Requiere: RF-P01 (Propietario registrado)
  └── Afecta: Conteo de personas por vivienda
```

---

### 3. Checklist de Desarrollo

Para cada requerimiento implementar:

- [ ] Página/Widget principal (StatefulWidget)
- [ ] Evento/Estado para BLoC
- [ ] Adaptador de API (si aplica)
- [ ] Validaciones de formato (CV-*)
- [ ] Diálogos de confirmación
- [ ] Manejo de errores
- [ ] Mensajes de éxito/error al usuario
- [ ] Registro en bitácora/auditoría
- [ ] Unit tests
- [ ] Widget tests
- [ ] Documentación de flujo

---

### 4. Notas Técnicas Importantes

**Facial Enrollment:**
- ✅ Integrado en registro de propietarios, residentes y miembros
- ✅ Mensajes dinámicos basados en tipo
- ✅ Navegación post-registro funcional
- Pendiente: Facial en actualización de propietario

**Datepicker:**
- ✅ Implementado en fechas de nacimiento
- ✅ Validación: mayor 18 años
- ✅ Formato: YYYY-MM-DD

**Parentesco:**
- ✅ 7 valores únicos: padre, madre, esposo, esposa, hijo, hija, otro
- ✅ Validación de unicidad (solo 1 esposo/a, 1 padre, 1 madre)
- ✅ Descripción obligatoria para "otro"

**Bitácora de Auditoría:**
- Todas las operaciones CRUD deben registrar:
  - Fecha y hora
  - Usuario administrador
  - Tipo de operación
  - ID del registro modificado
  - Valores anterior y nuevo (para ediciones)
  - Motivo (si aplica)

---

### 5. Validaciones Transversales (CV-*)

Aplicar según corresponda:

- **CV-05:** Validación de correo electrónico
- **CV-06:** Validación de celular ecuatoriano (09XXXXXXXX)
- **CV-07:** Validación de identificación válida
- **CV-10:** Validación de campos obligatorios
- **CV-14:** Confirmación visual de datos antes de acción
- **CV-27:** Advertencia: cuenta ya inactiva
- **CV-28:** Visualizar datos antes de bloquear
- **CV-29:** Restricción de login si cuenta bloqueada
- **CV-31:** Restricción de funcionalidades privadas si cuenta bloqueada
- **CV-32:** Validación de cuenta bloqueada como referencia

---

### 6. Testing Recomendado

**Para RF-P05 (Cambio de propietario):**
```dart
test('Cambio exitoso de propietario', () async {
  // Arrancar con vivienda X con propietario A
  // Cambiar a propietario B
  // Validar: Propietario A = inactivo
  //          Propietario B = activo en vivienda X
  //          Residente = asociado a propietario B
});

test('Cambio con residente convertido automáticamente', () async {
  // Arrancar: Vivienda X, Propietario A = Residente A
  // Cambiar a Propietario B
  // Validar: Propietario B registrado como residente automáticamente
});
```

**Para RF-C05 (Bloquear grupo):**
```dart
test('Bloqueo de residente bloquea automáticamente miembros', () async {
  // Arrancar: Residente + 2 miembros de familia activos
  // Bloquear residente con motivo
  // Validar: Residente = bloqueado
  //          Miembro 1 = bloqueado
  //          Miembro 2 = bloqueado
  //          No pueden iniciar sesión
});
```

---

## Métricas de Progreso

### Estado Actual (Enero 24, 2026)

- **Requerimientos implementados:** 3/30 (10%)
- **Requerimientos parcialmente implementados:** 6/30 (20%)
- **Requerimientos pendientes:** 21/30 (70%)

### Estimación de Esfuerzo

| Tarea | Horas | Prioridad |
|---|---|---|
| RF-P05 (Cambio propietario) | 12-16 | CRÍTICO |
| RF-C05,C06,C07,C08,C09 (Cuentas) | 16-20 | CRÍTICO |
| RF-P02 (Cónyuge) | 8-10 | IMPORTANTE |
| RF-P03 (Actualización) | 6-8 | IMPORTANTE |
| Dashboard avanzado | 8-10 | MEJORA |
| Historial avanzado | 6-8 | MEJORA |
| Desactivación/Reactivación | 10-12 | MEJORA |
| **TOTAL** | **66-84 horas** | **~2-3 semanas** |

---

## Conclusión

El módulo de administración tiene una base sólida con las funcionalidades de registro implementadas. Las **tareas críticas pendientes** son:

1. **Cambio de propietario de vivienda** (RF-P05)
2. **Gestión completa de bloqueo/desbloqueo de cuentas** (RF-C05-C09)

Estas dos áreas desbloquearán el resto de la funcionalidad administrativa. Una vez completadas, la aplicación tendrá un sistema de administración robusto y completo.

---

**Documento preparado para continuación del desarrollo**  
**Próxima revisión:** Después de completar Fase 1

# Diagrama de Flujos - Módulo de Administración

**Documento:** Visualización de flujos de datos y procesos  
**Última actualización:** Enero 24, 2026

---

## 1. Flujo General del Módulo

```
┌─────────────────────────────────────────────────────────────┐
│                    MÓDULO ADMINISTRACIÓN                    │
│                                                              │
│  Administrador del Sistema                                  │
│         ▼                                                    │
│    /adminDashboard  ◄─── Entrada Principal                 │
│         │                                                    │
│    ┌────┴────┬─────────┬──────────┬─────────────┐           │
│    ▼         ▼         ▼          ▼             ▼           │
│  Propietarios Residentes Miembros Cuentas Historia Perfil  │
│    │         │         │          │             │          │
│    │    ┌────┴─────────┴──┐       │             │          │
│    │    ▼                 ▼       ▼             ▼          │
│  CREAR REGISTRO  EDITAR BLOQUEAR CONSULTAR CONFIGURAR      │
│    │              │       │       │             │          │
│    └──────────┬───┴───────┴───────┴─────────────┘          │
│               ▼                                             │
│        FACIAL ENROLLMENT (post-operación)                   │
│               ▼                                             │
│      Éxito → Bitácora de Auditoría                          │
│               ▼                                             │
│        Base de Datos + Log de Eventos                       │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. Flujo: Registro de Propietario (RF-P01) ✅

```
USUARIO ADMIN                         SISTEMA
   │                                     │
   ├─ Navega a /adminCreateOwner ──────►│
   │                                     │
   │                      ┌──────────────┤
   │                      │              │
   │◄─ Formulario con ────┤  Mostrar:   │
   │   campos             │  - Manzana  │
   │                      │  - Villa    │
   │                      │  - Foto 1   │
   │                      │  - Foto 2   │
   │                      │  - Más...   │
   │                      └──────────────┤
   │                                     │
   ├─ Ingresa datos ──────────────────► │
   │                                     │ Validar identificación (CV-07)
   │                                     │ Validar correo (CV-05)
   │                                     │ Validar celular (CV-06)
   │                                     │ ¿Vivienda única? (CV-14)
   │                                     │ ¿Fotos OK? (distintas resoluciones)
   │                                     │
   ├─ Click "Guardar" ────────────────► │
   │                                     │
   │                      ┌──────────────┤
   │                      │ SI ERRORES:  │
   │◄─ Mensaje error ─────┤ Mostrar CV-* │
   │   Ej: "Cédula       │              │
   │   inválida"          └──────────────┤
   │                                     │
   │   [VUELVE AL FORMULARIO]            │
   │                                     │
   │   SI VÁLIDO:                        │
   │                                     │
   │                    ┌────────────────┤
   │                    │ Enviar a API:  │
   │                    │ POST /owners   │
   │                    └────────────────┤
   │                                     │
   │                    ┌────────────────┤
   │                    │ Crear en BD:   │
   │                    │ INSERT owner   │
   │                    │ Fecha/Hora = now()
   │                    │ Estado = ACTIVO
   │                    │ Tipo = RESIDENTE (default)
   │                    └────────────────┤
   │                                     │
   │◄─ Navega a /adminFacialEnrollment ─┤
   │   con {                             │
   │     personaId: 123                  │
   │     nombres: "Juan"                 │
   │     apellidos: "Pérez"              │
   │     type: "owner"                   │
   │   }                                 │
   │                                     │
   ├─ Captura fotos faciales ──────────►│
   │   (reconocimiento en vivo)          │
   │                                     │ enrollFacialData() API
   │                                     │ Guardar features en BD
   │                                     │
   ├─ Click "Finalizar" ──────────────► │
   │                                     │
   │◄─ SnackBar: "Propietario           │
   │   registrado correctamente" ────────┤
   │                                     │ BITÁCORA:
   │                                     │ - timestamp
   │                                     │ - admin_id
   │                                     │ - operation: CREATE_OWNER
   │                                     │ - owner_id: 123
   │                                     │ - datos completos
   │                                     │ - estado: SUCCESS
   │                                     │
   ├─ Navega a /adminOwners ──────────► │
   │   (auto-refresh de listado)         │
   │                                     │
   └─────────────────────────────────────┘
```

---

## 3. Flujo: Registro de Miembro de Familia (RF-R02) ✅

```
USUARIO ADMIN                         SISTEMA
   │                                     │
   ├─ Navega a /adminCreateMember ────► │
   │                                     │
   ├─ Ingresa Residente ID ────────────►│
   │                                     │ Búsqueda en BD
   │                                     │ ¿Existe?
   │                                     │ ¿Está activo?
   │                                     │ ¿Manzana/Villa coinciden?
   │                                     │
   │◄─ Muestra "Residente encontrado" ──┤
   │   (nombre, datos básicos)           │
   │                                     │
   ├─ Selecciona Parentesco ──────────► │ Validación:
   │   (padre, madre, esposo,            │ - ¿Solo 1 esposo/a? ✓
   │    esposa, hijo, hija, otro)        │ - ¿Solo 1 padre? ✓
   │                                     │ - ¿Solo 1 madre? ✓
   │                                     │ - ¿Múltiples hijos OK? ✓
   │                                     │
   ├─ Si "otro" → Ingresa descripción ─►│
   │                                     │
   ├─ Llena datos (nombres,             │
   │    apellidos, fecha nacimiento,     │
   │    email, celular, fotos) ─────────►│ Validar formato (CV-*)
   │                                     │
   ├─ Ingresa manzana/villa ──────────► │ ¿Coincide con residente?
   │                                     │
   ├─ Click "Guardar" ────────────────► │ POST /members
   │                                     │ INSERT member
   │                                     │
   │◄─ Navega a /adminFacialEnrollment ─┤
   │   con type: "member"                │
   │                                     │
   ├─ Captura rostro ──────────────────►│
   │                                     │
   │◄─ Mensaje: "Miembro de familia     │
   │   registrado correctamente" ────────┤ (nota: mensaje dinámico)
   │                                     │
   ├─ Navega a /adminMembers ──────────►│
   │                                     │
   └─────────────────────────────────────┘
```

---

## 4. Flujo: Cambio de Propietario (RF-P05) ❌ PENDIENTE

```
USUARIO ADMIN                         SISTEMA
   │                                     │
   ├─ Navega a /adminChangeOwner ──────►│
   │                                     │
   │  PASO 1: Búsqueda de Vivienda       │
   ├─ Ingresa Manzana ────────────────► │
   ├─ Ingresa Villa ──────────────────► │
   │                                     │ Validar vivienda existe
   │◄─ Muestra propietario actual ──────┤
   │   (Datos: Juan Pérez, Cédula,      │
   │    Email, Celular)                  │
   │                                     │
   │  PASO 2: Motivo del Cambio         │
   ├─ Ingresa motivo ─────────────────► │ Campo obligatorio (CV-10)
   │   (Ej: "Venta de propiedad")        │
   │                                     │
   │  PASO 3: Datos del Nuevo Propietario
   ├─ Llena formulario ───────────────► │ Igual a RF-P01
   │   (mismos campos que propietario)   │
   │                                     │
   │  PASO 4: Confirmación               │
   │                    ┌────────────────┤
   │                    │ Mostrar resumen:│
   │◄─ Diálogo de ──────┤ - Vivienda     │
   │   confirmación      │ - Prop. Anterior
   │                    │ - Prop. Nuevo  │
   │                    │ - Motivo       │
   │                    └────────────────┤
   │                                     │
   ├─ Click "Confirmar" ──────────────► │
   │                                     │
   │                    ┌────────────────┤
   │                    │ TRANSACCIÓN:   │
   │                    │                │
   │                    │ 1. Marcar      │
   │                    │    prop. anterior
   │                    │    como INACTIVO
   │                    │                │
   │                    │ 2. Registrar   │
   │                    │    nuevo prop. │
   │                    │    (igual RF-P01)
   │                    │                │
   │                    │ 3. ¿Residente  │
   │                    │    era prop.   │
   │                    │    anterior?   │
   │                    │    SÍ →        │
   │                    │    Registrar   │
   │                    │    nuevo prop. │
   │                    │    como        │
   │                    │    RESIDENTE   │
   │                    │    automático  │
   │                    │                │
   │                    │ 4. Actualizar  │
   │                    │    relación    │
   │                    │    vivienda    │
   │                    └────────────────┤
   │                                     │
   │◄─ Navega a /adminFacialEnrollment ─┤
   │   (facial del nuevo propietario)    │
   │                                     │
   │◄─ Mensaje: "Propietario registrado ┤
   │   correctamente" / "Nuevo           │
   │   propietario asignado como         │
   │   residente de la vivienda"         │
   │                                     │
   ├─ Navega a /adminOwners ──────────► │
   │                                     │
   └─────────────────────────────────────┘
```

---

## 5. Flujo: Bloquear Cuenta (RF-C05) ❌ PENDIENTE

```
USUARIO ADMIN                         SISTEMA
   │                                     │
   ├─ Navega a /adminAccounts ────────► │
   │  (opción: "Bloquear Cuenta")        │
   │                                     │
   ├─ Búsqueda por identificación ─────►│
   │                                     │ Validar cédula (CV-07)
   │                                     │ Buscar en BD
   │                                     │
   │◄─ Muestra datos de cuenta ────────┤
   │   (Tipo: RESIDENTE)                 │
   │   Nombres, Apellidos, Email,        │
   │   Miembros asociados: 3             │
   │                                     │
   ├─ Ingresa motivo de bloqueo ──────► │ Campo obligatorio (CV-10)
   │   (Ej: "Comportamiento             │
   │    inapropiado en acceso")          │
   │                                     │
   ├─ Click "Bloquear" ───────────────► │
   │                                     │
   │                    ┌────────────────┤
   │                    │ Diálogo de     │
   │◄─ Confirmación: ───┤ confirmación:  │
   │   "Se bloquearán    │ CV-28 (datos) │
   │    3 miembros de    │ CV-14 (confirmar)
   │    familia también" │                │
   │                    │ "¿Deseas       │
   │                    │  continuar?"   │
   │                    └────────────────┤
   │                                     │
   ├─ Click "Sí, bloquear" ───────────► │
   │                                     │
   │                    ┌────────────────┤
   │                    │ TRANSACCIÓN:   │
   │                    │                │
   │                    │ 1. Actualizar  │
   │                    │    residente:  │
   │                    │    status=BLOCKED
   │                    │                │
   │                    │ 2. Actualizar  │
   │                    │    3 miembros: │
   │                    │    status=BLOCKED
   │                    │                │
   │                    │ 3. Bitácora:   │
   │                    │    BLOCK_ACCOUNT│
   │                    │    residente_id│
   │                    │    members: 3  │
   │                    │    reason      │
   │                    │                │
   │                    │ 4. AuthBloc:   │
   │                    │    Invalidar   │
   │                    │    sesiones    │
   │                    │    activas     │
   │                    └────────────────┤
   │                                     │
   │◄─ SnackBar: "Cuentas bloqueadas" ──┤
   │   correctamente" + "3 miembros      │
   │   de familia también bloqueados"    │
   │                                     │
   ├─ Navega a /adminAccounts ────────► │
   │  (actualiza listado)                │
   │                                     │
   │                    ┌────────────────┤
   │                    │ AuthBloc:      │
   │                    │ Si estos       │
   │                    │ usuarios       │
   │                    │ intentan       │
   │                    │ login →        │
   │                    │ Error: Cuenta  │
   │                    │ bloqueada      │
   │                    └────────────────┤
   │                                     │
   └─────────────────────────────────────┘
```

---

## 6. Flujo: Eliminar Cuenta (RF-C09) ❌ PENDIENTE

```
USUARIO ADMIN                         SISTEMA
   │                                     │
   ├─ Navega a /adminAccounts ────────► │
   │  (opción: "Eliminar Cuenta")        │
   │                                     │
   ├─ Búsqueda por identificación ─────►│
   │                                     │
   │◄─ Muestra datos ──────────────────┤
   │                                     │
   │  ADVERTENCIA CRÍTICA:               │
   │  ⚠️ "Esta acción es PERMANENTE     │
   │     e IRREVERSIBLE                  │
   │     La cuenta NO podrá              │
   │     ser recuperada"                 │
   │                                     │
   ├─ Ingresa motivo ─────────────────► │ Campo obligatorio
   │                                     │
   ├─ Click "Proceder a Eliminación" ───►│
   │                                     │
   │                    ┌────────────────┤
   │                    │ Diálogo:       │
   │◄─ Solicita ───────┤ CV-14 (datos) │
   │   confirmación     │ CV-28 (visual) │
   │   final            │                │
   │                    │ "Escribir      │
   │   (Escribir        │  ELIMINAR para │
   │    ELIMINAR para   │  confirmar"    │
   │    confirmar)      │                │
   │                    └────────────────┤
   │                                     │
   ├─ Escribe "ELIMINAR" ──────────────►│
   │                                     │
   ├─ Click "Eliminar Permanentemente"──►│
   │                                     │
   │                    ┌────────────────┤
   │                    │ TRANSACCIÓN:   │
   │                    │                │
   │                    │ 1. Marcar:     │
   │                    │    deleted = TRUE
   │                    │                │
   │                    │ 2. Bitácora:   │
   │                    │    DELETE_ACCOUNT
   │                    │    persona_id  │
   │                    │    reason      │
   │                    │                │
   │                    │ 3. AuthBloc:   │
   │                    │    Rechazar    │
   │                    │    login:      │
   │                    │    "Cuenta no  │
   │                    │     existe"    │
   │                    │                │
   │                    │ 4. Validar:    │
   │                    │    No pueden:  │
   │                    │    - Reactivar │
   │                    │    - Desbloquear
   │                    │    - Usar como │
   │                    │      referencia│
   │                    └────────────────┤
   │                                     │
   │◄─ SnackBar: "Cuenta eliminada      │
   │   permanentemente" ────────────────┤
   │                                     │
   │                    ┌────────────────┤
   │                    │ IMPORTANTE:    │
   │                    │ Datos históricos│
   │                    │ se preservan   │
   │                    │ en auditoría   │
   │                    │ para referencia│
   │                    └────────────────┤
   │                                     │
   ├─ Navega a /adminAccounts ────────► │
   │                                     │
   └─────────────────────────────────────┘
```

---

## 7. Estructura de Estados en BLoC

```
OwnerState (raíz)
├── OwnerInitial                 (estado inicial)
├── OwnerLoading                 (cargando)
├── OwnerCreated                 (creación exitosa)
│   ├── message: String
│   └── owner: Map
├── OwnerUpdated                 (actualización exitosa)
│   ├── message: String
│   └── owner: Map
├── OwnerListed                  (listado obtenido)
│   └── owners: List<Map>
├── OwnerError                   (error general)
│   └── message: String
└── OwnerNotFound                (no encontrado)
    └── message: String

AccountState (raíz)                [NUEVO - crear]
├── AccountInitial
├── AccountLoading
├── AccountFound
├── AccountNotFound
├── AccountBlocked
├── AccountUnblocked
├── AccountDeleted
├── AccountError
└── ... (más según operación)
```

---

## 8. Navegación Post-Registro

```
Operación              Navegación Post-Registro
─────────────────────────────────────────────────────
Crear propietario      → /adminFacialEnrollment (type: owner)
Crear residente        → /adminFacialEnrollment (type: null)
Crear miembro          → /adminFacialEnrollment (type: member)
Crear cónyuge          → /adminFacialEnrollment (type: spouse) [FUTURO]
Cambiar propietario    → /adminFacialEnrollment (type: owner)
─────────────────────────────────────────────────────

Después de facial enrollment:
Todos → /adminXXX (listado relevante)
```

---

## 9. Ciclo de Vida de Datos

```
CREAR PROPIETARIO:
┌──────────────────────────────────────────────────┐
│ Formulario → Validación → API → BD → Facial → BD │
│              (CV-*)      POST  INSERT  SCAN    INSERT
│                                              features
└──────────────────────────────────────────────────┘
                        ▼
              Bitácora de Auditoría
              ├── timestamp
              ├── admin_id
              ├── owner_id
              ├── operación: CREATE
              └── status: SUCCESS

ACTUALIZAR PROPIETARIO:
┌─────────────────────────────────┐
│ Formulario → Validación → API → BD │
│              (CV-*)      PATCH UPDATE
└─────────────────────────────────┘
        ▼
  Bitácora
  ├── old_value: {email: old@email.com}
  ├── new_value: {email: new@email.com}
  └── ...

BLOQUEAR CUENTA:
┌────────────────────────────────────┐
│ Búsqueda → Confirmación → API → BD │
│           (CV-28)        PATCH UPDATE
│                          (residente)
│                          UPDATE
│                          (miembros)
└────────────────────────────────────┘
        ▼
  Bitácora
  ├── operación: BLOCK_ACCOUNT
  ├── target: RESIDENTE
  ├── affected_members: 3
  └── ...
```

---

## 10. Validaciones en Paralelo

```
Al ingresar Identificación:
┌─────────────────────────────────────────┐
│ Ingreso → CV-07 (formato) → Búsqueda BD │
│          (sync)              (async)    │
│          ↓                    ↓         │
│          Mostrar error         Mostrar  │
│          si formato            datos   │
│          inválido              si      │
│                                existe  │
└─────────────────────────────────────────┘

Al ingresar Email:
┌──────────────────────────────────────┐
│ Ingreso → CV-05 (regex) → Validación │
│          (sync)         (async)      │
│                                      │
│          Mostrar error si             │
│          no coincide con patrón       │
└──────────────────────────────────────┘

Al ingresar Celular:
┌──────────────────────────────────────────────────┐
│ Ingreso → CV-06 (formato) → Validar Ecuador (09) │
│          (sync)             (sync)               │
│          ↓                                        │
│          Mostrar error si no es 09XXXXXXXX       │
└──────────────────────────────────────────────────┘
```

---

**Diagrama completado. Usar como referencia visual durante desarrollo.**

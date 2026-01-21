# Gestión de Usuarios - Documentación Completa

## 📋 Descripción General

Se ha implementado un sistema completo de gestión de usuarios en el panel de administración con las siguientes características:

- **Gestión de Residentes**: Administrar residentes del complejo
- **Gestión de Propietarios**: Administrar propietarios y sus propiedades
- **Gestión de Miembros**: Administrar miembros de familia vinculados
- **Gestión de Cuentas**: Administrar cuentas de usuario del sistema

---

## 🏗️ Arquitectura Implementada

### Patrón Hexagonal
Todas las nuevas páginas siguen la arquitectura hexagonal del proyecto:
- **Domain Layer**: Entidades y puertos (ya existentes)
- **Application Layer**: BLoCs y Use Cases (reutilización de AdminDashboardBloc)
- **Infrastructure Layer**: Adapters y Providers (AdminApi existente)
- **Presentation Layer**: Pages, Widgets y Routes

### Componentes Principales

#### 1. **AdminUsersPage** (`/adminUsers`)
- **Tipo**: Hub/Contenedor
- **Función**: Punto de acceso central para todas las opciones de gestión de usuarios
- **Características**:
  - Tarjetas informativas con contadores
  - Navegación a sub-páginas
  - Estado administrado por AdminDashboardBloc
  - Uso de AdminScaffold para navegación consistente

#### 2. **AdminResidentsPage** (`/adminResidents`)
- **Tipo**: Página de gestión de residentes
- **Características**:
  - Búsqueda y filtrado por nombre/villa
  - Visualización de datos: nombre, sección, villa, email, teléfono
  - Acciones: Ver detalles, Bloquear/Desbloquear, Eliminar
  - Modal bottom sheet para detalles completos
  - Chips de estado

#### 3. **AdminOwnersPage** (`/adminOwners`)
- **Tipo**: Página de gestión de propietarios
- **Características**:
  - Búsqueda por nombre o email
  - Visualización: nombre, email, cantidad de propiedades
  - Acciones: Ver detalles, Ver propiedades, Bloquear/Desbloquear, Eliminar
  - Modal para visualizar propiedades vinculadas
  - Información completa del propietario

#### 4. **AdminMembersPage** (`/adminMembers`)
- **Tipo**: Página de gestión de miembros de familia
- **Características**:
  - Búsqueda por nombre o familia principal
  - Visualización: nombre, relación familiar, familia, ubicación
  - Acciones: Ver detalles, Bloquear/Desbloquear, Eliminar
  - Información completa del miembro (relación, email, fecha de registro)

#### 5. **AdminAccountsPage** (`/adminAccounts`)
- **Tipo**: Página de gestión de cuentas de usuario
- **Características**:
  - Búsqueda avanzada: nombre, email, Firebase UID
  - Filtros por estado: Todos, Activo, Bloqueado
  - Información: tipo de cuenta, email, UID, estado de verificación
  - Acciones: Ver detalles, Restablecer contraseña, Bloquear/Desbloquear, Eliminar
  - Chips informativos: estado de verificación, intentos de login

---

## 🎨 Diseño Visual

### Componentes Reutilizables

#### **_ResidentCard**
```dart
- Muestra información de residente en lista
- Avatar con color según estado
- Subtítulo con ubicación
- Menú de acciones
```

#### **_OwnerCard**
```dart
- Muestra información de propietario
- Avatar con icono de negocio
- Información de propiedades
- Menú de acciones expandido
```

#### **_MemberCard**
```dart
- Muestra información de miembro
- Avatar con color distintivo
- Relación familiar y ubicación
- Menú de acciones
```

#### **_AccountCard**
```dart
- Muestra información de cuenta
- Avatar con icono de usuario
- Email y tipo de cuenta
- Chips de estado (bloqueado, email no verificado)
```

#### **_DetailItem**
```dart
- Componente para mostrar pares clave-valor
- Soporta colores personalizados
- Usado en modales de detalles
```

### Paleta de Colores

| Elemento | Color | Uso |
|----------|-------|-----|
| Residentes | Azul | Cards, avatares, badges |
| Propietarios | Púrpura | Cards, avatares, badges |
| Miembros | Rosa | Cards, avatares, badges |
| Cuentas | Naranja | Cards, avatares, badges |
| Bloqueado | Rojo | Estado negativo |
| Activo | Verde | Estado positivo |
| Atención | Naranja | Estado neutral |

---

## 🔄 Flujo de Navegación

```
AdminScaffold (Navigation principal)
    ↓
AdminDashboard (0) ←→ AccessHistory (1) ←→ Users Hub (2) ←→ AdminProfile (3)
                                                    ↓
                    ┌───────────────────────────────┼───────────────────────────────┐
                    ↓                               ↓                               ↓
            AdminResidentsPage          AdminOwnersPage                  AdminMembersPage
                                                    ↓
                                            AdminAccountsPage
```

### Navegación Detail-to-Detail
- Cada página mantiene argumentos (personaId, identificacion)
- Al navegar a otras secciones usa `pushNamedAndRemoveUntil` para evitar stack innecesarios
- Tab selection automáticamente navega a la página correcta

---

## 📊 Funcionalidades Principales

### Búsqueda y Filtrado

#### AdminResidentsPage
```dart
- Búsqueda por: Nombre, Villa/Sección
- En tiempo real (onChange)
- Limpieza automática
```

#### AdminOwnersPage
```dart
- Búsqueda por: Nombre, Email
- En tiempo real (onChange)
```

#### AdminMembersPage
```dart
- Búsqueda por: Nombre, Familia principal
- En tiempo real (onChange)
```

#### AdminAccountsPage
```dart
- Búsqueda por: Nombre, Email, Firebase UID
- Filtros adicionales: Estado (Todos/Activo/Bloqueado)
- Combina búsqueda con filtros
```

### Operaciones CRUD

#### **CREATE** (Parcial)
- Las páginas muestran estructura para agregar nuevos registros (future implementation)
- FAB o botones de "Agregar" no implementados aún

#### **READ**
- Listado completo de usuarios/residentes/propietarios
- Búsqueda y filtrado
- Detalles expandidos en modal

#### **UPDATE**
- Bloquear/Desbloquear cuentas
- Restablecer contraseña (AdminAccountsPage)
- Edición básica de estado

#### **DELETE**
- Eliminación con confirmación
- Actualiza estado local inmediatamente
- SnackBar de confirmación

---

## 💾 Estructura de Datos

### ResidentData
```dart
final int id;
final String name;
final String section;
final String villa;
final String email;
final String phone;
bool isBlocked;
final String joinDate;
```

### OwnerData
```dart
final int id;
final String name;
final String email;
final String phone;
final int properties;
final String registrationDate;
bool isBlocked;
```

### MemberData
```dart
final int id;
final String name;
final String relationship;  // Relación familiar
final String parentName;    // Familia principal
final String section;
final String villa;
final String email;
final String joinDate;
bool isBlocked;
```

### AccountData
```dart
final int id;
final String firebaseUid;
final String name;
final String email;
final String type;  // Residente, Propietario, Miembro
final String createdDate;
final String lastLogin;
bool isBlocked;
int loginAttempts;
final bool emailVerified;
```

---

## 🔐 Acciones y Diálogos

### Diálogos Implementados

#### **Bloquear/Desbloquear**
- Confirmación de acción
- Toggle de estado isBlocked
- Reset de intentos de login si se desbloquea

#### **Eliminar**
- Confirmación de acción irreversible
- Actualización de lista
- Snackbar de confirmación

#### **Ver Detalles**
- Modal bottom sheet
- Información completa del usuario
- Botones de acción desde el modal

#### **Restablecer Contraseña** (AdminAccountsPage)
- Confirmación de envío
- Snackbar de confirmación
- Simula envío de email

#### **Ver Propiedades** (AdminOwnersPage)
- Modal bottom sheet
- Lista de propiedades del propietario
- Información: ubicación, estado, residentes

---

## 🚀 Integración con Backend

### Endpoints Disponibles (AdminApi)

```dart
// Residentes
getResidents() → List<ResidentData>

// Propietarios
getOwners() → List<OwnerData>

// Miembros
getFamilyMembers() → List<MemberData>

// Gestión de Cuentas
blockAccount(accountId) → void
unblockAccount(accountId) → void
deleteAccount(accountId) → void
getAccountDetails(firebaseUid) → AccountData
```

### Implementación Actual
- Datos mockeados localmente (para demostración)
- Ready para conectar con endpoints reales
- Estructura lista para inyección de AdminRepository

---

## 🎯 Próximos Pasos

### Corto Plazo
1. [ ] Conectar con endpoints reales del backend
2. [ ] Implementar paginación en listas grandes
3. [ ] Agregar animaciones de transición entre páginas
4. [ ] Implementar acciones en lote (multi-select)

### Mediano Plazo
1. [ ] Implementar CREATE (agregar nuevos usuarios)
2. [ ] Agregar auditoria de cambios
3. [ ] Exportar datos a CSV/PDF
4. [ ] Agregar gráficas de estadísticas por usuario

### Largo Plazo
1. [ ] Roles y permisos granulares
2. [ ] Historial de cambios por usuario
3. [ ] Sistema de notificaciones
4. [ ] Dashboard de administración avanzado

---

## 📁 Estructura de Archivos

```
lib/presentation/
├── pages/
│   ├── admin_users_page.dart          ← Hub principal
│   ├── admin_residents_page.dart      ← Gestión de residentes
│   ├── admin_owners_page.dart         ← Gestión de propietarios
│   ├── admin_members_page.dart        ← Gestión de miembros
│   └── admin_accounts_page.dart       ← Gestión de cuentas
├── routes/
│   └── app_routes.dart                ← Rutas actualizadas
└── widgets/
    └── admin_scaffold.dart            ← Scaffold reutilizado
```

---

## ✅ Checklist de Validación

- [x] Todas las páginas compilan sin errores
- [x] Arquitectura hexagonal mantenida
- [x] Estilo visual consistente
- [x] Navegación funcionando correctamente
- [x] BLoCs reutilizados apropiadamente
- [x] AdminScaffold integrando nuevas rutas
- [x] Búsqueda y filtrado implementado
- [x] Diálogos de confirmación funcionando
- [x] Datos estructurados correctamente
- [x] Componentes reutilizables creados
- [x] Rutas registradas en app_routes.dart

---

## 📝 Notas de Implementación

1. **State Management**: Se reutiliza AdminDashboardBloc para cargar datos iniciales
2. **Navegación**: Consistente con AdminScaffold
3. **Diseño**: Sigue Material Design 3 con colores temáticos
4. **Datos**: Estructuras de datos locales para demostración
5. **Escalabilidad**: Preparado para integración con repositorios reales
6. **Performance**: Listas virtualizadas con ListView.builder
7. **UX**: Confirmaciones en diálogos antes de acciones críticas

---

## 🔗 Referencias

- [AdminDashboardBloc](../../application/blocs/admin/)
- [AdminScaffold](../widgets/admin_scaffold.dart)
- [AdminApi](../../infrastructure/providers/admin_api.dart)
- [AppRoutes](../routes/app_routes.dart)

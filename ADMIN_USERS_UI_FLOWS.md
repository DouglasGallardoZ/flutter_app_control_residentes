# Sistema de Gestión de Usuarios - Guía Visual

## 🎯 Arquitectura General

```
┌─────────────────────────────────────────────────────────────────┐
│                      ADMIN SCAFFOLD (NavBar)                    │
│   [Dashboard] [Accesos] [Usuarios] [Perfil]                    │
└────────────────────┬────────────────────────────────────────────┘
                     │
        ┌────────────┴────────────┐
        │   ADMIN USERS PAGE      │
        │   (Hub/Contenedor)      │
        └────────────┬────────────┘
                     │
        ┌────────────┴──────────────────────┬──────────────────────┐
        │                                   │                      │
    ┌───▼─────┐              ┌──────▼──┐  ┌───▼──────┐      ┌──────▼─────┐
    │Residentes│              │Propietarios│  │Miembros│      │ Cuentas │
    │ (125)    │              │ (42)       │  │ (89)   │      │ (256)   │
    └───┬─────┘              └──────┬──┘  └───┬──────┘      └──────┬─────┘
        │                           │         │                    │
        │ Listado                   │         │                    │
        │ Búsqueda                  │         │                    │
        │ Filtrado                  │         │                    │
        │ Detalles                  │         │                    │
        │ Bloquear/Desbl.           │         │                    │
        │ Eliminar                  │         │ Restablecer Pass   │
        │                           │         │ Verificar Email    │
        └───────────────────────────┴─────────┴────────────────────┘
```

---

## 📱 Flujos de Pantalla

### Flujo 1: Gestión de Residentes

```
AdminUsersPage (Hub)
        │
        ├─ Click "Gestión de Residentes"
        │
        ▼
AdminResidentsPage
        │
        ├─ Búsqueda: "María"
        │
        ├─ Listado filtrado
        │  ├─ María Rodríguez (Manzana A - Villa 101)
        │  │  └─ PopupMenu: [Ver detalles] [Bloquear] [Eliminar]
        │  │     │
        │  │     ├─ Ver detalles
        │  │     │  ▼
        │  │     │  Modal Bottom Sheet
        │  │     │  ├─ Nombre, Ubicación, Email, Teléfono
        │  │     │  ├─ Fecha de registro
        │  │     │  ├─ Estado (Activo/Bloqueado)
        │  │     │  └─ Acciones: [Bloquear] [Eliminar]
        │  │     │
        │  │     ├─ Bloquear
        │  │     │  ▼
        │  │     │  Confirmar en diálogo
        │  │     │  ▼
        │  │     │  isBlocked = true
        │  │     │  ▼
        │  │     │  Chip "Bloqueado" en card
        │  │     │
        │  │     └─ Eliminar
        │  │        ▼
        │  │        Confirmar en diálogo
        │  │        ▼
        │  │        Remover de lista
        │  │        ▼
        │  │        SnackBar confirmación
```

### Flujo 2: Gestión de Propietarios

```
AdminUsersPage (Hub)
        │
        ├─ Click "Gestión de Propietarios"
        │
        ▼
AdminOwnersPage
        │
        ├─ Búsqueda: "carlos"
        │
        ├─ Listado filtrado
        │  ├─ Carlos López (3 propiedades)
        │  │  └─ PopupMenu: [Ver detalles] [Ver propiedades] [Bloquear] [Eliminar]
        │  │     │
        │  │     ├─ Ver detalles
        │  │     │  ▼
        │  │     │  Modal Bottom Sheet
        │  │     │  ├─ Nombre, Email, Teléfono
        │  │     │  ├─ Cantidad de propiedades
        │  │     │  ├─ Fecha de registro
        │  │     │  ├─ Estado
        │  │     │  └─ Acciones: [Ver Propiedades] [Bloquear] [Eliminar]
        │  │     │
        │  │     └─ Ver propiedades
        │  │        ▼
        │  │        Modal Bottom Sheet
        │  │        ├─ Manzana A - Villa 101 (2 residentes)
        │  │        ├─ Manzana B - Villa 210 (1 residente)
        │  │        └─ Manzana C - Villa 305 (3 residentes)
```

### Flujo 3: Gestión de Cuentas

```
AdminUsersPage (Hub)
        │
        ├─ Click "Gestión de Cuentas"
        │
        ▼
AdminAccountsPage
        │
        ├─ Filtro: Estado = "Todos"
        ├─ Búsqueda: "maria"
        │
        ├─ Listado filtrado
        │  ├─ María Rodríguez (maria@example.com)
        │  │  ├─ Tipo: Residente
        │  │  ├─ Estado: Activo
        │  │  ├─ Email verificado: ✓
        │  │  └─ PopupMenu:
        │  │     ├─ Ver detalles
        │  │     │  ▼
        │  │     │  Modal completo
        │  │     │  ├─ UID Firebase
        │  │     │  ├─ Email verificado
        │  │     │  ├─ Intentos de login
        │  │     │  ├─ Último acceso
        │  │     │  ├─ Acciones:
        │  │     │  │  ├─ [Restablecer Contraseña]
        │  │     │  │  ├─ [Bloquear]
        │  │     │  │  └─ [Eliminar Cuenta]
        │  │     │  │
        │  │     │  └─ Restablecer Contraseña
        │  │     │     ▼
        │  │     │     Enviar email
        │  │     │     ▼
        │  │     │     SnackBar "Enlace enviado"
```

---

## 🔄 Ciclo de Vida de Datos

### ResidentData Flow

```
1. CARGAR
   BLoC: LoadAdminMetrics
   └─ AdminApi.getResidents()
      └─ ResidentData[] (local mock)
      
2. MOSTRAR
   AdminResidentsPage
   └─ ListView.builder(filteredResidents)
      └─ _ResidentCard × N
      
3. INTERACTUAR
   a) Buscar: _searchController.text → filteredResidents
   b) Ver detalles: showModalBottomSheet(_showDetailsDialog)
   c) Bloquear: setState(() → resident.isBlocked = !resident.isBlocked)
   d) Eliminar: setState(() → _residents.remove(resident))
      
4. ACTUALIZAR
   setState() → rebuild → lista actualizada
   
5. MOSTRAR FEEDBACK
   ScaffoldMessenger.showSnackBar()
```

---

## 📊 Estructura de Componentes

```
AdminUsersPage
├─ AdminScaffold
│  ├─ AppBar: "Gestión de Usuarios"
│  ├─ BottomNavigationBar: 4 tabs
│  └─ Body: ListView
│     ├─ _UserManagementCard (Residentes)
│     ├─ _UserManagementCard (Propietarios)
│     ├─ _UserManagementCard (Miembros)
│     └─ _UserManagementCard (Cuentas)

AdminResidentsPage
├─ AdminScaffold
│  ├─ AppBar: "Gestión de Residentes"
│  ├─ Body: Column
│  │  ├─ SearchBar (TextField)
│  │  └─ ListView.builder
│  │     └─ _ResidentCard × N
│  │        ├─ Leading: CircleAvatar
│  │        ├─ Title: Nombre
│  │        ├─ Subtitle: Ubicación
│  │        ├─ Trailing: PopupMenuButton
│  │        │  ├─ Ver detalles → _showDetailsDialog()
│  │        │  ├─ Bloquear → _showBlockDialog()
│  │        │  └─ Eliminar → _showDeleteDialog()
│  │        └─ onTap: _showDetailsDialog()

_ResidentCard (Widget)
├─ CircleAvatar (color según estado)
├─ Nombre (Text)
├─ Ubicación (Text)
├─ Chip de estado (si bloqueado)
└─ PopupMenuButton

_showDetailsDialog()
└─ ModalBottomSheet
   ├─ Header con Avatar + Nombre
   ├─ _DetailItem × N
   │  └─ Row: Label | Value
   └─ Acciones: [Bloquear] [Eliminar]
```

---

## 🎨 Paleta de Colores por Sección

### Residentes (Azul)
- Avatar Background: `Colors.blue.shade200`
- Icon: `Colors.blue`
- Container Accent: `Colors.blue.shade200` (0.2 opacity)

### Propietarios (Púrpura)
- Avatar Background: `Colors.purple.shade200`
- Icon: `Colors.purple`
- Container Accent: `Colors.purple.shade200` (0.2 opacity)

### Miembros (Rosa)
- Avatar Background: `Colors.pink.shade200`
- Icon: `Colors.pink`
- Container Accent: `Colors.pink.shade200` (0.2 opacity)

### Cuentas (Naranja)
- Avatar Background: `Colors.orange.shade200`
- Icon: `Colors.orange`
- Container Accent: `Colors.orange.shade200` (0.2 opacity)

### Estados
- Activo: `Colors.green`
- Bloqueado: `Colors.red`
- Atención: `Colors.orange`

---

## 📐 Componentes Reutilizables

### _DetailItem
```dart
Row(
  Label (grey text)     |     Value (bold + optional color)
)
```
Usado en todos los modales de detalles.

### _UserManagementCard (AdminUsersPage)
```dart
Card(
  ├─ Container + Icon
  ├─ Nombre + Descripción
  ├─ Contador
  └─ Botón "Gestionar"
)
```

### Diálogos

#### _showBlockDialog
```
Title: Bloquear/Desbloquear usuario
Content: Confirmación
Actions: [Cancelar] [Aceptar]
```

#### _showDeleteDialog
```
Title: Eliminar usuario
Content: "Acción no reversible"
Actions: [Cancelar] [Eliminar (rojo)]
```

#### _showDetailsDialog
```
ModalBottomSheet(
  ├─ Avatar + Nombre
  ├─ _DetailItem × N
  └─ Acciones: [Bloquear] [Eliminar]
)
```

---

## 🚀 Flujo de Datos (State Management)

```
AdminDashboardBloc
├─ State: AdminDashboardLoaded
│  └─ AdminMetrics
│     ├─ totalAccess
│     ├─ successfulAccess
│     ├─ deniedAccess
│     ├─ visitors
│     └─ recentActivity[]
│
└─ Event: LoadAdminMetrics
   └─ Repository.getAdminMetrics()
      └─ AdminApi.getMetrics()
```

En las nuevas páginas de usuario:
```
AdminResidentsPage (Local State)
├─ List<ResidentData> _residents
├─ TextEditingController _searchController
├─ Computed: filteredResidents
│
└─ Cambios via setState()
   ├─ Búsqueda
   ├─ Bloqueo/Desbloqueo
   └─ Eliminación
```

---

## ✨ Características de UX

### Búsqueda
- En tiempo real (onChange)
- Case insensitive
- Múltiples campos de búsqueda
- Botón de limpiar si hay texto

### Confirmaciones
- Diálogos antes de acciones críticas
- SnackBars de confirmación
- Actualización visual instantánea

### Feedback Visual
- CircleAvatars con colores temáticos
- Chips para estados especiales
- Animaciones de tap en cards
- PopupMenuButton para más opciones

### Responsividad
- SingleChildScrollView en modales
- MaxLines + ellipsis en textos largos
- Padding consistente
- BorderRadius de 12dp en elementos principales

---

## 📝 Notas de Implementación

1. **Datos Locales**: Actualmente mockeados, listo para backend
2. **State Management**: Mezcla de BLoC (inicial) + setState (filtros)
3. **Navegación**: AdminScaffold para consistencia
4. **Performance**: ListView.builder para listas
5. **Accesibilidad**: Iconos + textos descriptivos
6. **Diseño**: Material Design 3 + tema personalizado

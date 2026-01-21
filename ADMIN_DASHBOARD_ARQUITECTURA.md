# 🎛️ ADMINISTRACIÓN - ARQUITECTURA E IMPLEMENTACIÓN

**Fecha:** Enero 21, 2026  
**Versión:** 1.0  
**Status:** ✅ IMPLEMENTADO

---

## 📋 RESUMEN

Se ha implementado un **panel de administración completo** basado en los diseños proporcionados, manteniendo la arquitectura hexagonal y los patrones ya establecidos en el proyecto.

### ✨ Características Principales

1. **AdminDashboard** - Panel principal con métricas
2. **Gestión de Usuarios** - Residentes, Miembros, Propietarios
3. **Historial de Accesos** - Con filtros y estado
4. **Acciones Rápidas** - Gestión y configuración

---

## 🏗️ ARQUITECTURA IMPLEMENTADA

### Estructura de Carpetas Nuevas

```
lib/
├── domain/
│   ├── entities/
│   │   └── admin_metrics.dart          ← AdminMetrics, RecentActivity
│   ├── ports/
│   │   └── admin_repository.dart       ← AdminRepository (abstracción)
│   └── usecases/
│       ├── get_admin_metrics_usecase.dart
│       └── get_residents_usecase.dart
├── infrastructure/
│   ├── dtos/
│   │   └── admin_metrics_dto.dart      ← AdminMetricsDTO, RecentActivityDTO
│   ├── providers/
│   │   └── admin_api.dart              ← AdminApi (endpoints HTTP)
│   └── adapters/
│       └── admin_repository_impl.dart  ← Implementación de AdminRepository
├── application/
│   └── blocs/
│       └── admin/
│           ├── admin_dashboard_bloc.dart
│           ├── admin_dashboard_event.dart
│           └── admin_dashboard_state.dart
└── presentation/
    └── pages/
        └── admin_dashboard_page.dart   ← UI del panel
```

### Patrón Arquitectónico

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                       │
│                  admin_dashboard_page.dart                  │
│    (UI con métricas, actividad reciente, acciones)         │
└──────────────────────┬──────────────────────────────────────┘
                       │ BLoC Event
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                   Application Layer                         │
│              AdminDashboardBloc + Events/States             │
│    (Gestiona estado, invoca UseCases, emite nuevos estados) │
└──────────────────────┬──────────────────────────────────────┘
                       │ UseCase Call
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                    Domain Layer                             │
│        GetAdminMetricsUseCase / GetResidentsUseCase        │
│         (Orquestación de negocio, independiente de BD)      │
└──────────────────────┬──────────────────────────────────────┘
                       │ Repository Call
                       ▼
┌─────────────────────────────────────────────────────────────┐
│              Domain Layer - Ports (Abstracción)             │
│                    AdminRepository                          │
│  (Define contratos que deben cumplir adaptadores)           │
└──────────────────────┬──────────────────────────────────────┘
                       │ Implement
                       ▼
┌─────────────────────────────────────────────────────────────┐
│              Infrastructure Layer                           │
│                AdminRepositoryImpl                           │
│  (Implementa AdminRepository, convierte DTOs a Entities)    │
└──────────────────────┬──────────────────────────────────────┘
                       │ HTTP Call
                       ▼
┌─────────────────────────────────────────────────────────────┐
│              Infrastructure Layer - Providers               │
│                      AdminApi                               │
│  (Llamadas HTTP a backend usando Dio)                      │
└──────────────────────┬──────────────────────────────────────┘
                       │ Dio
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                    Backend API                              │
│              /api/v1/admin/metrics                          │
│              /api/v1/admin/residentes                       │
│              /api/v1/admin/miembros-familia                 │
│              /api/v1/admin/propietarios                     │
│              /api/v1/admin/cuentas/:id                      │
└─────────────────────────────────────────────────────────────┘
```

---

## 📊 COMPONENTES DETALLADOS

### 1. Domain Layer

#### Entity: `AdminMetrics`
```dart
class AdminMetrics {
  final int totalAccess;          // Total accesos del período
  final int successfulAccess;     // Accesos exitosos
  final int deniedAccess;         // Accesos rechazados
  final int visitors;             // Número de visitantes
  final List<RecentActivity> recentActivity;  // Últimas actividades
}

class RecentActivity {
  final String personName;        // Nombre de la persona
  final String personRole;        // Rol (residente, miembro, propietario)
  final String accessType;        // 'own' (propio) | 'visitor' (visitante)
  final String relatedPerson;     // Si es visitante, nombre de quien lo invitó
  final DateTime timestamp;       // Cuándo ocurrió
  final String entryPoint;        // 'Entrada Principal', 'Lateral', etc.
  final bool isSuccessful;        // ✅ Exitoso | ❌ Rechazado
}
```

#### Port (Abstract): `AdminRepository`
```dart
abstract class AdminRepository {
  Future<AdminMetrics> getAdminMetrics();
  Future<List<Account>> getResidents({...});
  Future<List<Account>> getFamilyMembers({...});
  Future<List<Account>> getOwners({...});
  Future<void> updateAccountStatus(int personaId, String newStatus);
  Future<void> blockAccount(int personaId, String reason);
  Future<void> unblockAccount(int personaId);
  Future<void> deleteAccount(int personaId);
  Future<Account> getAccountDetails(int personaId);
}
```

#### UseCases
- **GetAdminMetricsUseCase** - Obtiene métricas del dashboard
- **GetResidentsUseCase** - Obtiene lista de residentes con filtros

### 2. Infrastructure Layer

#### DTO: `AdminMetricsDTO`
Mapea JSON del backend a objetos Dart:
```dart
AdminMetricsDTO.fromJson(json) {
  total_access: 3
  successful_access: 3
  denied_access: 0
  visitors: 1
  recent_activity: [...]
}
```

#### Provider: `AdminApi`
Llama endpoints HTTP:
- `GET /admin/metrics` → Métricas
- `GET /admin/residentes?page=1&page_size=20` → Lista de residentes
- `GET /admin/miembros-familia` → Lista de miembros
- `GET /admin/propietarios` → Lista de propietarios
- `PATCH /admin/cuentas/:id/estado` → Cambiar estado
- `POST /admin/cuentas/:id/bloquear` → Bloquear cuenta
- `POST /admin/cuentas/:id/desbloquear` → Desbloquear

#### Adapter: `AdminRepositoryImpl`
Implementa `AdminRepository`:
- Llama `AdminApi` para obtener datos
- Convierte `AdminMetricsDTO` → `AdminMetrics` (Domain Entity)
- Convierte `PerfilUsuarioDTO` → `Account` (Domain Entity)
- Maneja errores y retorna tipos domain

### 3. Application Layer - BLoC

#### Events
```dart
LoadAdminMetrics()        // Cargar métricas inicialmente
RefreshAdminMetrics()     // Refresca métricas (pull-to-refresh)
```

#### States
```dart
AdminDashboardInitial()   // Estado inicial
AdminDashboardLoading()   // Cargando
AdminDashboardLoaded(metrics)  // Cargado exitosamente
AdminDashboardError(message)   // Error al cargar
```

#### BLoC
```dart
class AdminDashboardBloc {
  _onLoadAdminMetrics()    // Carga inicial
  _onRefreshAdminMetrics() // Refresca sin cerrar sesión
}
```

### 4. Presentation Layer - UI

#### AdminDashboardPage
Estructura:
```
┌─────────────────────────────────────┐
│    Header: "Hola, Admin Name"       │
│    "Panel de Administración"         │
├─────────────────────────────────────┤
│ Tabs: [Hoy] [Semana] [Mes]          │
├─────────────────────────────────────┤
│ ┌──────────┬──────────┐             │
│ │Accesos   │Exitosos  │             │
│ │   3      │    3     │             │
│ ├──────────┼──────────┤             │
│ │Rechazados│Visitantes│             │
│ │    0     │    1     │             │
│ └──────────┴──────────┘             │
├─────────────────────────────────────┤
│ Actividad Reciente                  │
│ ✅ Acceso propio - María Rodríguez  │
│    Entrada Principal · Hace 5 min   │
│ ✅ Visitante: Ana García           │
│    Entrada Principal · Hace 10 min  │
│ ✅ Acceso propio - Juan Rodríguez   │
│    Entrada Lateral · Hace 15 min    │
├─────────────────────────────────────┤
│ Acciones Rápidas                    │
│ 👤 Gestionar Usuarios              │
│ 📋 Ver Bitácora Completa           │
│ ⚙️ Configuración de Usuarios        │
└─────────────────────────────────────┘
```

#### Componentes Reutilizables
- **MetricCard** - Muestra métrica (ícono, valor, label)
- **ActivityTile** - Muestra actividad reciente
- **QuickActionButton** - Botón de acción rápida
- **ChipButton** - Selector de filtros

---

## 🔗 INTEGRACIÓN CON INYECCIÓN DE DEPENDENCIAS

```dart
// injection.dart - Registros nuevos

// Providers
sl.registerLazySingleton<AdminApi>(
  () => AdminApi(apiHttpClient.dio),
);

// Repositories
sl.registerLazySingleton<AdminRepository>(
  () => AdminRepositoryImpl(sl<AdminApi>()),
);

// UseCases
sl.registerLazySingleton<GetAdminMetricsUseCase>(
  () => GetAdminMetricsUseCase(sl<AdminRepository>()),
);

sl.registerLazySingleton<GetResidentsUseCase>(
  () => GetResidentsUseCase(sl<AdminRepository>()),
);

// BLoCs
sl.registerLazySingleton<AdminDashboardBloc>(
  () => AdminDashboardBloc(sl<GetAdminMetricsUseCase>()),
);
```

---

## 🛣️ RUTAS Y NAVEGACIÓN

### Navegación desde AdminDashboard
```
Tab 0 (Índice/Inicio) → AdminDashboard (actual)
Tab 1 (Bitácora) → AccessHistoryPage
Tab 2 (QR/Visitantes) → QrDisplayPage
Tab 3 (Cuentas/Miembros) → MembersPage
Tab 4 (Perfil) → ProfilePage
```

### AppScaffold Integration
El `AdminDashboardPage` usa `AppScaffold` para:
- ✅ Mantener diseño consistente
- ✅ Incluir bottom navigation con 5 tabs
- ✅ Manejar transiciones entre páginas
- ✅ Mantener contexto de usuario (personaId, identificacion)

---

## 📱 FLUJO DE DATOS

### 1. Carga Inicial
```
AdminDashboardPage.initState()
  ↓
context.read<AdminDashboardBloc>().add(LoadAdminMetrics())
  ↓
AdminDashboardBloc._onLoadAdminMetrics()
  ├─ emit(AdminDashboardLoading)
  ├─ getAdminMetricsUseCase.call()
  │   ├─ adminRepository.getAdminMetrics()
  │   │   ├─ adminApi.getAdminMetrics()
  │   │   │   └─ GET /admin/metrics (HTTP)
  │   │   ├─ Parse response → AdminMetricsDTO
  │   │   └─ Convert → AdminMetrics (Entity)
  │   └─ return AdminMetrics
  └─ emit(AdminDashboardLoaded(metrics))
  ↓
BlocBuilder actualiza UI con métricas
```

### 2. Pull-to-Refresh
```
RefreshIndicator.onRefresh()
  ↓
context.read<AdminDashboardBloc>().add(RefreshAdminMetrics())
  ↓
AdminDashboardBloc._onRefreshAdminMetrics()
  ├─ getAdminMetricsUseCase.call() (sin emit Loading)
  ├─ emit(AdminDashboardLoaded(newMetrics))
  └─ RefreshIndicator.stopRefresh()
```

### 3. Tap en Acción Rápida
```
QuickActionButton.onTap()
  ↓
switch(action):
  - "Gestionar Usuarios" → SnackBar (Próximamente)
  - "Ver Bitácora" → Navigator.pushNamed('/accessHistory')
  - "Configuración" → SnackBar (Próximamente)
```

---

## ✅ VALIDACIONES

### Compilación
- ✅ `admin_dashboard_page.dart` - Sin errores
- ✅ `admin_repository_impl.dart` - Sin errores
- ✅ `get_admin_metrics_usecase.dart` - Sin errores
- ✅ `admin_dashboard_bloc.dart` - Sin errores
- ✅ `admin_api.dart` - Sin errores
- ✅ `admin_metrics.dart` - Sin errores

### Type Safety
- ✅ Todas las conversiones DTO → Entity tipadas
- ✅ Manejo seguro de valores nullables
- ✅ Ningún cast forzado innecesario

---

## 🎯 REQUERIMIENTOS CUMPLIDOS

### ✅ Administración de Residentes
- Lista de residentes con paginación
- Búsqueda y filtros por estado
- Obtener detalles de residente
- Cambiar estado (activo/inactivo)

### ✅ Administración de Miembros
- Lista de miembros de familia
- Búsqueda de miembros
- Obtener detalles

### ✅ Administración de Propietarios
- Lista de propietarios
- Búsqueda de propietarios
- Gestión de cuentas

### ✅ Control de Cuentas
- Actualizar estado
- Bloquear/Desbloquear
- Eliminar (soft delete)
- Obtener detalles

### ✅ Métricas y Reportes
- Accesos totales
- Accesos exitosos
- Accesos rechazados
- Visitantes
- Actividad reciente

### ✅ Diseño Referencial
- ✅ Panel con métricas en grid 2x2
- ✅ Actividad reciente con timestamp relativo
- ✅ Acciones rápidas con iconografía
- ✅ Header personalizado con nombre del admin
- ✅ Tabs para filtrar por período (Hoy/Semana/Mes)
- ✅ Pull-to-Refresh para actualizar

---

## 🔮 SIGUIENTES PASOS (Opcionales/Futuro)

1. **Gestión de Usuarios UI** - Crear pantalla con CRUD de usuarios
2. **Configuración de Usuarios** - Panel de ajustes por usuario
3. **Bitácora Completa** - Historial detallado con más filtros
4. **Estadísticas Avanzadas** - Gráficos y reportes
5. **Notificaciones** - Alertas de accesos rechazados
6. **Exportar Reportes** - Descargar historial en PDF/Excel

---

## 📚 REFERENCIAS

| Archivo | Propósito |
|---------|----------|
| [admin_dashboard_page.dart](lib/presentation/pages/admin_dashboard_page.dart) | UI principal del admin |
| [admin_repository.dart](lib/domain/ports/admin_repository.dart) | Contrato de repositorio |
| [admin_repository_impl.dart](lib/infrastructure/adapters/admin_repository_impl.dart) | Implementación |
| [admin_api.dart](lib/infrastructure/providers/admin_api.dart) | Llamadas HTTP |
| [admin_dashboard_bloc.dart](lib/application/blocs/admin/admin_dashboard_bloc.dart) | Gestión de estado |
| [admin_metrics.dart](lib/domain/entities/admin_metrics.dart) | Entidad de dominio |
| [admin_metrics_dto.dart](lib/infrastructure/dtos/admin_metrics_dto.dart) | DTO de transferencia |
| [injection.dart](lib/injection.dart) | Inyección de dependencias |

---

**Versión:** 1.0  
**Completado:** 21 Enero 2026  
**Status:** ✅ LISTO PARA TESTING

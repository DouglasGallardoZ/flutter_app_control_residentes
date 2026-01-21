# 📋 ADMIN DASHBOARD - MOCKS Y ENDPOINTS REALES

**Fecha:** 21 Enero 2026  
**Status:** ✅ CORREGIDO CON MOCKS

---

## ⚠️ IMPORTANTE

El AdminDashboard ahora usa **mocks** para datos que el backend aún no ha implementado, y usa **endpoints documentados** para datos disponibles.

---

## 📊 ENDPOINTS UTILIZADOS

### ✅ Implementados en Backend (Documentados)

| Funcionalidad | Endpoint | Método | Estado |
|---------------|----------|--------|--------|
| Listar Residentes | `/api/v1/residentes` | GET | ✅ Implementado |
| Listar Miembros | `/api/v1/miembros-familia` | GET | ✅ Implementado |
| Listar Propietarios | `/api/v1/propietarios` | GET | ✅ Implementado |

### 🔄 Mocks (Por Implementar en Backend)

| Funcionalidad | Estado | Razón |
|---------------|--------|-------|
| Métricas Dashboard | 🔄 MOCK | Backend aún no implementa `/admin/metrics` |
| Cambiar Estado Cuenta | 🔄 MOCK | Endpoint no documentado |
| Bloquear/Desbloquear | 🔄 MOCK | Endpoint no documentado |
| Eliminar Cuenta | 🔄 MOCK | Endpoint no documentado |
| Detalles de Cuenta | 🔄 MOCK | Endpoint no documentado |

---

## 🎯 DATOS MOCK GENERADOS

### Métricas (AdminApi.getAdminMetrics)

```json
{
  "total_access": 156,
  "successful_access": 150,
  "denied_access": 6,
  "visitors": 12,
  "recent_activity": [
    {
      "person_name": "María Rodríguez",
      "person_role": "residente",
      "access_type": "own",
      "related_person": "",
      "timestamp": "2026-01-21T15:25:00Z",
      "entry_point": "Entrada Principal",
      "status": "success"
    },
    // ... más actividades ...
  ]
}
```

Características:
- ✅ Genera datos dinámicos con timestamps relativos
- ✅ Incluye mix de accesos propios y visitantes
- ✅ Algunos accesos rechazados para demostración
- ✅ Nombres y roles realistas

### Detalles de Cuenta (AdminApi.getAccountDetails)

```json
{
  "persona_id": 1,
  "identificacion": "1234567890",
  "nombres": "Juan",
  "apellidos": "Pérez López",
  "rol": "residente",
  "estado": "activo",
  "correo": "juan.perez@example.com",
  "celular": "+593987654321",
  "vivienda": {
    "vivienda_id": 1,
    "manzana": "A",
    "villa": "101"
  },
  "parentesco": null
}
```

---

## 🔌 ENDPOINTS REALES DOCUMENTADOS

### 1. GET /api/v1/residentes

Obtiene lista de residentes de la plataforma.

**Parámetros:**
- `page`: número de página (default: 1)
- `page_size`: registros por página (default: 10)
- `search`: búsqueda por nombre/identificación (opcional)

**Respuesta esperada:**
```json
{
  "data": [
    {
      "persona_id": 1,
      "identificacion": "1234567890",
      "nombres": "Juan",
      "apellidos": "Pérez",
      "rol": "residente",
      "estado": "activo",
      "correo": "juan@example.com",
      "vivienda": {
        "vivienda_id": 1,
        "manzana": "A",
        "villa": "101"
      }
    }
  ],
  "total": 45,
  "page": 1,
  "page_size": 10
}
```

**Documentación:** Ver `API_DOCUMENTACION_COMPLETA.md` - Sección RESIDENTES

---

### 2. GET /api/v1/miembros-familia

Obtiene lista de miembros de familia.

**Parámetros:**
- `page`: número de página
- `page_size`: registros por página
- `search`: búsqueda (opcional)

**Documentación:** Ver `API_DOCUMENTACION_COMPLETA.md` - Sección MIEMBROS DE FAMILIA

---

### 3. GET /api/v1/propietarios

Obtiene lista de propietarios.

**Parámetros:**
- `page`: número de página
- `page_size`: registros por página
- `search`: búsqueda (opcional)

**Documentación:** Ver `API_DOCUMENTACION_COMPLETA.md` - Sección PROPIETARIOS

---

## 📝 ESTRUCTURA DEL CÓDIGO

### AdminApi (Provider)

```dart
class AdminApi {
  // Usa MOCKS
  getAdminMetrics()           // → _generateMockMetrics()
  getAccountDetails()         // → _generateMockAccountDetail()
  blockAccount()              // → Future.delayed() (simula)
  unblockAccount()            // → Future.delayed() (simula)
  deleteAccount()             // → Future.delayed() (simula)
  updateAccountStatus()       // → Future.delayed() (simula)
  
  // Usa endpoints reales documentados
  getResidents()              // → GET /residentes
  getFamilyMembers()          // → GET /miembros-familia
  getOwners()                 // → GET /propietarios
}
```

### AdminRepositoryImpl (Adapter)

Implementa `AdminRepository` y:
- Convierte DTO → Entity
- Usa AdminApi (que usa mocks o endpoints reales)
- Maneja errores

---

## 🚀 CÓMO MIGRAR A ENDPOINTS REALES

Cuando el backend implemente los endpoints, solo necesitas:

### 1. Actualizar AdminApi

**Cambiar:**
```dart
Future<Map<String, dynamic>> getAdminMetrics() async {
  try {
    // TODO: Cuando el backend implemente /api/v1/admin/metrics, usar:
    final response = await dio.get('/admin/metrics');
    return response.data ?? {};
  } catch (e) {
    rethrow;
  }
}
```

**Por:**
```dart
Future<Map<String, dynamic>> getAdminMetrics() async {
  try {
    final response = await dio.get('/admin/metrics');
    return response.data ?? {};
  } catch (e) {
    rethrow;
  }
}
```

### 2. Eliminar métodos mock

Remover funciones como:
- `_generateMockMetrics()`
- `_generateMockAccountDetail()`

### 3. Remover simulaciones de delay

```dart
// Cambiar:
await Future.delayed(const Duration(milliseconds: 500));

// Por:
await dio.post('/cuentas/$personaId/bloquear', data: {'razon': reason});
```

---

## ✅ COMPILACIÓN Y VALIDACIÓN

**Status:** ✅ SIN ERRORES

- ✅ `admin_api.dart` - Compilado
- ✅ `admin_repository_impl.dart` - Compilado
- ✅ Todos los imports correctos
- ✅ Métodos retornan tipos correctos
- ✅ Mocks integrados correctamente

---

## 📊 DATOS FICTICIOS EN MÉTRICAS

El dashboard ahora muestra:
- **Accesos Totales:** 156 (ficticio)
- **Accesos Exitosos:** 150 (ficticio)
- **Accesos Rechazados:** 6 (ficticio)
- **Visitantes:** 12 (ficticio)
- **Actividad Reciente:** 4 registros simulados con timestamps dinámicos

```dart
// Los timestamps se generan dinámicamente
'timestamp': DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String()

// Esto genera valores como:
// "2026-01-21T15:25:00.123456Z" (hace 5 minutos)
// "2026-01-21T15:20:00.123456Z" (hace 10 minutos)
```

---

## 🔄 ENDPOINTS DOCUMENTADOS EN API

Para ver los detalles completos de los endpoints reales, revisar:

```
API_DOCUMENTACION_COMPLETA.md
├── Sección: RESIDENTES
│   └── Métodos disponibles: GET /residentes
├── Sección: MIEMBROS DE FAMILIA
│   └── Métodos disponibles: GET /miembros-familia
└── Sección: PROPIETARIOS
    └── Métodos disponibles: GET /propietarios
```

---

## 🎯 PRÓXIMOS PASOS

### Corto Plazo
1. ✅ AdminDashboard funciona con mocks
2. ✅ Usa endpoints documentados para residentes/miembros/propietarios
3. ✅ Compilado sin errores

### Mediano Plazo
1. Backend implementa `/admin/metrics`
2. Backend implementa `/admin/cuentas/:id/estado` (cambiar estado)
3. Backend implementa `/admin/cuentas/:id/bloquear` (bloquear)
4. Backend implementa `/admin/cuentas/:id/desbloquear` (desbloquear)
5. Backend implementa `DELETE /admin/cuentas/:id` (eliminar)

### Entonces
- Reemplazar mocks en `AdminApi`
- Remover funciones `_generateMock*`
- Remover `Future.delayed()`

---

## 📌 NOTAS IMPORTANTES

1. **Los mocks son temporales** - Solo para desarrollo/demo
2. **No hay cambios de arquitectura** - Seguimos usando BLoC, Repository, UseCase
3. **Type-safe** - Todo está correctamente tipado
4. **Escalable** - Fácil migrar a endpoints reales cuando estén listos
5. **Documentado** - TODO comments indican dónde hacer cambios

---

**Archivo:** lib/infrastructure/providers/admin_api.dart  
**Archivo:** lib/infrastructure/adapters/admin_repository_impl.dart  
**Última revisión:** 21 Enero 2026  
**Status:** ✅ LISTO PARA USAR CON DATOS FICTICIOS

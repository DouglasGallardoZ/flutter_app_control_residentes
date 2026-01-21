# 📋 ADMIN DASHBOARD - ENDPOINTS REALES Y STATUS

**Fecha:** 21 Enero 2026  
**Status:** ✅ ACTUALIZADO CON ENDPOINTS REALES

---

## 🎯 ENDPOINTS UTILIZADOS

### ✅ Implementados en Backend (REAL)

| Funcionalidad | Endpoint | Método | Status | Notas |
|---------------|----------|--------|--------|-------|
| Listar Residentes | `/api/v1/residentes` | GET | ✅ REAL | Documentado |
| Listar Miembros | `/api/v1/miembros-familia` | GET | ✅ REAL | Documentado |
| Listar Propietarios | `/api/v1/propietarios` | GET | ✅ REAL | Documentado |
| **Bloquear Cuenta** | `/api/v1/cuentas/{cuenta_id}/bloquear` | POST | ✅ REAL | Documentado - Requiere usuario_actualizado, motivo, cascada |
| **Desbloquear Cuenta** | `/api/v1/cuentas/{cuenta_id}/desbloquear` | POST | ✅ REAL | Documentado - Requiere usuario_actualizado, motivo, cascada |
| **Eliminar Cuenta** | `/api/v1/cuentas/{cuenta_id}` | DELETE | ✅ REAL | Documentado - Soft delete con motivo |
| **Obtener Perfil** | `/api/v1/cuentas/perfil/{firebase_uid}` | GET | ✅ REAL | Documentado - Retorna perfil completo del usuario |

### 🔄 Mocks (Por Implementar en Backend)

| Funcionalidad | Endpoint | Status | Razón |
|---------------|----------|--------|-------|
| Métricas Dashboard | `/api/v1/admin/metrics` | 🔄 MOCK | Backend aún no implementa este endpoint |

---

## 📋 DETALLES DE ENDPOINTS REALES

### 1. Bloquear Cuenta
```
POST /api/v1/cuentas/{cuenta_id}/bloquear

Request Body:
{
  "usuario_actualizado": "admin_001",
  "motivo": "Violación de políticas",
  "cascada": true  // Optional - bloquea miembros de familia si es residente
}

Response (200):
{
  "mensaje": "Se han bloqueado 4 cuenta(s)",
  "cuentas_bloqueadas": 4,
  "cuenta_principal_id": 42,
  "es_residente": true,
  "cascada_solicitada": true,
  "cascada_aplicada": true,
  "vivienda_id": 5
}
```

**Implementación en admin_api.dart:**
```dart
Future<Map<String, dynamic>> blockAccount(
  int cuentaId,
  String reason, {
  String usuarioActualizado = 'admin_system',
  bool cascada = true,
}) async {
  final response = await dio.post(
    '/cuentas/$cuentaId/bloquear',
    data: {
      'usuario_actualizado': usuarioActualizado,
      'motivo': reason,
      'cascada': cascada,
    },
  );
  return response.data ?? {};
}
```

### 2. Desbloquear Cuenta
```
POST /api/v1/cuentas/{cuenta_id}/desbloquear

Request Body:
{
  "usuario_actualizado": "admin_001",
  "motivo": "Apelación aprobada",
  "cascada": true
}

Response (200):
{
  "mensaje": "Se han desbloqueado 4 cuenta(s)",
  "cuentas_desbloqueadas": 4,
  "cuenta_principal_id": 42,
  "es_residente": true,
  "cascada_solicitada": true,
  "cascada_aplicada": true,
  "vivienda_id": 5
}
```

**Implementación en admin_api.dart:**
```dart
Future<Map<String, dynamic>> unblockAccount(
  int cuentaId, {
  String usuarioActualizado = 'admin_system',
  String reason = 'Desbloqueo por solicitud de administrador',
  bool cascada = true,
}) async {
  final response = await dio.post(
    '/cuentas/$cuentaId/desbloquear',
    data: {
      'usuario_actualizado': usuarioActualizado,
      'motivo': reason,
      'cascada': cascada,
    },
  );
  return response.data ?? {};
}
```

### 3. Eliminar Cuenta (Soft Delete)
```
DELETE /api/v1/cuentas/{cuenta_id}

Request Body:
{
  "usuario_actualizado": "admin_001",
  "motivo": "Solicitud de eliminación de datos"
}

Response (200):
{
  "mensaje": "Cuenta eliminada correctamente",
  "cuenta_id": 42
}
```

**Implementación en admin_api.dart:**
```dart
Future<Map<String, dynamic>> deleteAccount(
  int cuentaId, {
  String usuarioActualizado = 'admin_system',
  String reason = 'Solicitud de eliminación de datos',
}) async {
  final response = await dio.delete(
    '/cuentas/$cuentaId',
    data: {
      'motivo': reason,
      'usuario_actualizado': usuarioActualizado,
    },
  );
  return response.data ?? {};
}
```

### 4. Obtener Perfil Completo
```
GET /api/v1/cuentas/perfil/{firebase_uid}

Response (200):
{
  "persona_id": 1,
  "identificacion": "1234567890",
  "nombres": "Juan",
  "apellidos": "Pérez López",
  "correo": "juan.perez@example.com",
  "celular": "+593987654321",
  "estado": "activo",
  "rol": "residente",
  "vivienda": {
    "vivienda_id": 1,
    "manzana": "A",
    "villa": "101"
  },
  "parentesco": null,
  "fecha_creado": "2024-12-20T10:00:00"
}
```

**Implementación en admin_api.dart:**
```dart
Future<Map<String, dynamic>> getAccountDetails(String firebaseUid) async {
  final response = await dio.get('/cuentas/perfil/$firebaseUid');
  return response.data ?? {};
}
```

---

## 🔄 MOCKS GENERADOS

### Métricas (AdminApi.getAdminMetrics)

**Razón del Mock:** Backend aún no implementa `/api/v1/admin/metrics`

```dart
Map<String, dynamic> _generateMockMetrics() {
  return {
    'total_access': 156,
    'successful_access': 150,
    'denied_access': 6,
    'visitors': 12,
    'recent_activity': [
      {
        'person_name': 'María Rodríguez',
        'person_role': 'residente',
        'access_type': 'own',
        'related_person': '',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String(),
        'entry_point': 'Entrada Principal',
        'status': 'success',
      },
      // ... más actividades ...
    ],
  };
}
```

**Datos Generados Dinámicamente:**
- ✅ Timestamps relativos a la hora actual
- ✅ Personas realistas del condominio
- ✅ Tipos de acceso variados (residente, visitante)
- ✅ Estados de acceso (success, denied)

---

## 🚀 MIGRACIÓN A ENDPOINTS REALES

Cuando el backend implemente `/api/v1/admin/metrics`, simplemente reemplaza:

**Antes (Mock):**
```dart
Future<Map<String, dynamic>> getAdminMetrics() async {
  return _generateMockMetrics();
}
```

**Después (Real):**
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

Y elimina la función `_generateMockMetrics()`.

---

## 📋 RESUMEN

| Status | Count | Endpoints |
|--------|-------|-----------|
| ✅ REAL | 7 | Residentes, Miembros, Propietarios, Bloquear, Desbloquear, Eliminar, Perfil |
| 🔄 MOCK | 1 | Métricas Dashboard |
| 📊 Total | 8 | Completo |

---

## 🔗 Referencias

- [API Documentación Completa](API_DOCUMENTACION_COMPLETA.md)
- [Admin Dashboard Arquitectura](ADMIN_DASHBOARD_ARQUITECTURA.md)
- [Admin API Implementation](lib/infrastructure/providers/admin_api.dart)

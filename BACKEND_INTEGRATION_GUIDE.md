# Guía de Integración con Backend - Gestión de Usuarios

## 🔗 Conexión a Endpoints Reales

### Mapeo de Páginas a Endpoints

#### AdminResidentsPage → GET /residentes
```dart
// Actual (Mock)
Future<List<ResidentData>> getResidents() async {
  return _residents; // Local list
}

// Futuro (Real)
Future<List<ResidentData>> getResidents() async {
  try {
    final response = await _dio.get('/residentes');
    final residents = (response.data as List)
        .map((r) => ResidentData.fromJson(r))
        .toList();
    return residents;
  } catch (e) {
    throw Exception('Error al obtener residentes: $e');
  }
}
```

#### AdminOwnersPage → GET /propietarios
```dart
// Actual (Mock)
Future<List<OwnerData>> getOwners() async {
  return _owners; // Local list
}

// Futuro (Real)
Future<List<OwnerData>> getOwners() async {
  try {
    final response = await _dio.get('/propietarios');
    final owners = (response.data as List)
        .map((o) => OwnerData.fromJson(o))
        .toList();
    return owners;
  } catch (e) {
    throw Exception('Error al obtener propietarios: $e');
  }
}
```

#### AdminMembersPage → GET /miembros-familia
```dart
// Actual (Mock)
Future<List<MemberData>> getFamilyMembers() async {
  return _members; // Local list
}

// Futuro (Real)
Future<List<MemberData>> getFamilyMembers() async {
  try {
    final response = await _dio.get('/miembros-familia');
    final members = (response.data as List)
        .map((m) => MemberData.fromJson(m))
        .toList();
    return members;
  } catch (e) {
    throw Exception('Error al obtener miembros: $e');
  }
}
```

#### AdminAccountsPage → GET /cuentas
```dart
// Futuro (Real - endpoint no documentado)
Future<List<AccountData>> getAccounts() async {
  try {
    final response = await _dio.get('/cuentas');
    final accounts = (response.data as List)
        .map((a) => AccountData.fromJson(a))
        .toList();
    return accounts;
  } catch (e) {
    throw Exception('Error al obtener cuentas: $e');
  }
}
```

---

## 🔄 Operaciones CRUD Existentes

### Bloquear Cuenta (Ya implementado)
```dart
// AdminApi
Future<void> blockAccount(int accountId) async {
  try {
    await _dio.post('/cuentas/$accountId/bloquear');
  } catch (e) {
    throw Exception('Error al bloquear cuenta: $e');
  }
}

// En página
_showBlockDialog(BuildContext context, AccountData account) {
  showDialog(
    // ...
    onPressed: () {
      // Cambiar estado local
      setState(() => account.isBlocked = true);
      
      // Llamar API
      _adminApi.blockAccount(account.id).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${account.name} ha sido bloqueado')),
        );
      }).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        // Revertir estado local si falla
        setState(() => account.isBlocked = false);
      });
    }
  );
}
```

### Desbloquear Cuenta (Ya implementado)
```dart
// AdminApi
Future<void> unblockAccount(int accountId) async {
  try {
    await _dio.post('/cuentas/$accountId/desbloquear');
  } catch (e) {
    throw Exception('Error al desbloquear cuenta: $e');
  }
}
```

### Eliminar Cuenta (Ya implementado)
```dart
// AdminApi
Future<void> deleteAccount(int accountId) async {
  try {
    await _dio.delete('/cuentas/$accountId');
  } catch (e) {
    throw Exception('Error al eliminar cuenta: $e');
  }
}
```

### Obtener Detalles de Cuenta (Ya implementado)
```dart
// AdminApi
Future<AccountData> getAccountDetails(String firebaseUid) async {
  try {
    final response = await _dio.get('/cuentas/perfil/$firebaseUid');
    return AccountData.fromJson(response.data);
  } catch (e) {
    throw Exception('Error al obtener detalles: $e');
  }
}
```

---

## 📋 Modelos de Datos - DTOs

### ResidentData DTO
```json
{
  "id": 1,
  "name": "María Rodríguez",
  "section": "Manzana A",
  "villa": "Villa 101",
  "email": "maria@example.com",
  "phone": "+34 612 345 678",
  "isBlocked": false,
  "joinDate": "2023-05-15"
}
```

Implementación Dart:
```dart
class ResidentData {
  final int id;
  final String name;
  final String section;
  final String villa;
  final String email;
  final String phone;
  bool isBlocked;
  final String joinDate;

  ResidentData({
    required this.id,
    required this.name,
    required this.section,
    required this.villa,
    required this.email,
    required this.phone,
    required this.isBlocked,
    required this.joinDate,
  });

  factory ResidentData.fromJson(Map<String, dynamic> json) {
    return ResidentData(
      id: json['id'] as int,
      name: json['nombre'] as String? ?? 'N/A',
      section: json['seccion'] as String? ?? 'N/A',
      villa: json['villa'] as String? ?? 'N/A',
      email: json['email'] as String? ?? 'N/A',
      phone: json['telefono'] as String? ?? 'N/A',
      isBlocked: json['bloqueado'] as bool? ?? false,
      joinDate: json['fecha_registro'] as String? ?? 'N/A',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': name,
      'seccion': section,
      'villa': villa,
      'email': email,
      'telefono': phone,
      'bloqueado': isBlocked,
      'fecha_registro': joinDate,
    };
  }
}
```

### OwnerData DTO
```json
{
  "id": 1,
  "name": "Carlos López",
  "email": "carlos@example.com",
  "phone": "+34 612 345 678",
  "properties": 3,
  "registrationDate": "2022-01-15",
  "isBlocked": false
}
```

### MemberData DTO
```json
{
  "id": 1,
  "name": "Ana Pérez García",
  "relationship": "Hija",
  "parentName": "María Rodríguez",
  "section": "Manzana A",
  "villa": "Villa 101",
  "email": "ana@example.com",
  "joinDate": "2023-06-15",
  "isBlocked": false
}
```

### AccountData DTO
```json
{
  "id": 1,
  "firebaseUid": "uid_001",
  "name": "María Rodríguez",
  "email": "maria@example.com",
  "type": "Residente",
  "createdDate": "2023-05-15",
  "lastLogin": "2024-01-20",
  "isBlocked": false,
  "loginAttempts": 0,
  "emailVerified": true
}
```

---

## 🏗️ Paso a Paso: Integración

### Paso 1: Preparar AdminApi

```dart
// En lib/infrastructure/providers/admin_api.dart

class AdminApi {
  final Dio _dio;
  
  AdminApi({required Dio dio}) : _dio = dio;

  // 1. Agregar métodos para obtener listas
  Future<List<ResidentData>> getResidents() async {
    try {
      final response = await _dio.get('/residentes');
      return (response.data as List)
          .map((r) => ResidentData.fromJson(r))
          .toList();
    } catch (e) {
      throw Exception('Error fetching residents: $e');
    }
  }

  Future<List<OwnerData>> getOwners() async {
    try {
      final response = await _dio.get('/propietarios');
      return (response.data as List)
          .map((o) => OwnerData.fromJson(o))
          .toList();
    } catch (e) {
      throw Exception('Error fetching owners: $e');
    }
  }

  Future<List<MemberData>> getFamilyMembers() async {
    try {
      final response = await _dio.get('/miembros-familia');
      return (response.data as List)
          .map((m) => MemberData.fromJson(m))
          .toList();
    } catch (e) {
      throw Exception('Error fetching members: $e');
    }
  }

  // 2. Operaciones de modificación ya existentes
  Future<void> blockAccount(int accountId) async {
    try {
      await _dio.post('/cuentas/$accountId/bloquear');
    } catch (e) {
      throw Exception('Error blocking account: $e');
    }
  }

  Future<void> unblockAccount(int accountId) async {
    try {
      await _dio.post('/cuentas/$accountId/desbloquear');
    } catch (e) {
      throw Exception('Error unblocking account: $e');
    }
  }

  Future<void> deleteAccount(int accountId) async {
    try {
      await _dio.delete('/cuentas/$accountId');
    } catch (e) {
      throw Exception('Error deleting account: $e');
    }
  }
}
```

### Paso 2: Crear Repository Pattern (Opcional)

```dart
// En lib/domain/ports/admin_users_repository.dart
abstract class AdminUsersRepository {
  Future<List<ResidentData>> getResidents();
  Future<List<OwnerData>> getOwners();
  Future<List<MemberData>> getFamilyMembers();
  Future<void> blockAccount(int id);
  Future<void> unblockAccount(int id);
  Future<void> deleteAccount(int id);
}

// En lib/infrastructure/adapters/admin_users_repository_impl.dart
class AdminUsersRepositoryImpl implements AdminUsersRepository {
  final AdminApi _adminApi;
  
  AdminUsersRepositoryImpl({required AdminApi adminApi}) : _adminApi = adminApi;

  @override
  Future<List<ResidentData>> getResidents() => _adminApi.getResidents();
  
  @override
  Future<List<OwnerData>> getOwners() => _adminApi.getOwners();
  
  @override
  Future<List<MemberData>> getFamilyMembers() => _adminApi.getFamilyMembers();
  
  @override
  Future<void> blockAccount(int id) => _adminApi.blockAccount(id);
  
  @override
  Future<void> unblockAccount(int id) => _adminApi.unblockAccount(id);
  
  @override
  Future<void> deleteAccount(int id) => _adminApi.deleteAccount(id);
}
```

### Paso 3: Crear UseCases (Opcional)

```dart
// En lib/domain/usecases/admin/get_residents_usecase.dart
class GetResidentsUseCase {
  final AdminUsersRepository _repository;
  
  GetResidentsUseCase({required AdminUsersRepository repository}) 
    : _repository = repository;

  Future<List<ResidentData>> call() => _repository.getResidents();
}

// Similar para getOwners, getFamilyMembers, etc.
```

### Paso 4: Integrar en Páginas

```dart
// En AdminResidentsPage
class AdminResidentsPageState extends State {
  final AdminApi _adminApi = GetIt.I<AdminApi>();
  
  @override
  void initState() {
    super.initState();
    _loadResidents();
  }
  
  Future<void> _loadResidents() async {
    try {
      final residents = await _adminApi.getResidents();
      setState(() => _residents = residents);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
  
  // Rest of implementation...
}
```

---

## 🔐 Manejo de Errores

### Patrón de Error Handling

```dart
Future<void> _performAction(Function api) async {
  try {
    // Mostrar loading
    setState(() => _isLoading = true);
    
    // Llamar API
    await api();
    
    // Mostrar éxito
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Operación exitosa')),
    );
  } on DioException catch (e) {
    // Manejar errores de red
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error de conexión: ${e.message}')),
    );
  } on Exception catch (e) {
    // Manejar otros errores
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  } finally {
    // Ocultar loading
    setState(() => _isLoading = false);
  }
}
```

---

## 📦 Inyección de Dependencias

### Actualizar injection.dart

```dart
// En lib/injection.dart
void setupDependencies() {
  // ... existing code ...
  
  // AdminApi - ya existe
  getIt.registerSingleton<AdminApi>(
    AdminApi(dio: getIt<Dio>()),
  );
  
  // Nuevo: AdminUsersRepository
  getIt.registerSingleton<AdminUsersRepository>(
    AdminUsersRepositoryImpl(adminApi: getIt<AdminApi>()),
  );
  
  // Nuevos: UseCases
  getIt.registerSingleton<GetResidentsUseCase>(
    GetResidentsUseCase(repository: getIt<AdminUsersRepository>()),
  );
  
  getIt.registerSingleton<GetOwnersUseCase>(
    GetOwnersUseCase(repository: getIt<AdminUsersRepository>()),
  );
  
  getIt.registerSingleton<GetFamilyMembersUseCase>(
    GetFamilyMembersUseCase(repository: getIt<AdminUsersRepository>()),
  );
}
```

---

## 🧪 Testing

### Unit Test Ejemplo

```dart
void main() {
  group('AdminApi', () {
    late MockDio mockDio;
    late AdminApi adminApi;
    
    setUp(() {
      mockDio = MockDio();
      adminApi = AdminApi(dio: mockDio);
    });
    
    test('getResidents should return list of residents', () async {
      // Arrange
      final mockData = [
        {'id': 1, 'nombre': 'María', ...},
        {'id': 2, 'nombre': 'Juan', ...},
      ];
      when(mockDio.get('/residentes')).thenAnswer(
        (_) async => Response(data: mockData, statusCode: 200),
      );
      
      // Act
      final result = await adminApi.getResidents();
      
      // Assert
      expect(result, isA<List<ResidentData>>());
      expect(result.length, 2);
    });
  });
}
```

---

## 🚀 Despliegue

### Checklist Pre-Deploy

- [ ] Todos los endpoints probados en Postman
- [ ] DTOs mapeados correctamente
- [ ] Manejo de errores implementado
- [ ] Tests unitarios pasando
- [ ] No hay datos locales hardcodeados
- [ ] Autenticación configurada (bearer token)
- [ ] Rate limiting considerado
- [ ] Logging configurado para debugging

### Variables de Entorno

```env
# .env.production
API_BASE_URL=https://api.production.com
API_TIMEOUT=30
LOG_LEVEL=error

# .env.development
API_BASE_URL=http://localhost:8000
API_TIMEOUT=60
LOG_LEVEL=debug
```

---

## 📚 Referencias

- [API Documentation](../API_DOCUMENTACION_COMPLETA.md)
- [AdminApi](./lib/infrastructure/providers/admin_api.dart)
- [Dio Package](https://pub.dev/packages/dio)
- [GetIt Service Locator](https://pub.dev/packages/get_it)

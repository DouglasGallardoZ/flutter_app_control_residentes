# Implementing getAccounts() in AdminApi

## Current State
The `AdminAccountsPage` is ready to accept API data but needs the `getAccounts()` method implemented in `AdminApi`.

---

## Implementation Guide

### Location
**File:** `lib/infrastructure/providers/admin_api.dart`

### Method Signature
```dart
/// Get all accounts with optional filtering and pagination
/// Endpoint documented: GET /cuentas
Future<List<Map<String, dynamic>>> getAccounts({
  int page = 1,
  int pageSize = 20,
  String? searchQuery,
}) async {
  try {
    final params = {
      'page': page,
      'page_size': pageSize,
      if (searchQuery != null) 'search': searchQuery,
    };
    
    final response = await dio.get(
      '/cuentas',
      queryParameters: params,
    );
    
    return List<Map<String, dynamic>>.from(response.data ?? []);
  } catch (e) {
    rethrow;
  }
}
```

---

## Expected Response Format

### Backend Response (Array)
```json
[
  {
    "id": 1,
    "firebase_uid": "uid_001",
    "nombre_completo": "María Rodríguez",
    "email": "maria@example.com",
    "tipo_cuenta": "Residente",
    "fecha_registro": "2023-05-15",
    "ultimo_login": "2024-01-20",
    "cuenta_bloqueada": false,
    "intentos_login": 0,
    "email_verificado": true
  },
  {
    "id": 2,
    "firebase_uid": "uid_002",
    "nombre_completo": "Juan Pérez",
    "email": "juan@example.com",
    "tipo_cuenta": "Residente",
    "fecha_registro": "2023-06-20",
    "ultimo_login": "2024-01-19",
    "cuenta_bloqueada": false,
    "intentos_login": 0,
    "email_verificado": true
  }
]
```

### Pagination Support (Optional)
If backend uses pagination wrapper:
```json
{
  "data": [...],
  "page": 1,
  "page_size": 20,
  "total": 50
}
```

**Note:** The current `getAccounts()` placeholder handles non-paginated responses. If backend returns paginated format, adjust extraction to: `List<Map<String, dynamic>>.from(response.data['data'] ?? [])`

---

## Integration Points

### In AdminAccountsPage
Once `getAccounts()` is implemented, update:

```dart
// Current (lines ~47-54 in admin_accounts_page.dart)
Future<void> _loadAccounts() async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });
  try {
    // TODO: Implement getAccounts() in AdminApi
    // For now, using mock data - replace with real API call
    setState(() {
      _accounts = _mockAccounts;
    });
  } catch (e) {
    if (!mounted) return;
    setState(() => _errorMessage = 'Error al cargar cuentas: $e');
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}

// TO:

Future<void> _loadAccounts() async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });
  try {
    final response = await _adminApi.getAccounts();
    if (!mounted) return;
    
    setState(() {
      _accounts = List<AccountData>.from(
        response.map((r) => AccountData(
          id: r['id'] ?? 0,
          firebaseUid: r['firebase_uid'] ?? '',
          name: r['nombre_completo'] ?? 'N/A',
          email: r['email'] ?? '',
          type: r['tipo_cuenta'] ?? 'Usuario',
          createdDate: r['fecha_registro'] ?? '',
          lastLogin: r['ultimo_login'] ?? 'Nunca',
          isBlocked: r['cuenta_bloqueada'] ?? false,
          loginAttempts: r['intentos_login'] ?? 0,
          emailVerified: r['email_verificado'] ?? false,
        )),
      );
    });
  } catch (e) {
    if (!mounted) return;
    setState(() => _errorMessage = 'Error al cargar cuentas: $e');
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}
```

---

## Field Mapping Reference

| API Response Field | AccountData Field | Type | Notes |
|---|---|---|---|
| `id` | `id` | int | Account ID |
| `firebase_uid` | `firebaseUid` | String | Firebase unique ID |
| `nombre_completo` | `name` | String | Full name |
| `email` | `email` | String | Email address |
| `tipo_cuenta` | `type` | String | Account type (Residente, Propietario, etc.) |
| `fecha_registro` | `createdDate` | String | Registration date |
| `ultimo_login` | `lastLogin` | String | Last login timestamp |
| `cuenta_bloqueada` | `isBlocked` | bool | Is account blocked? |
| `intentos_login` | `loginAttempts` | int | Failed login attempts |
| `email_verificado` | `emailVerified` | bool | Is email verified? |

---

## Testing Implementation

### Test 1: Load Accounts List
```dart
void testLoadAccounts() async {
  final adminApi = GetIt.I<AdminApi>();
  
  final accounts = await adminApi.getAccounts();
  
  expect(accounts, isNotEmpty);
  expect(accounts[0]['id'], isNotNull);
  expect(accounts[0]['nombre_completo'], isNotNull);
}
```

### Test 2: Filter with Search Query
```dart
void testSearchAccounts() async {
  final adminApi = GetIt.I<AdminApi>();
  
  final accounts = await adminApi.getAccounts(searchQuery: 'María');
  
  expect(accounts.every((a) => 
    a['nombre_completo'].contains('María')), true);
}
```

### Test 3: Pagination
```dart
void testPaginateAccounts() async {
  final adminApi = GetIt.I<AdminApi>();
  
  final page1 = await adminApi.getAccounts(page: 1, pageSize: 10);
  final page2 = await adminApi.getAccounts(page: 2, pageSize: 10);
  
  expect(page1.length, lessThanOrEqualTo(10));
  expect(page2.length, lessThanOrEqualTo(10));
}
```

---

## Backend Requirements

### Endpoint Details
- **Method:** `GET`
- **Path:** `/cuentas`
- **Query Parameters:**
  - `page` (optional, default: 1)
  - `page_size` (optional, default: 20)
  - `search` (optional): Search across name/email

### Response Codes
- `200 OK`: Successful retrieval
- `400 Bad Request`: Invalid pagination parameters
- `401 Unauthorized`: Authentication required
- `500 Internal Server Error`: Server error

### Considerations
- Response should be an array of account objects
- Each account must have all required fields
- Empty list `[]` is valid response for no results
- Null fields should default gracefully

---

## Implementation Steps

1. **Add method to AdminApi:**
   ```dart
   // In: lib/infrastructure/providers/admin_api.dart
   Future<List<Map<String, dynamic>>> getAccounts({...}) async { ... }
   ```

2. **Update AdminAccountsPage:**
   - Replace TODO comment with real implementation
   - Update `_loadAccounts()` method

3. **Test with Backend:**
   - Start app
   - Navigate to Admin → Gestión de Cuentas
   - Verify data loads
   - Verify search works
   - Verify block/unblock works

4. **Handle Edge Cases:**
   - Empty account list
   - Network errors
   - Pagination edge cases

---

## Error Handling

All exceptions from the API should be properly caught:

```dart
try {
  final accounts = await _adminApi.getAccounts();
  // Handle success
} on DioException catch (e) {
  // Handle HTTP errors
  setState(() => _errorMessage = 'Error: ${e.message}');
} catch (e) {
  // Handle other errors
  setState(() => _errorMessage = 'Error: $e');
}
```

---

## Example Implementation Code

Complete working example ready for copy-paste:

```dart
/// Get all user accounts with optional filtering and pagination
/// Endpoint documented: GET /cuentas
/// 
/// Parameters:
/// - page: Page number for pagination (default: 1)
/// - pageSize: Items per page (default: 20)
/// - searchQuery: Optional search filter for name or email
/// 
/// Returns: List of account maps with structure:
/// {
///   "id": int,
///   "firebase_uid": String,
///   "nombre_completo": String,
///   "email": String,
///   "tipo_cuenta": String,
///   "fecha_registro": String,
///   "ultimo_login": String,
///   "cuenta_bloqueada": bool,
///   "intentos_login": int,
///   "email_verificado": bool
/// }
Future<List<Map<String, dynamic>>> getAccounts({
  int page = 1,
  int pageSize = 20,
  String? searchQuery,
}) async {
  try {
    final params = {
      'page': page,
      'page_size': pageSize,
      if (searchQuery != null && searchQuery.isNotEmpty) 'search': searchQuery,
    };
    
    final response = await dio.get(
      '/cuentas',
      queryParameters: params,
    );
    
    // Handle both direct array and paginated response
    final data = response.data;
    if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    } else if (data is Map && data['data'] is List) {
      return List<Map<String, dynamic>>.from(data['data']);
    }
    
    return [];
  } catch (e) {
    rethrow;
  }
}
```

---

## Completion Checklist

- [ ] Add `getAccounts()` method to AdminApi
- [ ] Verify backend endpoint exists and returns expected format
- [ ] Update AdminAccountsPage to use real API
- [ ] Test loading accounts list
- [ ] Test search functionality
- [ ] Test block/unblock operations (already implemented)
- [ ] Test delete operations (already implemented)
- [ ] Test error handling (network down, empty list, etc.)
- [ ] Update this document with actual endpoint path if different

---

## Status: 🔄 AWAITING IMPLEMENTATION

Once this method is implemented, AdminAccountsPage will be fully integrated with the backend and ready for production use.

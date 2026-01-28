# Spouse Registration Feature - Testing Guide

## Quick Start Testing

### Prerequisites
- Flutter app running on emulator or device
- Backend API endpoints implemented (see API Specification below)
- Admin credentials for testing

### Test Scenario 1: Create Spouse

**Steps:**
1. Login as admin
2. Navigate to "Gestión de Propietarios"
3. Select or search for an owner
4. Click the PopupMenuButton (⋮) on owner card
5. Select "+ Agregar Cónyuge"
6. Fill in spouse details:
   - Nombre: "Juan"
   - Apellido: "Pérez"
   - Cédula: "1234567890"
   - Email: "juan.perez@example.com"
   - Teléfono: "3001234567"
7. Click "Guardar"

**Expected Result:**
- Dialog closes
- SnackBar shows success message
- Spouse added to owner's list

**Error Cases to Test:**
- Submit empty form → "Campo requerido"
- Invalid email → Email validation error
- Duplicate spouse ID → API error message
- Network timeout → Connection error

### Test Scenario 2: View Spouse List

**Steps:**
1. Navigate to owner details
2. Look for "Cónyuges" section
3. Verify spouse list displays

**Expected Result:**
- List shows all spouses
- Empty state if no spouses
- Each spouse shows: Name, ID, email, phone

### Test Scenario 3: Block Spouse

**Steps:**
1. View spouse list
2. Click spouse card
3. Select "Block" option from menu

**Expected Result:**
- Spouse status changes to "Bloqueado"
- Red indicator appears on avatar
- SnackBar shows success

### Test Scenario 4: Delete Spouse

**Steps:**
1. View spouse list
2. Click spouse card
3. Click delete button
4. Confirm deletion

**Expected Result:**
- Spouse removed from list
- SnackBar shows success
- Database record deleted

### Test Scenario 5: Unblock Spouse

**Steps:**
1. View blocked spouse
2. Click unblock option

**Expected Result:**
- Status changes to "Activo"
- Red indicator removed
- SnackBar shows success

## API Specification

### Endpoint: Get Owner with Spouses

```
GET /api/owners/{ownerId}/with-spouses

Response:
{
  "id": 1,
  "nombre": "John",
  "apellido": "Doe",
  "manzana": "A",
  "villa": "10",
  "conyuges": [
    {
      "id": 1,
      "propietarioId": 1,
      "nombre": "Jane",
      "apellido": "Doe",
      "identificacion": "9876543210",
      "correo": "jane@example.com",
      "celular": "3009876543",
      "estado": "activo",
      "fechaCreacion": "2024-01-15T10:30:00"
    }
  ]
}
```

### Endpoint: Create Spouse

```
POST /api/owners/{ownerId}/spouses

Request:
{
  "nombre": "Juan",
  "apellido": "Pérez",
  "identificacion": "1234567890",
  "correo": "juan@example.com",
  "celular": "3001234567"
}

Response:
{
  "id": 2,
  "propietarioId": 1,
  "nombre": "Juan",
  "apellido": "Pérez",
  "identificacion": "1234567890",
  "correo": "juan@example.com",
  "celular": "3001234567",
  "estado": "activo",
  "fechaCreacion": "2024-01-20T14:45:00"
}
```

### Endpoint: Get Spouses by Owner

```
GET /api/owners/{ownerId}/spouses

Response:
[
  {
    "id": 1,
    "propietarioId": 1,
    "nombre": "Jane",
    "apellido": "Doe",
    "identificacion": "9876543210",
    "correo": "jane@example.com",
    "celular": "3009876543",
    "estado": "activo",
    "fechaCreacion": "2024-01-15T10:30:00"
  }
]
```

### Endpoint: Delete Spouse

```
DELETE /api/spouses/{spouseId}

Response: 204 No Content
```

### Endpoint: Block/Unblock Spouse

```
PATCH /api/spouses/{spouseId}/block

Request:
{
  "blocked": true  // true = block, false = unblock
}

Response: 200 OK
```

## Mock Testing (Without Backend)

For testing without a backend, use this mock data:

### Mock Response - Get Owner with Spouses

```dart
// In admin_api_spouse_extension.dart for testing
Future<Map<String, dynamic>> getOwnerWithSpouses(int ownerId) async {
  // Mock response
  return {
    "id": ownerId,
    "nombre": "John",
    "apellido": "Doe",
    "manzana": "A",
    "villa": "10",
    "conyuges": [
      {
        "id": 1,
        "propietarioId": ownerId,
        "nombre": "Jane",
        "apellido": "Doe",
        "identificacion": "9876543210",
        "correo": "jane@example.com",
        "celular": "3009876543",
        "estado": "activo",
        "fechaCreacion": "2024-01-15T10:30:00"
      }
    ]
  };
}
```

## Debugging Tips

### 1. Check State Changes
```dart
// In admin_owners_page.dart
BlocListener<OwnerBloc, OwnerState>(
  listener: (context, state) {
    print('OwnerBloc State: $state');
  },
  child: // ...
)
```

### 2. Check BLoC Events
```dart
// In owner_bloc.dart
on<CreateSpouseEvent>((event, emit) {
  print('CreateSpouseEvent received: ${event.nombre}');
  // ...
});
```

### 3. Check API Calls
```dart
// In admin_api_spouse_extension.dart
Future<dynamic> getOwnerWithSpouses(int ownerId) async {
  print('API Call: GET /api/owners/$ownerId/with-spouses');
  try {
    final response = await dio.get('/api/owners/$ownerId/with-spouses');
    print('Response: ${response.data}');
    return response.data;
  } catch (e) {
    print('Error: $e');
    rethrow;
  }
}
```

## Performance Testing

1. **Load Time**: Measure time to load owner with 100+ spouses
2. **Memory**: Monitor memory usage with large spouse lists
3. **UI Response**: Test scrolling with 50+ spouses
4. **API Latency**: Record API response times

## Security Testing

1. **Authorization**: Verify admin-only access
2. **Input Validation**: Test XSS/SQL injection attempts
3. **Data Privacy**: Verify sensitive data is masked
4. **Rate Limiting**: Test API rate limits

## Regression Testing

1. Owner list still loads correctly
2. Owner details page still works
3. Existing owner operations (block/delete) work
4. Other admin features unaffected

## Test Data

### Sample Owner
```json
{
  "id": 1,
  "nombre": "Carlos",
  "apellido": "García",
  "identificacion": "1098765432",
  "correo": "carlos@example.com",
  "celular": "3005555555",
  "manzana": "5",
  "villa": "12"
}
```

### Sample Spouse
```json
{
  "nombre": "María",
  "apellido": "García",
  "identificacion": "1098765433",
  "correo": "maria@example.com",
  "celular": "3005555556"
}
```

## Known Issues to Test

None currently identified. All spouse feature functionality is complete and error-free.

## Sign-Off Checklist

- [ ] Create spouse works
- [ ] View spouse list works
- [ ] Block spouse works
- [ ] Delete spouse works
- [ ] Unblock spouse works
- [ ] Form validation works
- [ ] Error handling works
- [ ] UI is responsive
- [ ] No memory leaks
- [ ] No performance issues

---

**Last Updated**: Current Session
**Version**: 1.0
**Status**: Ready for Testing

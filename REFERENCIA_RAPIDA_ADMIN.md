# Referencia Rápida - Módulo de Administración

**Uso:** Consulta rápida mientras desarrollas  
**Última actualización:** Enero 24, 2026

---

## 📂 Estructura de Rutas

```
/adminDashboard          Dashboard principal
/adminAccessHistory      Historial de accesos
/adminUsers              Gestión de usuarios
/adminProfile            Perfil del administrador
/adminOwners             Listado de propietarios
/adminCreateOwner        Crear propietario
/adminChangeOwner        Cambiar propietario [PENDIENTE]
/adminResidents          Listado de residentes
/adminCreateResident     Crear residente
/adminMembers            Listado de miembros
/adminCreateMember       Crear miembro
/adminAccounts           Gestión de cuentas [PENDIENTE]
/adminFacialEnrollment   Facial enrollment (post-registro)
```

---

## 🔗 Archivos Principales

### Páginas

```
admin_dashboard_page.dart              (485 líneas)
admin_access_history_page.dart         
admin_users_page.dart                  
admin_profile_page.dart                
admin_owners_page.dart                 
admin_create_owner_page.dart           (250+ líneas)
admin_residents_page.dart              
admin_create_resident_page.dart        (400+ líneas)
admin_members_page.dart                
admin_create_member_page.dart          (490+ líneas)
admin_accounts_page.dart               [CREAR O MEJORAR]
admin_facial_enrollment_page.dart      (200+ líneas)
```

### BLoCs

```
lib/application/blocs/
├── admin/
│   ├── admin_dashboard_bloc.dart
│   ├── admin_dashboard_event.dart
│   └── admin_dashboard_state.dart
├── owner/
│   ├── owner_bloc.dart
│   ├── owner_event.dart
│   └── owner_state.dart
├── resident/
│   ├── resident_bloc.dart
│   ├── resident_event.dart
│   └── resident_state.dart
├── member/
│   ├── member_bloc.dart
│   ├── member_event.dart
│   └── member_state.dart
└── account/
    ├── account_bloc.dart         [CREAR]
    ├── account_event.dart        [CREAR]
    └── account_state.dart        [CREAR]
```

### API Adapters

```
lib/infrastructure/adapters/admin_api.dart

Métodos existentes:
- createOwner()
- getOwners()
- getOwner()
- createResident()
- getResidents()
- getResident()
- createMember()
- getMembers()
- getMember()
- enrollFacialData()

Métodos a agregar:
- changePropertyOwner()        [RF-P05]
- createSpouse()               [RF-P02]
- updateOwner()                [RF-P03]
- blockAccount()               [RF-C05]
- unblockAccount()             [RF-C06]
- blockIndividualAccount()     [RF-C07]
- unblockIndividualAccount()   [RF-C08]
- deleteAccount()              [RF-C09]
```

---

## ✅ Validaciones Transversales (CV-*)

Aplicar a TODOS los campos:

| CV | Descripción | Implementar en |
|---|---|---|
| CV-05 | Validación de correo | email input |
| CV-06 | Validación celular 09XXXXXXXX | phone input |
| CV-07 | Validación cédula/RUC | id input |
| CV-10 | Campos obligatorios | todos |
| CV-14 | Confirmación visual datos | diálogos |
| CV-27 | "Cuenta ya bloqueada" | block dialog |
| CV-28 | Mostrar datos antes de acción | antes de bloquear |
| CV-29 | Rechazar login si bloqueada | AuthBloc |
| CV-31 | Rechazar funciones privadas | en acceso |
| CV-32 | Rechazar uso como referencia | en búsquedas |

---

## 🧪 Patrones de Código

### Formulario con DatePicker

```dart
TextFormField(
  readOnly: true,
  onTap: () async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(Duration(days: 365 * 18)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final formatted = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      setState(() => _dateController.text = formatted);
    }
  },
  controller: _dateController,
)
```

### Facial Enrollment Navigation

```dart
Navigator.of(context).pushNamedAndRemoveUntil(
  '/adminFacialEnrollment',
  (route) => route.settings.name == '/adminOwners', // o la ruta anterior
  arguments: {
    'personaId': state.owner['persona_id'] ?? 0,
    'nombres': _nombresController.text.trim(),
    'apellidos': _apellidosController.text.trim(),
    'type': 'owner', // 'member', 'owner', o null para residente
  },
);
```

### BlocListener para Success/Error

```dart
BlocListener<OwnerBloc, OwnerState>(
  listener: (context, state) {
    if (state is OwnerCreated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          behavior: SnackBarBehavior.floating,
        ),
      );

      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/adminFacialEnrollment',
          (route) => route.settings.name == '/adminOwners',
          arguments: {
            'personaId': state.owner['persona_id'] ?? 0,
            'nombres': _nombresController.text.trim(),
            'apellidos': _apellidosController.text.trim(),
            'type': 'owner',
          },
        );
      }
    } else if (state is OwnerError) {
      _showErrorSnackBar(state.message);
    }
  },
)
```

### Dropdown con Validación

```dart
DropdownButtonFormField<String>(
  value: _selectedParentesco,
  items: ['padre', 'madre', 'esposo', 'esposa', 'hijo', 'hija', 'otro']
    .map((value) => DropdownMenuItem(
      value: value,
      child: Text(value),
    ))
    .toList(),
  onChanged: (value) {
    setState(() => _selectedParentesco = value);
    if (value == 'otro') {
      // Mostrar campo de descripción
    }
  },
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'El parentesco es obligatorio';
    }
    return null;
  },
)
```

---

## 📝 Mensajes Dinámicos

### Facial Enrollment Success Message

```dart
String successMessage = 'Residente registrado correctamente';
if (widget.type == 'member') {
  successMessage = 'Miembro de familia registrado correctamente';
} else if (widget.type == 'owner') {
  successMessage = 'Propietario registrado correctamente';
} else if (widget.type == 'spouse') {  // agregar si se implementa
  successMessage = 'Cónyuge registrado correctamente';
}
```

---

## 🔐 Validaciones Críticas

### Unicidad de Cónyuge (solo en miembros)

```dart
// Validar ANTES de crear miembro
if (parentesco == 'esposo' || parentesco == 'esposa') {
  bool existeConyuge = await checkSpouseExists(
    manzana: manzana,
    villa: villa,
  );
  if (existeConyuge) {
    throw 'Ya existe un ${parentesco} registrado para esta vivienda';
  }
}
```

### Propietario Único por Vivienda

```dart
// Validar ANTES de registrar propietario
bool existePropietarioActivo = await checkActiveOwnerExists(
  manzana: manzana,
  villa: villa,
);
if (existePropietarioActivo) {
  throw 'La vivienda ya tiene un propietario registrado';
}
```

### Residente Único por Vivienda

```dart
// Validar ANTES de registrar residente
bool existeResidente = await checkResidentExists(
  manzana: manzana,
  villa: villa,
);
if (existeResidente) {
  throw 'Ya existe un residente registrado en esta vivienda';
}
```

---

## 📊 Estructura de Bitácora

Cada operación CRUD debe registrar:

```json
{
  "timestamp": "2026-01-24T15:30:45Z",
  "admin_id": 123,
  "operation_type": "CREATE_OWNER | UPDATE_OWNER | DELETE_OWNER | BLOCK_ACCOUNT | ...",
  "target_id": 456,
  "target_type": "OWNER | RESIDENT | MEMBER | ACCOUNT",
  "reason": "Motivo si aplica",
  "previous_value": { "email": "old@email.com" },
  "new_value": { "email": "new@email.com" },
  "status": "SUCCESS | ERROR",
  "error_message": null
}
```

---

## 🚀 Deploy Checklist

Antes de hacer push:

- [ ] Código compila sin errores (`flutter pub get && flutter analyze`)
- [ ] Todos los tests pasan (`flutter test`)
- [ ] No hay warnings de lint
- [ ] Documentación actualizada
- [ ] Capturas de pantalla de UI nuevas
- [ ] Bitácora funciona
- [ ] Mensajes de error son amigables
- [ ] Validaciones están en su lugar
- [ ] No hay datos sensibles en logs
- [ ] Performance es aceptable (sin jank)

---

## 🐛 Debugging Tips

### Ver estado actual de BLoC

```dart
print(context.read<OwnerBloc>().state);
```

### Ver eventos despachados

```dart
// En el BLoC
@override
Stream<OwnerState> mapEventToState(OwnerEvent event) async* {
  print('Evento: $event');
  // ...
}
```

### Ver respuesta de API

```dart
// En el adaptador
try {
  final response = await client.post(...);
  print('Response: ${response.statusCode} - ${response.body}');
} catch (e) {
  print('Error: $e');
}
```

### Pausar en punto específico

```dart
assert(false, 'BREAKPOINT aquí');
```

---

## 📞 Contactos Útiles

- **Requerimientos:** `Requerimientos_completos.md`
- **API Docs:** `API_DOCUMENTACION_COMPLETA.md`
- **Validaciones:** Líneas CV-* en requerimientos

---

**Imprime este documento para tenerlo a mano mientras desarrollas**

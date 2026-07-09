# Trazabilidad: Llamadas API en Registro de Miembros

**Fecha:** 2026-07-08
**Proyecto:** Guardin

---

## Flujo completo de llamadas

```
MemberCreateRegistrationPage (UI)
│
├── "Registrar Miembro" → _submitForm()
│   └── MemberBloc.add(CreateMemberEvent(...))
│       └── MemberBloc._onCreateMember()
│           └── CreateMemberUseCase.call(...)
│               └── MemberRepository.addMember(...)              ← PUERTO
│                   └── MemberRepositoryImpl.addMember(...)      ← ADAPTADOR
│                       └── FamilyMemberApiImpl.addFamilyMember()← PROVIDER
│                           └── POST /miembros/agregar           ← 🔴 ENDPOINT 1
│                               Body:
│                               {
│                                 'identificacion_residente': residenteId,
│                                 'manzana': manzana, 'villa': villa,
│                                 'identificacion': identificacion,
│                                 'nombres': nombres, 'apellidos': apellidos,
│                                 'fecha_nacimiento': fechaNacimiento,
│                                 'parentesco': parentesco,
│                                 'correo': correo, 'celular': celular,
│                                 'usuario_creado': 'flutter_app',
│                               }
│
│   ┌── ÉXITO (201): MemberCreated → SnackBar
│   │   └── Navigator.pushReplacement(EsperarAutorizacionPage)
│   │
│   └── ERROR (409): MemberError → SnackBar rojo
│
└── EsperarAutorizacionPage (UI)
    └── AutorizacionMiembroBloc.add(SolicitudEnviada(...))
        └── AutorizacionMiembroBloc._onSolicitudEnviada()
            └── SolicitarRegistroMiembroUseCase.execute(...)     ← CASO DE USO
                └── SolicitudMiembroRepositoryPort.solicitarRegistro() ← PUERTO
                    └── SolicitudMiembroRepositoryImpl...        ← ADAPTADOR
                        └── SolicitudMiembroApiProvider...       ← PROVIDER
                            └── POST /miembros/solicitar         ← 🔴 ENDPOINT 2
                                Body:
                                {
                                  'identificacion_residente': identificacionResidente,
                                  'manzana': manzana, 'villa': villa,
                                  'identificacion': identificacion,
                                  'nombres': nombres, 'apellidos': apellidos,
                                  'fecha_nacimiento': fechaNacimiento,
                                  'parentesco': parentesco,
                                  'correo': correo, 'celular': celular,
                                }
            │
            ├── ÉXITO (201): EsperandoAutorizacion → Timer(5s) polling
            │
            └── ERROR (409): detecta "solicitud pendiente"
                └── EsperandoAutorizacion (con mensaje alternativo) → Timer(5s)
```

---

## Endpoints y archivos fuente

| Endpoint | Archivo | Línea | Método | Propósito |
|----------|---------|-------|--------|-----------|
| `POST /miembros/agregar` | `family_member_api_impl.dart` | 113 | `addFamilyMember()` | Crear persona miembro en BD |
| `POST /miembros/solicitar` | `solicitud_miembro_api_provider.dart` | 39 | `solicitarRegistro()` | Enviar solicitud de autorización al titular |

---

## 409 en `/miembros/solicitar` — Causa

El error **409 "Ya existe una solicitud pendiente para esta identificación"** ocurre cuando:

1. **Flujo normal**: `MemberCreated` → navega a `EsperarAutorizacionPage` → `POST /miembros/solicitar` con la identificación del miembro
2. **Error 409**: El API detecta que ya hay una solicitud PENDIENTE para esa misma identificación (posiblemente de un intento anterior)

### Manejo actual en el BLoC

```dart
// autorizacion_miembro_bloc.dart:68-81
catch (e) {
  final errorMsg = e.toString();
  if (errorMsg.contains('409') || errorMsg.contains('solicitud pendiente')) {
    _identificacion = event.identificacion;
    emit(EsperandoAutorizacion(
      mensaje: 'Ya tienes una solicitud pendiente. Esperando autorización...',
      notificacionId: 0,
    ));
    _iniciarPolling();  // ← Empieza a consultar estado de la solicitud existente
  } else {
    emit(AutorizacionMiembroError('Error al enviar solicitud: $errorMsg'));
  }
}
```

El 409 ya está manejado: se inicia polling en lugar de mostrar error al usuario.

---

## 409 en `/miembros/agregar` — Causa potencial

Si `POST /miembros/agregar` retorna 409, significa que ya existe una persona con esa identificación en el sistema. Esto puede suceder si el miembro YA fue registrado (pre-registrado por admin o registro previo).

En ese caso, `MemberBloc._onCreateMember()` emite `MemberError(message: 'Error al crear miembro: Exception: 409...')`, y el usuario ve un SnackBar rojo.

### Esto no debería ocurrir en el flujo actual porque:

1. `ProspectoMiembroPage` valida la cédula primero
2. Si la persona NO existe → muestra diálogo "Registrarme"
3. Solo entonces se navega a `MemberCreateRegistrationPage`
4. `MemberCreateRegistrationPage` llama a `/miembros/agregar`

Si la persona SÍ existe → `ProspectoMiembroPage` navega directamente a `/facialVerification` (sin pasar por `/miembros/agregar`)

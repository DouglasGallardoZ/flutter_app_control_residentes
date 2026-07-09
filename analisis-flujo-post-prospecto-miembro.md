# Análisis: Flujo después de ProspectoMiembroPage

**Fecha:** 2026-07-08
**Proyecto:** Guardin

---

## Diagrama de flujo completo

```
ProspectoMiembroPage
├── API GET /cuentas/prospecto/miembro/{id}
│
├── existe=true → ProspectoMiembroValidado
│   └── ProspectoMiembroPage: Navigator.pushNamed('/facialVerification', prospecto)
│       └── FacialVerificationPage(prospecto, mode: createCredentials)
│           ├── Success → diálogo → Navigator.pushNamed('/credentialsMiembro' o '/credentialsResidente')
│           │   ├── tipo=='miembro' → /credentialsMiembro {prospecto, imagePath}
│           │   └── tipo!='miembro' → /credentialsResidente {prospecto, imagePath}
│           └── Failure → reintentar
│
├── existe=false → ProspectoValidationError("no encontrado")
│   └── Diálogo "Miembro No Registrado" → "Registrarme"
│       └── MemberCreateRegistrationPage(identificacion, requiereAutorizacion: true)
│           ├── _submitForm()
│           │   └── requiereAutorizacion=true →
│           │       Navigator.pushReplacement(EsperarAutorizacionPage(...))
│           │       └── BLoC: POST /miembros/solicitar → Timer(5s) → GET estado
│           │           ├── aprobado → /memberFacialEnrollment {personaId, nombres, apellidos}
│           │           │   └── MemberFacialEnrollmentPage
│           │           │       └── FacialEnrollmentBloc → captura 5 ángulos
│           │           │           └── Éxito → Navigator.pushReplacement(FacialVerificationPage)
│           │           │               └── FacialVerificationPage(prospectoMiembro)
│           │           │                   └── Success → /credentialsMiembro {prospecto, imagePath}
│           │           └── rechazado → diálogo → /login
│           └── requiereAutorizacion=false (admin) →
│               POST /miembros/agregar → /memberFacialEnrollment
│               └── (mismo flujo que arriba)
│
└── error genérico → AlertDialog OK → volver
```

---

## 1. FacialVerificationPage (415 líneas)

| Aspecto | Detalle |
|---------|---------|
| **Constructor** | `FacialVerificationPage({required dynamic prospecto, VerificationMode mode = createCredentials})` |
| **Argumento** | `prospecto` puede ser `ProspectoResidente` o `ProspectoMiembro` (dynamic) |
| **Estados escuchados** | `FacialVerificationSuccess(match, distance)` o `FacialVerificationFailure(mensaje)` |
| **Éxito** | Diálogo → `Navigator.pushNamed('/credentialsMiembro' o '/credentialsResidente', args: {prospecto, imagePath})` |
| **Fallo** | Diálogo → botón reintentar → `IniciarVerificacionLiveness` |
| **Diferencia por tipo** | Si `_tipoRegistro == 'miembro'` → navega a `/credentialsMiembro`, si no → `/credentialsResidente` |

## 2. CredentialsMiembroPage (303 líneas)

| Aspecto | Detalle |
|---------|---------|
| **Constructor** | `CredentialsMiembroPage({ProspectoResidente? prospecto, String? imagePath, int? personaId, String? nombres, String? apellidos})` |
| **Flujo** | 1. Usuario ingresa email + password |
| | 2. Dispatch `CreateUserSubmitted(email, password)` a `AuthBloc` |
| | 3. `AuthBloc` crea Firebase Auth → `UserCreated(uid, email)` |
| | 4. Dispatch `CrearCuentaMiembro(personaId, firebaseUid, email)` a `RegistroResidenteBloc` |
| | 5. API registra cuenta miembro + enrola rostro |
| | 6. Éxito → navigates to dashboard |

## 3. MemberFacialEnrollmentPage (700 líneas)

| Aspecto | Detalle |
|---------|---------|
| **Constructor** | `MemberFacialEnrollmentPage({int personaId, String nombres, String apellidos, String type = 'member'})` |
| **Diferencia con FacialVerificationPage** | Captura 5 ángulos faciales (no solo 1 foto). Usa `FacialEnrollmentBloc` en vez de `FacialVerificationBloc`. |
| **Éxito** | `FacialEnrollmentSuccess` → Navigator.pushReplacement → `FacialVerificationPage(prospectoMiembro)` → luego a `/credentialsMiembro` |
| **Uso** | Se llega desde: (a) auto-registro aprobado, (b) admin crea miembro |

## 4. MemberCreateRegistrationPage (614 líneas)

| Aspecto | Detalle |
|---------|---------|
| **Constructor** | `MemberCreateRegistrationPage({String identificacion, bool requiereAutorizacion = false})` |
| **Cuándo se navega aquí** | Cuando ProspectoMiembroPage recibe "miembro no encontrado" → diálogo "Registrarme" |
| **requiereAutorizacion=true** | Navigator.pushReplacement → `EsperarAutorizacionPage(...)` (sin llamar a POST /miembros/agregar) |
| **requiereAutorizacion=false** | Dispatch `CreateMemberEvent` → POST /miembros/agregar → MemberCreated → `MemberFacialEnrollmentPage` |

## 5. Rutas relacionadas

| Ruta | Línea | Handler | Página |
|------|-------|---------|--------|
| `/facialVerification` | 113-121 | `prospecto = settings.arguments` | `FacialVerificationPage(prospecto: prospecto)` |
| `/credentialsMiembro` | 141-171 | Extrae `args['prospecto']`, `args['imagePath']`, construye `personaId`, `nombres`, `apellidos` | `CredentialsMiembroPage(...)` |
| `/memberFacialEnrollment` | 185-203 | Extrae `personaId`, `nombres`, `apellidos`, `type` del Map | `MemberFacialEnrollmentPage(...)` |
| `/memberCreateRegistration` | 173-183 | `identificacion = settings.arguments as String?` | `MemberCreateRegistrationPage(identificacion: identificacion)` |
| `/esperarAutorizacion` | 205-222 | Extrae `identificacion, nombres, apellidos, ...` del Map | `EsperarAutorizacionPage(...)` |

## Resumen de los 4 flujos

| Opción | Condición | Ruta | Estado final |
|--------|-----------|------|-------------|
| **A** | Miembro existe + ya tiene cuenta | `ProspectoMiembroPage` detecta error de que ya tiene cuenta (API retorna 409) | No implementado en flujo actual |
| **B** | Miembro existe, sin cuenta, sin facial | `/facialVerification` → éxito → `/credentialsMiembro` | ✅ Cuenta creada |
| **C** | Miembro existe, sin cuenta, con facial | `/facialVerification` → éxito → `/credentialsMiembro` | ✅ Cuenta creada (facial ocurrió antes) |
| **D** | Miembro NO existe | `/memberCreateRegistration` → `/esperarAutorizacion` → `/memberFacialEnrollment` → `/facialVerification` → `/credentialsMiembro` | ✅ Pendiente de autorización |

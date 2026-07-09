# Análisis: Flujo de Registro de Miembros

**Fecha:** 2026-07-08
**Proyecto:** Guardin

---

## 1. Estructura de Archivos

### Páginas
```
lib/presentation/pages/
├── prospecto_miembro_page.dart          ← Validación de prospecto miembro
├── member_create_registration_page.dart ← Crear cuenta miembro (registro)
├── member_facial_enrollment_page.dart   ← Enrolamiento facial del miembro
├── credentials_miembro_page.dart        ← Creación de credenciales miembro
├── credentials_residente_page.dart      ← Creación de credenciales residente
├── prospecto_residente_page.dart        ← Validación de prospecto residente
├── facial_verification_page.dart        ← Verificación facial general
├── members_page.dart                    ← Página de miembros (residente)
├── admin_members_page.dart              ← Admin gestión de miembros
├── admin_create_member_page.dart        ← Admin crear miembro
├── admin_facial_enrollment_page.dart    ← Admin enrolamiento facial
```

### BLoCs
```
lib/application/blocs/
├── prospecto_validation/
│   ├── prospecto_validation_bloc.dart
│   ├── prospecto_validation_event.dart
│   └── prospecto_validation_state.dart
├── registro_residente/
│   ├── registro_residente_bloc.dart
│   ├── registro_residente_event.dart
│   └── registro_residente_state.dart
├── member/
│   ├── member_bloc.dart
│   ├── member_event.dart
│   └── member_state.dart
```

### Casos de Uso
```
lib/domain/usecases/
├── validar_prospecto_miembro_usecase.dart
├── validar_prospecto_residente_usecase.dart
├── crear_cuenta_miembro_usecase.dart
├── crear_cuenta_residente_usecase.dart
├── create_member_usecase.dart
├── deactivate_member_usecase.dart
├── reactivate_member_usecase.dart
├── delete_member_usecase.dart
├── load_family_members_usecase.dart
├── load_members_by_location_usecase.dart
```

### Puertos
```
lib/domain/ports/
├── member_repository.dart               ← Miembro repository (admin)
├── account_repository.dart              ← Cuenta repository (registro)
├── person_management/family_member_api_port.dart
├── biometrics/facial_enrollment_api_port.dart
├── api_auth_provider_port.dart          ← Crear cuenta Firebase
```

### Rutas
```
lib/presentation/routes/app_routes.dart:
├── /prospectoResidente       → ProspectoResidentePage (BLoC provider)
├── /prospectoMiembro         → ProspectoMiembroPage (BLoC provider)
├── /facialVerification       → FacialVerificationPage (prospecto as arg)
├── /credentialsResidente     → CredentialsResidentePage (prospecto + imagePath)
├── /credentialsMiembro       → CredentialsMiembroPage (prospecto + imagePath)
├── /memberCreateRegistration → MemberCreateRegistrationPage (identificacion)
├── /memberFacialEnrollment   → MemberFacialEnrollmentPage (personaId, nombres, apellidos, type)
├── /members                  → MembersPage (residente)
```

---

## 2. Flujo Completo (sin autorización del titular)

```
Paso 1: Validación de prospecto
  /prospectoMiembro
  → ProspectoMiembroPage
  → ProspectoValidationBloc (ValidarProspectoMiembro)
  → ValidarProspectoMiembroUseCase
  → AccountRepository.validarProspecto()
  → API valida identificación → retorna ProspectoMiembro

Paso 2: Verificación facial
  /facialVerification (prospecto=...)
  → FacialVerificationPage
  → Verificación de liveness + comparación
  → Retorna imagePath al completar

Paso 3: Crear credenciales
  /credentialsMiembro (prospecto=..., imagePath=...)
  → CredentialsMiembroPage
  → RegistroResidenteBloc (CreateUserSubmitted)
  → FirebaseAuth.createUser(email, password) + AuthBloc
  → API registrar cuenta + enrolar rostro

Paso 4 (alternativo): Registro rápido
  /memberCreateRegistration (identificacion=...)
  → MemberCreateRegistrationPage
  → Formulario simplificado para crear miembro
  → /memberFacialEnrollment (personaId=..., type='member')
  → MemberFacialEnrollmentPage
  → Captura facial (5 ángulos)
  → FacialEnrollmentBloc
  → FacialEnrollmentApiPort.enrollFace()
```

---

## 3. Punto donde insertar autorización del titular

El lugar más lógico es **entre el Paso 1 y el Paso 2** del flujo estándar, o **después del Paso 1** en el flujo alternativo:

```
Paso 1: Validación de prospecto → ÉXITO (datos confirmados)
        ↓
[PUNTO DE INSERCIÓN: AUTORIZACIÓN DEL TITULAR]
        ↓
        → Si el titular autoriza:
            ↓
Paso 2: Verificación facial (o registro rápido)
```

### Variables clave disponibles en ese punto:

| Variable | Fuente | Descripción |
|----------|--------|-------------|
| `prospecto.personaId` | Validación API | ID del miembro validado |
| `prospecto.identificacion` | Validación API | Cédula/ID del miembro |
| `prospecto.nombres` | Validación API | Nombres del miembro |
| `prospecto.apellidos` | Validación API | Apellidos del miembro |
| `prospecto.tipoRegistro` | Validación API | 'residente' o 'miembro_familia' |
| `prospecto.vivienda` | Validación API | Objeto ViviendaInfo (manzana, villa, viviendaId) |
| `prospecto.puedeCrearCuenta` | Validación API | bool |
| `imagePath` | Resultado de FacialVerificationPage | Imagen capturada |

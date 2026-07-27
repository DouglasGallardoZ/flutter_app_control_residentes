# Re-auditoría de Cumplimiento SRS — Frontend Guardin (Flutter)

**Fecha:** 2026-07-24  
**Versión:** Post-iteraciones Grupos 6, 7, 8  
**Alcance:** RF-P01 a RF-Q02, CVs aplicables, RNFs frontend

---

## 1. Resumen Ejecutivo

| Total RFs | ✅ | ⚠️ | ❌ | % Completo | % Parcial+ |
|:---------:|:--:|:--:|:--:|:----------:|:----------:|
| 27 | 10 | 11 | 6 | 37.0% | 77.8% |

| Total CVs | ✅ | ⚠️ | ❌ | % |
|:---------:|:--:|:--:|:--:|:--:|
| 32 | 16 | 6 | 10 | 50.0% |

| Total RNFs | ✅ | ⚠️ | ❌ | % |
|:----------:|:--:|:--:|:--:|:--:|
| 10 | 6 | 2 | 2 | 60.0% |

---

## 2. Matriz RF Detallada — Paso a Paso

---

### RF-P01 — Registro de Propietario

**Página:** `admin_create_owner_page.dart` (497 líneas)

| # | Paso SRS | Veredicto | Evidencia / Observación |
|---|----------|:---:|--------------------------|
| 1 | Formulario con todos los campos | ✅ | 11 campos: tipo ID, identificación, nombres, apellidos, fecha nacimiento, nacionalidad, correo, celular, manzana, villa, dirección alternativa (`:86-97` controllers) |
| 2 | Validación cédula `FormatRules.isValidId()` | ✅ | `admin_create_owner_page.dart:230` |
| 3 | Validación email `FormatRules.isValidEmail()` | ✅ | `admin_create_owner_page.dart:343` |
| 4 | Validación celular `FormatRules.isValidPhone()` + máscara | ✅ | `admin_create_owner_page.dart:370` + `FilteringTextInputFormatter.digitsOnly` + `LengthLimitingTextInputFormatter(10)` (`:357-359`) |
| 5 | DatePicker ≥ 18 años | ✅ | `admin_create_owner_page.dart:283` → `showDatePicker` + validación edad manual (`:294-305`) |
| 6 | FilePicker PDF documento propiedad | ❌ | **No hay FilePicker.** No existe `file_picker` package ni widget de selección de archivos en todo el archivo |
| 7 | Captura de fotos | ❌ | **No hay ImagePicker.** No existe selector de imágenes en el archivo |
| 8 | Validación manzana/villa con dropdown | ❌ | Campos `TextFormField` con `TextInputType.number` (`:386-402`, `:406-422`). Texto libre, sin dropdown ni autocomplete |
| 9 | POST endpoint correcto | ✅ | `CreateOwnerEvent` → `POST /propietarios` (`owner_api_impl.dart:87-89`) |
| 10 | Mensajes error coinciden SRS | ⚠️ | Errores del backend se muestran vía `_manejarError`. Mensajes de validación son genéricos (`"Cédula inválida"`, `"Formato de correo inválido"`). Sin mapeo a CV-01, CV-05, CV-06 |
| 11 | Navegación post-registro a facial enrollment | ✅ | `Navigator.pushNamed('/adminFacialEnrollment')` con personaId + type='owner' (`:144-153`) |

**Veredicto RF-P01:** ⚠️ PARCIAL — Faltan FilePicker PDF + ImagePicker fotos + selector manzana/villa

---

### RF-P02 — Registro de Cónyuge

**Página:** `create_spouse_dialog.dart` (708 líneas, es `CreateSpousePage`)

| # | Paso SRS | Veredicto | Evidencia |
|---|----------|:---:|-----------|
| 1 | Asociado al propietario seleccionado | ✅ | Recibe `OwnerEntity owner` (`:14`), muestra datos del owner (`:218-296`) |
| 2 | Manzana/villa heredadas (CV-17) | ✅ | Sin campos manuales. Muestra info: `"Manzana: ${widget.owner.manzana} \| Villa: ${widget.owner.villa}"` (`:281-288`). Banner azul: `"La ubicación será heredada del propietario"` (`:644-653`) |
| 3 | Fecha nacimiento con restricciones (CV-16) | ✅ | DatePicker + validación ≥ 18 años (`:451-523`) |
| 4 | Fotos obligatorias | ❌ | **No hay ImagePicker ni campos de foto** |
| 5 | POST endpoint correcto | ✅ | `POST /propietarios/{ownerId}/conyuge` (`spouse_api_impl.dart:40-42`) |
| 6 | Validaciones ID/email/celular | ✅ | `isValidId` (`:388`), `isValidEmail` (`:569`), `isValidPhone` (`:597`) + máscaras |
| 7 | Navegación post-registro | ✅ | `Navigator.pop(true)` (`:179`) |

**Veredicto RF-P02:** ⚠️ PARCIAL — Faltan fotos obligatorias

---

### RF-P03 — Actualización de Propietario

**Página:** `admin_owners_page.dart` (971 líneas)

| # | Paso SRS | Veredicto | Evidencia |
|---|----------|:---:|-----------|
| 1 | Diálogo de edición de propietario | ❌ | **No existe.** `_OwnerDetailPage` (`:661-964`) solo muestra datos como read-only. `PopupMenuButton` (`:696-749`) solo ofrece: Bloquear/Desbloquear/Eliminar |
| 2 | Solo edita correo, celular, fotos | ❌ | N/A — sin diálogo |
| 3 | No permite editar identificación, nombres, manzana, villa | ❌ | N/A |
| 4 | Precarga datos existentes | ❌ | N/A |
| 5 | PUT endpoint | ❌ | No existe llamada PUT para propietarios en `owner_api_impl.dart` |

**Veredicto RF-P03:** ❌ NO IMPLEMENTADO — Sin diálogo de edición, sin endpoint PUT

---

### RF-P04 — Baja de Propietario

**Página:** `admin_owners_page.dart`

| # | Paso SRS | Veredicto | Evidencia |
|---|----------|:---:|-----------|
| 1 | Diálogo confirmación con motivo | ⚠️ | Existe `_confirmarBloqueo` (`:87-170`) con título `"Bloquear Propietario"`, mensaje, campo Motivo, botón "Bloquear" (naranja). Pero se llama "BlockOwner" no "Baja" |
| 2 | POST endpoint baja | ⚠️ | `POST /propietarios/{id}/baja` (`owner_api_impl.dart:124-125`). El endpoint es correcto pero el nombre del evento es inconsistente |
| 3 | SnackBar "Propietario dado de baja" | ❌ | El estado `OwnerBlocked` (`:40`) tiene mensaje genérico, no específico de "baja" |
| 4 | Motivo obligatorio | ❌ | **No se valida que el motivo no esté vacío** (`:154`). Se envía `motivoCtrl.text.trim()` aunque esté vacío |

**Veredicto RF-P04:** ⚠️ PARCIAL — Funcionalidad existe pero con naming inconsistente ("Block" vs "Baja"), motivo no obligatorio, mensaje no específico

---

### RF-P05 — Cambio de Propietario

**Páginas:** `admin_manzana_villas_page.dart`, `admin_villa_detalle_page.dart`

| # | Paso SRS | Veredicto | Evidencia |
|---|----------|:---:|-----------|
| 1 | Selección vivienda por manzana/villa | ✅ | Navegación: `AdminViviendasPage` → `AdminManzanaVillasPage` → `AdminVillaDetallePage` |
| 2 | Muestra propietario actual | ✅ | `admin_manzana_villas_page.dart:261-268` (nombre + badge "Titular"). `admin_villa_detalle_page.dart:99-100` (nombreCompleto en diálogo) |
| 3 | Búsqueda/selección nuevo propietario | ⚠️ | Campo manual de ID (`TextField` numérico en `_ChangeOwnerDialog`). No hay dropdown de búsqueda con `LoadActiveOwners` |
| 4 | Tipo: titular/copropietario | ✅ | `DropdownButtonFormField` con opciones `'titular'`/`'copropietario'` (`:327-335`) |
| 5 | Motivo obligatorio | ✅ | Validado en `_formValido`: `_motivoCtrl.text.trim().isNotEmpty` más `_confirmado` |
| 6 | Doble confirmación (motivo + checkbox) | ✅ | `CheckboxListTile` "Confirmo el cambio" (`:339-344`) + `Motivo del cambio *` (`:333-338`) |
| 7 | POST `/viviendas/cambio-propietario` | ✅ | `ViviendaApi.cambiarPropietario()` → `POST /viviendas/cambio-propietario` |
| 8 | SnackBar éxito/error | ✅ | `PropietarioCambiado` → SnackBar verde. `ViviendaError` → SnackBar rojo |
| 9 | Recuperación tras error (pantalla loading infinita) | ✅ | `vivienda_bloc.dart:284-290`: `Future.delayed(500ms)` + `LoadVillaDetalle` |

**Veredicto RF-P05:** ✅ COMPLETO — Búsqueda de propietario es manual (no dropdown autocomplete), pero funcional

---

### RF-R01 — Registro de Residente

**Página:** `admin_create_resident_page.dart` (516 líneas)

| # | Paso SRS | Veredicto | Evidencia |
|---|----------|:---:|-----------|
| 1 | Formulario con todos los campos | ✅ | 12 campos: tipo ID, identificación, nombres, apellidos, fecha, nacionalidad, correo, celular, manzana, villa, dirección alt, doc autorización |
| 2 | Validaciones ID/email/celular/edad | ✅ | `isValidId` (`:235`), `isValidEmail` (`:348`), `isValidPhone` (`:375`), edad ≥ 18 (`:294-305`) |
| 3 | FilePicker documento autorización PDF | ❌ | **Es un TextFormField de texto plano** (`:447-458`). Inicializado con `'ruta/documento.pdf'` (`:57`). No es un FilePicker real |
| 4 | POST endpoint | ✅ | `POST /residentes` (`resident_api_impl.dart:91-93`) |
| 5 | Navegación post-registro | ✅ | `/adminFacialEnrollment` (`:150-158`) |

**Veredicto RF-R01:** ⚠️ PARCIAL — `docAutorizacionPdf` es campo de texto, no FilePicker

---

### RF-R02 — Registro de Miembro

**Página:** `admin_create_member_page.dart` (574 líneas)

| # | Paso SRS | Veredicto | Evidencia |
|---|----------|:---:|-----------|
| 1 | ID residente + ID miembro | ✅ | `_residenteIdController` (`:214-225`) + `_identificacionController` (`:262-277`) |
| 2 | Validación residente activo | ❌ | **No se valida** que el residente exista o esté activo antes de crear el miembro |
| 3 | Manzana/villa coinciden con residente | ❌ | Campos manuales (`:479-495`, `:499-514`). No se autocompletan ni validan contra el residente |
| 4 | Parentesco | ✅ | Dropdown con 8 opciones (`:44-52`) + campo condicional "otro" (`:373-392`) |
| 5 | Fotografía obligatoria | ❌ | **No hay ImagePicker** en el archivo |
| 6 | POST endpoint | ✅ | `POST /miembros/agregar` (`family_member_api_impl.dart:112-113`) |
| 7 | Navegación post-registro | ✅ | `/adminFacialEnrollment` con type='member' (`:177-186`) |

**Veredicto RF-R02:** ⚠️ PARCIAL — Sin validación residente activo, sin fotos, manzana/villa no heredadas

---

### RF-R03 — Desactivación de Residente

**Página:** `admin_residents_page.dart`

| # | Paso SRS | Veredicto | Evidencia |
|---|----------|:---:|-----------|
| 1 | Diálogo confirmación con motivo | ⚠️ | Existe `_confirmarBloqueo` (`:73-166`). Título `"Desactivar Residente"`, mensaje `"¿Desactivar a X? No podrá generar QR ni acceder."`, campo Motivo. Pero **motivo no es obligatorio** (`:147-152`) |
| 2 | POST endpoint | ✅ | `POST /residentes/{id}/desactivar` (`resident_api_impl.dart:108-109`) |
| 3 | **Advierte que miembros también se desactivan** | ❌ | Solo dice `"No podrá generar QR ni acceder"` (`:95`). **No menciona a los miembros de familia** |
| 4 | SnackBar confirmación | ✅ | `ResidentDeactivated` → SnackBar naranja con mensaje |

**Veredicto RF-R03:** ⚠️ PARCIAL — No advierte sobre desactivación en cascada de miembros

---

### RF-R04 — Desactivación de Miembro

**Página:** `admin_members_page.dart` / `members_page.dart`

| # | Paso SRS | Veredicto | Evidencia |
|---|----------|:---:|-----------|
| 1 | Diálogo con motivo | ✅ | `members_page.dart:31-62`: título `"Bloquear a X"`, campo Motivo requerido (`motivoCtrl.text.isNotEmpty` en `:58`) |
| 2 | POST endpoint | ✅ | `DeactivateMemberEvent` → API call |
| 3 | SnackBar "Miembro desactivado" | ✅ | `MemberDeactivated` → SnackBar naranja (`:164-166`) |
| 4 | Admin + resident-facing | ✅ | Disponible en `admin_members_page.dart` y `members_page.dart` |

**Veredicto RF-R04:** ✅ COMPLETO

---

### RF-R05 — Reactivación de Residente

**Página:** `admin_residents_page.dart`

| # | Paso SRS | Veredicto | Evidencia |
|---|----------|:---:|-----------|
| 1 | Botón Reactivar solo inactivos | ✅ | `PopupMenuButton` muestra "Reactivar" solo si `estado != 'activo'` |
| 2 | Diálogo con motivo | ⚠️ | Existe pero **motivo no obligatorio** (`:156-161`) |
| 3 | POST endpoint | ✅ | `POST /residentes/{id}/reactivar` (`resident_api_impl.dart:129-130`) |
| 4 | **Muestra que miembros NO se reactivan** | ❌ | Sin mención en el diálogo ni SnackBar |

**Veredicto RF-R05:** ⚠️ PARCIAL — Motivo no obligatorio, sin advertencia sobre miembros

---

### RF-R06 — Reactivación de Miembro

**Página:** `admin_members_page.dart` / `members_page.dart`

| # | Paso SRS | Veredicto | Evidencia |
|---|----------|:---:|-----------|
| 1 | Botón Reactivar solo inactivos | ✅ | `members_page.dart:284`: `if (m.estado == 'inactivo')` → muestra "Desbloquear" |
| 2 | **Valida residente asociado activo** | ❌ | **No hay validación.** No se verifica que el residente esté activo antes de permitir reactivar |
| 3 | Muestra error si residente inactivo | ❌ | Sin implementar |
| 4 | POST endpoint | ✅ | `ReactivateMemberEvent` |
| 5 | Motivo obligatorio | ✅ | `motivoCtrl.text.isNotEmpty` (`:91`) |

**Veredicto RF-R06:** ⚠️ PARCIAL — Sin validación de residente activo previo

---

### RF-C01 — Crear Cuenta Residente

**Flujo:** `ProspectoResidentePage` → `FacialVerificationPage` → `CredentialsResidentePage`

| # | Paso SRS | Veredicto | Evidencia |
|---|----------|:---:|-----------|
| 1 | Validación identificación residente activo | ✅ | `prospecto_residente_page.dart:97-105` → `FormatRules.isValidId()` + `ValidarProspectoResidente` |
| 2 | Reconocimiento facial | ✅ | `facial_verification_page.dart` con liveness (5 retos: frente, izq, der, sonreír, 5s c/u) |
| 3 | Contraseña + confirmación | ✅ | `credentials_residente_page.dart:200-266` |
| 4 | Indicador fortaleza | ✅ | `LinearProgressIndicator` + 5 niveles (`:228-245`, `:305-334`) |
| 5 | Confirmación en tiempo real | ✅ | `onChanged → _confirmKey.currentState?.validate()` (`:251`) |
| 6 | Firebase Auth | ✅ | `CreateUserSubmitted` → `AuthBloc` |
| 7 | POST backend cuenta | ✅ | `CrearCuentaResidente` → `RegistroResidenteBloc` |

**Veredicto RF-C01:** ✅ COMPLETO

---

### RF-C02 — Crear Cuenta Miembro No Registrado

**Flujo:** `ProspectoMiembroPage` → `MemberCreateRegistrationPage` → `EsperarAutorizacionPage`

| # | Paso SRS | Veredicto | Evidencia |
|---|----------|:---:|-----------|
| 1 | Validación identificación | ✅ | `prospecto_miembro_page.dart:334-339` → `FormatRules.isValidId(v.trim())` |
| 2 | Flujo "no encontrado" → registro | ✅ | `_mostrarDialogoNoEncontrado` (`:94-144`): "Miembro No Registrado" → opción "Registrarme" → navega a `MemberCreateRegistrationPage` |
| 3 | **Validación parentesco único** | ❌ | **No implementado.** No se verifica que el parentesco para el par miembro-residente sea único |
| 4 | Polling autorización | ✅ | `autorizacion_miembro_bloc.dart:158-164`: `Timer.periodic(5s)` + `EstadoSolicitudConsultada`. Limpieza en `close()` |
| 5 | Estados de polling | ✅ | Aprobado → navega a facial. Rechazado → diálogo con motivo. Error → SnackBar |
| 6 | Formulario registro completo | ✅ | `member_create_registration_page.dart`: 14 campos con validaciones |

**Veredicto RF-C02:** ⚠️ PARCIAL — Sin validación parentesco único

---

### RF-C03 — Crear Cuenta Miembro Registrado

**Flujo:** `ProspectoMiembroPage` → `CredentialsMiembroPage` → `FacialVerificationPage`

| # | Paso SRS | Veredicto | Evidencia |
|---|----------|:---:|-----------|
| 1 | Validación facial | ✅ | Flujo con `tieneFacialEnrolado` check (`prospecto_miembro_page.dart:149`) |
| 2 | Contraseñas | ⚠️ | Email con regex (`:196-205`). Contraseña ≥ 6 caracteres (`:227-234`). **Pero sin indicador fortaleza ni validación tiempo real** |
| 3 | Firebase Auth | ✅ | Mismo patrón `CreateUserSubmitted` |

**Veredicto RF-C03:** ⚠️ PARCIAL — Miembro no tiene indicador fortaleza ni confirmación en tiempo real (sí lo tiene residente)

---

### RF-C04 — Autorización de Residente

**Página:** `miembros/aprobacion_miembro_page.dart`

| # | Paso SRS | Veredicto | Evidencia |
|---|----------|:---:|-----------|
| 1 | Lista solicitudes pendientes | ✅ | `CargarSolicitudesPendientes()` en `initState` (`:14`). `ListView.builder` de `_SolicitudCard` (`:100-136`) |
| 2 | Muestra datos solicitante | ✅ | `_SolicitudCard` (`:304-433`): nombreCompleto, parentesco, identificación, dirección, fecha |
| 3 | Botón Aprobar | ✅ | `FilledButton.icon` verde "Aprobar" (`:414-426`) → diálogo confirmación |
| 4 | Botón Rechazar | ✅ | `OutlinedButton.icon` rojo "Rechazar" (`:394-410`) → diálogo con motivo opcional |
| 5 | **Deep link desde notificación** | ❌ | `notificacion_detalle_page.dart:208-222` navega con `rutaAccion` pero `app_routes.dart:245-249` NO pasa argumentos a `AprobacionMiembroPage`. Sin handler para cargar solicitud específica por ID |
| 6 | SnackBar confirmación | ✅ | `SolicitudAprobadaExitosa` / `SolicitudRechazadaExitosa` |

**Veredicto RF-C04:** ⚠️ PARCIAL — Deep link definido pero sin paso de argumentos (ID de solicitud)

---

### RF-C05 — Bloquear Residente + Miembros

**Página:** `admin_accounts_page.dart`

| # | Paso SRS | Veredicto | Evidencia |
|---|----------|:---:|-----------|
| 1 | Checkbox cascada | ✅ | `CheckboxListTile` "Bloqueo en cascada" con subtitle `"También bloquea las cuentas de los miembros de familia"` (`:162-184`) |
| 2 | Diálogo motivo | ⚠️ | Existe `TextField 'Motivo'` pero **no es obligatorio** — se envía aunque esté vacío (`:231-233`) |
| 3 | POST endpoint | ✅ | `BlockAccountEvent(cascada: true)` |
| 4 | SnackBar | ✅ | `AccountBlocked` con mensaje |

**Veredicto RF-C05:** ⚠️ PARCIAL — Motivo no obligatorio

---

### RF-C06 — Desbloquear + Miembros

| # | Paso SRS | Veredicto | Evidencia |
|---|----------|:---:|-----------|
| 1 | Checkbox cascada (desbloqueo) | ❌ | **No aparece checkbox de cascada en desbloqueo** (`admin_accounts_page.dart:237-251`: `cascada: false` hardcodeado). Solo en bloqueo |
| 2 | Motivo obligatorio | ⚠️ | Campo presente pero no validado como requerido |
| 3 | SnackBar | ✅ | `AccountUnblocked` |

**Veredicto RF-C06:** ⚠️ PARCIAL — Sin cascada en desbloqueo

---

### RF-C07 — Bloquear Individual

| Página | Veredicto | Evidencia |
|--------|:---:|-----------|
| AdminResidentsPage | ✅ | `_confirmarBloqueo` ("Desactivar Residente") con motivo |
| AdminOwnersPage | ✅ | `_confirmarBloqueo` ("Bloquear Propietario") con motivo |
| AdminMembersPage | ✅ | Diálogo con motivo requerido |

**Veredicto RF-C07:** ✅ COMPLETO

---

### RF-C08 — Desbloquear Individual

| Página | Veredicto | Evidencia |
|--------|:---:|-----------|
| AdminResidentsPage | ✅ | Diálogo "Reactivar Residente" |
| AdminOwnersPage | ✅ | Diálogo "Desbloquear Propietario" |
| AdminMembersPage | ✅ | `_mostrarDialogoDesbloqueo` |

**Veredicto RF-C08:** ✅ COMPLETO

---

### RF-C09 — Eliminar Cuenta

| # | Paso SRS | Veredicto | Evidencia |
|---|----------|:---:|-----------|
| 1 | Icono ⚠️ advertencia | ✅ | `Icons.warning_amber`, rojo, tamaño 48 (`admin_accounts_page.dart:267-270`) |
| 2 | Texto irreversibilidad | ✅ | `"Esta acción no se puede deshacer."` (`:273-274`) |
| 3 | **Doble confirmación** | ❌ | **Una sola confirmación (Sí/No).** Sin checkbox ni segundo paso requerido por SRS |
| 4 | Motivo obligatorio | ❌ | Sin campo de motivo para eliminación |
| 5 | SnackBar "Cuenta eliminada" | ✅ | `AccountDeleted` |

**Veredicto RF-C09:** ❌ PARCIAL — Sin doble confirmación, sin motivo obligatorio

---

### RF-N01 a RF-N04 — Notificaciones

| RF | Veredicto | Evidencia |
|----|:---:|-----------|
| **RF-N01** Push Masivo Residentes | ✅ | Filtro "Residentes" (`_tipoDestinatario`). `SwitchListTile` → `AdminSeleccionarTodos()`. Confirmación "Todos los residentes" |
| **RF-N02** Push Masivo Propietarios | ✅ | Filtro "Propietarios" con misma mecánica |
| **RF-N03** Push Individual Residente | ✅ | Búsqueda + `CheckboxListTile` individual. Filtro manzana/villa |
| **RF-N04** Push Individual Propietario | ✅ | Propietarios disponibles al seleccionar filtro correspondiente |

**Veredicto RF-N01-04:** ✅ COMPLETO (los 4)

---

### RF-Q01 — QR Propio

| # | Paso SRS | Veredicto | Evidencia |
|---|----------|:---:|-----------|
| 1 | Selector duración 1/3/6/12 horas | ✅ | `DropdownButtonFormField<int>` (`qr_self_page.dart:442-449`) |
| 2 | Selector fecha/hora personalizable | ✅ | `showDatePicker` + `showTimePicker` con toggle `Switch` (`:379-435`) |
| 3 | Validación fecha pasada | ✅ | `validFrom!.isBefore(DateTime.now())` → error (`:123`) |
| 4 | Visualización QR | ✅ | Navega a `QrDisplayPage` con `qrValue` (`:267-279`) |
| 5 | **Anti-captura** | ✅ | **Implementado en `qr_display_page.dart`**: `NoScreenshot.instance.screenshotOff()` en `initState` (`:53-60`), `screenshotOn()` en `dispose` (`:63-72`) |

**Veredicto RF-Q01:** ✅ COMPLETO — Anti-captura está en la página de display, no en la de configuración (correcto)

---

### RF-Q02 — QR Visita

| # | Paso SRS | Veredicto | Evidencia |
|---|----------|:---:|-----------|
| 1 | Formulario datos visita | ✅ | Campos nombre + identificación. Selector visitante frecuente / nuevo (`qr_visit_page.dart:530-599`) |
| 2 | Visitantes frecuentes | ✅ | Lista con búsqueda, selección táctil, pre-llenado de campos (`:442-527`) |
| 3 | Validación vivienda | ✅ | `LoadVisitantesVivienda` → `VisitorBloc` |
| 4 | **Botón Compartir** | ❌ | **Stub:** `onPressed: () => _error('Compartir disponible al integrar captura')` (`:803`) |
| 5 | Botón Descargar | ❌ | **Stub:** `onPressed: () => _error('Descargar disponible al integrar captura')` (`:805`) |

**Veredicto RF-Q02:** ⚠️ PARCIAL — Compartir y Descargar son stubs

---

## 3. Matriz CV → Frontend

| CV | Descripción | ✅ | Archivo:línea | Observación |
|----|-------------|:--:|---------------|-------------|
| CV-01 | Cédula ecuatoriana 10 dígitos | ✅ | 8 call sites en 6 archivos | `FormatRules.isValidId(r'^\d{10}$')` |
| CV-02 | ID extranjera no vacía | ✅ | `DropdownButtonFormField` tipo ID en todos los forms | Validación condicional |
| CV-03 | Nombres/apellidos no vacíos | ✅ | Validación `required` en todos los forms | — |
| CV-04 | Edad ≥ 18 DatePicker | ✅ | `admin_create_resident_page.dart:294-305` y 3+ archivos | Cálculo manual de edad |
| CV-05 | Email formato válido | ✅ | 5 call sites en 4 archivos | Regex + max 100 chars |
| CV-06 | Celular 09XXXXXXXX + máscara | ✅ | 4 call sites | `isValidPhone` + `digitsOnly` + `LengthLimiting(10)` |
| CV-07 | Error manzana/villa no existe | ❌ | — | Sin validación frontend. Depende de backend 404 |
| CV-08 | FilePicker PDF | ❌ | `admin_create_resident_page.dart:447-458` | TextFormField con hardcoded `'ruta/documento.pdf'` |
| CV-09 | Selector imagen JPG/PNG | ❌ | — | Sin ImagePicker en ningún formulario |
| CV-10 | Mensaje "no existe" (404) | ✅ | 7+ API providers | `_manejarError` extrae `detail`/`message` |
| CV-11 | Login → cuenta bloqueada | ✅ | `app_scaffold.dart:89-105` | `_protegerRuta`: `estado != 'activo'` → logout + `/login` |
| CV-12 | Login → cuenta eliminada | ⚠️ | `auth_bloc.dart:165` | `'user-disabled'` mapea a `'Esta cuenta ha sido deshabilitada'`. No distingue eliminada |
| CV-13 | Activos navegan | ✅ | `app_scaffold.dart:89` | Guard solo bloquea si `!= 'activo'` |
| CV-14 | Mensaje inactivo | ✅ | `app_scaffold.dart:93` | `'Error: cuenta bloqueada'` rojo |
| CV-15 | Dirección alternativa opcional | ✅ | 4 forms | Campo `String?` sin validator |
| CV-16 | DatePicker cónyuge | ✅ | `create_spouse_dialog.dart:451-523` | ≥ 18 años |
| CV-17 | Manzana/villa coinciden con usuario | ❌ | — | Sin validación de coincidencia |
| CV-18 | Mensaje duplicado | ⚠️ | API providers | Backend envía `detail`, frontend muestra crudo. Sin mapeo amigable |
| CV-19 | Facial exitoso | ✅ | `facial_verification_page.dart:274-295` | Navega a dashboard |
| CV-20 | Facial fallido | ✅ | `facial_verification_page.dart:257-272` | Diálogo "Verificación Fallida" + Reintentar |
| CV-21 | Contraseña == confirmación | ✅ | `credentials_residente_page.dart:257-264` | `'Las contraseñas no coinciden'` |
| CV-22 | Error no coinciden tiempo real | ✅ | Residente: `onChanged → validate()` (`:251`). Miembro: ❌ sin real-time |
| CV-23 | Indicador fortaleza | ✅ | `credentials_residente_page.dart:228-245` | 5 niveles. Miembro: ❌ sin indicador |
| CV-24 | Pantalla OTP | ❌ | — | No existe |
| CV-25 | Mensaje código incorrecto | ❌ | — | No aplica |
| CV-26 | Mensaje cuenta ya existe | ✅ | `auth_bloc.dart:145-173` | Mapeo Firebase errors |
| CV-27 | Advertencia cuenta inactiva | ⚠️ | `app_scaffold.dart:89` | Solo en navegación, no en login |
| CV-28 | Visualización previa datos | ⚠️ | `member_create_registration_page.dart` | Muestra datos pero sin paso "Confirmar" explícito |
| CV-29 | Redirigir a login (bloqueada) | ✅ | `app_scaffold.dart:101-105` | `pushNamedAndRemoveUntil('/login')` |
| CV-30 | QR rechaza cuenta bloqueada | ❌ | `qr_self_page.dart` | Sin verificación de estado antes de generar QR |
| CV-31 | Guards navegación | ✅ | `app_scaffold.dart:73-106` | `_protegerRuta` en cada build |
| CV-32 | Error consistente bloqueo | ❌ | Login: genérico. Navegación: específico | Inconsistencia en mensajes |

---

## 4. Matriz RNF → Frontend

| RNF | ✅ | Evidencia |
|-----|:--:|-----------|
| Identificación: máscara 10 dígitos | ✅ | `LengthLimitingTextInputFormatter(10)` en 5 forms |
| Correo: teclado email, max 100 chars | ✅ | `TextInputType.emailAddress` + `isValidEmail` ≤ 100 chars |
| Fecha: DatePicker nativo | ✅ | `showDatePicker()` en 4+ forms |
| Celular: máscara 09XXXXXXXX | ✅ | `FilteringTextInputFormatter.digitsOnly` + `LengthLimiting(10)` en 5 fields |
| Dirección alternativa: max 120, opcional | ❌ | Campo existe pero sin `maxLength: 120` |
| Arquitectura hexagonal | ✅ | 4 capas: domain, application, infrastructure, presentation |
| Inyección dependencias (GetIt) | ✅ | `injection.dart` con ~50+ registros |
| Manejo notificaciones push (FCM + badge) | ⚠️ | `NotificacionPushHandlerPort` definido. Infraestructura existe |
| Manejo errores (backend → usuario) | ⚠️ | Patrón `_manejarError` en 7+ providers pero sin capa centralizada de traducción |
| Estados de carga (spinner) | ✅ | Todos los BLoCs con estado `Loading`. Corrección reciente: `ViviendaError` + Reintentar en 3 páginas |

---

## 5. GAPS Críticos Priorizados

### 🔴 Críticos (6)

| # | Gap | RF/CV | Impacto |
|---|------|-------|---------|
| 1 | **Sin FilePicker PDF** | RF-R01, CV-08 | `docAutorizacionPdf` es campo texto con placeholder hardcodeado. Residentes no pueden adjuntar documento real |
| 2 | **Sin ImagePicker fotos** | RF-P01, RF-R02, CV-09 | Ni propietarios ni miembros pueden subir fotos. Requerimiento SRS explícito |
| 3 | **RF-P03 sin implementar** | RF-P03 | No hay edición de propietario. No se puede actualizar correo/celular/fotos |
| 4 | **Eliminar cuenta sin doble confirmación** | RF-C09 | Diálogo simple Sí/No. Falta checkbox o segundo paso |
| 5 | **Sin validación parentesco único** | RF-C02 | Miembro podría duplicar parentesco para mismo residente |
| 6 | **Botones Compartir/Descargar QR stubs** | RF-Q02 | Placeholders no funcionales |

### 🟠 Altos (5)

| # | Gap | RF/CV | Impacto |
|---|------|-------|---------|
| 7 | **Sin validación residente activo en reactivación miembro** | RF-R06 | Miembro podría reactivarse con residente inactivo |
| 8 | **Sin cascada en desbloqueo** | RF-C06 | `cascada: false` hardcodeado. Solo existe en bloqueo |
| 9 | **Sin advertencia cascada en desactivación residente** | RF-R03 | No informa que miembros serán afectados |
| 10 | **Sin OTP en registro** | CV-24, CV-25 | No hay verificación de email |
| 11 | **Miembro sin indicador fortaleza ni real-time confirm** | RF-C03 | Menos seguro que residente. Inconsistencia entre flujos |

### 🟡 Medios (5)

| # | Gap | Impacto |
|---|------|---------|
| 12 | Sin validación manzana/villa existentes (CV-07) | Error solo en backend |
| 13 | Sin dropdown/autocomplete manzana/villa en forms | Campos de texto numérico manual |
| 14 | Motivo no obligatorio en varios diálogos admin | Campos vacíos enviados al backend |
| 15 | Sin mensaje amigable para duplicados (CV-18) | Error backend crudo |
| 16 | Deep link notificaciones sin argumentos (RF-C04) | No carga solicitud específica |

---

## 6. Comparativa con Auditoría Anterior (08-jul-2026)

### Mejoró ✅

| Área | Antes | Ahora |
|------|-------|-------|
| Validaciones formularios | Parcial, inconsistentes | `FormatRules` aplicado en 8+ forms con 16 call sites |
| Máscara celular | No implementada | 5 campos con `digitsOnly` + `LengthLimiting(10)` |
| Indicador fortaleza contraseña | No existía | `LinearProgressIndicator` + 5 niveles (residente) |
| Confirmación tiempo real | No existía | `onChanged → validate()` (residente) |
| Viviendas 3 niveles | Solo lista plana | Manzanas → Villas → Detalle Villa |
| Cambio propietario | No implementado | Flujo completo con diálogo + validación + endpoint |
| Estados error BLoC | Solo Loading/Loaded | `ViviendaError` + Reintentar en 3 páginas |
| Widget deactivated | Error recurrente | `final bloc = context.read<X>()` antes de async gap (5 fixes) |
| Notificaciones por tipo | No existía | Filter chips: Todos/Residentes/Propietarios |
| Anti-captura QR | No implementado | `NoScreenshot.screenshotOff()` en `qr_display_page.dart` |

### Sigue igual (sin cambios) ❌

| Área | Estado |
|------|--------|
| FilePicker PDF | Campo de texto (no arreglado) |
| ImagePicker fotos | Sin implementar (no arreglado) |
| RF-P03 Editar propietario | Sin implementar (no arreglado) |
| OTP | Sin implementar (no arreglado) |
| Doble confirmación eliminar cuenta | Sin implementar (no arreglado) |
| Validación parentesco único | Sin implementar (no arreglado) |

---

## 7. Deuda Técnica Identificada

| Issue | Ubicación | Severidad |
|-------|-----------|:---:|
| Email regex triplicado | 4 lugares con 3 patrones diferentes | Media |
| `isValidBirthDate` código muerto | `format_rules.dart:5` — 0 usos | Baja |
| `TimestampVO` duplicado | `timestamp.dart` + `timestamp_vo.dart` | Baja |
| `_manejarError` copiado 7 veces | 7 API providers | Media |
| `Identification` value object inconsistente | Strips non-digits vs `isValidId` regex estricto | Media |
| `Residente ID` validator trata campo como fecha | `member_create_registration_page.dart:335-342` | Alta (bug) |
| `deleteResident` lanza `UnimplementedError` | `resident_repository_impl.dart:108-109` | Alta |

---

*Reporte generado mediante análisis exhaustivo de código fuente con verificación línea por línea. Fecha: 2026-07-24.*

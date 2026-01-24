# Roadmap de Desarrollo - Módulo de Administración

**Documento:** Plan detallado de tareas pendientes  
**Última actualización:** Enero 24, 2026  
**Versión:** 1.0

---

## 🎯 Fase 1: CRÍTICO (Semanas 1-2)

### Tarea 1: RF-P05 - Cambio de Propietario de Vivienda

**Descripción:** Implementar flujo completo de cambio de propietario de una vivienda.

**Entregables:**

1. **Página UI: `admin_change_owner_page.dart`**
   ```dart
   - StatefulWidget con 4 pasos (wizard)
   - Paso 1: Búsqueda de vivienda (manzana/villa)
   - Paso 2: Confirmación de propietario actual
   - Paso 3: Ingreso de nuevo propietario (formulario RF-P01)
   - Paso 4: Confirmación y resumen de cambios
   ```

2. **Eventos y Estados BLoC**
   ```dart
   class OwnerChangeEvent
   class SearchPropertyEvent
   class ConfirmPropertyEvent
   class ValidateNewOwnerEvent
   class ConfirmOwnerChangeEvent
   
   class OwnerChangeLoading
   class PropertyFound
   class PropertyNotFound
   class NewOwnerValidated
   class OwnerChangedSuccessfully
   class OwnerChangeError
   ```

3. **Adaptador de API**
   ```dart
   Future<Map> searchProperty(String manzana, String villa)
   Future<Map> getPropertyOwner(int propertyId)
   Future<bool> changePropertyOwner(
     int propertyId,
     int oldOwnerId,
     int newOwnerId,
     String reason,
     String newOwnerData
   )
   ```

4. **Validaciones**
   - ✅ Vivienda existe
   - ✅ Propietario actual está activo
   - ✅ Nuevo propietario cumple RF-P01
   - ✅ Motivo obligatorio (CV-10)
   - ✅ Confirmación visual (CV-28)
   - ✅ No hay otro propietario activo en esa vivienda

5. **Lógica de Negocio**
   ```dart
   1. Obtener propietario actual
   2. Desactivar propietario actual
   3. Registrar nuevo propietario (usa RF-P01)
   4. Si residente == propietario anterior:
      → Registrar nuevo propietario como residente
   5. Actualizar relación vivienda-propietario
   6. Bitácora: tipo=CHANGE_OWNER, 
              old_owner_id, new_owner_id, reason
   ```

6. **Interfaz en `/adminOwners`**
   ```dart
   - Agregar botón "Cambiar Propietario" por cada vivienda
   - Navegar a /adminChangeOwner con {manzana, villa}
   - Retornar a /adminOwners después de éxito
   ```

7. **Testing**
   - [ ] Búsqueda exitosa de vivienda
   - [ ] Búsqueda fallida (vivienda no existe)
   - [ ] Propietario no está activo (error)
   - [ ] Nuevo propietario con datos inválidos (error)
   - [ ] Cambio exitoso sin residente
   - [ ] Cambio exitoso con auto-registro de residente
   - [ ] Bitácora registrada correctamente

**Archivos a crear/modificar:**
- [ ] `lib/presentation/pages/admin_change_owner_page.dart` (CREAR)
- [ ] `lib/application/blocs/owner/owner_change_event.dart` (CREAR)
- [ ] `lib/application/blocs/owner/owner_change_state.dart` (CREAR)
- [ ] `lib/application/blocs/owner/owner_change_bloc.dart` (CREAR)
- [ ] `lib/infrastructure/adapters/admin_api.dart` (MODIFICAR - agregar método)
- [ ] `lib/presentation/pages/admin_owners_page.dart` (MODIFICAR - agregar botón)
- [ ] `lib/presentation/routes/app_routes.dart` (MODIFICAR - agregar ruta)

---

### Tarea 2: RF-C05 - Bloquear Cuenta (Residente + Miembros)

**Descripción:** Bloquear cuenta de residente y todos sus miembros de familia automáticamente.

**Entregables:**

1. **Modal/Diálogo: `_BlockAccountDialog`**
   ```dart
   - Búsqueda por identificación
   - Mostrar datos: nombres, apellidos, email
   - Campo obligatorio: motivo de bloqueo
   - Confirmación (Sí/No)
   - Avisar: "Se bloquearán N miembros de familia también"
   ```

2. **Eventos y Estados BLoC**
   ```dart
   class SearchAccountEvent
   class BlockAccountEvent
   
   class AccountSearchLoading
   class AccountFound
   class AccountNotFound
   class AccountAlreadyBlocked
   class BlockAccountLoading
   class AccountBlockedSuccessfully
   class BlockAccountError
   ```

3. **Adaptador de API**
   ```dart
   Future<Map> searchAccount(String identificacion)
   Future<List> getFamilyMembers(int residenteId)
   Future<bool> blockAccount(int personaId, String reason)
   Future<bool> blockFamilyMembers(int residenteId, String reason)
   ```

4. **Validaciones**
   - ✅ Identificación válida (CV-07)
   - ✅ Cuenta existe
   - ✅ Cuenta no está bloqueada (CV-27)
   - ✅ Motivo obligatorio (CV-10)
   - ✅ Confirmación visual (CV-28)

5. **Lógica de Negocio**
   ```dart
   1. Validar identificación
   2. Buscar cuenta
   3. Validar estado: debe estar activa
   4. Obtener lista de miembros de familia
   5. Cambiar estado de residente a inactivo
   6. Cambiar estado de todos los miembros a inactivo
   7. Actualizar auth: rechazar login de esta persona
   8. Bitácora: BLOCK_ACCOUNT, residente_id, 
              members_count, reason
   ```

6. **Integración con AuthBloc**
   ```dart
   // En login, validar:
   if (account.status == 'blocked') {
     return LoginError('Error: cuenta bloqueada')
   }
   
   // En acceso a funcionalidades privadas (CV-31, CV-32)
   if (currentUser.status == 'blocked') {
     return AccessDenied('Error: cuenta bloqueada')
   }
   ```

7. **Interfaz en `/adminAccounts` o `/adminUsers`**
   ```dart
   - Nueva sección: "Bloquear Cuenta"
   - Campo de búsqueda
   - Botón: "Buscar y Bloquear"
   - Modal con diálogo
   ```

8. **Testing**
   - [ ] Búsqueda exitosa de cuenta
   - [ ] Búsqueda fallida
   - [ ] Cuenta ya bloqueada (advertencia)
   - [ ] Bloqueo exitoso de residente
   - [ ] Auto-bloqueo de 3 miembros de familia
   - [ ] Miembros NO pueden iniciar sesión
   - [ ] Residente NO puede iniciar sesión
   - [ ] Bitácora registrada
   - [ ] No se puede acceder a funcionalidades privadas

**Archivos a crear/modificar:**
- [ ] `lib/presentation/pages/admin_accounts_page.dart` (CREAR o MODIFICAR)
- [ ] `lib/application/blocs/account/account_event.dart` (CREAR)
- [ ] `lib/application/blocs/account/account_state.dart` (CREAR)
- [ ] `lib/application/blocs/account/account_bloc.dart` (CREAR)
- [ ] `lib/infrastructure/adapters/admin_api.dart` (MODIFICAR)
- [ ] `lib/application/blocs/auth/auth_bloc.dart` (MODIFICAR - agregar validación)
- [ ] `lib/presentation/routes/app_routes.dart` (MODIFICAR - agregar ruta si es nueva página)

---

### Tarea 3: RF-C06 - Desbloquear Cuenta (Residente + Miembros)

**Descripción:** Desbloquear cuenta de residente e inmediatamente desbloquear todos sus miembros.

**Entregables:** (Similar a RF-C05, invertido)

1. **Modal/Diálogo: `_UnblockAccountDialog`**
   - Búsqueda por identificación
   - Validación: debe estar bloqueada
   - Campo obligatorio: motivo de desbloqueo
   - Confirmación
   - Avisar: "Se desbloquearán N miembros también"

2. **Eventos y Estados BLoC**
   ```dart
   class UnblockAccountEvent
   
   class UnblockAccountLoading
   class AccountUnblockedSuccessfully
   class AccountNotBlocked
   class UnblockAccountError
   ```

3. **Lógica de Negocio**
   ```dart
   1. Validar identificación
   2. Buscar cuenta: debe estar bloqueada
   3. Obtener lista de miembros
   4. Cambiar estado de residente a activo
   5. Cambiar estado de todos los miembros a activo
   6. Permitir login nuevamente
   7. Bitácora: UNBLOCK_ACCOUNT, residente_id, 
              members_count, reason
   ```

4. **Interfaz en `/adminAccounts`**
   - Sección: "Desbloquear Cuenta"
   - Similar a bloqueo
   - Validación adicional: "Debe estar bloqueada"

5. **Testing**
   - [ ] Desbloqueo exitoso
   - [ ] Cuenta no está bloqueada (error)
   - [ ] Auto-desbloqueo de miembros
   - [ ] Residente puede iniciar sesión nuevamente
   - [ ] Miembros pueden iniciar sesión
   - [ ] Bitácora registrada

**Archivos a modificar:**
- [ ] `lib/presentation/pages/admin_accounts_page.dart`
- [ ] `lib/application/blocs/account/account_event.dart`
- [ ] `lib/application/blocs/account/account_state.dart`
- [ ] `lib/infrastructure/adapters/admin_api.dart`

---

### Tarea 4: RF-C07 - Bloquear Cuenta Individual

**Descripción:** Bloquear una sola cuenta (residente O miembro) sin afectar a otros.

**Entregables:**

1. **Modal/Diálogo: `_BlockIndividualDialog`**
   - Similar a RF-C05
   - Pero: bloquea SOLO esa persona
   - Aclaración: "Esto NO afectará a otros miembros de familia"

2. **Eventos y Estados**
   ```dart
   class BlockIndividualAccountEvent
   
   class IndividualAccountBlockedSuccessfully
   ```

3. **Lógica diferencia con RF-C05**
   ```dart
   // RF-C05: Bloquea residente + TODOS los miembros
   // RF-C07: Bloquea solo 1 persona (puede ser residente O miembro)
   
   // Si es residente:
   blockAccount(residenteId) // Solo residente
   
   // Si es miembro:
   blockAccount(miembroId) // Solo ese miembro
   
   // NO afecta a otros miembros de la familia
   ```

4. **Interfaz en `/adminAccounts`**
   - Sección: "Bloquear Cuenta Individual"
   - Búsqueda por ID
   - Mostrar: nombre, apellido, tipo (residente/miembro), vivienda
   - Advertencia: "Otros miembros NO serán afectados"

5. **Testing**
   - [ ] Bloqueo de residente solamente
   - [ ] Bloqueo de un miembro de familia
   - [ ] Otros miembros permanecen activos
   - [ ] Usuario bloqueado NO puede iniciar sesión
   - [ ] Otros usuarios pueden iniciar sesión
   - [ ] Bitácora registrada correctamente

---

### Tarea 5: RF-C08 - Desbloquear Cuenta Individual

**Descripción:** Desbloquear una sola cuenta sin afectar a otros.

**Similar a RF-C07 pero en sentido inverso.**

---

### Tarea 6: RF-C09 - Eliminar Cuenta Definitivamente

**Descripción:** Eliminar de forma PERMANENTE E IRREVERSIBLE una cuenta.

**Entregables:**

1. **Modal/Diálogo: `_DeleteAccountDialog`**
   ```dart
   - Búsqueda por identificación
   - Mostrar datos personales
   - ADVERTENCIA GRANDE: 
     "Esta acción es PERMANENTE e IRREVERSIBLE
      La cuenta NO podrá ser recuperada"
   - Campo obligatorio: motivo de eliminación
   - Confirmación final (Sí/No)
   - Validación: escribir "ELIMINAR" para confirmar
   ```

2. **Eventos y Estados**
   ```dart
   class DeleteAccountEvent
   
   class DeleteAccountLoading
   class AccountDeletedSuccessfully
   class AccountAlreadyDeleted
   class DeleteAccountError
   ```

3. **Lógica de Negocio**
   ```dart
   1. Validar identificación
   2. Buscar cuenta
   3. Validar que NO esté ya eliminada
   4. Mostrar advertencia muy clara
   5. Pedir confirmación final
   6. Marcar: cuenta.deleted = true
   7. Rechazar login: "Error: cuenta no existe"
   8. Rechazar acceso a funcionalidades: "Cuenta no existe"
   9. Rechazar reactivación: "Cuenta no existe"
   10. Bitácora: DELETE_ACCOUNT, persona_id, reason
   ```

4. **Diferencia: Bloqueado vs Eliminado**
   ```dart
   // BLOQUEADO (Reversible)
   cuenta.status = 'blocked' // Se puede desbloquear
   
   // ELIMINADO (Irreversible)
   cuenta.deleted = true // NO se puede recuperar
   ```

5. **Interfaz en `/adminAccounts`**
   - Sección: "Eliminar Cuenta Definitivamente"
   - Búsqueda por ID
   - Mostrar: nombre, apellido, tipo, vivienda
   - Botón: "Proceder a Eliminación"
   - Modal con confirmación

6. **Testing**
   - [ ] Búsqueda exitosa
   - [ ] Cuenta ya eliminada (error)
   - [ ] Eliminación exitosa
   - [ ] Cuenta NO puede iniciar sesión (error: cuenta no existe)
   - [ ] NO se puede reactivar (error: cuenta no existe)
   - [ ] NO se puede usar como referencia (error: cuenta no existe)
   - [ ] Bitácora registrada
   - [ ] Datos históricos preservados (auditoría)

**Archivos a crear/modificar:**
- [ ] `lib/presentation/pages/admin_accounts_page.dart`
- [ ] `lib/application/blocs/account/account_event.dart`
- [ ] `lib/application/blocs/account/account_state.dart`
- [ ] `lib/infrastructure/adapters/admin_api.dart`

---

## 🟡 Fase 2: IMPORTANTE (Semanas 3-4)

### Tarea 7: RF-P02 - Registro de Cónyuge

**Descripción:** Permitir registro del cónyuge asociado a un propietario.

**Entregables:**

1. **Página: `admin_create_spouse_page.dart`**
   - Similar a `admin_create_member_page.dart`
   - Búsqueda de propietario por ID
   - Validación: solo un cónyuge por propietario activo

2. **Eventos y Estados BLoC**
   ```dart
   class CreateSpouseEvent
   class SpouseCreatedSuccessfully
   ```

3. **Formulario de Cónyuge**
   - Identificación
   - Nombres, Apellidos
   - Fecha de nacimiento
   - Correo electrónico
   - Celular
   - Fotos de rostro (mínimo 2)
   - Facial enrollment

4. **Validaciones**
   - ✅ Solo un cónyuge por propietario
   - ✅ Propietario existe y está activo
   - ✅ Fotos obligatorias
   - ✅ Todas las CV-* transversales

5. **Integración**
   - Opción en `/adminOwners`
   - Botón "Registrar Cónyuge" después de registrar propietario
   - Navegación a facial enrollment con `type: 'spouse'`
   - Mensaje: "Cónyuge registrado correctamente"

---

### Tarea 8: RF-P03 - Actualización de Propietario

**Descripción:** Permitir actualización de datos de contacto del propietario.

**Entregables:**

1. **Modal/Página de Edición**
   - Búsqueda de propietario por ID
   - Mostrar datos actuales
   - Campos editables:
     - Correo electrónico
     - Celular
     - Fotos de rostro
   - Campos NO editables:
     - Identificación
     - Nombres, Apellidos
     - Fecha de nacimiento

2. **Eventos y Estados**
   ```dart
   class UpdateOwnerEvent
   class OwnerUpdatedSuccessfully
   ```

3. **Interfaz en `/adminOwners`**
   - Botón "Editar" por cada propietario
   - Modal con formulario
   - Confirmación de cambios

4. **Bitácora**
   - Registrar valores antiguos y nuevos
   - Tipo: UPDATE_OWNER

---

## 🟢 Fase 3: MEJORA (Semana 5)

### Tarea 9: Dashboard Avanzado

**Enhancements:**
- Gráficos de accesos por hora
- Métricas de bloqueados
- Alertas de seguridad
- Residentes sin foto

### Tarea 10: Historial Avanzado

**Enhancements:**
- Filtros por tipo
- Búsqueda por manzana
- Exportación a reportes

### Tarea 11: Desactivación/Reactivación

**Implementar:**
- RF-R03, RF-R04, RF-R05, RF-R06

---

## 📋 Checklist General

Para cada tarea:

- [ ] Crear estructura de carpetas necesarias
- [ ] Crear evento/estado BLoC
- [ ] Crear bloc principal
- [ ] Crear página/widget UI
- [ ] Crear adaptador de API
- [ ] Integrar validaciones (CV-*)
- [ ] Agregar ruta en `app_routes.dart`
- [ ] Crear unit tests para lógica
- [ ] Crear widget tests para UI
- [ ] Crear integration tests
- [ ] Documentar en README
- [ ] Code review
- [ ] Testing manual

---

## 📊 Métricas de Progreso

Actualizar semanalmente:

| Tarea | Estado | % Completitud | Bloqueadores |
|---|---|---|---|
| RF-P05 | ❌ Not Started | 0% | - |
| RF-C05 | ❌ Not Started | 0% | - |
| RF-C06 | ❌ Not Started | 0% | RF-C05 |
| RF-C07 | ❌ Not Started | 0% | RF-C05 |
| RF-C08 | ❌ Not Started | 0% | RF-C07 |
| RF-C09 | ❌ Not Started | 0% | - |
| RF-P02 | ❌ Not Started | 0% | - |
| RF-P03 | ❌ Not Started | 0% | - |

---

**Documento listo para iniciar desarrollo**

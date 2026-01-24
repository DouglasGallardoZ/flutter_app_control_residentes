# Tracker de Progreso - Módulo de Administración

**Última actualización:** Enero 24, 2026  
**Formato:** Actualizar semanalmente

---

## 📅 Timeline de Desarrollo

### Semana 1 (Enero 24 - Enero 31)

#### Tarea 1: RF-C05 - Bloquear Cuenta (Residente + Miembros)
- [ ] Crear página `/adminAccounts` o mejorar existente
- [ ] Crear BLoC: `account_bloc.dart`, `account_event.dart`, `account_state.dart`
- [ ] Crear métodos API: `blockAccount()`, `blockFamilyMembers()`
- [ ] Implementar modal/diálogo de búsqueda
- [ ] Implementar validaciones (CV-*)
- [ ] Integrar con AuthBloc (rechazar login)
- [ ] Crear tests
- [ ] Merge a main
- **Estado:** ❌ Not Started
- **Estimación:** 16h
- **Horas usadas:** 0h

#### Tarea 2: RF-P05 - Cambio de Propietario de Vivienda
- [ ] Crear página `admin_change_owner_page.dart` (wizard 4 pasos)
- [ ] Crear BLoC: `owner_change_bloc.dart`, eventos, estados
- [ ] Crear métodos API: `changePropertyOwner()`, `searchProperty()`
- [ ] Paso 1: Búsqueda de vivienda
- [ ] Paso 2: Confirmación de propietario actual
- [ ] Paso 3: Datos de nuevo propietario
- [ ] Paso 4: Confirmación y resumen
- [ ] Lógica: desactivar anterior, registrar nuevo, auto-residente
- [ ] Integrar en `/adminOwners` (botón "Cambiar propietario")
- [ ] Crear tests
- [ ] Merge a main
- **Estado:** ❌ Not Started
- **Estimación:** 16h
- **Horas usadas:** 0h

---

### Semana 2 (Enero 31 - Febrero 7)

#### Tarea 3: RF-C06 - Desbloquear Cuenta
- [ ] Agregar métodos API: `unblockAccount()`, `unblockFamilyMembers()`
- [ ] Agregar eventos/estados en BLoC
- [ ] Crear modal/diálogo para desbloqueo
- [ ] Validar: cuenta debe estar bloqueada
- [ ] Auto-desbloqueo de miembros
- [ ] Restaurar permisos de login
- [ ] Crear tests
- [ ] Merge a main
- **Estado:** ❌ Not Started
- **Estimación:** 8h
- **Horas usadas:** 0h

#### Tarea 4: RF-C07 - Bloquear Cuenta Individual
- [ ] Agregar métodos API: `blockIndividualAccount()`
- [ ] Agregar eventos/estados en BLoC
- [ ] Crear modal para bloqueo individual
- [ ] Validar: bloquea solo esa persona
- [ ] Otros miembros NO se afectan
- [ ] Crear tests
- [ ] Merge a main
- **Estado:** ❌ Not Started
- **Estimación:** 6h
- **Horas usadas:** 0h

#### Tarea 5: RF-C08 - Desbloquear Cuenta Individual
- [ ] Similar a C07 en sentido inverso
- [ ] Agregar métodos API
- [ ] Agregar eventos/estados
- [ ] Crear modal
- [ ] Crear tests
- [ ] Merge a main
- **Estado:** ❌ Not Started
- **Estimación:** 6h
- **Horas usadas:** 0h

#### Tarea 6: RF-C09 - Eliminar Cuenta Definitivamente
- [ ] Agregar métodos API: `deleteAccount()`
- [ ] Agregar eventos/estados en BLoC
- [ ] Crear modal CON ADVERTENCIA CRÍTICA
- [ ] Validación: escribir "ELIMINAR" para confirmar
- [ ] Marcar: deleted = true (no reversible)
- [ ] Rechazar login: "Cuenta no existe"
- [ ] Crear tests
- [ ] Merge a main
- **Estado:** ❌ Not Started
- **Estimación:** 8h
- **Horas usadas:** 0h

**Semana 1-2 Total:**
- Estimado: 60 horas
- Completado: 0%
- En progreso: 0%
- Bloqueadores: Ninguno

---

### Semana 3 (Febrero 7 - Febrero 14)

#### Tarea 7: RF-P02 - Registro de Cónyuge
- [ ] Crear página `admin_create_spouse_page.dart`
- [ ] Crear eventos/estados para cónyuge
- [ ] Búsqueda de propietario por ID
- [ ] Validar: solo 1 cónyuge por propietario
- [ ] Formulario de cónyuge
- [ ] Fotos de rostro obligatorias
- [ ] Facial enrollment con type: "spouse"
- [ ] Mensaje: "Cónyuge registrado correctamente"
- [ ] Agregar opción en `/adminOwners`
- [ ] Crear tests
- [ ] Merge a main
- **Estado:** ❌ Not Started
- **Estimación:** 10h
- **Horas usadas:** 0h

#### Tarea 8: RF-P03 - Actualización de Propietario
- [ ] Crear modal/página de edición
- [ ] Búsqueda de propietario por ID
- [ ] Campos editables: email, celular, fotos
- [ ] Campos NO editables: cédula, nombres, apellidos
- [ ] Validar propietario existe y está activo
- [ ] Comparar valores antiguos vs nuevos
- [ ] Bitácora: registrar cambios
- [ ] Agregar botón "Editar" en `/adminOwners`
- [ ] Crear tests
- [ ] Merge a main
- **Estado:** ❌ Not Started
- **Estimación:** 8h
- **Horas usadas:** 0h

**Semana 3 Total:**
- Estimado: 18 horas
- Completado: 0%
- En progreso: 0%
- Bloqueadores: Ninguno

---

### Semana 4 (Febrero 14 - Febrero 21)

#### Tarea 9: Dashboard Avanzado
- [ ] Agregar gráficos de accesos por hora
- [ ] Agregar métricas de bloqueados/eliminados
- [ ] Agregar alertas de seguridad
- [ ] Mostrar residentes sin foto facial
- [ ] Agregar cuentas bloqueadas pendientes
- [ ] Topología de ocupación (residentes/manzana)
- [ ] Crear tests
- [ ] Merge a main
- **Estado:** ❌ Not Started
- **Estimación:** 10h
- **Horas usadas:** 0h

#### Tarea 10: Historial Avanzado
- [ ] Agregar filtros: tipo de acceso (QR, facial, manual)
- [ ] Agregar búsqueda por manzana/villa
- [ ] Agregar estadísticas por usuario
- [ ] Mostrar intentos fallidos
- [ ] Agregar exportación a CSV/PDF
- [ ] Gráficos de tendencias
- [ ] Crear tests
- [ ] Merge a main
- **Estado:** ❌ Not Started
- **Estimación:** 8h
- **Horas usadas:** 0h

#### Tarea 11: Desactivación/Reactivación
- [ ] RF-R03: Desactivación de Residente
- [ ] RF-R04: Desactivación de Miembro
- [ ] RF-R05: Reactivación de Residente
- [ ] RF-R06: Reactivación de Miembro
- [ ] Interfaz en `/adminResidents` y `/adminMembers`
- [ ] Validaciones (debe estar en estado correcto)
- [ ] Motivo obligatorio
- [ ] Bitácora
- [ ] Crear tests
- [ ] Merge a main
- **Estado:** ❌ Not Started
- **Estimación:** 12h
- **Horas usadas:** 0h

**Semana 4 Total:**
- Estimado: 30 horas
- Completado: 0%
- En progreso: 0%
- Bloqueadores: Ninguno

---

## 📊 Estadísticas Globales

### Por Estado

```
No Iniciado:        ████████████████████████████████████████ 100% (30 tareas)
En Progreso:        ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░   0%
Completado:         ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░   0%
Bloqueado:          ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░   0%
```

### Por Semana

```
Semana 1-2 (Crítico):    60 horas estimadas
Semana 3 (Importante):   18 horas estimadas
Semana 4 (Mejora):       30 horas estimadas
─────────────────────────────────────────────
TOTAL:                   108 horas estimadas
```

### Horas Acumuladas

```
Enero 24:  0 horas usadas (0%)
Enero 31: 60 horas estimadas (55%)
Febrero 7: 78 horas estimadas (72%)
Febrero 14:108 horas estimadas (100%)
```

---

## 🔴 Problemas / Bloqueadores

### Activos
- (Ninguno actualmente)

### Resueltos
- (Ninguno registrado)

### Por Registrar
- Cualquier bloqueador que surja durante desarrollo

---

## ✅ Checklist de Control de Calidad

### Antes de Merge

- [ ] Código compila sin errores
- [ ] Todos los tests pasan (unit + widget + integration)
- [ ] No hay warnings de lint
- [ ] Validaciones CV-* implementadas
- [ ] Bitácora funciona
- [ ] Mensajes de error son claros
- [ ] No hay hardcoded strings (usar constantes)
- [ ] Performance es aceptable (sin jank)
- [ ] Código documentado (comentarios en lugares complejos)

### Después de Merge

- [ ] Code review aprobado
- [ ] Testing manual completado
- [ ] Screenshots de UI en PR
- [ ] Documentación actualizada
- [ ] Casos edge testeados

---

## 📝 Notas por Tarea

### Tarea 1-2 (Semana 1)

**Riesgos:**
- Complejidad del cambio de propietario
- Integridad de datos en transacciones

**Dependencias:**
- Métodos API deben estar listos
- AuthBloc debe permitir validaciones adicionales

**Testing crítico:**
- Bloqueo de múltiples personas
- Cambio de propietario con auto-residente

---

### Tarea 7-8 (Semana 3)

**Dependencias:**
- RF-P01 debe estar completamente funcional
- Facial enrollment debe estar listo

---

### Tarea 9-11 (Semana 4)

**Estos son enhancements opcionales** - pueden llevarse a semana 5 si sea necesario

---

## 🚀 Criterio de Finalización

**Módulo completamente funcional cuando:**

- ✅ Todos los 30 requerimientos implementados (100%)
- ✅ Cero requerimientos en estado "Parcial"
- ✅ Todos los tests pasan
- ✅ Cero warnings de lint
- ✅ Documentación actualizada
- ✅ Testing manual completado
- ✅ Code review de equipo aprobado

---

## 📞 Actualización Semanal

**Formato para actualizar cada viernes:**

```
Semana XX (Fecha - Fecha)

Completado esta semana:
- [ ] Tarea X (% completitud)
- [ ] Tarea Y (% completitud)

En progreso:
- [ ] Tarea Z (% completitud)

Próxima semana:
- [ ] Tarea A (% estimado)
- [ ] Tarea B (% estimado)

Bloqueadores encontrados:
- (Listar si hay)

Horas utilizadas:
- Planeadas: XXh
- Reales: XXh
- Variación: XXh (⬆️ ⬇️ →)
```

---

**Tracker listo para usar**  
**Actualizar cada viernes con progreso**

# 🧪 Guía de Testing Rápida

## Quick Start - Cómo Probar el Sistema

### Acceso a las Nuevas Páginas

#### 1. Desde la Ruta AdminScaffold
```
AdminDashboard (Tab 0)
    ↓
AccessHistory (Tab 1) 
    ↓
Usuarios (Tab 2) ← Aquí está el hub
    ↓
AdminProfile (Tab 3)
```

#### 2. Rutas Directas
Si necesitas navegar directamente, usa:
```dart
// Hub de usuarios
Navigator.pushNamed(context, '/adminUsers');

// Gestiones específicas
Navigator.pushNamed(context, '/adminResidents');
Navigator.pushNamed(context, '/adminOwners');
Navigator.pushNamed(context, '/adminMembers');
Navigator.pushNamed(context, '/adminAccounts');
```

### Casos de Prueba

#### Test 1: Listar Residentes
1. Navega a `/adminResidents`
2. Deberías ver una lista de residentes
3. Búsqueda: escribe "María" en el searchbar
4. Resultado: filtrado a "María Rodríguez"

#### Test 2: Ver Detalles de Residente
1. Haz clic en una tarjeta de residente
2. Aparece un modal bottom sheet
3. Información visible:
   - Nombre completo
   - Email y teléfono
   - Ubicación (sección/villa)
   - Fecha de registro
   - Estado (Activo/Bloqueado)

#### Test 3: Bloquear un Residente
1. En la lista, haz clic en el menú (⋮) de un residente
2. Selecciona "Ver detalles" o "Bloquear"
3. Aparece un diálogo de confirmación
4. Confirma la acción
5. SnackBar confirma: "María Rodríguez ha sido bloqueado"
6. Chip rojo "Bloqueado" aparece en la tarjeta

#### Test 4: Buscar Propietarios
1. Navega a `/adminOwners`
2. Busca por nombre: "Carlos"
3. Resultado: "Carlos López" (3 propiedades)
4. Busca por email: "sandra@"
5. Resultado: "Sandra García"

#### Test 5: Ver Propiedades de Propietario
1. Haz clic en propietario
2. Selecciona "Ver propiedades"
3. Modal con lista de propiedades:
   - Manzana A - Villa 101
   - Manzana B - Villa 210
   - Manzana C - Villa 305

#### Test 6: Buscar Miembros
1. Navega a `/adminMembers`
2. Deberías ver miembros de familia
3. Búsqueda por familia: "María Rodríguez"
4. Resultado: "Ana Pérez García" (Hija), "Pedro Rodríguez" (Padre)

#### Test 7: Gestión de Cuentas - Búsqueda Avanzada
1. Navega a `/adminAccounts`
2. Búsqueda por nombre: "María"
3. Búsqueda por email: "maria@"
4. Búsqueda por UID: "uid_001"

#### Test 8: Filtrar Cuentas
1. En `/adminAccounts`, verifica chips de filtro
2. Filtro "Todos": muestra todas (256)
3. Filtro "Activo": muestra solo activas
4. Filtro "Bloqueado": muestra solo bloqueadas

#### Test 9: Restablecer Contraseña
1. En cuentas, haz clic en cuenta
2. Botón "Restablecer Contraseña"
3. Confirma en diálogo
4. SnackBar: "Enlace de restablecimiento enviado a..."

#### Test 10: Eliminar Usuario
1. Haz clic en usuario (cualquier página)
2. Menú → "Eliminar"
3. Diálogo de confirmación (acción irreversible)
4. Confirma
5. Usuario eliminado de lista
6. SnackBar de confirmación

---

## 🔍 Validación de UI

### Elementos Visuales a Verificar

#### Cards
- [ ] Avatar con color según tipo
- [ ] Nombre visible
- [ ] Subtítulo con información
- [ ] Chip de estado si está bloqueado
- [ ] Menú popup (⋮) en trailing

#### Búsqueda
- [ ] SearchBar en la parte superior
- [ ] Icono de búsqueda (lupa)
- [ ] Botón X para limpiar si hay texto
- [ ] Búsqueda en tiempo real

#### Modals
- [ ] Bottom sheet deslizable
- [ ] Avatar + nombre en header
- [ ] Pares clave-valor bien alineados
- [ ] Botones de acción visibles
- [ ] Colores consistentes

#### Diálogos
- [ ] Título descriptivo
- [ ] Contenido claro
- [ ] Botones [Cancelar] [Aceptar]
- [ ] Acción confirma cambio

#### Feedback
- [ ] SnackBar muestra mensajes
- [ ] Sin errores en consola
- [ ] UI responde a interacciones
- [ ] Transiciones suaves

---

## 🐛 Debugging

### Logs Útiles

```dart
// Para ver qué página está activa
print('Ruta actual: ${ModalRoute.of(context)?.settings.name}');

// Para verificar datos
print('Residentes filtrados: ${filteredResidents.length}');

// Para debugging de BLoC
print('Estado del BLoC: ${state.runtimeType}');
```

### Errores Comunes

#### "Ruta desconocida: /adminResidents"
- Verificar que la ruta esté en `app_routes.dart`
- Asegurar que el nombre coincide exactamente

#### "Null check operator used on null"
- Verificar argumentos en Navigator.pushNamed
- Asegurar que personaId e identificacion no son null

#### "RenderFlex overflowed"
- Envolver contenido en SingleChildScrollView
- Ajustar padding/margin
- Usar FitBox si es necesario

#### "setState() called after dispose()"
- Cancelar operaciones async en dispose()
- Usar mounted before calling setState()

---

## 📊 Métricas de Rendimiento

### Esperado
- Carga de lista: < 500ms
- Búsqueda: Instantánea (local)
- Modal opening: < 300ms
- Transición: Suave (60 fps)

### Comandos de Profiling
```bash
# Modo debug con profiling
flutter run --profile

# Analizar perfor mance
flutter run --verbose

# Chequear memory
flutter run --profile --profile-from-dex
```

---

## ✨ Casos de Éxito

### Versión Completa (All Green)
- ✓ Todas las 5 páginas funcionan
- ✓ Búsqueda filtra correctamente
- ✓ Diálogos confirman acciones
- ✓ SnackBars muestran feedback
- ✓ Navegación es fluida
- ✓ No hay errores en consola
- ✓ Material Design 3 aplicado

### Criterios de Aceptación
1. [ ] Navegar a todas las páginas sin errores
2. [ ] Búsqueda en tiempo real funciona
3. [ ] Filtros funcionan correctamente
4. [ ] Diálogos muestran confirmaciones
5. [ ] Acciones actualizan UI
6. [ ] SnackBars dan feedback
7. [ ] Modals muestran detalles
8. [ ] Colores son consistentes
9. [ ] Responsive en diferentes tamaños
10. [ ] Sin warnings críticos

---

## 🔄 Integración Backend (Futuro)

### Cuando Conectes API
1. [ ] Reemplazar datos locales con llamadas API
2. [ ] Agregar loading indicators
3. [ ] Implementar error handling
4. [ ] Agregar retry logic
5. [ ] Implementar caching
6. [ ] Agregar paginación
7. [ ] Testing con datos reales
8. [ ] Optimizar performance

### Endpoints a Conectar
```
GET /residentes          → AdminResidentsPage
GET /propietarios        → AdminOwnersPage
GET /miembros-familia    → AdminMembersPage
GET /cuentas            → AdminAccountsPage
POST /cuentas/{id}/bloquear
POST /cuentas/{id}/desbloquear
DELETE /cuentas/{id}
```

---

## 📝 Checklist Final

Antes de considerar completo, verifica:

### Funcionalidad
- [ ] Todas las páginas accesibles
- [ ] Búsqueda funciona
- [ ] Filtros funcionan
- [ ] Diálogos funcionan
- [ ] Acciones funcionan
- [ ] Navegación fluida

### Diseño
- [ ] Colores correctos
- [ ] Layouts responsivos
- [ ] Iconos visibles
- [ ] Textos legibles
- [ ] Consistencia visual

### Código
- [ ] Sin errores
- [ ] Sin warnings
- [ ] Bien formateado
- [ ] Documentado
- [ ] Reutilizable

### Documentación
- [ ] README actualizado
- [ ] Comentarios en código
- [ ] Guías de uso
- [ ] Arquitectura clara

---

## 🆘 Soporte Rápido

### Si algo no funciona:
1. Verificar que la ruta está en `app_routes.dart`
2. Revisar los argumentos (personaId, identificacion)
3. Revisar la consola de errores
4. Ejecutar `flutter clean && flutter pub get`
5. Revisar la documentación específica

### Documentos a Revisar:
- Funcionalidad: `ADMIN_USERS_MANAGEMENT.md`
- Flujos: `ADMIN_USERS_UI_FLOWS.md`
- Integración: `BACKEND_INTEGRATION_GUIDE.md`
- Resumen: `IMPLEMENTATION_SUMMARY.md`

---

## 🎯 Conclusión

Sistema de gestión de usuarios **100% funcional** listo para:
1. Testing manual
2. Demostración
3. Integración con backend
4. Producción

**Tiempo de testing estimado**: 30-60 minutos

¡Bienvenido al futuro del admin panel! 🚀

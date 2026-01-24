# FAQ y Troubleshooting - Módulo de Administración

**Última actualización:** Enero 24, 2026

---

## ❓ Preguntas Frecuentes

### General

**P: ¿Por dónde empiezo?**
A: Lee [INDICE_MAESTRO.md](INDICE_MAESTRO.md) primero, luego [RESUMEN_EJECUTIVO.md](RESUMEN_EJECUTIVO.md)

**P: ¿Cuántos requerimientos hay que implementar?**
A: 30 requerimientos totales. Actualmente implementados: 3 (10%). Críticos pendientes: 2 (bloqueador de todo)

**P: ¿Cuál es el orden de implementación?**
A: Ver [ROADMAP_DESARROLLO.md](ROADMAP_DESARROLLO.md). Primero: RF-P05 y RF-C05-C09 (críticos, 2 semanas)

**P: ¿Hay una manera visual de entender los flujos?**
A: Sí, ver [DIAGRAMAS_FLUJOS_ADMIN.md](DIAGRAMAS_FLUJOS_ADMIN.md) con diagramas ASCII de cada proceso

**P: ¿Qué validaciones debo aplicar?**
A: Ver [REFERENCIA_RAPIDA_ADMIN.md](REFERENCIA_RAPIDA_ADMIN.md) sección "Validaciones Transversales (CV-*)"

---

### Desarrollo

**P: ¿Qué patrón arquitectónico se usa?**
A: Hexagonal + BLoC. Domain → Infrastructure → Application → Presentation

**P: ¿Dónde están los archivos del módulo?**
A: `/lib/presentation/pages/admin*.dart` (páginas), `/lib/application/blocs/` (lógica), `/lib/infrastructure/adapters/admin_api.dart` (API)

**P: ¿Cómo implemento un nuevo requerimiento?**
A: 
1. Lee la descripción en [MODULO_ADMINISTRACION_RESUMEN.md](MODULO_ADMINISTRACION_RESUMEN.md)
2. Consulta los pasos en [ROADMAP_DESARROLLO.md](ROADMAP_DESARROLLO.md)
3. Revisa ejemplos en [DIAGRAMAS_FLUJOS_ADMIN.md](DIAGRAMAS_FLUJOS_ADMIN.md)
4. Usa patrones en [REFERENCIA_RAPIDA_ADMIN.md](REFERENCIA_RAPIDA_ADMIN.md)

**P: ¿Cómo crear un BLoC nuevo?**
A:
1. Crear carpeta en `/lib/application/blocs/`
2. Crear `*_event.dart` con eventos
3. Crear `*_state.dart` con estados
4. Crear `*_bloc.dart` con lógica
5. Registrar en `injection.dart` (GetIt)
6. Usar en página con `BlocProvider` y `BlocListener`/`BlocBuilder`

**P: ¿Dónde registro métodos de API?**
A: En `/lib/infrastructure/adapters/admin_api.dart`. Sigue el patrón de métodos existentes

**P: ¿Cómo validar campos?**
A: En el formulario con `TextFormField.validator` + validaciones CV-*. Ver ejemplos en [REFERENCIA_RAPIDA_ADMIN.md](REFERENCIA_RAPIDA_ADMIN.md)

---

### Facial Enrollment

**P: ¿Cómo funciona el facial enrollment post-registro?**
A: 
1. Usuario completa registro (propietario/residente/miembro)
2. Sistema navega a `/adminFacialEnrollment` con argumentos incluyendo `type`
3. Sistema captura fotos faciales
4. Sistema envía features al servidor
5. Sistema muestra mensaje dinámico según tipo
6. Usuario regresa al listado

**P: ¿Qué significa el parámetro `type` en facial enrollment?**
A: Define qué tipo de persona se registró para mostrar mensaje correcto:
- `'owner'` → "Propietario registrado correctamente"
- `'member'` → "Miembro de familia registrado correctamente"
- `null` → "Residente registrado correctamente"

**P: ¿Cómo agrego más tipos de mensaje?**
A: En `admin_facial_enrollment_page.dart`, modifica la lógica de `successMessage` para agregar nuevos casos

---

### Bitácora y Auditoría

**P: ¿Debo registrar cada operación en bitácora?**
A: Sí, TODAS las operaciones CRUD deben registrarse. Ver estructura en [REFERENCIA_RAPIDA_ADMIN.md](REFERENCIA_RAPIDA_ADMIN.md)

**P: ¿Qué información registrar?**
A: Timestamp, admin_id, tipo de operación, ID del registro, valores anterior/nuevo, motivo si aplica, estado (success/error)

**P: ¿Cómo implementar la bitácora?**
A: Crear tabla `bitacora_admin` con campos especificados. Insertar registro después de cada operación exitosa

---

### Testing

**P: ¿Debo escribir tests?**
A: Sí, obligatorio antes de hacer merge. Unit tests + widget tests + integration tests

**P: ¿Qué debo testear?**
A: Validaciones, flujos happy path, casos edge, manejo de errores, integración con API

**P: ¿Hay ejemplos de tests?**
A: No en la doc actual, pero ver patrón en carpeta `test/`

---

### Integración

**P: ¿Cómo integro mi código con el resto?**
A: 
1. Agregar ruta en `/lib/presentation/routes/app_routes.dart`
2. Registrar BLoC en `injection.dart`
3. Agregar imports necesarios
4. Testear navegación y flujos

**P: ¿Cómo manejo errores de validación?**
A: Mostrar snackbar o error en campo del formulario. Ver ejemplos en código existente

---

## 🔧 Troubleshooting

### Errores Comunes

#### Error: "Provider not found"
**Causa:** BLoC no está registrado en `injection.dart`
**Solución:** 
```dart
// En injection.dart, agregar:
sl.registerSingleton<YourBloc>(
  YourBloc(yourRepository),
);
```

#### Error: "readOnly implies controller == null"
**Causa:** TextFormField tiene tanto `readOnly` como `controller` sin `initialValue`
**Solución:** 
```dart
// Mover inicialización a initState:
@override
void initState() {
  super.initState();
  _dateController.text = 'valor inicial';
}

// En build:
TextFormField(
  readOnly: true,
  controller: _dateController,
  // NO usar initialValue
)
```

#### Error: "No element"
**Causa:** Intentar acceder a elemento de lista que no existe
**Solución:** Validar primero que lista no esté vacía
```dart
if (state.items.isNotEmpty) {
  final item = state.items[0];
}
```

#### Error: "Bad state: Stream has already been listened to"
**Causa:** Listener agregado dos veces a stream
**Solución:** Revisar que `BlocListener` no se agregue múltiples veces

#### Error: "FormatException: Invalid email"
**Causa:** Validación de email rechaza formato válido
**Solución:** Usar regex más permisivo o validación del servidor

#### Error: "El widget ya está en ese estado"
**Causa:** Llamar `setState()` después de que widget se unmount
**Solución:** Verificar `if (mounted)` antes de `setState()`
```dart
if (mounted) {
  setState(() => _variable = value);
}
```

---

### Performance

#### Problema: Listado lento con muchos registros
**Síntomas:** Jank, lag al scroll
**Soluciones:**
1. Implementar paginación (cargar 20-30 items por vez)
2. Usar `ListView.builder` en lugar de `ListView`
3. Cachear búsquedas frecuentes
4. Lazy load en lugar de cargar todo

#### Problema: Validaciones lentas
**Síntomas:** Lag al escribir en inputs
**Soluciones:**
1. Usar debouncing para búsquedas
2. Validaciones async en servidor, no en app
3. Cachear resultados de validación

---

### Validaciones

#### Problema: Validación de correo rechaza direcciones válidas
**Solución:** Usar regex más permisivo
```dart
// Pattern común:
^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$

// Más permisivo:
^[^@]+@[^@]+\.[^@]+$
```

#### Problema: Validación de celular rechaza números válidos
**Solución:** Validar que sea 10 dígitos ecuatorianos
```dart
if (!identificacion.startsWith('09') || identificacion.length != 10) {
  return 'El celular debe ser 09XXXXXXXX';
}
```

#### Problema: Validación de cédula rechaza cédulas válidas
**Solución:** Usar librería de validación o algoritmo de verificación correcto

---

### API

#### Problema: Response 401 Unauthorized
**Causa:** Token expirado o no autorizado
**Solución:** 
1. Validar token en AuthBloc
2. Hacer re-login si token expirado
3. Validar que usuario es administrador

#### Problema: Response 400 Bad Request
**Causa:** Datos enviados incorrectos
**Solución:** 
1. Loguear request body
2. Validar formato de datos
3. Consultar documentación de API

#### Problema: Response 500 Server Error
**Causa:** Error en servidor
**Solución:** 
1. Revisar logs del servidor
2. Contactar backend team
3. Mientras, mostrar mensaje amigable al usuario

---

### Database

#### Problema: Constraint violation (unique)
**Causa:** Intento de crear registro duplicado
**Solución:** Validar antes de insertar
```dart
// Antes de crear propietario, validar:
bool exists = await adminApi.checkPropertyOwnerExists(manzana, villa);
if (exists) {
  throw 'Ya existe propietario en esa vivienda';
}
```

#### Problema: Foreign key constraint violation
**Causa:** Intento de referenciar record inexistente
**Solución:** Validar que ID existe antes de usar como referencia
```dart
bool residentExists = await adminApi.checkResident(residentId);
if (!residentExists) {
  throw 'Residente no existe';
}
```

---

## 🚀 Optimizaciones

### Para Mejorar Performance

1. **Paginación en listados**
   ```dart
   // En lugar de cargar todo, cargar páginas
   List items = await api.getItems(page: 1, limit: 20);
   ```

2. **Cacheo de búsquedas**
   ```dart
   final Map<String, dynamic> cache = {};
   
   Future<dynamic> search(String query) async {
     if (cache.containsKey(query)) {
       return cache[query];
     }
     final result = await api.search(query);
     cache[query] = result;
     return result;
   }
   ```

3. **Debouncing en inputs**
   ```dart
   Timer? _debounce;
   
   void _onSearchChanged(String value) {
     _debounce?.cancel();
     _debounce = Timer(Duration(milliseconds: 500), () {
       _performSearch(value);
     });
   }
   ```

4. **Lazy loading en scrolls**
   ```dart
   // Cargar más items cuando usuario llega al final
   onNotification: (ScrollNotification notification) {
     if (notification.metrics.pixels == notification.metrics.maxScrollExtent) {
       _loadMoreItems();
     }
   }
   ```

---

## 📞 Cuándo Pedir Ayuda

### Contacta al Lead si:
- Bloqueador que no puedes resolver
- Necesitas cambios en arquitectura
- API no responde como esperas
- Validación no aplica según requerimientos
- Testing no resulta como esperas

### Documentación a consultar:
1. [REFERENCIA_RAPIDA_ADMIN.md](REFERENCIA_RAPIDA_ADMIN.md) - patterns
2. [DIAGRAMAS_FLUJOS_ADMIN.md](DIAGRAMAS_FLUJOS_ADMIN.md) - visualización
3. [MODULO_ADMINISTRACION_RESUMEN.md](MODULO_ADMINISTRACION_RESUMEN.md) - contexto
4. [Requerimientos_completos.md](Requerimientos_completos.md) - especificación

### Busca ejemplos en:
1. Código existente: `admin_create_owner_page.dart`
2. Código existente: `admin_create_member_page.dart`
3. Código existente: `admin_facial_enrollment_page.dart`

---

## 🎓 Recursos de Aprendizaje

### Flutter
- [Flutter BLoC pattern](https://bloclibrary.dev/)
- [Form validation](https://flutter.dev/docs/cookbook/forms/validation)
- [Navigation and routing](https://flutter.dev/docs/development/ui/navigation)

### Firebase
- [Authentication](https://firebase.google.com/docs/auth)
- [Firestore](https://firebase.google.com/docs/firestore)
- [Realtime Database](https://firebase.google.com/docs/database)

### Dart
- [Async programming](https://dart.dev/guides/libraries/async-await)
- [Streams](https://dart.dev/tutorials/language/streams)
- [JSON serialization](https://flutter.dev/docs/development/data-and-backend/json)

---

## ✨ Tips y Tricks

### Debugging
1. Usar `print()` para outputs rápidos
2. Usar breakpoints con DevTools
3. Usar `flutter pub global run example:main` para ejecutar ejemplos
4. Usar `flutter test --verbose` para ver detalles de tests

### Productividad
1. Usar snippets de código (botón de atajos en Android Studio)
2. Usar refactoring automático (botón amarilla en VS Code)
3. Usar Ctrl+Shift+R para refactor rápido
4. Usar Ctrl+K para comentar/descomentar líneas

### Calidad
1. Ejecutar `flutter analyze` regularmente
2. Ejecutar `flutter test` antes de merge
3. Hacer code review propio antes de pedir review
4. Escribir commits descriptivos

---

**FAQ completado**  
**Actualizar con nuevas preguntas según surjan**

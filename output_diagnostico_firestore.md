# Diagnóstico: notificaciones — migración a Firestore en tiempo real

## 1. `lib/presentation/widgets/insignia_notificaciones.dart` — COMPLETO

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/usecases/obtener_no_leidas_usecase.dart';
import '../../injection.dart';

class InsigniaNotificaciones extends StatefulWidget {
  final String usuarioId;
  final VoidCallback? onTap;

  const InsigniaNotificaciones({
    super.key,
    required this.usuarioId,
    this.onTap,
  });

  @override
  State<InsigniaNotificaciones> createState() =>
      _InsigniaNotificacionesState();
}

class _InsigniaNotificacionesState
    extends State<InsigniaNotificaciones>
    with WidgetsBindingObserver {
  int _noLeidas = 0;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cargarNoLeidas();
    _refreshTimer = Timer.periodic(
        const Duration(seconds: 30), (_) {
      if (mounted) _cargarNoLeidas();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(
      AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _cargarNoLeidas();
    }
  }

  @override
  void didUpdateWidget(
      covariant InsigniaNotificaciones oldWidget) {
    super.didUpdateWidget(oldWidget);
    _cargarNoLeidas();
  }

  Future<void> _cargarNoLeidas() async {
    try {
      final useCase = sl<ObtenerNoLeidasUseCase>();
      final count =
          await useCase.execute(widget.usuarioId);
      if (mounted) {
        setState(() => _noLeidas = count);
      }
    } catch (e) {
      print('Error cargando no leídas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(
              Icons.notifications_outlined),
          onPressed: widget.onTap ??
              () async {
                await Navigator.pushNamed(
                  context,
                  '/notificaciones',
                  arguments:
                      widget.usuarioId,
                );
                _cargarNoLeidas();
              },
        ),
        if (_noLeidas > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Text(
                _noLeidas > 99
                    ? '99+'
                    : '$_noLeidas',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
```

## 2. Usos de `InsigniaNotificaciones(` en `lib/`

### `family_dashboard_page.dart:132`
```dart
      title: 'Acceso Residencial',                    // L130
      routeName: '/familyDashboard',                  // L131
      actions: [                                       // L131
        InsigniaNotificaciones(                        // L132 ←
          usuarioId: personaId.toString(),             // L133
        ),                                            // L134
      ],                                              // L135
```

### `resident_dashboard_page.dart:150`
```dart
      title: 'Acceso Residencial',                    // L146
      routeName: '/residentDashboard',                // L147
      isRoot: true,                                   // L148
      actions: [                                      // L149
        InsigniaNotificaciones(                       // L150 ←
          usuarioId: personaId.toString(),            // L151
        ),                                            // L152
      ],                                              // L153
```

## 3. Búsqueda de Firestore en Flutter

### `firestore` en `lib/` (case insensitive) — 4 matches
| Archivo | Línea | Contenido |
|---------|-------|-----------|
| `lib/injection.dart` | 4 | `import 'package:cloud_firestore/cloud_firestore.dart';` |
| `lib/injection.dart` | 195 | `final firestore = FirebaseFirestore.instance;` |
| `lib/injection.dart` | 196 | `sl.registerLazySingleton<FirebaseFirestore>(() => firestore);` |
| `lib/infrastructure/providers/firestore_provider.dart` | 1 | `import 'package:cloud_firestore/cloud_firestore.dart';` |

### `snapshots` en `lib/` — 0 matches
No hay ninguna suscripción `snapshots()` en Flutter.

### `collection(` en `lib/` — 0 matches
No hay referencias a colecciones de Firestore en Flutter.

### `FirebaseFirestore` en `lib/` — 4 matches
| Archivo | Línea | Contenido |
|---------|-------|-----------|
| `lib/injection.dart` | 195 | `final firestore = FirebaseFirestore.instance;` |
| `lib/injection.dart` | 196 | `sl.registerLazySingleton<FirebaseFirestore>(() => firestore);` |
| `lib/infrastructure/providers/firestore_provider.dart` | 4 | `final FirebaseFirestore db;` |
| `lib/infrastructure/providers/firestore_provider.dart` | 7 | `static FirestoreProvider create() => FirestoreProvider(FirebaseFirestore.instance);` |

## 4. `cloud_firestore` en `pubspec.yaml`

```yaml
cloud_firestore: ^6.1.0
```
Está declarado pero **no se usa activamente** en la lógica de la app.

## 5. `FirestoreProvider` — único archivo existente

```dart
// lib/infrastructure/providers/firestore_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreProvider {
  final FirebaseFirestore db;
  FirestoreProvider(this.db);

  static FirestoreProvider create() => FirestoreProvider(FirebaseFirestore.instance);
}
```
Es un wrapper vacío — solo tiene el `db` y un factory. Sin métodos, sin listeners, sin queries.

## 6. Cadena HTTP polling actual (`obtenerNoLeidas`)

### Port (`lib/domain/ports/notificacion_repository_port.dart:10`)
```dart
Future<int> obtenerNoLeidas(String usuarioId);
```

### Use case (`lib/domain/usecases/obtener_no_leidas_usecase.dart`)
```dart
class ObtenerNoLeidasUseCase {
  final NotificacionRepositoryPort _repository;
  ObtenerNoLeidasUseCase(this._repository);
  Future<int> execute(String usuarioId) {
    return _repository.obtenerNoLeidas(usuarioId);
  }
}
```

### Repository impl (`lib/infrastructure/adapters/notificacion_repository_impl.dart:30`)
```dart
@override
Future<int> obtenerNoLeidas(String usuarioId) async {
  return _apiProvider.obtenerNoLeidas(usuarioId);
}
```

### API provider (`lib/infrastructure/providers/notificacion_api_provider.dart:23`)
```dart
Future<int> obtenerNoLeidas(String usuarioId) async {
  final respuesta =
      await _cliente.dio.get('/notificaciones/no-leidas');
  return respuesta.data['no_leidas'] ?? 0;
}
```

## Resumen del diagnóstico

| Aspecto | Estado actual |
|---------|---------------|
| `cloud_firestore` en `pubspec.yaml` | ✅ `^6.1.0` |
| `FirebaseFirestore` registrado en DI | ✅ `LazySingleton` en `injection.dart:196` |
| `FirestoreProvider` wrapper | ✅ Creado pero vacío (solo `db` + factory) |
| Suscripciones `snapshots()` en Flutter | ❌ **No existe ninguna** |
| Referencias a `collection()` en Flutter | ❌ **No existe ninguna** |
| Contador no leídas | ❌ **Polling HTTP** cada 30s (`Timer.periodic`) + `WidgetsBindingObserver` on resume |
| Endpoint HTTP | `GET /notificaciones/no-leidas` retorna `{"no_leidas": N}` |
| Widget insignia | `InsigniaNotificaciones` — usado en 2 lugares (family y resident dashboard) |

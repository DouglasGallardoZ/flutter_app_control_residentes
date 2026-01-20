# ✅ Checklist de Configuración Post-Implementación

## 🔧 Configuración Necesaria

### 1. URL Base del API
- [ ] Actualizar `apiBaseUrl` en `lib/injection.dart` según ambiente
  ```dart
  // Desarrollo
  const String apiBaseUrl = 'http://localhost:8000/api/v1';
  
  // Producción
  const String apiBaseUrl = 'https://api.residencias.com/api/v1';
  ```

### 2. Firebase Configuration
- [ ] Verificar que Firebase esté configurado con **email/password authentication**
- [ ] En Firebase Console → Authentication → Sign-in method → Email/Password habilitado
- [ ] Proyecto de Firebase vinculado correctamente en pubspec.yaml

### 3. Dependencias en pubspec.yaml
- [ ] `firebase_core: ^4.2.1`
- [ ] `firebase_auth: ^6.1.2`
- [ ] `dio: ^5.5.0` (para HTTP client)
- [ ] `get_it: ^9.2.0` (inyección de dependencias)
- [ ] `flutter_bloc: ^9.1.1` (ya existe)

---

## 🚀 Primeros Pasos

### 1. Clean & Rebuild
```bash
flutter clean
flutter pub get
flutter pub upgrade
```

### 2. Verificar Compilación
```bash
flutter analyze  # Debe tener solo warnings menores de imports no usadas
flutter build apk --debug  # O ios para macOS
```

### 3. Verificar que Firebase está inicializado
```dart
// En main.dart - Ya está configurado
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  // ...
}
```

---

## 🧪 Testing Manual - Login

### Requisitos previos
1. Tener un backend ejecutándose en `http://localhost:8000/api/v1`
2. Usuario creado en Firebase con email/password
3. Usuario tiene un perfil en la BD del backend

### Pasos
1. [ ] Ejecutar app: `flutter run`
2. [ ] En LoginPage, ingresar:
   - Email: `usuario@example.com`
   - Password: `SecurePass123!`
3. [ ] Hacer tap en "Ingresar"
4. [ ] Verificar:
   - [ ] Se ve CircularProgressIndicator mientras carga
   - [ ] Se navega al dashboard correcto según rol
   - [ ] No hay errores en consola
   - [ ] Token se obtiene correctamente

### Errores esperados y soluciones

| Error | Causa | Solución |
|-------|-------|----------|
| "Credenciales inválidas" | Usuario no existe en Firebase | Crear usuario en Firebase Console |
| "Cuenta no encontrada en BD" | Usuario existe en Firebase pero no en BD | Crear perfil en la BD del backend |
| "Connection refused" | Backend no está corriendo | `python main.py` en carpeta backend |
| "CORS error" | Backend no permite requests desde Flutter | Verificar CORS en backend |
| "401 Unauthorized" | Token expirado o inválido | Aplicación debe manejar refresh automático |

---

## 🔐 Seguridad

- [ ] **No hardcodear URLs**: Usar variables de entorno
- [ ] **No loguear tokens**: Nunca imprimir tokens en logs
- [ ] **HTTPS en producción**: Usar certificados SSL/TLS
- [ ] **Validar emails**: Backend debe validar formato de email
- [ ] **Rate limiting**: Backend debe limitar intentos de login

---

## 📊 Monitoreo

### Logs Recomendados
```dart
// Ver requests HTTP
dio.interceptors.add(LoggingInterceptor());

// Ver cambios de autenticación
authRepo.authStateChanges.listen((user) {
  print('Auth changed: $user');
});

// Ver errores de BLoC
Bloc.observer = SimpleBlocObserver();
```

### Métricas a Trackear
- [ ] Tiempo de login (debe ser < 3 segundos)
- [ ] Tasa de éxito/fallos en login
- [ ] Errores de red
- [ ] Errores de validación

---

## 🔄 Flujos Principales Implementados

### ✅ Login
```
LoginPage → AuthBloc → LoginUseCase → AuthRepository 
  → Firebase Auth + API → Account entity → Dashboard
```

### ✅ Generar QR
```
QrPage → QrBloc → GenerateQrUseCase → QrRepository 
  → QrApi → Backend → QrCode entity → Display
```

### ✅ Ver Historial
```
HistoryPage → AccessHistoryBloc → LoadAccessHistoryUseCase 
  → AccessHistoryRepository → AccessHistoryApi → AccessLog entities
```

---

## 🐛 Debugging Avanzado

### Activar todos los logs
```dart
// En main.dart
void main() async {
  // ...
  Bloc.observer = SimpleBlocObserver();
  dio.interceptors.add(LoggingInterceptor());
  // ...
}

class SimpleBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    print('${bloc.runtimeType} - $change');
    super.onChange(bloc, change);
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print('${bloc.runtimeType} - Error: $error');
    super.onError(bloc, error, stackTrace);
  }
}
```

### Inspeccionar estado de autenticación
```dart
// En cualquier widget
final authRepo = sl<AuthRepository>();
authRepo.authStateChanges.listen((user) {
  print('User: $user');
  if (user != null) {
    authRepo.getIdToken().then((token) {
      print('Token: $token');
    });
  }
});
```

### Ver detalles de errores HTTP
```dart
try {
  await qrApi.generarQRPropio(...);
} on DioException catch (e) {
  print('Status Code: ${e.response?.statusCode}');
  print('Response: ${e.response?.data}');
  print('Headers: ${e.response?.headers}');
}
```

---

## ✨ Próximas Mejoras Sugeridas

1. **Refresh automático de tokens**
   - Implementar refresh_token en Firebase
   - Auto-refresh antes de que expire

2. **Offline support**
   - Cachear datos locales con Hive/SQLite
   - Sincronizar cuando hay conexión

3. **Rate limiting del cliente**
   - Evitar múltiples clicks en botones
   - Throttling en búsquedas

4. **Analytics**
   - Trackear eventos de login/logout
   - Trackear generación de QR

5. **Push notifications**
   - Notificar cuando hay nuevo acceso
   - Recordatorios de QR próximo a expirar

6. **Dark mode**
   - Adaptar LoginPage al tema oscuro
   - Ya está preparado con `ThemeController`

---

## 📞 Troubleshooting

### "No se conecta al API"
```
1. Verificar URL en injection.dart
2. Verificar que backend está corriendo
3. Verificar que están en la misma red
4. Verificar CORS si es cross-origin
5. Verificar firewall
```

### "Firebase Auth no funciona"
```
1. Verificar credenciales en GoogleService-Info.plist (iOS)
2. Verificar credenciales en google-services.json (Android)
3. Verificar que usuario existe en Firebase Console
4. Verificar que email/password está habilitado
```

### "Token inválido"
```
1. Token expiró - debe refrescarse automáticamente
2. Errores al obtener token - verificar permisos en Firebase
3. Token mal formateado - verificar en jwt.io
```

### "Perfil no encontrado"
```
1. Usuario no existe en BD
2. Vivienda no está asignada
3. Usuario está inactivo
4. Endpoint /cuentas/perfil no existe en backend
```

---

## 📝 Notas Importantes

> ⚠️ **No olvide**: El proyecto ahora depende de un backend externo. Sin él, la app no funcionará.

> 💡 **Tip**: Usar `flutter run -d chrome --web-renderer=html` para debugging en web.

> 🔑 **Seguridad**: Nunca commitear credenciales reales. Usar `.env` o variables de entorno.

> 🚀 **Performance**: La primera carga de login puede tardar más por la inicialización de Firebase.

---

## 📚 Referencias Útiles

- [Firebase Auth Documentation](https://firebase.flutter.dev/docs/auth/start)
- [Dio HTTP Client](https://pub.dev/packages/dio)
- [Flutter BLoC Pattern](https://bloclibrary.dev)
- [Clean Architecture](https://resocoder.com/flutter-clean-architecture)
- [Hexagonal Architecture](https://en.wikipedia.org/wiki/Hexagonal_architecture_(software))

---

**Estado**: ✅ Implementación Completa  
**Última actualización**: 2024-12-19  
**Próxima revisión**: Al integrar nuevo módulo  
**Responsable**: Equipo de Desarrollo  

# 🧪 Guía de Pruebas - Flujo de Registro de Residentes

## ⚙️ Requisitos Previos

### Backend
- ✅ API principal corriendo en `http://192.168.1.3:8080/api/v1`
- ✅ Servicio de biometría corriendo en `http://192.168.1.3:8090/api/v1`
- ✅ PostgreSQL con datos de residentes pre-cargados
- ✅ Firebase Configurado

### Desarrollo
- ✅ Flutter 3.x+ con Dart
- ✅ Emulador/Dispositivo físico con cámara frontal
- ✅ Plugin de cámara: `camera`
- ✅ Firebase Auth habilitado

---

## 📱 Instrucciones de Prueba Manual

### Test 1: Navegación Inicial

**Pasos:**
1. Iniciar la app
2. Ver LoginPage con botón "Crear Cuenta"
3. ✅ Verificar que el botón está visible bajo formulario de login

**Resultado Esperado:**
- Botón visible y funcional
- Se puede navegar a RegisterOptionPage

---

### Test 2: Pantalla de Opciones

**Pasos:**
1. Click en "Crear Cuenta" desde LoginPage
2. Ver RegisterOptionPage

**Resultado Esperado:**
- ✅ Botón "Crear Cuenta de Residente" habilitado
- ✅ Botón "Crear Cuenta de Miembro" deshabilitado
- ✅ Botón "Volver al Login" funciona

---

### Test 3: Validación de Prospecto Residente

**Pasos:**
1. Click en "Crear Cuenta de Residente"
2. Ingresa cédula válida de un residente existente (ej: "1234567890")
3. Click "Validar"

**Resultado Esperado:**
- ✅ Loading spinner aparece
- ✅ Si la cédula existe: Navega a FacialVerificationPage
- ✅ Si no existe: Muestra SnackBar rojo "Prospecto no encontrado"
- ✅ Si ya tiene cuenta: Muestra SnackBar "Esta persona ya tiene cuenta"

**Casos de Error:**
- Cédula vacía: Validación del formulario
- Cédula < 10 dígitos: Validación del formulario
- Cédula inexistente: API retorna 404
- Persona ya con cuenta: API retorna 409

---

### Test 4: Verificación Facial

**Pasos:**
1. Desde ProspectoResidentePage, ingresa cédula válida y valida
2. Se abre FacialVerificationPage con preview de cámara
3. Asegúrate que el rostro está bien iluminado
4. Click botón de captura (FAB azul)

**Resultado Esperado:**
- ✅ Cámara frontal se inicializa
- ✅ Preview muestra video en tiempo real
- ✅ Botón de captura captura imagen
- ✅ Loading spinner durante validación
- ✅ Si rostro coincide (distancia < 0.6): Navega a CredentialsResidentePage
- ✅ Si no coincide: Muestra SnackBar naranja con distancia

**Casos de Error:**
- No hay cámara: Muestra SnackBar "No hay cámara disponible"
- Rostro no detectado: API retorna error
- Distancia > 0.6: Muestra "Verificación fallida. Intente nuevamente"

---

### Test 5: Creación de Credenciales

**Pasos:**
1. Desde FacialVerificationPage, captura foto válida
2. Se abre CredentialsResidentePage
3. Ingresa:
   - Email: `usuario@test.com`
   - Contraseña: `Password123`
   - Confirmación: `Password123`
4. Click "Crear Cuenta"

**Resultado Esperado:**
- ✅ Validación de email (debe contener @)
- ✅ Validación de contraseña (mínimo 6 caracteres)
- ✅ Validación de confirmación (debe coincidir)
- ✅ Loading spinner durante creación
- ✅ Si éxito: SnackBar verde "¡Cuenta creada exitosamente!"
- ✅ Redirección a ResidentDashboard

**Casos de Error:**
- Email inválido: Validación formulario
- Contraseña corta: Validación formulario
- Contraseñas no coinciden: Validación formulario
- Email ya existe: Firebase retorna error "email-already-in-use"
- Contraseña débil: Firebase retorna "weak-password"

---

### Test 6: Flujo Completo (End-to-End)

**Preparación:**
- Limpiar caché de Firebase Auth (opcional)
- Tener una cédula de residente en el sistema sin cuenta

**Pasos:**
1. Iniciar desde LoginPage
2. Click "Crear Cuenta"
3. Select "Residente"
4. Ingresa cédula válida → Valida
5. Captura foto válida → Verifica
6. Ingresa credentials → Crea
7. ¿Aparece en ResidentDashboard?

**Resultado Esperado:**
- ✅ Flujo completo sin errores
- ✅ Usuario autenticado
- ✅ Datos del residente visibles en dashboard

---

## 🔍 Pruebas Técnicas

### Test 7: Verificar Llamadas API

**Usando DevTools/Postman:**

1. **Validar Prospecto:**
```bash
curl -X GET "http://192.168.1.3:8080/api/v1/cuentas/prospecto/residente/1234567890"

# Respuesta esperada (200):
{
  "persona_id": 1,
  "identificacion": "1234567890",
  "nombres": "Juan",
  "apellidos": "Pérez",
  "vivienda": {
    "vivienda_id": 1,
    "manzana": "A",
    "villa": "101"
  },
  "puede_crear_cuenta": true
}
```

2. **Verificar Facial:**
```bash
curl -X POST "http://192.168.1.3:8090/api/v1/verify" \
  -F "persona_id=1" \
  -F "image=@foto.jpg"

# Respuesta esperada (200):
{
  "persona_id": 1,
  "match": true,
  "distance": 0.32
}
```

3. **Crear Cuenta:**
```bash
curl -X POST "http://192.168.1.3:8080/api/v1/cuentas/residente/firebase" \
  -H "Content-Type: application/json" \
  -d '{
    "persona_id": 1,
    "firebase_uid": "xyz123",
    "username": "usuario@test.com",
    "usuario_creado": "flutter_app"
  }'

# Respuesta esperada (201):
{
  "id": 42,
  "firebase_uid": "xyz123",
  "persona_id": 1,
  "nombres": "Juan Pérez",
  "mensaje": "Cuenta de residente creada exitosamente"
}
```

---

### Test 8: Verificar Estados BLoC

**Usando Flutter DevTools:**

1. Abre Dart DevTools
2. Selecciona ProspectoValidationBloc
3. Observa transición de estados:
   ```
   ProspectoValidationInitial
   ↓ (al validar)
   ProspectoValidationLoading
   ↓ (si éxito)
   ProspectoResidenteValidado(prospecto)
   ↓ (si error)
   ProspectoValidationError(message)
   ```

---

### Test 9: Verificar Inyección de Dependencias

**En main.dart o test:**
```dart
import 'package:guardin/injection.dart';

void testDependencies() async {
  await inject();
  
  final bloc = sl<ProspectoValidationBloc>();
  assert(bloc != null);
  
  final repo = sl<AccountRepository>();
  assert(repo != null);
  
  final provider = sl<AccountApiProvider>();
  assert(provider != null);
}
```

---

### Test 10: Verificar Rutas

**Verificar que todas las rutas existen:**
```dart
import 'package:guardin/presentation/routes/app_routes.dart';

void testRoutes() {
  assert(AppRoutes.registerOption == '/registerOption');
  assert(AppRoutes.prospectoResidente == '/prospectoResidente');
  assert(AppRoutes.facialVerification == '/facialVerification');
  assert(AppRoutes.credentialsResidente == '/credentialsResidente');
}
```

---

## 📊 Matriz de Casos de Prueba

| Caso | Entrada | Esperado | Estado |
|------|---------|----------|--------|
| Navegación | Click "Crear Cuenta" | RegisterOptionPage | ✅ |
| Cédula válida | 1234567890 | ProspectoResidenteValidado | ❓ |
| Cédula inválida | 000000000 | ProspectoValidationError | ❓ |
| Cédula duplicada | (con cuenta) | ProspectoValidationError (409) | ❓ |
| Rostro válido | Captura foto | CredentialsResidentePage | ❓ |
| Rostro inválido | Captura distinta | Error (distancia > 0.6) | ❓ |
| Email válido | user@test.com | Procede | ✅ |
| Email inválido | usertest | Error validación | ✅ |
| Contraseña válida | Pass123 | Procede | ✅ |
| Contraseña corta | Pass | Error validación | ✅ |
| Confirmación incorrecta | Pass123 / Diff456 | Error validación | ✅ |

---

## 🐛 Debugging

### Logs a Verificar

1. **Bloc Events:**
```
I/flutter: [ProspectoValidationBloc] ValidarProspectoResidente(1234567890)
I/flutter: [ProspectoValidationBloc] ProspectoResidenteValidado(...)
```

2. **API Calls:**
```
I/flutter: GET /cuentas/prospecto/residente/1234567890 → 200 OK
I/flutter: POST /verify → 200 OK
```

3. **Firebase Auth:**
```
I/firebase_auth: Creating user with email: usuario@test.com
I/firebase_auth: User created: uid=xyz123
```

### Errores Comunes

| Error | Causa | Solución |
|-------|-------|----------|
| "No hay cámara" | Emulador sin cámara | Usar dispositivo físico o configurar cámara emulador |
| "404 Not Found" | API no responde | Verificar URL y puerto correcto |
| "PERMISSION_DENIED" | Permisos de cámara | Permitir en settings del dispositivo |
| "Timeout" | Servidor lento | Aumentar timeout en Dio |
| "Invalid Email" | Email malformado | Verificar formato | 

---

## ✅ Checklist de Aceptación

- [ ] Botón "Crear Cuenta" visible en LoginPage
- [ ] RegisterOptionPage muestra dos opciones
- [ ] ProspectoResidentePage valida cédula correctamente
- [ ] FacialVerificationPage captura y verifica rostro
- [ ] CredentialsResidentePage crea usuario en Firebase
- [ ] Cuenta se crea en backend API
- [ ] Usuario redirigido a Dashboard
- [ ] Todos los errores manejados con mensajes claros
- [ ] Tema claro y oscuro funcionan
- [ ] No hay errores de compilación

---

**Última actualización:** 26 Enero 2026  
**Responsable de Pruebas:** [Usuario]  
**Estado:** 🚀 LISTO PARA PRUEBAS

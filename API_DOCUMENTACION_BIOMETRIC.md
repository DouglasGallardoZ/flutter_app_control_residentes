# 📚 Documentación Completa de APIs - Biometric Service

## 📋 Contenido

1. [Información General](#información-general)
2. [Endpoints](#endpoints)
3. [Modelos de Datos](#modelos-de-datos)
4. [Códigos de Estado HTTP](#códigos-de-estado-http)
5. [Ejemplos de Uso](#ejemplos-de-uso)
6. [Manejo de Errores](#manejo-de-errores)
7. [Flujo de Operaciones](#flujo-de-operaciones)

---

## 🌐 Información General

### Descripción
**Biometric Service** es un microservicio REST construido con **FastAPI** que proporciona capacidades de reconocimiento facial mediante embeddings. Implementa una arquitectura hexagonal que separa la lógica de negocio de las dependencias externas.

### Características Principales
- ✅ Enrolamiento facial con múltiples imágenes
- ✅ Verificación de identidad 1:1
- ✅ Validación de visita comparando foto de cédula vs rostro vivo
- ✅ Almacenamiento en PostgreSQL con pgvector
- ✅ Procesamiento exclusivamente en CPU usando ONNX Runtime
- ✅ Modelo de IA: InsightFace (buffalo_s)

### Configuración Base
```
Base URL: http://localhost:8000
API Prefix: /api/v1
OpenAPI Docs: http://localhost:8000/docs
ReDoc: http://localhost:8000/redoc
```

### Tecnologías
- **Framework**: FastAPI
- **Base de Datos**: PostgreSQL (con extensión pgvector)
- **IA/CV**: InsightFace + ONNX Runtime
- **Validación**: Pydantic
- **Async**: Python AsyncIO

---

## 🔌 Endpoints

### 1. POST `/enroll` - Enrolamiento de Persona

Registra una nueva persona en el sistema con sus datos biométricos faciales.

#### Descripción
Captura múltiples imágenes de una persona, extrae embeddings faciales de cada una, calcula un embedding promedio normalizado y los almacena en la base de datos.

#### Método HTTP
```
POST /enroll
```

#### Parámetros

| Nombre | Tipo | Ubicación | Requerido | Descripción |
|--------|------|-----------|-----------|-------------|
| `persona_id` | `integer` | Form Data | ✅ | ID único de la persona a registrar |
| `usuario_creado` | `string` | Form Data | ✅ | Usuario/ID que realiza el registro (para auditoría) |
| `images` | `List[file]` | Form Data (multipart) | ✅ | Mínimo 3 imágenes faciales en formato JPG/PNG |

#### Restricciones
- **Mínimo de imágenes**: 3
- **Formatos soportados**: JPG, JPEG, PNG, BMP
- **Requisito**: Debe detectarse un rostro claro en cada imagen
- **Tamaño recomendado**: 640x480 o superior

#### Request Example
```bash
curl -X POST "http://localhost:8000/enroll" \
  -F "persona_id=101" \
  -F "usuario_creado=admin" \
  -F "images=@foto1.jpg" \
  -F "images=@foto2.jpg" \
  -F "images=@foto3.jpg"
```

#### Response (200 OK)
```json
{
  "persona_id": 101,
  "status": "enrolled"
}
```

#### Response Model
```python
class EnrollResponse(BaseModel):
    persona_id: int
    status: str
```

#### Posibles Errores
| Código | Descripción |
|--------|------------|
| 422 | Menos de 3 imágenes o no se detectó rostro |
| 500 | Error interno del servidor |

#### Lógica Interna
1. ✔️ Valida que hay al menos 3 imágenes
2. ✔️ Lee contenido de todas las imágenes
3. ✔️ Para cada imagen:
   - Extrae embedding facial usando InsightFace
   - Genera ruta de almacenamiento
   - Guarda imagen en el sistema de archivos
   - Almacena información de foto en BD
4. ✔️ Calcula embedding promedio normalizado
5. ✔️ Almacena embedding promedio en BD
6. ✔️ Retorna confirmación

---

### 2. POST `/verify` - Verificación de Identidad

Verifica la identidad de una persona comparándola con su registro biométrico.

#### Descripción
Realiza una verificación 1:1 comparando el embedding de una imagen proporcionada contra el embedding promedio registrado de una persona. Calcula la distancia coseno y determina coincidencia basada en un umbral configurable.

#### Método HTTP
```
POST /verify
```

#### Parámetros

| Nombre | Tipo | Ubicación | Requerido | Descripción |
|--------|------|-----------|-----------|-------------|
| `persona_id` | `integer` | Form Data | ✅ | ID de la persona a verificar (debe estar enrollada) |
| `image` | `file` | Form Data (multipart) | ✅ | Imagen facial para verificación |

#### Restricciones
- **Prerequisito**: La persona debe estar previamente enrollada
- **Formatos soportados**: JPG, JPEG, PNG, BMP
- **Requisito**: Debe detectarse un rostro claro en la imagen
- **Umbral por defecto**: 0.6 (distancia coseno)

#### Request Example
```bash
curl -X POST "http://localhost:8000/verify" \
  -F "persona_id=101" \
  -F "image=@rostro_verificacion.jpg"
```

#### Response (200 OK) - Coincidencia
```json
{
  "persona_id": 101,
  "match": true,
  "distance": 0.3245
}
```

#### Response (200 OK) - No Coincidencia
```json
{
  "persona_id": 101,
  "match": false,
  "distance": 0.7892
}
```

#### Response Model
```python
class VerifyResponse(BaseModel):
    persona_id: int
    match: bool
    distance: float
```

#### Interpretación de Resultados
- **distance ≤ 0.6**: ✅ `match = true` (Identidad Verificada)
- **distance > 0.6**: ❌ `match = false` (Identidad NO Verificada)

#### Posibles Errores
| Código | Descripción |
|--------|------------|
| 422 | No se detectó rostro o persona no enrollada |
| 500 | Error interno del servidor |

#### Lógica Interna
1. ✔️ Lee imagen proporcionada
2. ✔️ Extrae embedding de la imagen
3. ✔️ Obtiene embedding promedio almacenado de la persona
4. ✔️ Calcula distancia coseno entre embeddings
5. ✔️ Compara distancia con umbral (0.6)
6. ✔️ Retorna resultado con confianza

---

### 3. POST `/validate` - Validación de Visita

Valida que el rostro presente coincide con la foto de documento de identidad (sin base de datos).

#### Descripción
Comparación 1:1 entre dos imágenes sin depender de una base de datos. Útil para validar que la persona presente es quien afirma ser, comparando su rostro vivo contra la foto de su cédula o documento.

#### Método HTTP
```
POST /validate
```

#### Parámetros

| Nombre | Tipo | Ubicación | Requerido | Descripción |
|--------|------|-----------|-----------|-------------|
| `foto_cedula` | `file` | Form Data (multipart) | ✅ | Foto del documento de identidad/cédula |
| `foto_rostro_vivo` | `file` | Form Data (multipart) | ✅ | Foto del rostro en vivo (presente) |

#### Restricciones
- **No requiere** registro previo
- **Formatos soportados**: JPG, JPEG, PNG, BMP
- **Requisito**: Debe detectarse un rostro claro en ambas imágenes
- **Umbral por defecto**: 0.6 (distancia coseno)
- **Caso de uso**: Verificación de presencialidad, validación de identidad documental

#### Request Example
```bash
curl -X POST "http://localhost:8000/validate" \
  -F "foto_cedula=@cedula_scan.jpg" \
  -F "foto_rostro_vivo=@selfie.jpg"
```

#### Response (200 OK) - Coincidencia
```json
{
  "match": true,
  "distance": 0.4123
}
```

#### Response (200 OK) - No Coincidencia
```json
{
  "match": false,
  "distance": 0.8456
}
```

#### Response Model
```python
class ValidateResponse(BaseModel):
    match: bool
    distance: float
```

#### Interpretación de Resultados
- **distance ≤ 0.6**: ✅ `match = true` (Rostros Coinciden)
- **distance > 0.6**: ❌ `match = false` (Rostros NO Coinciden)

#### Posibles Errores
| Código | Descripción |
|--------|------------|
| 422 | No se detectó rostro en una o ambas imágenes |
| 500 | Error interno del servidor |

#### Lógica Interna
1. ✔️ Lee ambas imágenes
2. ✔️ Extrae embedding de foto de cédula
3. ✔️ Extrae embedding de foto de rostro vivo
4. ✔️ Calcula distancia coseno entre los dos embeddings
5. ✔️ Compara distancia con umbral (0.6)
6. ✔️ Retorna resultado sin almacenar información

---

### 4. GET `/health` - Verificación de Salud

Verifica que el servicio está disponible y funcionando correctamente.

#### Descripción
Endpoint de health check para verificar la disponibilidad del servicio.

#### Método HTTP
```
GET /health
```

#### Parámetros
Ninguno

#### Request Example
```bash
curl -X GET "http://localhost:8000/health"
```

#### Response (200 OK)
```json
{
  "status": "healthy"
}
```

#### Casos de Uso
- Monitoreo de disponibilidad
- Load balancing
- Verificación de estado antes de usar otros endpoints

---

## 📦 Modelos de Datos

### 1. EnrollResponse
**Respuesta del endpoint `/enroll`**

```python
class EnrollResponse(BaseModel):
    persona_id: int          # ID de la persona registrada
    status: str              # Estado: "enrolled"
```

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `persona_id` | `integer` | ID único de la persona registrada |
| `status` | `string` | Estado del registro ("enrolled") |

**Ejemplo:**
```json
{
  "persona_id": 101,
  "status": "enrolled"
}
```

---

### 2. VerifyResponse
**Respuesta del endpoint `/verify`**

```python
class VerifyResponse(BaseModel):
    persona_id: int          # ID de la persona verificada
    match: bool              # ¿Coincide la identidad?
    distance: float          # Distancia coseno (0.0 - 1.0)
```

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `persona_id` | `integer` | ID de la persona verificada |
| `match` | `boolean` | `true` si la verificación es exitosa, `false` si no |
| `distance` | `float` | Distancia coseno calculada (rango 0.0-1.0) |

**Ejemplo (Coincidencia):**
```json
{
  "persona_id": 101,
  "match": true,
  "distance": 0.3245
}
```

**Ejemplo (No Coincidencia):**
```json
{
  "persona_id": 101,
  "match": false,
  "distance": 0.8932
}
```

---

### 3. ValidateResponse
**Respuesta del endpoint `/validate`**

```python
class ValidateResponse(BaseModel):
    match: bool              # ¿Coinciden los rostros?
    distance: float          # Distancia coseno (0.0 - 1.0)
```

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `match` | `boolean` | `true` si los rostros coinciden, `false` si no |
| `distance` | `float` | Distancia coseno calculada (rango 0.0-1.0) |

**Ejemplo (Coincidencia):**
```json
{
  "match": true,
  "distance": 0.4521
}
```

---

### 4. Modelos de Dominio (Internos)

#### Embedding
Representa un vector de embedding facial normalizado.

```python
@dataclass
class Embedding:
    vector: np.ndarray       # Vector de 512 dimensiones
    
    def to_list(self) -> list:
        return self.vector.tolist()
```

#### PersonaFoto
Datos de una foto individual de una persona.

```python
@dataclass
class PersonaFoto:
    persona_titular_fk: int              # FK a la persona
    ruta_imagen: str                     # Ruta del archivo en disco
    formato: str                         # jpg, png, etc.
    embedding: Embedding                 # Embedding de esta foto
    usuario_creado: str                  # Usuario que la subió
    foto_pk: Optional[int] = None        # PK en BD
    eliminado: bool = False              # Soft delete flag
    motivo_eliminado: Optional[str] = None
    fecha_creado: Optional[datetime] = None
    fecha_actualizado: Optional[datetime] = None
    usuario_actualizado: Optional[str] = None
```

#### PersonaEmbedding
Embedding promedio de una persona.

```python
@dataclass
class PersonaEmbedding:
    persona_titular_fk: int          # FK a la persona
    embedding: Embedding             # Embedding promedio normalizado
    embedding_pk: Optional[int] = None  # PK en BD
```

#### VerificacionFacial
Resultado de una comparación facial.

```python
@dataclass
class VerificacionFacial:
    coincide: bool                   # ¿Hay coincidencia?
    distancia: float                 # Distancia coseno
```

---

## 📊 Códigos de Estado HTTP

### Códigos de Éxito

| Código | Significado | Descripción |
|--------|------------|-------------|
| **200** | OK | Solicitud exitosa |

### Códigos de Error del Cliente

| Código | Significado | Descripción |
|--------|------------|-------------|
| **422** | Unprocessable Entity | Datos inválidos, validación fallida |
| | | - Menos de 3 imágenes en `/enroll` |
| | | - No se detectó rostro en imagen |
| | | - Persona no existe o no está enrollada |
| | | - Formato de imagen no soportado |

### Códigos de Error del Servidor

| Código | Significado | Descripción |
|--------|------------|-------------|
| **500** | Internal Server Error | Error interno del servidor |
| | | - Error en procesamiento de imagen |
| | | - Error de conexión a BD |
| | | - Error en sistema de archivos |

---

## 💡 Ejemplos de Uso

### Ejemplo Completo 1: Enrolamiento y Verificación

#### Paso 1: Enrolar una persona

```bash
# Preparar 3 imágenes de la persona
# foto1.jpg, foto2.jpg, foto3.jpg

curl -X POST "http://localhost:8000/enroll" \
  -F "persona_id=101" \
  -F "usuario_creado=admin@sistema.com" \
  -F "images=@foto1.jpg" \
  -F "images=@foto2.jpg" \
  -F "images=@foto3.jpg"

# Respuesta esperada:
# {
#   "persona_id": 101,
#   "status": "enrolled"
# }
```

#### Paso 2: Verificar la identidad de la persona

```bash
# Después de enrollar, podemos verificar
curl -X POST "http://localhost:8000/verify" \
  -F "persona_id=101" \
  -F "image=@rostro_a_verificar.jpg"

# Respuesta esperada (si coincide):
# {
#   "persona_id": 101,
#   "match": true,
#   "distance": 0.4523
# }
```

### Ejemplo Completo 2: Validación de Visita

```bash
# Validar sin base de datos
curl -X POST "http://localhost:8000/validate" \
  -F "foto_cedula=@cedula.jpg" \
  -F "foto_rostro_vivo=@selfie.jpg"

# Respuesta esperada (si coincide):
# {
#   "match": true,
#   "distance": 0.3876
# }
```

### Ejemplo 3: Python con Requests

```python
import requests

# Configuración
BASE_URL = "http://localhost:8000"

# 1. Enrolamiento
with open("foto1.jpg", "rb") as f1, \
     open("foto2.jpg", "rb") as f2, \
     open("foto3.jpg", "rb") as f3:
    
    files = {
        "images": [f1, f2, f3]
    }
    data = {
        "persona_id": 101,
        "usuario_creado": "admin"
    }
    
    response = requests.post(
        f"{BASE_URL}/enroll",
        files=files,
        data=data
    )
    print(response.json())

# 2. Verificación
with open("rostro_verificar.jpg", "rb") as f:
    files = {"image": f}
    data = {"persona_id": 101}
    
    response = requests.post(
        f"{BASE_URL}/verify",
        files=files,
        data=data
    )
    result = response.json()
    
    if result["match"]:
        print(f"✅ Identidad verificada (distancia: {result['distance']})")
    else:
        print(f"❌ Identidad NO verificada (distancia: {result['distance']})")
```

### Ejemplo 4: JavaScript/Fetch

```javascript
// Enrolamiento
const formData = new FormData();
formData.append("persona_id", "101");
formData.append("usuario_creado", "admin");
formData.append("images", document.getElementById("foto1").files[0]);
formData.append("images", document.getElementById("foto2").files[0]);
formData.append("images", document.getElementById("foto3").files[0]);

const enrollResponse = await fetch("http://localhost:8000/enroll", {
  method: "POST",
  body: formData
});

const enrollData = await enrollResponse.json();
console.log(enrollData);

// Verificación
const verifyData = new FormData();
verifyData.append("persona_id", "101");
verifyData.append("image", document.getElementById("fotoVerificar").files[0]);

const verifyResponse = await fetch("http://localhost:8000/verify", {
  method: "POST",
  body: verifyData
});

const result = await verifyResponse.json();
console.log(`Match: ${result.match}, Distancia: ${result.distance}`);
```

---

## ⚠️ Manejo de Errores

### Errores Comunes y Soluciones

#### Error: "Se requieren al menos 3 imágenes para enrollar"
```json
{
  "detail": "Se requieren al menos 3 imágenes para enrollar"
}
```
**Solución:** Proporcione al menos 3 imágenes en el endpoint `/enroll`.

#### Error: "No se detectó rostro"
```json
{
  "detail": "No se detectó rostro en la imagen"
}
```
**Causas posibles:**
- Imagen muy oscura o borrosa
- Rostro parcialmente visible
- Múltiples rostros en la imagen
- Formato de imagen inválido

**Soluciones:**
- Use imágenes claras y bien iluminadas
- Asegure que el rostro ocupa al menos 30% de la imagen
- Capture solo un rostro por imagen

#### Error: "No hay embedding de referencia para persona {id}"
```json
{
  "detail": "No hay embedding de referencia para persona 101"
}
```
**Causa:** La persona no está enrollada.
**Solución:** Primero enrolle la persona mediante `/enroll`.

#### Error: "Error interno del servidor" (500)
```json
{
  "detail": "Error interno del servidor"
}
```
**Causas posibles:**
- Conexión a BD interrumpida
- Problema en el sistema de archivos
- Fallo en procesamiento de imagen

**Solución:** Revise los logs del servidor y contacte al equipo de soporte.

### Manejo de Errores en Cliente

#### Python
```python
import requests
from requests.exceptions import RequestException

try:
    response = requests.post(
        "http://localhost:8000/verify",
        files={"image": open("foto.jpg", "rb")},
        data={"persona_id": 101},
        timeout=30
    )
    response.raise_for_status()  # Lanza excepción para errores HTTP
    
    result = response.json()
    print(f"Resultado: {result}")
    
except requests.exceptions.HTTPError as e:
    print(f"Error HTTP {e.response.status_code}: {e.response.json()}")
except requests.exceptions.Timeout:
    print("Timeout: El servidor tardó demasiado")
except RequestException as e:
    print(f"Error de conexión: {e}")
```

#### JavaScript
```javascript
async function verify(personaId, fotoFile) {
  const formData = new FormData();
  formData.append("persona_id", personaId);
  formData.append("image", fotoFile);
  
  try {
    const response = await fetch("http://localhost:8000/verify", {
      method: "POST",
      body: formData
    });
    
    if (!response.ok) {
      const error = await response.json();
      throw new Error(`${response.status}: ${error.detail}`);
    }
    
    const result = await response.json();
    return result;
    
  } catch (error) {
    console.error("Error en verificación:", error.message);
    throw error;
  }
}
```

---

## 🔄 Flujo de Operaciones

### Flujo 1: Enrolamiento Completo

```
┌─────────────────────────────────────┐
│  Cliente POST /enroll              │
│  - persona_id: 101                 │
│  - usuario_creado: admin           │
│  - images: [3+ fotos]              │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  FastAPI                            │
│  Validar 3+ imágenes               │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  CasoDeUsoEnrollamiento.ejecutar()  │
└──────────────┬──────────────────────┘
               │
       ┌───────┴───────┐
       ▼               ▼
┌──────────────┐ ┌────────────────────┐
│ Para c/foto: │ │ Adaptadores        │
│ 1. Extraer   │ │ (Inyectados)       │
│    embedding │ │ - Analizador       │
│ 2. Guardar   │ │ - PostgreSQL       │
│    foto      │ │ - FileSystem       │
│ 3. Guardar   │ └────────────────────┘
│    en BD     │
└──────────────┘
       │
       ▼
┌─────────────────────────────────────┐
│ Calcular embedding promedio         │
│ (Normalización L2)                  │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│ Guardar embedding promedio en BD    │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│ Respuesta 200 OK                    │
│ {                                   │
│   "persona_id": 101,                │
│   "status": "enrolled"              │
│ }                                   │
└─────────────────────────────────────┘
```

### Flujo 2: Verificación Facial

```
┌─────────────────────────────────────┐
│  Cliente POST /verify               │
│  - persona_id: 101                  │
│  - image: foto                      │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  FastAPI - Leer imagen              │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  CasoDeUsoVerificacion.ejecutar()   │
└──────────────┬──────────────────────┘
               │
       ┌───────┴────────┐
       ▼                ▼
┌──────────────┐ ┌────────────────────┐
│ 1. Extraer   │ │ Adaptadores        │
│    embedding │ │ - Analizador:      │
│ 2. Obtener   │ │   • obtener_       │
│    embedding │ │     embedding()    │
│    almacenado│ │   • calcular_      │
│ 3. Calcular  │ │     distancia_     │
│    distancia │ │     coseno()       │
│    coseno    │ │                    │
│ 4. Comparar  │ │ - PostgreSQL:      │
│    con umbral│ │   • obtener_       │
│    (0.6)     │ │     embedding()    │
└──────────────┘ └────────────────────┘
       │
       ▼
┌─────────────────────────────────────┐
│ Respuesta 200 OK                    │
│ {                                   │
│   "persona_id": 101,                │
│   "match": true/false,              │
│   "distance": 0.XXXX                │
│ }                                   │
└─────────────────────────────────────┘
```

### Flujo 3: Validación de Visita

```
┌─────────────────────────────────────┐
│  Cliente POST /validate             │
│  - foto_cedula: imagen              │
│  - foto_rostro_vivo: imagen         │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  FastAPI - Leer ambas imágenes      │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  CasoDeUsoValidacionVisita.ejecutar()│
│  (Sin dependencia de BD)             │
└──────────────┬──────────────────────┘
               │
       ┌───────┴────────┐
       ▼                ▼
┌──────────────┐ ┌────────────────────┐
│ 1. Extraer   │ │ Adaptadores        │
│    embedding │ │ - Analizador:      │
│    de cedula │ │   • obtener_       │
│ 2. Extraer   │ │     embedding()    │
│    embedding │ │   • calcular_      │
│    de vivo   │ │     distancia_     │
│ 3. Calcular  │ │     coseno()       │
│    distancia │ │                    │
│    coseno    │ │ (No usa BD)        │
│ 4. Comparar  │ │                    │
│    con umbral│ │                    │
│    (0.6)     │ │                    │
└──────────────┘ └────────────────────┘
       │
       ▼
┌─────────────────────────────────────┐
│ Respuesta 200 OK                    │
│ {                                   │
│   "match": true/false,              │
│   "distance": 0.XXXX                │
│ }                                   │
└─────────────────────────────────────┘
```

---

## 🔐 Notas de Seguridad

### Consideraciones de Seguridad

1. **Autenticación**: En producción, implemente autenticación/autorización en los endpoints
2. **Rate Limiting**: Implemente rate limiting para prevenir abuso
3. **HTTPS**: Use HTTPS en producción
4. **Validación**: Todas las imágenes se validan (debe detectarse rostro)
5. **Logs**: Se registran todas las operaciones con IDs de usuario

### Recomendaciones

```python
# Recomendado en producción: Agregar autenticación
from fastapi.security import HTTPBearer, HTTPAuthCredentials

security = HTTPBearer()

@app.post("/enroll")
async def registrar_residente(
    credentials: HTTPAuthCredentials = Depends(security),
    persona_id: int = Form(...),
    usuario_creado: str = Form(...),
    images: List[UploadFile] = File(...)
):
    # Validar token
    token = credentials.credentials
    # ... validación ...
    pass
```

---

## 📈 Métricas de Distancia Coseno

### Interpretación de Resultados

| Distancia | Interpretación | Caso de Uso |
|-----------|----------------|------------|
| 0.0 - 0.3 | Identidad muy clara | Misma persona, excelente coincidencia |
| 0.3 - 0.6 | Identidad probable | Misma persona (umbral: ✅ MATCH) |
| 0.6 - 0.8 | Identidad dudosa | Podría ser la misma (cerca del umbral) |
| 0.8 - 1.0 | Identidad muy diferente | Personas distintas (❌ NO MATCH) |

### Características del Modelo InsightFace (buffalo_s)

- **Dimensionalidad**: 512 dimensiones
- **Modelo**: InsightFace buffalo_s
- **Runtime**: ONNX (CPU optimizado)
- **Normalización**: L2
- **Métrica**: Distancia Coseno
- **Umbral recomendado**: 0.6

---

## 🔗 Referencias Relacionadas

- Documento de Arquitectura: [ARQUITECTURA.md](ARQUITECTURA.md)
- Diagrama de Sistemas: [DIAGRAMAS.md](DIAGRAMAS.md)
- README del Proyecto: [README.md](README.md)
- Esquema de BD: [ddl.sql](ddl.sql)

---

## 📞 Soporte

Para reportar problemas o sugerencias:
- Revisar logs de la aplicación
- Verificar conectividad con PostgreSQL
- Validar formato de imágenes
- Contactar al equipo de desarrollo

**Última actualización:** enero 2026

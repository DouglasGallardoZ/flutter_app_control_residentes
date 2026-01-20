# 🗺️ Roadmap de Implementación - APIs Backend Integradas

## 📍 Estado Actual (2024-12-19)

### ✅ **FASE 1: Autenticación y Perfiles** - COMPLETADA
- Firebase Auth integrado
- Login con email/password
- Obtención de perfil desde API
- BLoC de autenticación funcional
- LoginPage actualizada

### ✅ **FASE 2: Generación de QR** - COMPLETADA
- QR propio (acceso personal)
- QR de visita
- Listado con paginación
- DTOs para mapeo
- QrBloc funcional

### ✅ **FASE 3: Historial de Acceso** - COMPLETADA
- Carga desde API
- Soporte paginación
- AccessHistoryBloc actualizado
- Mapeo de entidades

### ✅ **FASE 4: Infraestructura y DTOs** - COMPLETADA
- ApiHttpClient con JWT interceptor
- Providers especializados (Auth, QR, History)
- DTOs para respuestas
- Repositories adaptados
- Inyección de dependencias actualizada

### ✅ **FASE 5: Documentación** - COMPLETADA
- Resumen de implementación
- Guía rápida de APIs
- Checklist de configuración
- Este roadmap

---

## 🚀 PRÓXIMAS FASES (Roadmap)

### **FASE 6: Miembros de Familia** (Estimado: 1-2 semanas)
- [ ] Adaptador para endpoints de miembros
  - GET /miembros/{vivienda_id}
  - POST /miembros/{residente_id}/agregar
  - POST /miembros/{miembro_id}/desactivar
  - DELETE /miembros/{miembro_id}
- [ ] MiembrosFamiliaBloc
- [ ] UI para gestionar miembros
- [ ] DTOs para respuestas
- **Dependencias**: Ninguna (BLOQUEADO: Espera endpoints en backend)

### **FASE 7: Gestión de Propietarios** (Estimado: 1-2 semanas)
- [ ] Adaptador para endpoints de propietarios
  - POST /propietarios/
  - POST /propietarios/{id}/conyuge
  - GET /propietarios/{vivienda_id}
  - DELETE /propietarios/{id}
- [ ] PropietariosBloc
- [ ] UI para gestión
- **Dependencias**: Fase 6 (para estructura de viviendas)
- **Nota**: Probablemente sea para vista de admin

### **FASE 8: Validación de QR** (Estimado: 2-3 semanas)
- [ ] Adaptador para validar QR
  - POST /acceso/validar-qr (con token QR)
  - Integración con biometría
  - Logging de accesos
- [ ] QRValidationBloc
- [ ] UI con cámara para scanear
- **Dependencias**: FASE 6 (necesita estar integrada)
- **Bloqueador**: Integración de cámara y reconocimiento facial

### **FASE 9: Biometría (Reconocimiento Facial)** (Estimado: 3-4 semanas)
- [ ] Integración con API de biometría
  - POST /face/registrar
  - POST /face/validar
- [ ] Captura de foto
- [ ] Envío al servidor
- [ ] ML Kit integrado (local)
- **Dependencias**: Fase 8 (validación de acceso)
- **Complejidad**: Alta
- **Riesgos**: Privacidad, precisión, permisos de cámara

### **FASE 10: Caché y Offline** (Estimado: 2-3 semanas)
- [ ] SQLite para caché local
  - Guardar últimas 100 transacciones
  - Guardar perfil del usuario
  - Guardar lista de QRs
- [ ] Sincronización cuando hay conexión
- [ ] Indicadores de sync status
- **Dependencias**: Todas las fases anteriores
- **Mejora**: Performance y UX sin internet

### **FASE 11: Notificaciones Push** (Estimado: 1-2 semanas)
- [ ] Firebase Cloud Messaging setup
- [ ] Manejo de notificaciones
  - Nuevo acceso detectado
  - QR próximo a expirar
  - Alertas de seguridad
- [ ] Permisos en iOS/Android
- [ ] Deep linking a pages
- **Dependencias**: Firebase setup (ya existe)

### **FASE 12: Analytics** (Estimado: 1 semana)
- [ ] Firebase Analytics integration
- [ ] Eventos a trackear
  - login/logout
  - QR generation
  - Access attempt
  - Errors
- [ ] Dashboard de métricas
- **Dependencias**: Ninguna especial

### **FASE 13: Dark Mode Completo** (Estimado: 1 semana)
- [ ] Adaptar LoginPage a dark mode
- [ ] Revisar todos los colores
- [ ] Temas consistentes
- [ ] Testing en ambos modos
- **Dependencias**: Ya hay estructura base (ThemeController)

### **FASE 14: Refresh Automático de Tokens** (Estimado: 3-5 días)
- [ ] Implementar refresh_token en Firebase
- [ ] Auto-refresh antes de expirar
- [ ] Manejo de refresh fallido
- [ ] Logout automático si no se puede refrescar
- **Dependencias**: Ninguna especial

### **FASE 15: Rate Limiting y Throttling** (Estimado: 3-5 días)
- [ ] Evitar multiple clicks
- [ ] Throttling en búsquedas
- [ ] Limitar reintentos de login
- [ ] Feedback visual
- **Dependencias**: UI/UX improvements

### **FASE 16: Testing Automático** (Estimado: 2-3 semanas)
- [ ] Unit tests para repositories
- [ ] Unit tests para use cases
- [ ] Unit tests para BLoCs
- [ ] Widget tests para pages principales
- [ ] Integration tests
- **Cobertura objetivo**: >70%

### **FASE 17: Performance Optimization** (Estimado: 1-2 semanas)
- [ ] Profiling con DevTools
- [ ] Optimizar builds
- [ ] Lazy loading de datos
- [ ] Imágenes comprimidas
- [ ] Reducir tamaño del APK
- **Objetivo**: < 50MB en release

---

## 📊 Timeline Estimado

```
ACTUAL (Completado)
├── 2024-12-19: Fases 1-5 ✅
│
PRÓXIMO TRIMESTRE (Q1 2025)
├── 2025-01-20: Fase 6 (Miembros)
├── 2025-02-10: Fase 7 (Propietarios)
├── 2025-02-28: Fase 8 (Validación QR)
│
PRÓXIMOS 3 MESES (Q2 2025)
├── 2025-03-30: Fase 9 (Biometría) ⚠️ Alto riesgo
├── 2025-04-20: Fase 10 (Caché)
├── 2025-05-10: Fase 11 (Push)
│
PRÓXIMOS 6 MESES (Q3 2025)
├── 2025-06-01: Fase 12 (Analytics)
├── 2025-06-15: Fase 13 (Dark mode)
├── 2025-06-30: Fase 14 (Token refresh)
├── 2025-07-15: Fase 15 (Rate limiting)
└── 2025-08-30: Fases 16-17 (Testing + Opt)
```

---

## 🎯 Prioridades por Impacto

### 🔴 CRÍTICO (Implementar primero)
1. **Fase 8 - Validación de QR**: Core business
2. **Fase 10 - Caché offline**: UX crítica en campo
3. **Fase 14 - Refresh tokens**: Seguridad y UX

### 🟡 IMPORTANTE (Después)
4. **Fase 6 - Miembros familia**: Feature solicitada
5. **Fase 9 - Biometría**: Diferenciador
6. **Fase 11 - Push**: Engagement

### 🟢 MEJORA (Cuando sea posible)
7. Fase 7 - Propietarios (Admin only)
8. Fase 12 - Analytics (Insights)
9. Fase 13 - Dark mode (UX)
10. Fase 15 - Rate limiting (Dev hygiene)
11. Fases 16-17 - Testing/Optimization (Quality)

---

## 🚧 Dependencias Bloqueadas

| Fase | Bloqueador | Estado |
|------|-----------|--------|
| 6 | Endpoints backend no están documentados | ⏳ Pendiente |
| 7 | Endpoints backend no están documentados | ⏳ Pendiente |
| 8 | API validación QR no existe | ⏳ Pendiente |
| 9 | API biometría no existe | ⏳ Pendiente |
| 9 | Permisos de cámara iOS/Android | ⏳ Requerido |

---

## 💻 Stack Tecnológico Previsto

```
Ya Implementado:
├── Flutter 3.0+
├── Dart 3.0+
├── Firebase Auth
├── Dio (HTTP Client)
├── Flutter BLoC
├── GetIt (DI)
├── Provider
└── Google Fonts

A Agregar (Próximas fases):
├── SQLite / Hive (Caché)
├── Firebase Cloud Messaging (Push)
├── Firebase Analytics
├── Camera (Biometría)
├── ML Kit (Facial recognition)
├── Connectivity (Offline detection)
├── Shared Preferences (Preferencias)
└── Mockito (Testing)
```

---

## 📋 Requisitos del Backend (Para futuras fases)

### Miembros de Familia
```
GET /api/v1/miembros/{vivienda_id}
POST /api/v1/miembros/{residente_id}/agregar
POST /api/v1/miembros/{miembro_id}/desactivar
DELETE /api/v1/miembros/{miembro_id}
```

### Propietarios
```
GET /api/v1/propietarios/{vivienda_id}
POST /api/v1/propietarios/
POST /api/v1/propietarios/{id}/conyuge
DELETE /api/v1/propietarios/{id}
```

### Validación de Acceso
```
POST /api/v1/acceso/validar-qr
POST /api/v1/face/registrar
POST /api/v1/face/validar
```

---

## 👥 Responsabilidades

| Rol | Responsabilidad | Fases |
|-----|-----------------|-------|
| Frontend Dev | UI/BLoCs/Pages | 6, 7, 8, 13 |
| Backend Dev | API endpoints | 6, 7, 8, 9 |
| ML/AI | Modelo biometría | 9 |
| DevOps | Build/Deploy CI/CD | 16, 17 |
| QA | Testing | 16 |

---

## 🎓 Lecciones & Mejores Prácticas

### Lo que funcionó bien
✅ Arquitectura hexagonal permite cambios fáciles
✅ DTOs desacoplan respuestas de API
✅ BLoCs centralizan lógica de estado
✅ Separación de capas es clara

### Mejoras futuras
⚠️ Agregar más tests unitarios
⚠️ Documentar endpoints conforme se crean
⚠️ Versionar API (v1, v2, etc.)
⚠️ Error handling más específico

---

## 📞 Contacto & Soporte

### Dudas sobre esta fase:
- Ver `IMPLEMENTACION_APIS_RESUMEN.md`
- Ver `GUIA_RAPIDA_APIS.md`
- Ver `CHECKLIST_CONFIGURACION.md`

### Para fases futuras:
- Backend: Coordinar con backend team
- UI/UX: Revisar wireframes en Figma
- Testing: Crear test plan antes de dev

---

## ✨ Conclusión

La base está lista. Las próximas fases se construirán sobre esta arquitectura sólida.

**Estado**: 🟢 Productivo
**Siguiente hito**: Fase 6 (Miembros de Familia)
**Duración estimada**: 2 meses hasta MVP+
**Equipo estimado**: 2-3 developers

---

**Documento actualizado**: 2024-12-19
**Versión**: 1.0.0 Roadmap
**Responsable**: Equipo de Desarrollo

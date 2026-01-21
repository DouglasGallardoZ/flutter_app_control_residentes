## 📊 Matriz de trazabilidad de la App

| Rol / Actor              | Código RF | Descripción breve | Tablas principales en Postgres |
|---------------------------|-----------|-------------------|--------------------------------|
| **Administrador del Sistema** | RF-C05 | Bloquear cuentas de residente y miembros de familia | `cuenta`, `evento_cuenta`, `bitacora` |
|                           | RF-C06 | Desbloquear cuentas de residente y miembros de familia | `cuenta`, `evento_cuenta`, `bitacora` |
|                           | RF-C07 | Bloquear cuenta individual (residente o miembro) | `cuenta`, `evento_cuenta` |
|                           | RF-C08 | Desbloquear cuenta individual (residente o miembro) | `cuenta`, `evento_cuenta` |
|                           | RF-C09 | Eliminación definitiva de cuenta | `cuenta`, `evento_cuenta`, `bitacora` |
|                           | RF-P01 | Registro de propietario | `propietario_vivienda`, `persona`, `vivienda` |
|                           | RF-P02 | Registro de cónyuge | `propietario_vivienda`, `persona` |
|                           | RF-P03 | Actualización de información de propietario | `propietario_vivienda`, `persona` |
|                           | RF-P04 | Baja de propietario | `propietario_vivienda` |
|                           | RF-P05 | Cambio de propietario de vivienda | `propietario_vivienda`, `vivienda` |
|                           | RF-R01 | Registro de residente | `residente_vivienda`, `persona` |
|                           | RF-R02 | Registro de miembro de familia | `miembro_vivienda`, `persona` |
|                           | RF-R03 | Desactivación de residente | `residente_vivienda` |
|                           | RF-R04 | Desactivación de miembro de familia | `miembro_vivienda` |
|                           | RF-R05 | Reactivación de residente | `residente_vivienda` |
|                           | RF-R06 | Reactivación de miembro de familia | `miembro_vivienda` |
|                           | RF-N01 | Notificaciones masivas a residentes | `notificacion`, `notificacion_destino` |
|                           | RF-N02 | Notificaciones masivas a propietarios | `notificacion`, `notificacion_destino` |
|                           | RF-N03 | Notificación individual a residente | `notificacion`, `notificacion_destino` |
|                           | RF-N04 | Notificación individual a propietario | `notificacion`, `notificacion_destino` |
| **Residente**             | RF-C01 | Crear cuenta de residente | `cuenta`, `persona`, `residente_vivienda` |
|                           | RF-C04 | Autorizar registro de miembro de familia | `miembro_vivienda`, `cuenta` |
|                           | RF-Q01 | Generar QR propio | `qr`, `acceso` |
|                           | RF-Q02 | Generar QR para visitas | `qr`, `visita`, `acceso` |
| **Miembro de Familia**    | RF-C02 | Crear cuenta de miembro no registrado (con autorización) | `cuenta`, `miembro_vivienda`, `persona` |
|                           | RF-C03 | Crear cuenta de miembro registrado | `cuenta`, `miembro_vivienda` |
|                           | RF-Q01 | Generar QR propio | `qr`, `acceso` |
|                           | RF-Q02 | Generar QR para visitas | `qr`, `visita`, `acceso` |

---

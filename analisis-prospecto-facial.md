# Análisis: Tipos de prospecto en FacialVerificationPage

**Fecha:** 2026-07-08

---

## 1. Constructor — tipo `dynamic`

```dart
class FacialVerificationPage extends StatelessWidget {
  final dynamic prospecto;              // ← dynamic: acepta cualquier tipo
  final VerificationMode mode;          // ← createCredentials (default) o unlockApp

  const FacialVerificationPage({
    super.key,
    required this.prospecto,            // ← siempre se requiere
    this.mode = VerificationMode.createCredentials,
  });
```

## 2. Getters que acceden al `prospecto`

```dart
// Línea 62-68: determina el tipo de registro
String get _tipoRegistro {
  if (widget.prospecto is ProspectoMiembro) return 'miembro';
  if (widget.prospecto is ProspectoResidente) {
    return (widget.prospecto as ProspectoResidente).tipoRegistro;
  }
  return 'residente';   // ← fallback seguro
}

// Línea 70-78: extrae personaId
int get _personaId {
  if (widget.prospecto is ProspectoMiembro) {
    return (widget.prospecto as ProspectoMiembro).personaId ?? 0;
  }
  if (widget.prospecto is ProspectoResidente) {
    return (widget.prospecto as ProspectoResidente).personaId ?? 0;
  }
  return 0;             // ← fallback seguro
}
```

**Sin crash silencioso:** ambos getters usan `null-aware ??` y `fallback 0`. Si `prospecto` es `null` o de otro tipo, retornan valores por defecto.

## 3. Usos de FacialVerificationPage en el proyecto (6 lugares)

| Origen | Línea | Tipo de `prospecto` | `mode` | Propósito |
|--------|-------|---------------------|--------|-----------|
| **`prospecto_miembro_page.dart`** → `/facialVerification` | routes:117 | `ProspectoResidente` (construido en listener) | `createCredentials` (default) | Miembro existe → verificación facial |
| **`member_facial_enrollment_page.dart`** → inline | 184 | `ProspectoMiembro` (con `widget.prospectoCompleto ?? ProspectoMiembro(personaId)`) | `createCredentials` (default) | Enrolamiento exitoso → verificación |
| **`login_page.dart`** → inline | 130 | `ProspectoResidente` | `unlockApp` | Login → step-up auth |
| **`family_dashboard_page.dart`** → inline | 62 | `ProspectoResidente` | `unlockApp` | Navegación segura desde dashboard |
| **`resident_dashboard_page.dart`** → inline | 64 | `ProspectoResidente` | `unlockApp` | Navegación segura desde dashboard |
| **Ruta `/facialVerification`** | routes:113-121 | `settings.arguments` (sin cast) | `createCredentials` (default) | Desde Navigator.pushNamed |

## 4. Modo `unlockApp` vs `createCredentials`

| `mode` | Uso | Navegación al éxito |
|--------|-----|---------------------|
| `createCredentials` (default) | Registro de residente/miembro | `Navigator.pushNamed('/credentialsMiembro' o '/credentialsResidente')` |
| `unlockApp` | Step-up auth (login, dashboard) | `Navigator.of(context).pop(true)` |

## 5. Verificación de compatibilidad: `ProspectoMiembro` desde `MemberFacialEnrollmentPage`

La página `MemberFacialEnrollmentPage` (línea 170-180) construye:
```dart
final prospectoMiembro = widget.prospectoCompleto ?? ProspectoMiembro(
  existe: true,
  personaId: widget.personaId,
  nombres: widget.nombres,
  apellidos: widget.apellidos,
);
```

Luego navega:
```dart
Navigator.of(context).pushReplacement(
  MaterialPageRoute(
    builder: (_) => FacialVerificationPage(prospecto: prospectoMiembro),
  ),
);
```

`FacialVerificationPage` recibe un `ProspectoMiembro` con `personaId`, `nombres`, `apellidos`. 
- `_tipoRegistro` → `'miembro'` ✅
- `_personaId` → `personaId ?? 0` ✅ (nunca null porque widget.personaId es `required int`)
- Éxito → `Navigator.pushNamed('/credentialsMiembro', ...)` ✅

**Conclusión:** El paso de `ProspectoMiembro` desde `MemberFacialEnrollmentPage` a `FacialVerificationPage` es seguro y no debería causar crash silencioso. Todos los accesos a propiedades usan `is` checks y `null` fallbacks.

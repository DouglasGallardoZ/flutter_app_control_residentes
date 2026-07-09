# Diagnóstico: Bug "Miembro No Registrado" para miembro existente

**Fecha:** 2026-07-08
**Proyecto:** Guardin

---

## Cadena de llamadas

```
ProspectoMiembroPage (UI)
  → BlocListener dispatch: ValidarProspectoMiembro(identificacion)
    → ProspectoValidationBloc._onValidarProspectoMiembro()
      → ValidarProspectoMiembroUseCase.execute(identificacion)
        → AccountRepository.validarProspectoMiembro()
          → AccountRepositoryImpl.validarProspectoMiembro()
            → AccountApiProvider.validarProspectoMiembro()
              → GET /cuentas/prospecto/miembro/{id}
              ← Response: {"existe": true, "persona_id": 22, "nombres": "Leonor", ...}
              → ProspectoMiembro.fromJson(response.data)
              ← ProspectoMiembro(existe: true, personaEncontrada: null, ...)
      → BLoC check: existe && personaEncontrada == true
      → true && (null == true) = FALSE → ❌ BUG
      → emit(ProspectoValidationError("Miembro no encontrado en el sistema"))
  → UI: state.message.contains("no encontrado") → "Miembro No Registrado" dialog
```

## Causa raíz

| Archivo | Línea | Código | Problema |
|---------|-------|--------|----------|
| `prospecto_validation_bloc.dart` | 44 | `if (prospecto.existe && prospecto.personaEncontrada == true)` | Requiere que `personaEncontrada` sea explícitamente `true`. Pero la API no envía este campo. |
| `domain/entities/prospecto_residente.dart` | 73 | `personaEncontrada: json['persona_encontrada']` | `personaEncontrada` es `null` cuando el backend no lo envía. |
| `prospecto_miembro_page.dart` | 115 | `if (state.message.contains('no encontrado'))` | Muestra "Miembro No Registrado" para el error genérico. |

## API response real vs. esperado

| Campo | API envía | Flutter recibe |
|-------|-----------|----------------|
| `existe` | `true` | `true` |
| `persona_encontrada` | ❌ No enviado | `null` |
| `persona_id` | `22` | `22` |
| `nombres` | `"Leonor"` | `"Leonor"` |
| `apellidos` | `"Teran"` | `"Teran"` |

## Flujo de decisión en el BLoC

```dart
// Línea 44 - condición actual
if (prospecto.existe && prospecto.personaEncontrada == true)
//                   ↑              ↑
//                 true        null == true = FALSE
// Resultado: NO ENTRA al if → cae al else → error
```

## Corrección necesaria

**Archivo:** `lib/application/blocs/prospecto_validation/prospecto_validation_bloc.dart`
**Línea 44:**
```dart
// ANTES (roto):
if (prospecto.existe && prospecto.personaEncontrada == true)

// DESPUÉS (corregido):
if (prospecto.existe && (prospecto.personaEncontrada ?? true))
//                        ↑   null → usa true por defecto
```

O simplemente:
```dart
if (prospecto.existe)
// Ya que existe=true es suficiente para considerar al miembro como registrado
```

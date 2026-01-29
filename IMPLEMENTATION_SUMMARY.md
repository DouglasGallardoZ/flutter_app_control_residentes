# Access Tracking Implementation Summary

## Overview
This implementation adds real-time access tracking to the resident and member dashboards, displaying the number of accesses today and showing detailed access history with filtering capabilities.

## Changes Made

### 1. **Extended ResidentBloc** (`lib/application/blocs/resident/resident_bloc.dart`)
   - Added `GetResidenceAccessesUseCase` injection
   - Added new event handler: `_onLoadResidenceAccesses()`
   - Handles loading residence access data from the API endpoint

### 2. **New Event Class** (`lib/application/blocs/resident/resident_event.dart`)
   - Added `LoadResidenceAccessesEvent` class
   - Supports optional filters: `fechaInicio`, `fechaFin`, `tipo`, `resultado`
   - Required parameter: `viviendaId`

### 3. **New State Class** (`lib/application/blocs/resident/resident_state.dart`)
   - Added `ResidenceAccessesLoaded` state
   - Contains `accessesData` (Map with accesos list) and `viviendaId`
   - Used to display access information in the UI

### 4. **Updated Dependency Injection** (`lib/injection.dart`)
   - Registered `GetResidenceAccessesUseCase` in `ResidentBloc`
   - Added injection of `getResidenceAccessesUseCase` parameter

### 5. **Enhanced Resident Dashboard** (`lib/presentation/pages/resident_dashboard_page.dart`)
   - Added `_requestedAccesses` flag to track if accesses were loaded
   - Imported `ResidentBloc`, `ResidentEvent`, and `ResidentState`
   - **Metrics Section**: 
     - "Accesos Hoy" now dynamically loads and displays real access count
     - Calls API with today's date filters (YYYY-MM-DD format)
     - Shows loading state while fetching data
   - **Recent Activity Section**:
     - Replaced hardcoded activity with real access data
     - Displays up to 3 most recent accesses
     - Shows access type (QR Residente, QR Visita, etc.)
     - Indicates success/failure status with visual indicator
     - Handles empty state gracefully

### 6. **Refactored Access History Page** (`lib/presentation/pages/access_history_page.dart`)
   - **Migrated from `AccessHistoryBloc` to `ResidentBloc`**
   - Now uses `LoadResidenceAccessesEvent` for residence-specific data
   - **Filters**:
     - Status: Todos, Exitosos, Rechazados
     - Type: Todos, QR Residente, QR Visita
   - **Features**:
     - Loads accesses from residence via `residence_id` from AuthBloc
     - Displays access type, timestamp, and result status
     - Proper error handling with user-friendly messages
     - Empty state message when no accesses exist
   - **Navigation**:
     - Fixed null safety issues in navigation handling
     - Maintains proper state across tab transitions

## API Integration

### Endpoint Used
- **GET** `/api/v1/accesos/vivienda/{vivienda_id}`
- Optional filters: `fecha_inicio`, `fecha_fin`, `tipo`, `resultado`
- Authentication: Bearer token (required)

### Response Structure
```json
{
  "vivienda_id": 123,
  "manzana": "A",
  "villa": "101",
  "total_accesos": 5,
  "accesos": [
    {
      "acceso_pk": 1,
      "tipo": "qr_residente",
      "vivienda_visita_fk": 123,
      "resultado": "autorizado",
      "motivo": null,
      "placa_detectada": null,
      "biometria_ok": true,
      "placa_ok": false,
      "intentos": 1,
      "observacion": null,
      "fecha_creado": "2024-01-15T14:30:00",
      "guardia_nombre": null,
      "residente_autoriza_nombre": "Juan Pérez",
      "visita_nombres": null
    }
  ]
}
```

## Data Flow

1. **User logs in** → AuthBloc stores `residence_id` (viviendaId)
2. **Resident Dashboard loads** → Requests accesses for today
   ```
   LoadResidenceAccessesEvent(
     viviendaId: authState.user['residence_id'],
     fechaInicio: "2024-01-15",
     fechaFin: "2024-01-15"
   )
   ```
3. **ResidentBloc processes** → Calls GetResidenceAccessesUseCase
4. **API returns data** → BLoC emits `ResidenceAccessesLoaded` state
5. **UI updates** → Displays accesses count and recent activity

## Key Features

✅ **Real-time access tracking** - Shows actual access counts per day
✅ **Access type identification** - Distinguishes between QR Residente, QR Visita, etc.
✅ **Success/Failure status** - Visual indicators for authorized/rejected accesses
✅ **Filtering capabilities** - Filter by status and access type
✅ **Responsive design** - Adapts to loading, success, and error states
✅ **Null safety** - All potential null values properly handled
✅ **Navigation support** - Maintains data across dashboard tabs

## Testing Recommendations

1. **Verify access count updates** when new accesses are logged
2. **Test filter functionality** with various date ranges and types
3. **Validate error handling** with invalid residence IDs
4. **Check navigation flow** between dashboard and history pages
5. **Test with family members** to ensure proper role-based access

## Files Modified
- `lib/application/blocs/resident/resident_bloc.dart`
- `lib/application/blocs/resident/resident_event.dart`
- `lib/application/blocs/resident/resident_state.dart`
- `lib/injection.dart`
- `lib/presentation/pages/resident_dashboard_page.dart`
- `lib/presentation/pages/access_history_page.dart`

## Dependencies Used
- `flutter_bloc` - State management
- `get_it` - Dependency injection (already imported)
- Existing `GetResidenceAccessesUseCase` - API integration
- `AccesosViviendaDTO` - Data model (already existed)

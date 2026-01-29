# Access Tracking Feature - Usage Guide

## Overview
The access tracking feature now displays real-time access information in both the resident dashboard and detailed access history page.

## Features Implemented

### 1. Resident Dashboard - "Accesos Hoy" Metric
**Location**: Metrics section at the top of the resident dashboard
- **Automatic Loading**: Fetches accesses for today's date automatically
- **Display**: Shows the count of accesses that occurred today
- **Loading State**: Displays a loading indicator while fetching
- **Real-time**: Uses the API endpoint `/api/v1/accesos/vivienda/{vivienda_id}`

**How it works**:
1. User opens the resident dashboard
2. The page automatically loads the user's `residence_id` from the authenticated session
3. An API call is made with today's date as both `fecha_inicio` and `fecha_fin`
4. The returned count is displayed in the metric card

### 2. Recent Activity Section
**Location**: Below "Acceso Rápido" section on the dashboard
- **Display**: Shows up to 3 most recent accesses
- **Information**:
  - Access type (QR Residente, QR Visita, Autorizado por Guardia)
  - Date and time of access
  - Success/Failure status with visual indicator
- **Empty State**: Shows friendly message if no accesses today

**Access Types shown**:
- 🔵 **QR Residente** - Resident's personal QR code access
- 👥 **QR Visita** - Visitor QR code access
- 👮 **Autorizado por Guardia** - Manual authorization by security guard

**Status Indicators**:
- ✅ **Exitoso** (Success) - Green checkmark
- ❌ **Rechazado** (Rejected) - Red X mark

### 3. Access History Page
**Location**: Navigate via "Historial" button in quick access or tab navigation
- **Full History**: Displays all accesses for the residence
- **Filters**:
  - **Status Filter**: Todos, Exitosos, Rechazados
  - **Type Filter**: Todos, QR Residente, QR Visita
- **Pagination**: Displays accesses in scrollable list
- **Details**: Shows access type, timestamp, and result

**Filter Examples**:
- Select "Exitosos" + "QR Residente" = Show successful resident QR accesses only
- Select "Rechazados" + "Todos" = Show all rejected accesses
- Select "Todos" + "Todos" = Show all accesses without filtering

## Technical Architecture

### Data Flow Diagram
```
┌─────────────────────────────────────────────────────────────┐
│                   User Session                              │
│         (AuthBloc stores residence_id)                      │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
        ┌──────────────────────────────┐
        │   ResidentDashboardPage      │
        │   AccessHistoryPage          │
        └──────────────┬───────────────┘
                       │
                       ▼
        ┌──────────────────────────────┐
        │  LoadResidenceAccessesEvent  │
        │   (viviendaId, date filters) │
        └──────────────┬───────────────┘
                       │
                       ▼
        ┌──────────────────────────────┐
        │     ResidentBloc Handler     │
        │   _onLoadResidenceAccesses   │
        └──────────────┬───────────────┘
                       │
                       ▼
        ┌──────────────────────────────────────┐
        │  GetResidenceAccessesUseCase         │
        │  (Domain business logic layer)       │
        └──────────────┬───────────────────────┘
                       │
                       ▼
        ┌──────────────────────────────────────┐
        │  ResidentRepositoryImpl               │
        │  (Infrastructure adapter)            │
        └──────────────┬───────────────────────┘
                       │
                       ▼
        ┌──────────────────────────────────────┐
        │  AdminApi.getResidenceAccesses()     │
        │  GET /api/v1/accesos/vivienda/{id}   │
        └──────────────┬───────────────────────┘
                       │
                       ▼
        ┌──────────────────────────────────────┐
        │  API Server Response                 │
        │  (AccesosViviendaDTO)                │
        └──────────────┬───────────────────────┘
                       │
                       ▼
        ┌──────────────────────────────────────┐
        │  ResidenceAccessesLoaded State       │
        │  (UI updates with data)              │
        └──────────────────────────────────────┘
```

### Files Involved
1. **State Management**
   - `lib/application/blocs/resident/resident_bloc.dart` - Event handler
   - `lib/application/blocs/resident/resident_event.dart` - LoadResidenceAccessesEvent
   - `lib/application/blocs/resident/resident_state.dart` - ResidenceAccessesLoaded state

2. **Domain Layer**
   - `lib/domain/usecases/get_residence_accesses_usecase.dart` - UseCase (existing)
   - `lib/domain/ports/resident_repository.dart` - Repository interface (existing)

3. **Infrastructure Layer**
   - `lib/infrastructure/adapters/resident_repository_impl.dart` - Implementation
   - `lib/infrastructure/providers/admin_api.dart` - API client
   - `lib/infrastructure/dtos/acceso_vivienda_dto.dart` - DTO

4. **Presentation Layer**
   - `lib/presentation/pages/resident_dashboard_page.dart` - Dashboard UI
   - `lib/presentation/pages/access_history_page.dart` - History page UI

5. **Dependency Injection**
   - `lib/injection.dart` - Service locator configuration

## API Endpoint Details

### Endpoint
```
GET /api/v1/accesos/vivienda/{vivienda_id}
```

### Request Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| vivienda_id | integer | Yes | ID of the residence |
| fecha_inicio | string | No | Start date (YYYY-MM-DD) |
| fecha_fin | string | No | End date (YYYY-MM-DD) |
| tipo | string | No | Access type filter |
| resultado | string | No | Result filter |

### Response Example
```json
{
  "vivienda_id": 123,
  "manzana": "A",
  "villa": "101",
  "total_accesos": 5,
  "accesos": [
    {
      "acceso_pk": 1001,
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
    },
    {
      "acceso_pk": 1002,
      "tipo": "qr_visita",
      "vivienda_visita_fk": 123,
      "resultado": "autorizado",
      "motivo": null,
      "fecha_creado": "2024-01-15T15:45:00",
      "visitaNombres": "Carlos López"
    }
  ]
}
```

## Access Types (Tipos)
- `qr_residente` - Resident QR code
- `qr_visita` - Visitor QR code
- `visita_sin_qr` - Visitor without QR
- `manual_guardia` - Manual entry by guard

## Access Results (Resultados)
- `autorizado` - Access granted
- `rechazado` - Access denied
- `codigo_expirado` - QR code expired
- `cuenta_bloqueada` - Account blocked

## Troubleshooting

### Issue: Accesos Hoy shows 0 but there were accesses
**Solution**: 
- Verify the API is running and accessible
- Check that `residence_id` is properly set in the AuthBloc
- Ensure date filters are correct (today's date in YYYY-MM-DD format)

### Issue: Access History page shows "No hay registros"
**Possible causes**:
1. User has no accesses in the selected date range
2. Filters are too restrictive
3. API endpoint is not responding

**Solution**:
- Clear filters (select "Todos" for both status and type)
- Check API logs for errors
- Verify user's residence_id is valid

### Issue: Data not updating
**Solution**:
- Refresh the page (pull down to refresh)
- The data loads automatically on page open
- Check internet connection

## Testing the Feature

### Unit Test Suggestions
```dart
// Test LoadResidenceAccessesEvent
test('should emit ResidenceAccessesLoaded when accesses are fetched', () async {
  // Arrange
  final event = LoadResidenceAccessesEvent(viviendaId: 123);
  
  // Act
  residentBloc.add(event);
  
  // Assert
  await expectLater(
    residentBloc.stream,
    emitsInOrder([
      ResidentLoading(),
      isA<ResidenceAccessesLoaded>(),
    ]),
  );
});
```

### Manual Testing Steps
1. **Log in** as a resident
2. **Navigate** to the resident dashboard
3. **Verify** "Accesos Hoy" shows a number
4. **Check** recent activity section displays actual accesses
5. **Click** "Historial" button
6. **Test** each filter combination
7. **Verify** date ranges work correctly

## Performance Notes
- Accesses are loaded once per page open
- Data is cached in the BLoC state
- Filters are applied client-side (no additional API calls)
- Pull-to-refresh will reload the data

## Future Enhancements
- [ ] Real-time updates via WebSocket
- [ ] Export access history to PDF
- [ ] Detailed access analytics
- [ ] Access alerts/notifications
- [ ] Advanced filtering by time ranges
- [ ] Access statistics dashboard

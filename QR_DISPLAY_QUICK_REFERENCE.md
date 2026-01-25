# QR Display Refactoring - Quick Reference Guide

## 🎯 What Was Changed?

The `qr_display_page.dart` was violating Hexagonal Architecture by embedding business logic in the presentation layer. It's now fully refactored with proper separation of concerns.

---

## 📂 New Files

```
lib/application/blocs/qr_display/
├── qr_display_bloc.dart      (175 lines - Business logic)
├── qr_display_event.dart     (20 lines - Event definitions)
└── qr_display_state.dart     (50 lines - State & Value objects)
```

---

## 🔧 Modified Files

1. **lib/presentation/pages/qr_display_page.dart**
   - Removed: All business logic, data extraction, navigation switch
   - Added: BlocListener, BlocBuilder, event triggers
   - Result: ~200 lines of pure UI code

2. **lib/injection.dart**
   - Added: `AuthBloc` registration
   - Added: `QrDisplayBloc` registration

3. **lib/app.dart**
   - Added: `QrDisplayBloc` import
   - Added: `BlocProvider<QrDisplayBloc>` to MultiBlocProvider
   - Cleaned: Removed unused imports

---

## 📊 Architecture Layers

```
┌─────────────────────────────────────────┐
│        PRESENTATION LAYER               │
│  qr_display_page.dart (UI Only)         │
│  - BlocBuilder for state rendering      │
│  - BlocListener for navigation          │
│  - Event triggers on user actions       │
└──────────────────┬──────────────────────┘
                   │
                   │ depends on
                   ↓
┌─────────────────────────────────────────┐
│       APPLICATION LAYER                 │
│  qr_display_bloc.dart                   │
│  - _onInitialize()                      │
│  - _onNavigateToScreen(index)           │
│  - _onNavigateBack()                    │
│  - _extractUserData()                   │
└──────────────────┬──────────────────────┘
                   │
                   │ reads
                   ↓
┌─────────────────────────────────────────┐
│       APPLICATION LAYER                 │
│  AuthBloc.state                         │
│  - PersonaId, nombres, apellidos        │
│  - Vivienda object, role                │
└─────────────────────────────────────────┘
```

---

## 🔄 Data Flow

### Initialization
```
PageInitialized
    ↓
context.read<QrDisplayBloc>().add(InitializeQrDisplay())
    ↓
BLoC reads AuthBloc.state
    ↓
_extractUserData() processes:
  - Concatenate nombres + apellidos
  - Format residencia from vivienda
  - Determine role (family member or resident)
  - Set homeRoute based on role
    ↓
emit(QrDisplayLoaded(UserDataForDisplay))
    ↓
BlocBuilder rebuilds UI with userData
```

### Navigation
```
User taps tab (index 0, 2, 3, or 4)
    ↓
onTabSelected(i) callback
    ↓
context.read<QrDisplayBloc>().add(NavigateToScreen(i))
    ↓
BLoC._onNavigateToScreen(event) handles:
  - Case 0: Navigate to home (Dashboard/FamilyDashboard)
  - Case 2: Navigate to AccessHistory
  - Case 3: Navigate to Members
  - Case 4: Navigate to Profile
    ↓
emit(NavigationRequested(route, arguments))
    ↓
BlocListener receives state change
    ↓
Navigator.of(context).pushNamed(route, arguments: arguments)
```

---

## 🧩 Key Components

### UserDataForDisplay (Value Object)
```dart
class UserDataForDisplay {
  final String userId;              // personaId from AuthBloc
  final String userName;            // "nombres apellidos"
  final String identificacion;      // User ID
  final String residenceId;         // "Manzana X, Villa Y"
  final bool isFamilyMember;        // Role check
  final String homeRoute;           // /residentDashboard or /familyDashboard
}
```

### QrDisplayBloc Events
```dart
InitializeQrDisplay()              // Load user data
NavigateToScreen(int screenIndex)  // Navigate to screen
NavigateBack()                     // Return to home
```

### QrDisplayBloc States
```dart
QrDisplayInitial              // Starting state
QrDisplayLoaded(userData)     // Data loaded, ready to display
QrDisplayError(message)       // Error occurred
NavigationRequested(route)    // Navigation needed
```

---

## 🎯 Usage in Page

```dart
// Initialize in initState
@override
void initState() {
  super.initState();
  context.read<QrDisplayBloc>().add(InitializeQrDisplay());
}

// Handle navigation
void onTabSelected(int i) {
  context.read<QrDisplayBloc>().add(NavigateToScreen(i));
}

// In build method
@override
Widget build(BuildContext context) {
  return BlocListener<QrDisplayBloc, QrDisplayState>(
    listener: (context, state) {
      if (state is NavigationRequested) {
        Navigator.of(context).pushNamed(state.route, arguments: state.arguments);
      }
    },
    child: BlocBuilder<QrDisplayBloc, QrDisplayState>(
      builder: (context, state) {
        if (state is QrDisplayLoaded) {
          // Render UI with state.userDataForDisplay
          return YourUI(userData: state.userDataForDisplay);
        }
        return LoadingIndicator();
      },
    ),
  );
}
```

---

## ✅ Compliance Checklist

- [x] All business logic in BLoC
- [x] Presentation layer = UI only
- [x] Proper event/state definitions
- [x] Value object for data passing
- [x] Dependency injection configured
- [x] No compilation errors
- [x] Hexagonal Architecture compliant
- [x] BLoC pattern compliant
- [x] Null safety maintained
- [x] Error handling implemented

---

## 🐛 Debugging Tips

### Check BLoC State
```dart
print(context.read<QrDisplayBloc>().state);
```

### Check Navigation
```dart
// In BLoC
debugPrint('[QrDisplayBloc] Navigating to $route with args $arguments');

// In Page
debugPrint('[QrDisplayPage] NavigationRequested: $route');
```

### Test User Data Extraction
```dart
// In QrDisplayBloc._extractUserData()
debugPrint('[extractUserData] userName: $userName');
debugPrint('[extractUserData] residenceId: $residenceId');
```

---

## 📝 Notes

- BLoC handles ALL business logic
- Page is PURELY for rendering UI
- Navigation is state-driven (not imperatively called)
- User data is extracted ONCE and stored in state
- Value object ensures type safety for data passing
- Proper null handling at all layers

---

**Status**: ✅ Production Ready  
**Errors**: ZERO  
**Architecture**: COMPLIANT ✅

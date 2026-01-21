# 🚀 Quick Start - Testing API Integration

**Time to Test:** ~15 minutes  
**Prerequisites:** Backend running, admin credentials ready

---

## 🎯 Test Scenario Overview

### Scenario 1: Load Residents (5 min)
```
1. Start app
2. Navigate to: Admin → Gestión de Usuarios → Residentes
3. Verify: Spinner appears while loading
4. Verify: List of residents loads after 2-3 seconds
5. Verify: Each resident shows: Name, Section, Villa, Status
```

### Scenario 2: Search Residents (3 min)
```
1. Type a resident name in search box
2. Verify: List filters in real-time
3. Clear search box
4. Verify: All residents show again
```

### Scenario 3: Block/Unblock Resident (5 min)
```
1. Click ⋮ menu on a resident
2. Select "Bloquear"
3. Confirm in dialog
4. Verify: Resident shows "Bloqueado" chip
5. Click menu again, select "Desbloquear"
6. Verify: "Bloqueado" chip disappears
```

### Scenario 4: Delete Resident (2 min)
```
1. Click ⋮ menu on a resident
2. Select "Eliminar"
3. Confirm deletion
4. Verify: Resident removed from list
```

### Scenario 5: Error Handling (3 min)
```
1. Disconnect network (airplane mode)
2. Click "Reintentar" button
3. Verify: Error message appears
4. Reconnect network
5. Click "Reintentar" again
6. Verify: Data loads successfully
```

---

## 📍 Page Navigation

### Admin Dashboard Access
```
Start App
    ↓
Login with admin account
    ↓
Bottom NavBar → Click Admin icon (4th tab)
    ↓
AdminScaffold loaded (4 tabs: Dashboard, AccessHistory, Users, Profile)
    ↓
Click "Users" tab (Tab 2)
    ↓
AdminUsersPage (4 cards)
```

### From Users Hub to Specific Pages
```
AdminUsersPage
├── Residentes Card → AdminResidentsPage ✅ API INTEGRATED
├── Propietarios Card → AdminOwnersPage ✅ API INTEGRATED  
├── Miembros Card → AdminMembersPage ✅ API INTEGRATED
└── Cuentas Card → AdminAccountsPage ⚠️ PARTIAL INTEGRATION
```

---

## 🧪 Test Data Checklist

### What to Look For

#### AdminResidentsPage
- [ ] Data loads automatically on page open
- [ ] Shows at least 3 residents
- [ ] Each resident has: Name, Section, Villa, Email, Phone, Join Date
- [ ] Some residents marked as "Bloqueado"
- [ ] Search works for name and villa
- [ ] Block/Unblock changes status immediately

#### AdminOwnersPage
- [ ] Data loads automatically
- [ ] Shows owner name, email, phone, property count
- [ ] "Ver propiedades" button shows list
- [ ] Block/Unblock functionality works
- [ ] Delete removes owner from list

#### AdminMembersPage
- [ ] Data loads automatically
- [ ] Shows member info with family relationship
- [ ] Search works for name and parent name
- [ ] Block/Unblock works
- [ ] Delete works

#### AdminAccountsPage (Currently on Mock Data)
- [ ] Shows account list (mock data for now)
- [ ] Block/Unblock buttons work (real API)
- [ ] Delete button works (real API)
- [ ] Status filter works (mock data)

---

## 🔴 Error Scenarios to Test

### Network Error
```
Steps:
1. Open page
2. Data loading... (spinner shows)
3. Turn off WiFi/Internet
4. After 10 seconds, error message appears:
   "Error al cargar residentes: Connection timeout"
5. "Reintentar" button visible
6. Turn WiFi back on
7. Click "Reintentar"
8. Data loads successfully
```

### Empty List
```
Steps:
1. Open page
2. Spinner shows
3. If no data in backend, shows:
   "No se encontraron residentes"
   (With icon)
```

### Invalid Search
```
Steps:
1. Open page
2. Data loads
3. Search for non-existent value (e.g., "zzzzz")
4. Shows: "No se encontraron residentes"
5. Clear search
6. All data shows again
```

---

## ✅ Expected Behavior

### Loading State
```
Show: CircularProgressIndicator (spinning circle)
Text: "Cargando residentes..."
Duration: 1-3 seconds (depends on backend)
Then: List appears
```

### Error State
```
Show: Error icon + message
Message: "Error al cargar residentes: [specific error]"
Button: "Reintentar"
Action: Click button to retry
```

### Success State
```
Show: Populated list
Each item: Card with person data
Actions: Menu button (⋮) with options
Search: Active search box
```

### Block/Unblock
```
Before: No "Bloqueado" chip
Menu: Click ⋮
Dialog: "¿Desea bloquear a [name]?"
Action: Click "Bloquear"
After: "Bloqueado" chip appears
Later: Can click "Desbloquear" to remove it
```

---

## 🐛 Troubleshooting

### Page Shows Spinner Forever
**Problem:** Data stuck loading  
**Solution:**
1. Pull down to refresh (if available)
2. Click "Reintentar" button
3. Navigate away and back
4. Check backend is running

### Data Doesn't Show After Load
**Problem:** API returns data but UI blank  
**Solution:**
1. Check backend returns correct field names
2. Check field mapping in code (see API_INTEGRATION_SUMMARY.md)
3. View network logs to see actual response

### Block/Unblock Returns Error
**Problem:** API call fails  
**Solution:**
1. Verify account ID is correct
2. Check backend endpoint exists
3. Check authentication token valid
4. View error message for details

### Search Not Working
**Problem:** Search doesn't filter list  
**Solution:**
1. Type slowly and wait for update
2. Search is case-insensitive (should work)
3. Search in name, email, or villa fields
4. Verify data loaded before searching

### Error Message Too Fast to Read
**Problem:** Can't see error details  
**Solution:**
1. Look in app logs (flutter logs)
2. Check device logcat (Android)
3. Check Xcode console (iOS)
4. Add `print()` statements temporarily

---

## 📱 Screenshots to Take

For documentation:
- [ ] Residents list loading (spinner visible)
- [ ] Residents list loaded (data visible)
- [ ] Search results
- [ ] Blocked resident (with chip)
- [ ] Error state (with retry button)
- [ ] Owners list
- [ ] Members list
- [ ] Accounts list

---

## ⏱️ Test Timeline

### Quick 5-Minute Test
```
1. Load residents page (1 min)
2. Search for resident (1 min)
3. Block a resident (1 min)
4. Unblock resident (1 min)
5. Check no errors (1 min)
```

### Full 15-Minute Test
```
1. Test Residents page (5 min)
2. Test Owners page (3 min)
3. Test Members page (3 min)
4. Test Accounts page (2 min)
5. Test error handling (2 min)
```

### Complete 30-Minute Test
```
1. Test all 4 pages (15 min)
2. Test all operations (10 min)
3. Test error scenarios (5 min)
```

---

## 📝 Test Report Template

```
Date: ___________
Tester: ___________
App Version: ___________

RESIDENTS PAGE: PASS / FAIL
- Load data: ✓ / ✗
- Search: ✓ / ✗
- Block: ✓ / ✗
- Unblock: ✓ / ✗
- Delete: ✓ / ✗
Issues: ___________

OWNERS PAGE: PASS / FAIL
- Load data: ✓ / ✗
- Block/Unblock: ✓ / ✗
Issues: ___________

MEMBERS PAGE: PASS / FAIL
- Load data: ✓ / ✗
- Block/Unblock: ✓ / ✗
Issues: ___________

ACCOUNTS PAGE: PASS / FAIL
- Block/Unblock: ✓ / ✗
- Delete: ✓ / ✗
Issues: ___________

ERROR HANDLING: PASS / FAIL
- Network error message: ✓ / ✗
- Retry button works: ✓ / ✗
Issues: ___________

Overall: PASS / FAIL
Comments: ___________
```

---

## 🎯 Success Criteria

### ✅ Test Passes If:
1. All pages load data within 5 seconds
2. No error messages appear (unless intentionally testing errors)
3. Search/filter functionality works
4. Block/Unblock changes status immediately
5. Delete removes item from list
6. Error states show helpful messages
7. Retry button successfully retries operation
8. No crashes or exceptions
9. UI is responsive during operations
10. All operations provide user feedback

### ❌ Test Fails If:
1. Any page crashes
2. Data doesn't load (without error message)
3. Operations fail silently
4. Search doesn't work
5. Block/Unblock doesn't update UI
6. Error messages are confusing
7. No retry mechanism available
8. UI freezes during loading
9. Missing user feedback
10. Backend returns unexpected format

---

## 📞 Support

### If Something Goes Wrong

1. **Check the logs:**
   ```bash
   flutter logs
   ```

2. **Check backend is running:**
   ```bash
   curl http://localhost:8000/residentes
   ```

3. **Look at network traffic:**
   - Use Dio interceptors
   - Check browser DevTools
   - Check Charles Proxy

4. **Review documentation:**
   - API_INTEGRATION_SUMMARY.md
   - BACKEND_INTEGRATION_GUIDE.md
   - IMPLEMENT_GET_ACCOUNTS.md

5. **Report issues with:**
   - Page name (ResidentsPage, OwnersPage, etc.)
   - Expected behavior
   - Actual behavior
   - Error message (if any)
   - Steps to reproduce

---

**Ready to Test!** 🚀  
Start with Scenario 1 and work through each one.

Questions? See EXECUTIVE_SUMMARY.md or API_INTEGRATION_SUMMARY.md

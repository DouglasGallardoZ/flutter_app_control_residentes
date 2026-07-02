abstract class SecuritySessionState {}

class SecuritySessionInitial extends SecuritySessionState {
  SecuritySessionInitial();
}

class SecuritySessionLocked extends SecuritySessionState {
  SecuritySessionLocked();
}

class SecuritySessionActive extends SecuritySessionState {
  SecuritySessionActive();
}

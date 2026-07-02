import 'package:flutter/material.dart';

abstract class SecuritySessionEvent {}

class LockSessionRequested extends SecuritySessionEvent {
  LockSessionRequested();
}

class UnlockSessionRequested extends SecuritySessionEvent {
  UnlockSessionRequested();
}

class AppLifecycleChanged extends SecuritySessionEvent {
  final AppLifecycleState state;

  AppLifecycleChanged(this.state);
}

class SessionTerminated extends SecuritySessionEvent {
  SessionTerminated();
}

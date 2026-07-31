import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'security_session_event.dart';
import 'security_session_state.dart';

class SecuritySessionBloc
    extends Bloc<SecuritySessionEvent, SecuritySessionState> {
  Timer? _ttlTimer;
  static const _ttlDuration = Duration(minutes: 5);

  SecuritySessionBloc() : super(SecuritySessionInitial()) {
    on<LockSessionRequested>(_onLock);
    on<UnlockSessionRequested>(_onUnlock);
    on<AppLifecycleChanged>(_onLifecycleChanged);
    on<SessionTerminated>(_onTerminated);
  }

  void _startTtlTimer() {
    _cancelTtlTimer();
    _ttlTimer = Timer(_ttlDuration, () => add(LockSessionRequested()));
  }

  void _cancelTtlTimer() {
    _ttlTimer?.cancel();
    _ttlTimer = null;
  }

  Future<void> _onLock(
    LockSessionRequested event,
    Emitter<SecuritySessionState> emit,
  ) async {
    _cancelTtlTimer();
    emit(SecuritySessionLocked());
  }

  Future<void> _onUnlock(
    UnlockSessionRequested event,
    Emitter<SecuritySessionState> emit,
  ) async {
    _startTtlTimer();
    emit(SecuritySessionActive());
  }

  Future<void> _onLifecycleChanged(
    AppLifecycleChanged event,
    Emitter<SecuritySessionState> emit,
  ) async {
    if (event.state == AppLifecycleState.paused ||
        event.state == AppLifecycleState.detached) {
      _cancelTtlTimer();
      emit(SecuritySessionLocked());
    }
  }

  Future<void> _onTerminated(
    SessionTerminated event,
    Emitter<SecuritySessionState> emit,
  ) async {
    print('SESSION: SecuritySessionBloc terminado');
    _cancelTtlTimer();
    emit(SecuritySessionLocked());
  }

  @override
  Future<void> close() {
    _cancelTtlTimer();
    return super.close();
  }
}

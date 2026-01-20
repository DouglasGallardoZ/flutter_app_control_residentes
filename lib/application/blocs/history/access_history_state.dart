// lib/application/blocs/history/access_history_state.dart
import '../../../domain/entities/access_log.dart';
abstract class AccessHistoryState {}
class AccessHistoryInitial extends AccessHistoryState {}
class AccessHistoryLoading extends AccessHistoryState {}
class AccessHistoryLoaded extends AccessHistoryState { final List<AccessLog> logs; AccessHistoryLoaded(this.logs); }
class AccessHistoryError extends AccessHistoryState { final String message; AccessHistoryError(this.message); }

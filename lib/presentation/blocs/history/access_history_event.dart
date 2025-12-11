abstract class AccessHistoryEvent {}

class LoadAccessHistory extends AccessHistoryEvent {
  final String accountId;
  LoadAccessHistory(this.accountId);
}

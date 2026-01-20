abstract class AccessHistoryEvent {}

class LoadAccessHistory extends AccessHistoryEvent {
  final int? page;
  final int? pageSize;

  LoadAccessHistory({
    this.page,
    this.pageSize,
  });
}

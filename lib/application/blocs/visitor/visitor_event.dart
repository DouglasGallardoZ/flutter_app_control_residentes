import '../../../domain/entities/visitor.dart';

abstract class VisitorEvent {}
class LoadVisitors extends VisitorEvent {
  final String residenceId;
  LoadVisitors(this.residenceId);
}
class SearchVisitors extends VisitorEvent {
  final String query;
  SearchVisitors(this.query);
}
class SelectVisitor extends VisitorEvent {
  final Visitor visitor;
  SelectVisitor(this.visitor);
}
class UpsertVisitorRequested extends VisitorEvent {
  final String residenceId;
  final String id;
  final String name;
  final String? phone;
  final DateTime visitTime;
  UpsertVisitorRequested(this.residenceId, this.id, this.name, this.phone, this.visitTime);
}

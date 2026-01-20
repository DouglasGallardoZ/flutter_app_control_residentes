import '../../../domain/entities/visitor.dart';

abstract class VisitorState {}
class VisitorInitial extends VisitorState {}
class VisitorLoading extends VisitorState {}
class VisitorLoaded extends VisitorState {
  final List<Visitor> all;
  final List<Visitor> filtered;
  final Visitor? selected;
  final String helper;
  VisitorLoaded({required this.all, required this.filtered, this.selected, this.helper = ''});

  VisitorLoaded copyWith({
    List<Visitor>? all,
    List<Visitor>? filtered,
    Visitor? selected,
    String? helper,
  }) => VisitorLoaded(
    all: all ?? this.all,
    filtered: filtered ?? this.filtered,
    selected: selected ?? this.selected,
    helper: helper ?? this.helper,
  );
}
class VisitorSuccess extends VisitorState {
  final Visitor visitor;
  final String badge; // "Visitante registrado exitosamente"
  VisitorSuccess(this.visitor, {this.badge = 'Visitante registrado exitosamente'});
}
class VisitorError extends VisitorState { final String message; VisitorError(this.message); }

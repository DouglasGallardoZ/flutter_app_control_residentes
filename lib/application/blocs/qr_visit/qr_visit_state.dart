import '../../../domain/entities/qr_code.dart';
abstract class QrVisitState {}
class QrVisitInitial extends QrVisitState {}
class QrVisitLoading extends QrVisitState {}
class QrVisitReady extends QrVisitState { final QrCode qr; QrVisitReady(this.qr); }
class QrVisitError extends QrVisitState { final String message; QrVisitError(this.message); }

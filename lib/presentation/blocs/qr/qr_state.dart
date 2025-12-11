import '../../../domain/entities/qr_code.dart';

abstract class QrState {}
class QrInitial extends QrState {}
class QrLoading extends QrState {}
class QrReady extends QrState { final QrCode qr; QrReady(this.qr); }
class QrError extends QrState { final String message; QrError(this.message); }

abstract class FacialVerificationState {}

class FacialVerificationInitial extends FacialVerificationState {}

class FacialVerificationLoading extends FacialVerificationState {}

class FacialVerificationSuccess extends FacialVerificationState {
  final bool match;
  final double distance;

  FacialVerificationSuccess({required this.match, required this.distance});
}

class FacialVerificationFailure extends FacialVerificationState {
  final String mensaje;

  FacialVerificationFailure({required this.mensaje});
}

import 'dart:typed_data';
import 'package:equatable/equatable.dart';

enum FaceAngle { front, left, right }

abstract class FacialEnrollmentEvent extends Equatable {
  const FacialEnrollmentEvent();

  @override
  List<Object?> get props => [];
}

class EnrollmentStarted extends FacialEnrollmentEvent {
  final String personaId;

  const EnrollmentStarted({required this.personaId});

  @override
  List<Object?> get props => [personaId];
}

class FaceCaptured extends FacialEnrollmentEvent {
  final Uint8List bytes;
  final FaceAngle angle;

  const FaceCaptured({
    required this.bytes,
    required this.angle,
  });

  @override
  List<Object?> get props => [bytes, angle];
}

class EnrollmentSubmitted extends FacialEnrollmentEvent {
  const EnrollmentSubmitted();

  @override
  List<Object?> get props => [];
}

class EnrollmentRetried extends FacialEnrollmentEvent {
  const EnrollmentRetried();
}

class EnrollmentResubmit extends FacialEnrollmentEvent {
  const EnrollmentResubmit();
}

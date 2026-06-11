/// Entidad de dominio para un rostro detectado por el sistema de
/// detección facial. Contiene métricas de orientación y clasificación
/// necesarias tanto para enrolamiento como para liveness activo.
class DetectedFace {
  final double? headEulerAngleX;
  final double? headEulerAngleY;
  final double? headEulerAngleZ;
  final double? smilingProbability;
  final double? leftEyeOpenProbability;
  final double? rightEyeOpenProbability;

  const DetectedFace({
    this.headEulerAngleX,
    this.headEulerAngleY,
    this.headEulerAngleZ,
    this.smilingProbability,
    this.leftEyeOpenProbability,
    this.rightEyeOpenProbability,
  });

  factory DetectedFace.fromMap(Map<String, dynamic> map) {
    return DetectedFace(
      headEulerAngleX: (map['head_euler_angle_x'] as num?)?.toDouble(),
      headEulerAngleY: (map['head_euler_angle_y'] as num?)?.toDouble(),
      headEulerAngleZ: (map['head_euler_angle_z'] as num?)?.toDouble(),
      smilingProbability:
          (map['smiling_probability'] as num?)?.toDouble(),
      leftEyeOpenProbability:
          (map['left_eye_open_probability'] as num?)?.toDouble(),
      rightEyeOpenProbability:
          (map['right_eye_open_probability'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (headEulerAngleX != null) 'head_euler_angle_x': headEulerAngleX,
      if (headEulerAngleY != null) 'head_euler_angle_y': headEulerAngleY,
      if (headEulerAngleZ != null) 'head_euler_angle_z': headEulerAngleZ,
      if (smilingProbability != null)
        'smiling_probability': smilingProbability,
      if (leftEyeOpenProbability != null)
        'left_eye_open_probability': leftEyeOpenProbability,
      if (rightEyeOpenProbability != null)
        'right_eye_open_probability': rightEyeOpenProbability,
    };
  }
}

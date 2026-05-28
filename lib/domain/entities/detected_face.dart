class DetectedFace {
  final double? headEulerAngleY;
  final double? headEulerAngleZ;

  const DetectedFace({
    this.headEulerAngleY,
    this.headEulerAngleZ,
  });

  factory DetectedFace.fromMap(Map<String, dynamic> map) {
    return DetectedFace(
      headEulerAngleY: (map['head_euler_angle_y'] as num?)?.toDouble(),
      headEulerAngleZ: (map['head_euler_angle_z'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (headEulerAngleY != null) 'head_euler_angle_y': headEulerAngleY,
      if (headEulerAngleZ != null) 'head_euler_angle_z': headEulerAngleZ,
    };
  }
}

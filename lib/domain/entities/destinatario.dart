class Destinatario {
  final int personaId;
  final String nombreCompleto;
  final String identificacion;
  final String? manzana;
  final String? villa;
  final String tipo;
  bool seleccionado;

  Destinatario({
    required this.personaId,
    required this.nombreCompleto,
    required this.identificacion,
    this.manzana,
    this.villa,
    required this.tipo,
    this.seleccionado = false,
  });

  factory Destinatario.fromJson(Map<String, dynamic> json) {
    return Destinatario(
      personaId: json['persona_id'] ?? 0,
      nombreCompleto: json['nombre_completo'] ?? '',
      identificacion: json['identificacion'] ?? '',
      manzana: json['manzana'],
      villa: json['villa'],
      tipo: json['tipo'] ?? 'residente',
    );
  }

  String get direccion {
    if (manzana != null && villa != null) {
      return 'Mz $manzana, Villa $villa';
    }
    return '';
  }
}

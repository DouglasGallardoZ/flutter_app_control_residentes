// lib/domain/value_objects/identification.dart
class Identification {
  final String value;
  Identification(this.value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length != 10) {
      throw ArgumentError('Identificación inválida: debe tener 10 dígitos');
    }
  }
  @override
  String toString() => value;
}

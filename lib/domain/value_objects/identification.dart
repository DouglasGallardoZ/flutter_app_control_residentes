class Identification {
  final String value;
  Identification(this.value) {
    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
      throw ArgumentError('Identificación inválida');
    }
  }
}
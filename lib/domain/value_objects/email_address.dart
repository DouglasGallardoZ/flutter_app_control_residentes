class EmailAddress {
  final String value;
  EmailAddress(this.value) {
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      throw ArgumentError('Correo inválido');
    }
  }
}

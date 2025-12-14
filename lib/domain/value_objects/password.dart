class Password {
  final String value;
  Password(this.value) {
    if (value.length < 6) {
      throw ArgumentError('Contraseña demasiado corta (mínimo 6 caracteres)');
    }
  }
}
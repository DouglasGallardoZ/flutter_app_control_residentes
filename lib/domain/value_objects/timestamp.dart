class TimestampVO {
  final DateTime value;
  TimestampVO(this.value) {
    if (value.isAfter(DateTime.now().add(const Duration(days: 365)))) {
      throw ArgumentError('Fecha inválida: demasiado lejana');
    }
  }
}
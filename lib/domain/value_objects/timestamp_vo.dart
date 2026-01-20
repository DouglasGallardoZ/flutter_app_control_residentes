class TimestampVO {
  final DateTime value;
  TimestampVO(this.value) {
    final max = DateTime.now().add(const Duration(days: 365));
    if (value.isAfter(max)) throw ArgumentError('Fecha inválida: demasiado lejana');
  }
  @override
  String toString() => value.toIso8601String();
}

class QrCodeValue {
  final String value;
  QrCodeValue(this.value) {
    if (value.isEmpty) {
      throw ArgumentError('QR vacío');
    }
    if (!value.startsWith('SELF-') && !value.startsWith('VISIT-')) {
      throw ArgumentError('Formato de QR inválido');
    }
  }
}

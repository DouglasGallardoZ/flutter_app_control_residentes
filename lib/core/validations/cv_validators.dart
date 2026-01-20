import 'format_rules.dart';

class CvValidators {
  static String? cv01IdEcuador(String id, {required bool isEcuador}) {
    if (!isEcuador) return null;
    return FormatRules.isValidId(id) ? null : 'Error: identificación ecuatoriana inválida (CV-01)';
  }

  static String? cv05Email(String email) =>
      FormatRules.isValidEmail(email) ? null : 'Error: formato incorrecto (CV-05)';
}

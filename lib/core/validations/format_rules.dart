class FormatRules {
  static bool isValidId(String v) => RegExp(r'^\d{10}$').hasMatch(v);
  static bool isValidEmail(String v) =>
      v.length <= 100 && RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v);
  static bool isValidBirthDate(String v) => RegExp(r'^\d{2}-\d{2}-\d{4}$').hasMatch(v);
  static bool isValidPhone(String v) => RegExp(r'^09\d{8}$').hasMatch(v);
}

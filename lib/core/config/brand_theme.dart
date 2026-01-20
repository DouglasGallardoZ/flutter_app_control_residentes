class BrandTheme {
  final String name;
  final int primary;     // Hex ARGB
  final int secondary;
  final int accent;
  final int error;
  final bool dark;

  const BrandTheme({
    required this.name,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.error,
    this.dark = false,
  });
}

// Ejemplo de configuración por cliente (injection/env)
const defaultBrand = BrandTheme(
  name: 'Urbanizacion Test',
  primary: 0xFF1565C0,
  secondary: 0xFF2E7D32,
  accent: 0xFF00ACC1,
  error: 0xFFD32F2F,
  dark: false,
);
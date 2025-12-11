import 'brand_theme.dart';

enum FaceMode { local, api }

class Env {
  final String baseUrl;
  final FaceMode faceMode;
  final BrandTheme brandTheme;
  const Env({required this.baseUrl, required this.faceMode, required this.brandTheme});
}

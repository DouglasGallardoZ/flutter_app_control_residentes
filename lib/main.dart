import 'package:flutter/material.dart';
import 'app.dart';
import 'injection.dart';
import 'core/config/brand_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await inject();
  runApp(const App(brand: defaultBrand));
}

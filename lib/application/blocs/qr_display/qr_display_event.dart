abstract class QrDisplayEvent {}

/// Inicializa la página con datos del usuario desde AuthBloc
class InitializeQrDisplay extends QrDisplayEvent {}

/// Navega a una pantalla específica con los datos del usuario
class NavigateToScreen extends QrDisplayEvent {
  final int screenIndex;
  NavigateToScreen(this.screenIndex);
}

/// Navega atrás hacia el home
class NavigateBack extends QrDisplayEvent {}

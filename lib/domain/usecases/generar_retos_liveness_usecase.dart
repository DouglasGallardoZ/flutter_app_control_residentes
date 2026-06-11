import 'dart:math';
import '../entities/liveness_reto.dart';

/// Genera una secuencia aleatoria de retos de liveness para la
/// verificación facial activa. Cada sesión recibe entre 2 y 3 retos
/// únicos en orden aleatorio, impidiendo que un atacante pueda
/// anticipar la secuencia requerida.
class GenerarRetosLivenessUseCase {
  final Random _random;

  GenerarRetosLivenessUseCase({Random? random})
      : _random = random ?? Random();

  /// Retorna una lista de 2 o 3 [LivenessReto] únicos en orden aleatorio.
  List<LivenessReto> execute() {
    final todos = LivenessReto.values.toList();
    todos.shuffle(_random);

    final cantidad = _random.nextInt(2) + 2; // 2 o 3 retos
    return todos.take(cantidad).toList();
  }
}

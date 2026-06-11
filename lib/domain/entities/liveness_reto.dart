/// Retos de liveness aleatorio para verificación facial activa.
/// El sistema seleccionará 2 o 3 retos únicos por sesión para evitar
/// que un atacante pueda predecir o grabar la secuencia requerida.
enum LivenessReto {
  frente,
  izquierda,
  derecha,
  sonreir,
}

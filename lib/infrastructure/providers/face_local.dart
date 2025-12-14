class FaceLocal {
  Future<bool> validate({required String accountId, required String capturePath}) async {
    // Simulación de validación local (face_validation_lib se integraría aquí)
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }
}

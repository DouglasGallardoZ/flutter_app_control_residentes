abstract class FaceRepository {
  Future<bool> validateFace({required String accountId, required String capturePath});
}

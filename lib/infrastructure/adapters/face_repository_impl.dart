import '../../domain/ports/face_repository.dart';
import '../providers/face_api.dart';
import '../providers/face_local.dart';
import '../../core/config/env.dart';

class FaceRepositoryImpl implements FaceRepository {
  final FaceMode mode;
  final FaceApi api;
  final FaceLocal local;
  FaceRepositoryImpl({required this.mode, required this.api, required this.local});

  @override
  Future<bool> validateFace({required String accountId, required String capturePath}) async {
    if (mode == FaceMode.api) {
      return api.validate(accountId: accountId, capturePath: capturePath);
    }
    return local.validate(accountId: accountId, capturePath: capturePath);
    }
}

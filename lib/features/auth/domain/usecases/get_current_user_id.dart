import 'package:injectable/injectable.dart';
import 'package:word_flow/features/auth/domain/repositories/auth_repository.dart';

@lazySingleton
class GetCurrentUserId {
  GetCurrentUserId(this.authRepository);
  final AuthRepository authRepository;

  String? call() {
    return authRepository.currentUserId;
  }
}

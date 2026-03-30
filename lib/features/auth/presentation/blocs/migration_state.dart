import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:word_flow/features/auth/domain/entities/auth_user.dart';

part 'migration_state.freezed.dart';

@freezed
class MigrationState with _$MigrationState {
  const factory MigrationState.initial() = _Initial;
  const factory MigrationState.loading() = _Loading;
  const factory MigrationState.success() = _Success;
  const factory MigrationState.error(String message) = _Error;
  const factory MigrationState.pendingMerge(AuthUser user, int guestWordCount) = _PendingMerge;
}

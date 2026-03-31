import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:word_flow/features/auth/domain/entities/auth_user.dart';

part 'migration_state.freezed.dart';

@freezed
class MigrationState with _$MigrationState {
  const factory MigrationState.initial() = MigrationInitial;
  const factory MigrationState.loading() = MigrationLoading;
  const factory MigrationState.success() = MigrationSuccess;
  const factory MigrationState.error(String message) = MigrationError;
  const factory MigrationState.pendingMerge(AuthUser user, int guestWordCount) =
      MigrationPendingMerge;
  const factory MigrationState.rateLimited(Duration cooldown) =
      MigrationRateLimited;
}

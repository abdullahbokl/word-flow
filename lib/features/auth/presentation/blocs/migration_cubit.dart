import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:word_flow/core/services/migration_service.dart';
import 'package:word_flow/features/auth/domain/entities/auth_user.dart';
import 'package:word_flow/features/auth/domain/usecases/auth_usecases.dart';
import 'package:word_flow/features/auth/presentation/blocs/auth_cubit.dart';
import 'package:word_flow/features/auth/presentation/blocs/migration_state.dart';

@lazySingleton
class MigrationCubit extends Cubit<MigrationState> {
  MigrationCubit(
    this.signInUseCase,
    this.signUpUseCase,
    this.migrationService,
    this.authCubit,
  ) : super(const MigrationState.initial());

  final SignInWithEmailUseCase signInUseCase;
  final SignUpWithEmailUseCase signUpUseCase;
  final MigrationService migrationService;
  final AuthCubit authCubit;

  Future<void> signIn(String email, String password) async {
    emit(const MigrationState.loading());
    final result = await signInUseCase(email, password);
    await result.fold(
      (failure) async => emit(MigrationState.error(failure.message)),
      (user) async {
        final guestRes = await migrationService.getGuestWordsCount();
        final guestCount = guestRes.fold((_) => 0, (count) => count);
        if (guestCount > 0) {
          emit(MigrationState.pendingMerge(user, guestCount));
        } else {
          authCubit.onAuthenticatedWithMerge(user);
          emit(const MigrationState.success());
        }
      },
    );
  }

  Future<void> signUp(String email, String password) async {
    emit(const MigrationState.loading());
    final result = await signUpUseCase(email, password);
    await result.fold(
      (failure) async => emit(MigrationState.error(failure.message)),
      (user) async {
        await migrationService.migrateGuestData(user.id);
        authCubit.onAuthenticatedWithMerge(user);
        emit(const MigrationState.success());
      },
    );
  }

  Future<void> mergeAndSignIn(AuthUser user) async {
    emit(const MigrationState.loading());
    await migrationService.migrateGuestData(user.id);
    authCubit.onAuthenticatedWithMerge(user);
    emit(const MigrationState.success());
  }

  Future<void> discardGuestAndSignIn(AuthUser user) async {
    emit(const MigrationState.loading());
    await migrationService.discardGuestData();
    authCubit.onAuthenticatedWithDiscard(user);
    emit(const MigrationState.success());
  }

  void reset() {
    emit(const MigrationState.initial());
  }
}

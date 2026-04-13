import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wordflow/core/backup/backup_repository.dart';

abstract class BackupEvent extends Equatable {
  const BackupEvent();
  @override
  List<Object?> get props => [];
}

class CheckBackupStatus extends BackupEvent {}

class ConnectDrive extends BackupEvent {}

class PerformBackup extends BackupEvent {}

class PerformRestore extends BackupEvent {}

class SignOutBackup extends BackupEvent {}

enum BackupStatus { idle, loading, success, failure }

class BackupState extends Equatable {
  const BackupState(
      {this.status = BackupStatus.idle,
      this.isAuthenticated = false,
      this.userEmail,
      this.message,
      this.lastBackup});
  final BackupStatus status;
  final bool isAuthenticated;
  final String? userEmail;
  final String? message;
  final BackupMetadata? lastBackup;

  BackupState copyWith(
      {BackupStatus? status,
      bool? isAuthenticated,
      String? userEmail,
      String? message,
      BackupMetadata? lastBackup}) {
    return BackupState(
      status: status ?? this.status,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userEmail: userEmail ?? this.userEmail,
      message: message ?? this.message,
      lastBackup: lastBackup ?? this.lastBackup,
    );
  }

  @override
  List<Object?> get props =>
      [status, isAuthenticated, userEmail, message, lastBackup];
}

class BackupBloc extends Bloc<BackupEvent, BackupState> {
  BackupBloc(this._repo) : super(const BackupState()) {
    on<CheckBackupStatus>(_onCheckStatus);
    on<ConnectDrive>(_onConnect);
    on<PerformBackup>(_onBackup);
    on<PerformRestore>(_onRestore);
    on<SignOutBackup>(_onSignOut);
  }
  final BackupRepository _repo;

  Future<void> _onCheckStatus(
      CheckBackupStatus e, Emitter<BackupState> emit) async {
    final isAuth = await _repo.isAuthenticated();
    final email = isAuth ? await _repo.getConnectedEmail() : null;
    final meta = isAuth
        ? (await _repo.getBackupMetadata()).getOrElse((_) => null)
        : null;
    emit(state.copyWith(
        isAuthenticated: isAuth, userEmail: email, lastBackup: meta));
  }

  Future<void> _onConnect(ConnectDrive e, Emitter<BackupState> emit) async {
    emit(state.copyWith(status: BackupStatus.loading));
    final res = await _repo.connect();
    await res.fold(
      (f) async => emit(
          state.copyWith(status: BackupStatus.failure, message: f.message)),
      (_) async {
        final email = await _repo.getConnectedEmail();
        final meta = (await _repo.getBackupMetadata()).getOrElse((_) => null);
        emit(state.copyWith(
            status: BackupStatus.success,
            isAuthenticated: true,
            userEmail: email,
            message: 'Drive connected!',
            lastBackup: meta));
      },
    );
  }

  Future<void> _onBackup(PerformBackup e, Emitter<BackupState> emit) async {
    emit(state.copyWith(status: BackupStatus.loading));
    final res = await _repo.backup();
    await res.fold(
      (f) async => emit(
          state.copyWith(status: BackupStatus.failure, message: f.message)),
      (_) async {
        emit(state.copyWith()); // Clear message before second emit
        final meta = (await _repo.getBackupMetadata()).getOrElse((_) => null);
        emit(state.copyWith(
            status: BackupStatus.success,
            message: 'Backup success!',
            lastBackup: meta));
      },
    );
  }

  Future<void> _onRestore(PerformRestore e, Emitter<BackupState> emit) async {
    emit(state.copyWith(status: BackupStatus.loading));
    final res = await _repo.restore();
    await res.fold(
      (f) async => emit(
          state.copyWith(status: BackupStatus.failure, message: f.message)),
      (_) async {
        emit(state.copyWith(
            status: BackupStatus.success,
            message: 'Restore success! App will restart...'));
        await Future.delayed(const Duration(milliseconds: 1500));
        await SystemNavigator.pop();
      },
    );
  }

  Future<void> _onSignOut(SignOutBackup e, Emitter<BackupState> emit) async {
    await _repo.signOut();
    emit(const BackupState());
  }
}

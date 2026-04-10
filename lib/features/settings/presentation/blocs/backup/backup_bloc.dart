import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lexitrack/core/backup/backup_repository.dart';

// Events
abstract class BackupEvent extends Equatable {
  const BackupEvent();
  @override
  List<Object?> get props => [];
}

class CheckBackupStatus extends BackupEvent {}
class PerformBackup extends BackupEvent {}
class PerformRestore extends BackupEvent {}
class SignOutBackup extends BackupEvent {}

// States
enum BackupStatus { idle, loading, success, failure }

class BackupState extends Equatable {

  const BackupState({
    this.status = BackupStatus.idle,
    this.isAuthenticated = false,
    this.userEmail,
    this.message,
  });
  final BackupStatus status;
  final bool isAuthenticated;
  final String? userEmail;
  final String? message;

  BackupState copyWith({
    BackupStatus? status,
    bool? isAuthenticated,
    String? userEmail,
    String? message,
  }) {
    return BackupState(
      status: status ?? this.status,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userEmail: userEmail ?? this.userEmail,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, isAuthenticated, userEmail, message];
}

// Bloc
class BackupBloc extends Bloc<BackupEvent, BackupState> {

  BackupBloc(this._repository) : super(const BackupState()) {
    on<CheckBackupStatus>(_onCheckStatus);
    on<PerformBackup>(_onBackup);
    on<PerformRestore>(_onRestore);
    on<SignOutBackup>(_onSignOut);
  }
  final BackupRepository _repository;

  Future<void> _onCheckStatus(CheckBackupStatus event, Emitter<BackupState> emit) async {
    try {
      final isAuth = await _repository.isAuthenticated();
      final email = isAuth ? await _repository.getConnectedEmail() : null;
      emit(state.copyWith(isAuthenticated: isAuth, userEmail: email));
    } catch (e) {
      // If native plugin is not registered, we just stay in signed-out state
      emit(state.copyWith(isAuthenticated: false));
    }
  }

  Future<void> _onBackup(PerformBackup event, Emitter<BackupState> emit) async {
    emit(state.copyWith(status: BackupStatus.loading));
    try {
      final success = await _repository.backup();
    
      if (success) {
        final email = await _repository.getConnectedEmail();
        emit(state.copyWith(
          status: BackupStatus.success,
          isAuthenticated: true,
          userEmail: email,
          message: 'Backup completed successfully!',
        ));
      } else {
        emit(state.copyWith(
          status: BackupStatus.failure,
          message: 'Backup failed. Please try again.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: BackupStatus.failure,
        message: 'Google Sign In Error: Please ensure you have configured OAuth and restarted the app.',
      ));
    }
  }

  Future<void> _onRestore(PerformRestore event, Emitter<BackupState> emit) async {
    emit(state.copyWith(status: BackupStatus.loading));
    try {
      final success = await _repository.restore();
    
      if (success) {
        emit(state.copyWith(
          status: BackupStatus.success,
          message: 'Restore completed! Please restart the app to see changes.',
        ));
      } else {
        emit(state.copyWith(
          status: BackupStatus.failure,
          message: 'Restore failed. No backup found or connection error.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: BackupStatus.failure,
        message: 'Restore error: Native plugin failed to initialize.',
      ));
    }
  }

  Future<void> _onSignOut(SignOutBackup event, Emitter<BackupState> emit) async {
    await _repository.signOut();
    emit(const BackupState());
  }
}

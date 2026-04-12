import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:lexitrack/core/backup/google_auth_client.dart';
import 'package:lexitrack/core/backup/backup_repository.dart';
import 'package:lexitrack/core/database/app_database.dart';
import 'package:lexitrack/core/error/failures.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class BackupRepositoryImpl implements BackupRepository {
  BackupRepositoryImpl(this._db);
  final AppDatabase _db;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: [drive.DriveApi.driveAppdataScope]);

  @override
  Future<bool> isAuthenticated() async => _googleSignIn.isSignedIn();
  @override
  Future<String?> getConnectedEmail() async => _googleSignIn.currentUser?.email;
  @override
  Future<void> signOut() async => _googleSignIn.signOut();

  @override
  Future<Either<Failure, Unit>> connect() async => (await _getDriveApi()).map((_) => unit);

  Future<Either<Failure, drive.DriveApi>> _getDriveApi() async {
    try {
      var user = await _googleSignIn.signInSilently() ?? await _googleSignIn.signIn();
      if (user == null) return left(const BackupFailure('Google Sign-In cancelled'));
      final headers = await user.authHeaders;
      return right(drive.DriveApi(GoogleAuthClient(headers)));
    } catch (e) {
      return left(BackupFailure('Auth failed: $e'));
    }
  }

  @override
  Future<Either<Failure, BackupMetadata?>> getBackupMetadata() async {
    try {
      final driveRes = await _getDriveApi();
      if (driveRes.isLeft()) return left(driveRes.getLeft().getOrElse(() => const BackupFailure('Unknown')));
      final driveApi = driveRes.getOrElse((_) => throw Exception());

      const q = "name = 'lexitrack_backup.sqlite' and 'appDataFolder' in parents";
      final files = await driveApi.files.list(q: q, spaces: 'appDataFolder', $fields: 'files(id, modifiedTime, size)');
      if (files.files?.isEmpty ?? true) return right(null);

      final file = files.files!.first;
      return right(BackupMetadata(
        modifiedTime: file.modifiedTime?.toLocal() ?? DateTime.now(),
        size: int.tryParse(file.size ?? '0') ?? 0,
      ));
    } catch (e) {
      return left(BackupFailure('Failed to get metadata: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> backup() async {
    try {
      final driveRes = await _getDriveApi();
      if (driveRes.isLeft()) return left(driveRes.getLeft().getOrElse(() => const BackupFailure('Unknown')));
      final driveApi = driveRes.getOrElse((_) => throw Exception());

      await _db.checkpoint();
      final localFile = File(p.join((await getApplicationDocumentsDirectory()).path, 'lexitrack.sqlite'));
      if (!await localFile.exists()) return left(const BackupFailure('DB file not found'));

      const q = "name = 'lexitrack_backup.sqlite' and 'appDataFolder' in parents";
      final files = await driveApi.files.list(q: q, spaces: 'appDataFolder', $fields: 'files(id)');
      final media = drive.Media(localFile.openRead(), await localFile.length());

      if (files.files?.isNotEmpty ?? false) {
        await driveApi.files.update(drive.File(), files.files!.first.id!, uploadMedia: media);
      } else {
        await driveApi.files.create(drive.File()..name = 'lexitrack_backup.sqlite'..parents = ['appDataFolder'], uploadMedia: media);
      }
      return right(unit);
    } catch (e) {
      return left(BackupFailure('Backup failed: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> restore() async {
    try {
      final driveRes = await _getDriveApi();
      if (driveRes.isLeft()) return left(driveRes.getLeft().getOrElse(() => const BackupFailure('Unknown')));
      final driveApi = driveRes.getOrElse((_) => throw Exception());

      const q = "name = 'lexitrack_backup.sqlite' and 'appDataFolder' in parents";
      final files = await driveApi.files.list(q: q, spaces: 'appDataFolder', $fields: 'files(id)');
      if (files.files?.isEmpty ?? true) return left(const BackupFailure('No backup found'));

      final media = await driveApi.files.get(files.files!.first.id!, downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;
      await _db.close();
      final localFile = File(p.join((await getApplicationDocumentsDirectory()).path, 'lexitrack.sqlite'));
      for (var ext in ['-wal', '-shm']) {
        final f = File('${localFile.path}$ext');
        if (await f.exists()) await f.delete();
      }
      final ios = localFile.openWrite();
      await ios.addStream(media.stream);
      await ios.close();
      return right(unit);
    } catch (e) {
      return left(BackupFailure('Restore failed: $e'));
    }
  }
}

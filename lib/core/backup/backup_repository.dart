import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:lexitrack/core/backup/google_auth_client.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

abstract class BackupRepository {
  Future<bool> backup();
  Future<bool> restore();
  Future<bool> isAuthenticated();
  Future<void> signOut();
  Future<String?> getConnectedEmail();
}

class BackupRepositoryImpl implements BackupRepository {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      drive.DriveApi.driveAppdataScope,
    ],
  );

  @override
  Future<bool> isAuthenticated() async {
    return _googleSignIn.isSignedIn();
  }

  @override
  Future<String?> getConnectedEmail() async {
    return _googleSignIn.currentUser?.email;
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  @override
  Future<bool> backup() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return false;

      final authHeaders = await googleUser.authHeaders;
      final authenticateClient = GoogleAuthClient(authHeaders);
      final driveApi = drive.DriveApi(authenticateClient);

      // Get local database file
      final dir = await getApplicationDocumentsDirectory();
      final localFile = File(p.join(dir.path, 'lexitrack.sqlite'));
      if (!await localFile.exists()) return false;

      // Search for existing backup in appDataFolder
      const query = "name = 'lexitrack_backup.sqlite' and 'appDataFolder' in parents";
      final fileList = await driveApi.files.list(
        q: query,
        spaces: 'appDataFolder',
        $fields: 'files(id, name)',
      );

      final media = drive.Media(
        localFile.openRead(),
        await localFile.length(),
      );

      if (fileList.files != null && fileList.files!.isNotEmpty) {
        // Update existing backup
        final existingFileId = fileList.files!.first.id!;
        await driveApi.files.update(
          drive.File(),
          existingFileId,
          uploadMedia: media,
        );
      } else {
        // Create new backup
        final driveFile = drive.File()
          ..name = 'lexitrack_backup.sqlite'
          ..parents = ['appDataFolder'];
        await driveApi.files.create(
          driveFile,
          uploadMedia: media,
        );
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> restore() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return false;

      final authHeaders = await googleUser.authHeaders;
      final authenticateClient = GoogleAuthClient(authHeaders);
      final driveApi = drive.DriveApi(authenticateClient);

      // Search for backup in appDataFolder
      const query = "name = 'lexitrack_backup.sqlite' and 'appDataFolder' in parents";
      final fileList = await driveApi.files.list(
        q: query,
        spaces: 'appDataFolder',
        $fields: 'files(id, name)',
      );

      if (fileList.files == null || fileList.files!.isEmpty) return false;

      final fileId = fileList.files!.first.id!;
      final media = await driveApi.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      // Save to local file
      final dir = await getApplicationDocumentsDirectory();
      final localFile = File(p.join(dir.path, 'lexitrack.sqlite'));
      
      final ios = localFile.openWrite();
      await ios.addStream(media.stream);
      await ios.close();

      return true;
    } catch (e) {
      return false;
    }
  }
}

import 'package:injectable/injectable.dart';
import 'package:word_flow/core/database/app_database.dart';

@lazySingleton
class SyncPreferences {
  SyncPreferences(this._db);

  static const _lastPullPrefix = 'sync_pull_';
  final WordFlowDatabase _db;

  Future<DateTime?> getLastPullTimestamp(String userId) async {
    final timestampStr = await _db.getAppSetting('$_lastPullPrefix$userId');
    if (timestampStr == null) return null;
    return DateTime.parse(timestampStr);
  }

  Future<void> setLastPullTimestamp(String userId, DateTime timestamp) async {
    await _db.upsertAppSetting(
      '$_lastPullPrefix$userId',
      timestamp.toUtc().toIso8601String(),
    );
  }

  Future<void> clearUserTimestamp(String userId) async {
    await _db.deleteAppSetting('$_lastPullPrefix$userId');
  }

  /// Clears ALL per-user pull timestamps.
  /// Call on sign-out to ensure no stale cursors remain for any user.
  Future<void> clearAllTimestamps() async {
    // Delete all rows where key starts with the pull prefix.
    await _db.customStatement(
      "DELETE FROM app_settings WHERE key LIKE '$_lastPullPrefix%'",
    );
  }
}

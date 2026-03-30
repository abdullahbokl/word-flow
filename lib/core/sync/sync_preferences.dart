import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class SyncPreferences {
  static const _lastPullPrefix = 'sync_last_pull_';

  Future<DateTime?> getLastPullTimestamp(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final timestampStr = prefs.getString('$_lastPullPrefix$userId');
    if (timestampStr == null) return null;
    return DateTime.parse(timestampStr);
  }

  Future<void> setLastPullTimestamp(String userId, DateTime timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_lastPullPrefix$userId', timestamp.toIso8601String());
  }

  Future<void> clearUserTimestamp(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_lastPullPrefix$userId');
  }
}

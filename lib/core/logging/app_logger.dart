import 'package:talker/talker.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AppLogger {
  
  AppLogger() : _talker = Talker(
    settings: TalkerSettings(
      useConsoleLogs: true,
      useHistory: true,
    ),
  );
  final Talker _talker;
  
  Talker get talker => _talker;

  void debug(String message) => _talker.debug(message);
  void info(String message) => _talker.info(message);
  void warning(String message) => _talker.warning(message);
  void error(String message, [Object? error, StackTrace? stackTrace]) =>
      _talker.error(message, error, stackTrace);

  /// Sync-specific log
  void syncEvent(String message) => _talker.log(SyncLog(message));
  
  /// Database-specific log
  void dbEvent(String message) => _talker.log(DatabaseLog(message));
}

class SyncLog extends TalkerLog {
  SyncLog(String super.message);
  @override
  String get title => 'SYNC';
}

class DatabaseLog extends TalkerLog {
  DatabaseLog(String super.message);
  @override
  String get title => 'DB';
}

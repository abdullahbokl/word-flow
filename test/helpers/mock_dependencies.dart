import 'package:mocktail/mocktail.dart';
import 'package:word_flow/features/vocabulary/domain/repositories/word_repository.dart';
import 'package:word_flow/features/auth/domain/repositories/auth_repository.dart';
import 'package:word_flow/features/vocabulary/domain/repositories/sync_repository.dart';
import 'package:word_flow/features/vocabulary/data/datasources/word_local_source.dart';
import 'package:word_flow/features/vocabulary/data/datasources/word_remote_source.dart';
import 'package:word_flow/features/vocabulary/data/datasources/sync_local_source.dart';
import 'package:word_flow/features/vocabulary/domain/services/text_analysis_service.dart';
import 'package:word_flow/core/security/security_service.dart';
import 'package:word_flow/core/sync/connectivity_monitor.dart';
import 'package:word_flow/core/logging/app_logger.dart';

class MockWordRepository extends Mock implements WordRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockSyncRepository extends Mock implements SyncRepository {}

class MockWordLocalSource extends Mock implements WordLocalSource {}

class MockWordRemoteSource extends Mock implements WordRemoteSource {}

class MockSyncLocalSource extends Mock implements SyncLocalSource {}

class MockTextAnalysisService extends Mock implements TextAnalysisService {}

class MockSecurityService extends Mock implements SecurityService {}

class MockConnectivityMonitor extends Mock implements ConnectivityMonitor {}

class MockAppLogger extends Mock implements AppLogger {}

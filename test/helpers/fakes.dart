import 'package:mocktail/mocktail.dart';

// Repositories
import 'package:word_flow/features/vocabulary/domain/repositories/word_repository.dart';
import 'package:word_flow/features/vocabulary/domain/repositories/sync_repository.dart';

// Domain Services
import 'package:word_flow/features/vocabulary/domain/services/text_analysis_service.dart';

// Data Sources
import 'package:word_flow/features/vocabulary/data/datasources/word_local_source.dart';
import 'package:word_flow/features/vocabulary/data/datasources/word_remote_source.dart';
import 'package:word_flow/features/vocabulary/data/datasources/sync_local_source.dart';

// Core
import 'package:word_flow/core/database/write_queue.dart';
import 'package:word_flow/core/logging/app_logger.dart';

// Use Cases
import 'package:word_flow/features/vocabulary/domain/usecases/adopt_guest_words.dart';
import 'package:word_flow/features/vocabulary/domain/usecases/clear_local_words.dart';
import 'package:word_flow/features/vocabulary/domain/usecases/delete_word.dart';
import 'package:word_flow/features/vocabulary/domain/usecases/get_guest_words_count.dart';
import 'package:word_flow/features/vocabulary/domain/usecases/get_known_words.dart';
import 'package:word_flow/features/vocabulary/domain/usecases/get_known_word_texts.dart';
import 'package:word_flow/features/vocabulary/domain/usecases/get_pending_count.dart';
import 'package:word_flow/features/word_learning/domain/usecases/process_script.dart';
import 'package:word_flow/features/word_learning/domain/usecases/save_processed_words.dart';
import 'package:word_flow/features/vocabulary/domain/usecases/sync_pending_words.dart';
import 'package:word_flow/features/vocabulary/domain/usecases/toggle_known_word.dart';
import 'package:word_flow/features/vocabulary/domain/usecases/update_word.dart';
import 'package:word_flow/features/vocabulary/domain/usecases/watch_pending_count.dart';
import 'package:word_flow/features/vocabulary/domain/usecases/watch_words.dart';

// ============================================================================
// REPOSITORY MOCKS
// ============================================================================

class MockWordRepository extends Mock implements WordRepository {}
class MockSyncRepository extends Mock implements SyncRepository {}

// ============================================================================
// SERVICE MOCKS
// ============================================================================

class MockTextAnalysisService extends Mock implements TextAnalysisService {}

// ============================================================================
// DATA SOURCE MOCKS
// ============================================================================

class MockWordLocalSource extends Mock implements WordLocalSource {}
class MockWordRemoteSource extends Mock implements WordRemoteSource {}
class MockSyncLocalSource extends Mock implements SyncLocalSource {}
class MockLocalWriteQueue extends Mock implements LocalWriteQueue {}

// ============================================================================
// USE CASE MOCKS
// ============================================================================

class MockAdoptGuestWords extends Mock implements AdoptGuestWords {}
class MockClearLocalWords extends Mock implements ClearLocalWords {}
class MockDeleteWord extends Mock implements DeleteWord {}
class MockGetGuestWordsCount extends Mock implements GetGuestWordsCount {}
class MockGetKnownWords extends Mock implements GetKnownWords {}
class MockGetKnownWordTexts extends Mock implements GetKnownWordTexts {}
class MockGetPendingCount extends Mock implements GetPendingCount {}
class MockProcessScript extends Mock implements ProcessScript {}
class MockSaveProcessedWords extends Mock implements SaveProcessedWords {}
class MockSyncPendingWords extends Mock implements SyncPendingWords {}
class MockToggleKnownWord extends Mock implements ToggleKnownWord {}
class MockUpdateWord extends Mock implements UpdateWord {}
class MockWatchPendingCount extends Mock implements WatchPendingCount {}
class MockWatchWords extends Mock implements WatchWords {}

// ============================================================================
// CORE MOCKS
// ============================================================================

class MockAppLogger extends Mock implements AppLogger {}

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:word_flow/core/database/database_key_manager.dart';
import 'package:word_flow/core/errors/exceptions.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/core/logging/app_logger.dart';
import 'package:word_flow/core/security/security_service.dart';

class MockSecurityService extends Mock implements SecurityService {}

void main() {
  late MockSecurityService securityService;
  late DatabaseKeyManager manager;

  setUp(() {
    securityService = MockSecurityService();
    manager = DatabaseKeyManager(securityService, AppLogger());
  });

  test('persists key successfully on the second retry attempt', () async {
    when(
      () => securityService.read(key: any(named: 'key')),
    ).thenAnswer((_) async => right(null));

    var writeAttempts = 0;
    final attemptedValues = <String>[];

    when(
      () => securityService.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((invocation) async {
      writeAttempts++;
      attemptedValues.add(invocation.namedArguments[#value] as String);

      if (writeAttempts == 1) {
        return left(const SecurityFailure('first write failed'));
      }
      return right(unit);
    });

    final key = await manager.getOrCreateKey();

    expect(key, isNotEmpty);
    expect(writeAttempts, 2);
    expect(attemptedValues.length, 2);
    expect(attemptedValues.first, attemptedValues.last);
    verify(() => securityService.read(key: any(named: 'key'))).called(1);
    verify(
      () => securityService.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).called(2);
  });

  test('throws KeyPersistenceException after three failed writes', () async {
    when(
      () => securityService.read(key: any(named: 'key')),
    ).thenAnswer((_) async => right(null));

    when(
      () => securityService.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).thenAnswer(
      (_) async => left(const SecurityFailure('secure storage unavailable')),
    );

    await expectLater(
      manager.getOrCreateKey(),
      throwsA(isA<KeyPersistenceException>()),
    );

    verify(() => securityService.read(key: any(named: 'key'))).called(1);
    verify(
      () => securityService.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).called(3);
  });
}

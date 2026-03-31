import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:word_flow/core/security/secure_storage_service_impl.dart';
import 'package:word_flow/core/security/security_service.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockFlutterSecureStorage mockStorage;
  late SecurityService service;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    service = SecureStorageService(mockStorage);
  });

  group('SecureStorageService', () {
    const tKey = 'test_key';
    const tValue = 'test_value';

    test('should return right(unit) when write is successful', () async {
      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});

      final result = await service.write(key: tKey, value: tValue);

      expect(result.isRight(), isTrue);
      verify(() => mockStorage.write(key: tKey, value: tValue)).called(1);
    });

    test('should return right(value) when read is successful', () async {
      when(
        () => mockStorage.read(key: any(named: 'key')),
      ).thenAnswer((_) async => tValue);

      final result = await service.read(key: tKey);

      expect(result.getOrElse((_) => null), tValue);
      verify(() => mockStorage.read(key: tKey)).called(1);
    });
  });
}

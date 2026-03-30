import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_flow/core/errors/failures.dart';
import 'package:word_flow/features/auth/domain/validators/auth_validators.dart';

void main() {
  tearDown(() {});

  group('EmailValidator', () {
    test('accepts valid standard email', () {
      const email = 'user@example.com';

      final result = EmailValidator.validate(email);

      expect(result, const Right<AuthFailure, String>(email));
    });

    test('accepts valid plus-tagged email', () {
      const email = 'user+news@example.com';

      final result = EmailValidator.validate(email);

      expect(result, const Right<AuthFailure, String>(email));
    });

    test('accepts valid subdomain email', () {
      const email = 'user@mail.subdomain.example.org';

      final result = EmailValidator.validate(email);

      expect(result, const Right<AuthFailure, String>(email));
    });

    test('rejects invalid email with no @', () {
      const email = 'user.example.com';

      final result = EmailValidator.validate(email);

      expect(
        result,
        const Left<AuthFailure, String>(AuthFailure('Invalid email format')),
      );
    });

    test('rejects invalid email with double @@', () {
      const email = 'user@@example.com';

      final result = EmailValidator.validate(email);

      expect(
        result,
        const Left<AuthFailure, String>(AuthFailure('Invalid email format')),
      );
    });

    test('rejects too long email', () {
      final email = '${'a' * 245}@example.com';

      final result = EmailValidator.validate(email);

      expect(
        result,
        const Left<AuthFailure, String>(AuthFailure('Email is too long')),
      );
    });

    test('rejects empty email', () {
      const email = '';

      final result = EmailValidator.validate(email);

      expect(
        result,
        const Left<AuthFailure, String>(AuthFailure('Email cannot be empty')),
      );
    });
  });

  group('PasswordValidator', () {
    test('accepts password with 8+ chars, uppercase, and digit', () {
      const password = 'SecurePass1';

      final result = PasswordValidator.validate(password);

      expect(result, const Right<AuthFailure, String>(password));
    });

    test('rejects password without uppercase letter', () {
      const password = 'securepass1';

      final result = PasswordValidator.validate(password);

      expect(
        result,
        const Left<AuthFailure, String>(
          AuthFailure('Password must contain at least one uppercase letter'),
        ),
      );
    });

    test('rejects password without digit', () {
      const password = 'SecurePass';

      final result = PasswordValidator.validate(password);

      expect(
        result,
        const Left<AuthFailure, String>(
          AuthFailure('Password must contain at least one digit'),
        ),
      );
    });

    test('rejects password shorter than 8 characters', () {
      const password = 'Abc123';

      final result = PasswordValidator.validate(password);

      expect(
        result,
        const Left<AuthFailure, String>(
          AuthFailure('Password must be at least 8 characters'),
        ),
      );
    });
  });
}

import 'package:fpdart/fpdart.dart';
import 'package:word_flow/core/errors/failures.dart';

class EmailValidator {
  static Either<AuthFailure, String> validate(String email) {
    if (email.isEmpty) {
      return const Left(AuthFailure('Email cannot be empty'));
    }
    if (email.length > 254) {
      return const Left(AuthFailure('Email is too long'));
    }
    // Simple but effective RFC 5322 regex fragment
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    );
    if (!emailRegex.hasMatch(email)) {
      return const Left(AuthFailure('Invalid email format'));
    }
    return Right(email);
  }
}

class PasswordValidator {
  static Either<AuthFailure, String> validate(String password) {
    if (password.length < 8) {
      return const Left(AuthFailure('Password must be at least 8 characters'));
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return const Left(AuthFailure('Password must contain at least one uppercase letter'));
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return const Left(AuthFailure('Password must contain at least one digit'));
    }
    return Right(password);
  }
}

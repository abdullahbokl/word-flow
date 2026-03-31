import 'dart:convert';
import 'package:fpdart/fpdart.dart';
import 'package:word_flow/core/errors/failures.dart';

class InputSanitizer {
  static Either<Failure, String> sanitizeScript(String raw) {
    if (raw.trim().isEmpty) {
      return const Left(ProcessingFailure('Input text cannot be empty.'));
    }

    try {
      // Encode to bytes to check size and UTF-8 validity
      final bytes = utf8.encode(raw);

      // Max 500KB
      if (bytes.length > 500 * 1024) {
        return const Left(
          ProcessingFailure('Input text exceeds maximum size of 500KB.'),
        );
      }

      // Strict UTF-8 verification
      final checked = utf8.decode(bytes, allowMalformed: false);

      // Strip control chars except newline (\n), carriage return (\r), and tab (\t)
      final sanitized = checked.replaceAll(
        RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]'),
        '',
      );

      if (sanitized.trim().isEmpty) {
        return const Left(
          ProcessingFailure(
            'Input text consists entirely of invalid characters.',
          ),
        );
      }

      return Right(sanitized);
    } catch (e) {
      return Left(ProcessingFailure('Invalid text encoding: $e'));
    }
  }
}

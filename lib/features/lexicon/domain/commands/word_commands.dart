import 'package:freezed_annotation/freezed_annotation.dart';

part 'word_commands.freezed.dart';

@freezed
abstract class AddWordCommand with _$AddWordCommand {
  const factory AddWordCommand({
    required String text,
  }) = _AddWordCommand;
}

@freezed
abstract class RestoreWordCommand with _$RestoreWordCommand {
  const factory RestoreWordCommand({
    required String text,
    required int previousId,
    required int previousFrequency,
    required bool wasFullyDeleted,
  }) = _RestoreWordCommand;
}

@freezed
abstract class UpdateWordCommand with _$UpdateWordCommand {
  const factory UpdateWordCommand({
    required int id,
    String? text,
    String? meaning,
    String? description,
    List<String>? definitions,
    List<String>? examples,
    List<String>? translations,
    List<String>? synonyms,
    bool? isKnown,
  }) = _UpdateWordCommand;
}

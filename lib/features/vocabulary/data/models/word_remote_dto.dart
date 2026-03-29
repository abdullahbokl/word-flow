import 'package:freezed_annotation/freezed_annotation.dart';

part 'word_remote_dto.freezed.dart';
part 'word_remote_dto.g.dart';

@freezed
class WordRemoteDto with _$WordRemoteDto {
  const factory WordRemoteDto({
    required String id,
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'word_text') required String wordText,
    @JsonKey(name: 'total_count') @Default(1) int totalCount,
    @JsonKey(name: 'is_known') @Default(false) @BoolFromIntConverter() bool isKnown,
    @JsonKey(name: 'last_updated') required DateTime lastUpdated,
  }) = _WordRemoteDto;

  factory WordRemoteDto.fromJson(Map<String, dynamic> json) =>
      _$WordRemoteDtoFromJson(json);
}

class BoolFromIntConverter implements JsonConverter<bool, dynamic> {
  const BoolFromIntConverter();

  @override
  bool fromJson(dynamic json) {
    if (json is bool) return json;
    if (json is int) return json == 1;
    // Handle String if necessary (but SQLite/Supabase usually use int or bool)
    if (json is String) return json.toLowerCase() == 'true' || json == '1';
    return false;
  }

  @override
  dynamic toJson(bool object) => object;
}

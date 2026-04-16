import 'package:wordflow/core/database/app_database.dart';
import 'package:wordflow/features/lexicon/domain/entities/tag_entity.dart';

extension TagRowMapper on CustomTagRow {
  TagEntity toEntity() {
    return TagEntity(
      id: id,
      name: name,
    );
  }
}

extension TagRowListMapper on List<CustomTagRow> {
  List<TagEntity> toEntities() => map((r) => r.toEntity()).toList();
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_schedule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReviewSchedule _$ReviewScheduleFromJson(Map<String, dynamic> json) =>
    _ReviewSchedule(
      nextReviewDate: DateTime.parse(json['nextReviewDate'] as String),
      interval: (json['interval'] as num).toInt(),
      repetition: (json['repetition'] as num).toInt(),
      easinessFactor: (json['easinessFactor'] as num).toDouble(),
    );

Map<String, dynamic> _$ReviewScheduleToJson(_ReviewSchedule instance) =>
    <String, dynamic>{
      'nextReviewDate': instance.nextReviewDate.toIso8601String(),
      'interval': instance.interval,
      'repetition': instance.repetition,
      'easinessFactor': instance.easinessFactor,
    };

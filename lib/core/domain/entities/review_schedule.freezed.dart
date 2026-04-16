// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'review_schedule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReviewSchedule {
  DateTime get nextReviewDate;
  int get interval;
  int get repetition;
  double get easinessFactor;

  /// Create a copy of ReviewSchedule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ReviewScheduleCopyWith<ReviewSchedule> get copyWith =>
      _$ReviewScheduleCopyWithImpl<ReviewSchedule>(
          this as ReviewSchedule, _$identity);

  /// Serializes this ReviewSchedule to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ReviewSchedule &&
            (identical(other.nextReviewDate, nextReviewDate) ||
                other.nextReviewDate == nextReviewDate) &&
            (identical(other.interval, interval) ||
                other.interval == interval) &&
            (identical(other.repetition, repetition) ||
                other.repetition == repetition) &&
            (identical(other.easinessFactor, easinessFactor) ||
                other.easinessFactor == easinessFactor));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, nextReviewDate, interval, repetition, easinessFactor);

  @override
  String toString() {
    return 'ReviewSchedule(nextReviewDate: $nextReviewDate, interval: $interval, repetition: $repetition, easinessFactor: $easinessFactor)';
  }
}

/// @nodoc
abstract mixin class $ReviewScheduleCopyWith<$Res> {
  factory $ReviewScheduleCopyWith(
          ReviewSchedule value, $Res Function(ReviewSchedule) _then) =
      _$ReviewScheduleCopyWithImpl;
  @useResult
  $Res call(
      {DateTime nextReviewDate,
      int interval,
      int repetition,
      double easinessFactor});
}

/// @nodoc
class _$ReviewScheduleCopyWithImpl<$Res>
    implements $ReviewScheduleCopyWith<$Res> {
  _$ReviewScheduleCopyWithImpl(this._self, this._then);

  final ReviewSchedule _self;
  final $Res Function(ReviewSchedule) _then;

  /// Create a copy of ReviewSchedule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? nextReviewDate = null,
    Object? interval = null,
    Object? repetition = null,
    Object? easinessFactor = null,
  }) {
    return _then(_self.copyWith(
      nextReviewDate: null == nextReviewDate
          ? _self.nextReviewDate
          : nextReviewDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      interval: null == interval
          ? _self.interval
          : interval // ignore: cast_nullable_to_non_nullable
              as int,
      repetition: null == repetition
          ? _self.repetition
          : repetition // ignore: cast_nullable_to_non_nullable
              as int,
      easinessFactor: null == easinessFactor
          ? _self.easinessFactor
          : easinessFactor // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// Adds pattern-matching-related methods to [ReviewSchedule].
extension ReviewSchedulePatterns on ReviewSchedule {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ReviewSchedule value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ReviewSchedule() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ReviewSchedule value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ReviewSchedule():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ReviewSchedule value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ReviewSchedule() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(DateTime nextReviewDate, int interval, int repetition,
            double easinessFactor)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ReviewSchedule() when $default != null:
        return $default(_that.nextReviewDate, _that.interval, _that.repetition,
            _that.easinessFactor);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(DateTime nextReviewDate, int interval, int repetition,
            double easinessFactor)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ReviewSchedule():
        return $default(_that.nextReviewDate, _that.interval, _that.repetition,
            _that.easinessFactor);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(DateTime nextReviewDate, int interval, int repetition,
            double easinessFactor)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ReviewSchedule() when $default != null:
        return $default(_that.nextReviewDate, _that.interval, _that.repetition,
            _that.easinessFactor);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ReviewSchedule extends ReviewSchedule {
  const _ReviewSchedule(
      {required this.nextReviewDate,
      required this.interval,
      required this.repetition,
      required this.easinessFactor})
      : super._();
  factory _ReviewSchedule.fromJson(Map<String, dynamic> json) =>
      _$ReviewScheduleFromJson(json);

  @override
  final DateTime nextReviewDate;
  @override
  final int interval;
  @override
  final int repetition;
  @override
  final double easinessFactor;

  /// Create a copy of ReviewSchedule
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ReviewScheduleCopyWith<_ReviewSchedule> get copyWith =>
      __$ReviewScheduleCopyWithImpl<_ReviewSchedule>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ReviewScheduleToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ReviewSchedule &&
            (identical(other.nextReviewDate, nextReviewDate) ||
                other.nextReviewDate == nextReviewDate) &&
            (identical(other.interval, interval) ||
                other.interval == interval) &&
            (identical(other.repetition, repetition) ||
                other.repetition == repetition) &&
            (identical(other.easinessFactor, easinessFactor) ||
                other.easinessFactor == easinessFactor));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, nextReviewDate, interval, repetition, easinessFactor);

  @override
  String toString() {
    return 'ReviewSchedule(nextReviewDate: $nextReviewDate, interval: $interval, repetition: $repetition, easinessFactor: $easinessFactor)';
  }
}

/// @nodoc
abstract mixin class _$ReviewScheduleCopyWith<$Res>
    implements $ReviewScheduleCopyWith<$Res> {
  factory _$ReviewScheduleCopyWith(
          _ReviewSchedule value, $Res Function(_ReviewSchedule) _then) =
      __$ReviewScheduleCopyWithImpl;
  @override
  @useResult
  $Res call(
      {DateTime nextReviewDate,
      int interval,
      int repetition,
      double easinessFactor});
}

/// @nodoc
class __$ReviewScheduleCopyWithImpl<$Res>
    implements _$ReviewScheduleCopyWith<$Res> {
  __$ReviewScheduleCopyWithImpl(this._self, this._then);

  final _ReviewSchedule _self;
  final $Res Function(_ReviewSchedule) _then;

  /// Create a copy of ReviewSchedule
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? nextReviewDate = null,
    Object? interval = null,
    Object? repetition = null,
    Object? easinessFactor = null,
  }) {
    return _then(_ReviewSchedule(
      nextReviewDate: null == nextReviewDate
          ? _self.nextReviewDate
          : nextReviewDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      interval: null == interval
          ? _self.interval
          : interval // ignore: cast_nullable_to_non_nullable
              as int,
      repetition: null == repetition
          ? _self.repetition
          : repetition // ignore: cast_nullable_to_non_nullable
              as int,
      easinessFactor: null == easinessFactor
          ? _self.easinessFactor
          : easinessFactor // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

// dart format on

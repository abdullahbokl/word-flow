// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lexicon_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LexiconStats {
  int get total;
  int get known;
  int get unknown;
  int get excluded;

  /// Create a copy of LexiconStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $LexiconStatsCopyWith<LexiconStats> get copyWith =>
      _$LexiconStatsCopyWithImpl<LexiconStats>(
          this as LexiconStats, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is LexiconStats &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.known, known) || other.known == known) &&
            (identical(other.unknown, unknown) || other.unknown == unknown) &&
            (identical(other.excluded, excluded) ||
                other.excluded == excluded));
  }

  @override
  int get hashCode => Object.hash(runtimeType, total, known, unknown, excluded);

  @override
  String toString() {
    return 'LexiconStats(total: $total, known: $known, unknown: $unknown, excluded: $excluded)';
  }
}

/// @nodoc
abstract mixin class $LexiconStatsCopyWith<$Res> {
  factory $LexiconStatsCopyWith(
          LexiconStats value, $Res Function(LexiconStats) _then) =
      _$LexiconStatsCopyWithImpl;
  @useResult
  $Res call({int total, int known, int unknown, int excluded});
}

/// @nodoc
class _$LexiconStatsCopyWithImpl<$Res> implements $LexiconStatsCopyWith<$Res> {
  _$LexiconStatsCopyWithImpl(this._self, this._then);

  final LexiconStats _self;
  final $Res Function(LexiconStats) _then;

  /// Create a copy of LexiconStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total = null,
    Object? known = null,
    Object? unknown = null,
    Object? excluded = null,
  }) {
    return _then(_self.copyWith(
      total: null == total
          ? _self.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      known: null == known
          ? _self.known
          : known // ignore: cast_nullable_to_non_nullable
              as int,
      unknown: null == unknown
          ? _self.unknown
          : unknown // ignore: cast_nullable_to_non_nullable
              as int,
      excluded: null == excluded
          ? _self.excluded
          : excluded // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [LexiconStats].
extension LexiconStatsPatterns on LexiconStats {
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
    TResult Function(_LexiconStats value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LexiconStats() when $default != null:
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
    TResult Function(_LexiconStats value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LexiconStats():
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
    TResult? Function(_LexiconStats value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LexiconStats() when $default != null:
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
    TResult Function(int total, int known, int unknown, int excluded)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LexiconStats() when $default != null:
        return $default(
            _that.total, _that.known, _that.unknown, _that.excluded);
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
    TResult Function(int total, int known, int unknown, int excluded) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LexiconStats():
        return $default(
            _that.total, _that.known, _that.unknown, _that.excluded);
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
    TResult? Function(int total, int known, int unknown, int excluded)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LexiconStats() when $default != null:
        return $default(
            _that.total, _that.known, _that.unknown, _that.excluded);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _LexiconStats extends LexiconStats {
  const _LexiconStats(
      {required this.total,
      required this.known,
      required this.unknown,
      this.excluded = 0})
      : super._();

  @override
  final int total;
  @override
  final int known;
  @override
  final int unknown;
  @override
  @JsonKey()
  final int excluded;

  /// Create a copy of LexiconStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$LexiconStatsCopyWith<_LexiconStats> get copyWith =>
      __$LexiconStatsCopyWithImpl<_LexiconStats>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _LexiconStats &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.known, known) || other.known == known) &&
            (identical(other.unknown, unknown) || other.unknown == unknown) &&
            (identical(other.excluded, excluded) ||
                other.excluded == excluded));
  }

  @override
  int get hashCode => Object.hash(runtimeType, total, known, unknown, excluded);

  @override
  String toString() {
    return 'LexiconStats(total: $total, known: $known, unknown: $unknown, excluded: $excluded)';
  }
}

/// @nodoc
abstract mixin class _$LexiconStatsCopyWith<$Res>
    implements $LexiconStatsCopyWith<$Res> {
  factory _$LexiconStatsCopyWith(
          _LexiconStats value, $Res Function(_LexiconStats) _then) =
      __$LexiconStatsCopyWithImpl;
  @override
  @useResult
  $Res call({int total, int known, int unknown, int excluded});
}

/// @nodoc
class __$LexiconStatsCopyWithImpl<$Res>
    implements _$LexiconStatsCopyWith<$Res> {
  __$LexiconStatsCopyWithImpl(this._self, this._then);

  final _LexiconStats _self;
  final $Res Function(_LexiconStats) _then;

  /// Create a copy of LexiconStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? total = null,
    Object? known = null,
    Object? unknown = null,
    Object? excluded = null,
  }) {
    return _then(_LexiconStats(
      total: null == total
          ? _self.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      known: null == known
          ? _self.known
          : known // ignore: cast_nullable_to_non_nullable
              as int,
      unknown: null == unknown
          ? _self.unknown
          : unknown // ignore: cast_nullable_to_non_nullable
              as int,
      excluded: null == excluded
          ? _self.excluded
          : excluded // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on

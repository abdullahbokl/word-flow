// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lexicon_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LexiconState {
  BlocStatus<List<WordEntity>> get status;
  WordFilter get filter;
  WordSort get sort;
  String get query;
  LexiconStats get stats;
  int get page;
  bool get hasReachedMax;

  /// Create a copy of LexiconState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $LexiconStateCopyWith<LexiconState> get copyWith =>
      _$LexiconStateCopyWithImpl<LexiconState>(
          this as LexiconState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is LexiconState &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.filter, filter) || other.filter == filter) &&
            (identical(other.sort, sort) || other.sort == sort) &&
            (identical(other.query, query) || other.query == query) &&
            (identical(other.stats, stats) || other.stats == stats) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.hasReachedMax, hasReachedMax) ||
                other.hasReachedMax == hasReachedMax));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, status, filter, sort, query, stats, page, hasReachedMax);

  @override
  String toString() {
    return 'LexiconState(status: $status, filter: $filter, sort: $sort, query: $query, stats: $stats, page: $page, hasReachedMax: $hasReachedMax)';
  }
}

/// @nodoc
abstract mixin class $LexiconStateCopyWith<$Res> {
  factory $LexiconStateCopyWith(
          LexiconState value, $Res Function(LexiconState) _then) =
      _$LexiconStateCopyWithImpl;
  @useResult
  $Res call(
      {BlocStatus<List<WordEntity>> status,
      WordFilter filter,
      WordSort sort,
      String query,
      LexiconStats stats,
      int page,
      bool hasReachedMax});

  $LexiconStatsCopyWith<$Res> get stats;
}

/// @nodoc
class _$LexiconStateCopyWithImpl<$Res> implements $LexiconStateCopyWith<$Res> {
  _$LexiconStateCopyWithImpl(this._self, this._then);

  final LexiconState _self;
  final $Res Function(LexiconState) _then;

  /// Create a copy of LexiconState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? filter = null,
    Object? sort = null,
    Object? query = null,
    Object? stats = null,
    Object? page = null,
    Object? hasReachedMax = null,
  }) {
    return _then(_self.copyWith(
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as BlocStatus<List<WordEntity>>,
      filter: null == filter
          ? _self.filter
          : filter // ignore: cast_nullable_to_non_nullable
              as WordFilter,
      sort: null == sort
          ? _self.sort
          : sort // ignore: cast_nullable_to_non_nullable
              as WordSort,
      query: null == query
          ? _self.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
      stats: null == stats
          ? _self.stats
          : stats // ignore: cast_nullable_to_non_nullable
              as LexiconStats,
      page: null == page
          ? _self.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      hasReachedMax: null == hasReachedMax
          ? _self.hasReachedMax
          : hasReachedMax // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }

  /// Create a copy of LexiconState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LexiconStatsCopyWith<$Res> get stats {
    return $LexiconStatsCopyWith<$Res>(_self.stats, (value) {
      return _then(_self.copyWith(stats: value));
    });
  }
}

/// Adds pattern-matching-related methods to [LexiconState].
extension LexiconStatePatterns on LexiconState {
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
    TResult Function(_LexiconState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LexiconState() when $default != null:
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
    TResult Function(_LexiconState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LexiconState():
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
    TResult? Function(_LexiconState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LexiconState() when $default != null:
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
    TResult Function(
            BlocStatus<List<WordEntity>> status,
            WordFilter filter,
            WordSort sort,
            String query,
            LexiconStats stats,
            int page,
            bool hasReachedMax)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LexiconState() when $default != null:
        return $default(_that.status, _that.filter, _that.sort, _that.query,
            _that.stats, _that.page, _that.hasReachedMax);
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
    TResult Function(
            BlocStatus<List<WordEntity>> status,
            WordFilter filter,
            WordSort sort,
            String query,
            LexiconStats stats,
            int page,
            bool hasReachedMax)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LexiconState():
        return $default(_that.status, _that.filter, _that.sort, _that.query,
            _that.stats, _that.page, _that.hasReachedMax);
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
    TResult? Function(
            BlocStatus<List<WordEntity>> status,
            WordFilter filter,
            WordSort sort,
            String query,
            LexiconStats stats,
            int page,
            bool hasReachedMax)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LexiconState() when $default != null:
        return $default(_that.status, _that.filter, _that.sort, _that.query,
            _that.stats, _that.page, _that.hasReachedMax);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _LexiconState implements LexiconState {
  const _LexiconState(
      {this.status = const BlocStatus.initial(),
      this.filter = WordFilter.all,
      this.sort = WordSort.frequencyDesc,
      this.query = '',
      this.stats = const LexiconStats(total: 0, known: 0, unknown: 0),
      this.page = 0,
      this.hasReachedMax = false});

  @override
  @JsonKey()
  final BlocStatus<List<WordEntity>> status;
  @override
  @JsonKey()
  final WordFilter filter;
  @override
  @JsonKey()
  final WordSort sort;
  @override
  @JsonKey()
  final String query;
  @override
  @JsonKey()
  final LexiconStats stats;
  @override
  @JsonKey()
  final int page;
  @override
  @JsonKey()
  final bool hasReachedMax;

  /// Create a copy of LexiconState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$LexiconStateCopyWith<_LexiconState> get copyWith =>
      __$LexiconStateCopyWithImpl<_LexiconState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _LexiconState &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.filter, filter) || other.filter == filter) &&
            (identical(other.sort, sort) || other.sort == sort) &&
            (identical(other.query, query) || other.query == query) &&
            (identical(other.stats, stats) || other.stats == stats) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.hasReachedMax, hasReachedMax) ||
                other.hasReachedMax == hasReachedMax));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, status, filter, sort, query, stats, page, hasReachedMax);

  @override
  String toString() {
    return 'LexiconState(status: $status, filter: $filter, sort: $sort, query: $query, stats: $stats, page: $page, hasReachedMax: $hasReachedMax)';
  }
}

/// @nodoc
abstract mixin class _$LexiconStateCopyWith<$Res>
    implements $LexiconStateCopyWith<$Res> {
  factory _$LexiconStateCopyWith(
          _LexiconState value, $Res Function(_LexiconState) _then) =
      __$LexiconStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {BlocStatus<List<WordEntity>> status,
      WordFilter filter,
      WordSort sort,
      String query,
      LexiconStats stats,
      int page,
      bool hasReachedMax});

  @override
  $LexiconStatsCopyWith<$Res> get stats;
}

/// @nodoc
class __$LexiconStateCopyWithImpl<$Res>
    implements _$LexiconStateCopyWith<$Res> {
  __$LexiconStateCopyWithImpl(this._self, this._then);

  final _LexiconState _self;
  final $Res Function(_LexiconState) _then;

  /// Create a copy of LexiconState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? status = null,
    Object? filter = null,
    Object? sort = null,
    Object? query = null,
    Object? stats = null,
    Object? page = null,
    Object? hasReachedMax = null,
  }) {
    return _then(_LexiconState(
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as BlocStatus<List<WordEntity>>,
      filter: null == filter
          ? _self.filter
          : filter // ignore: cast_nullable_to_non_nullable
              as WordFilter,
      sort: null == sort
          ? _self.sort
          : sort // ignore: cast_nullable_to_non_nullable
              as WordSort,
      query: null == query
          ? _self.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
      stats: null == stats
          ? _self.stats
          : stats // ignore: cast_nullable_to_non_nullable
              as LexiconStats,
      page: null == page
          ? _self.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      hasReachedMax: null == hasReachedMax
          ? _self.hasReachedMax
          : hasReachedMax // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }

  /// Create a copy of LexiconState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LexiconStatsCopyWith<$Res> get stats {
    return $LexiconStatsCopyWith<$Res>(_self.stats, (value) {
      return _then(_self.copyWith(stats: value));
    });
  }
}

// dart format on

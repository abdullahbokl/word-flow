// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lexicon_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LexiconEvent {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is LexiconEvent);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'LexiconEvent()';
  }
}

/// @nodoc
class $LexiconEventCopyWith<$Res> {
  $LexiconEventCopyWith(LexiconEvent _, $Res Function(LexiconEvent) __);
}

/// Adds pattern-matching-related methods to [LexiconEvent].
extension LexiconEventPatterns on LexiconEvent {
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
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadLexicon value)? load,
    TResult Function(LexiconUpdateReceived value)? updateReceived,
    TResult Function(LexiconStatsUpdateReceived value)? statsUpdateReceived,
    TResult Function(LexiconErrorReceived value)? errorReceived,
    TResult Function(ToggleWordStatusEvent value)? toggleStatus,
    TResult Function(DeleteWordEvent value)? delete,
    TResult Function(RestoreWordEvent value)? restore,
    TResult Function(SearchLexicon value)? search,
    TResult Function(FilterLexicon value)? filter,
    TResult Function(AddWordManuallyEvent value)? addManually,
    TResult Function(UpdateWordEvent value)? update,
    TResult Function(SortLexicon value)? sort,
    TResult Function(FetchMoreLexicon value)? fetchMore,
    TResult Function(ExcludeWordEvent value)? exclude,
    TResult Function(UpdateWordCategory value)? updateCategory,
    TResult Function(StartReview value)? startReview,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case LoadLexicon() when load != null:
        return load(_that);
      case LexiconUpdateReceived() when updateReceived != null:
        return updateReceived(_that);
      case LexiconStatsUpdateReceived() when statsUpdateReceived != null:
        return statsUpdateReceived(_that);
      case LexiconErrorReceived() when errorReceived != null:
        return errorReceived(_that);
      case ToggleWordStatusEvent() when toggleStatus != null:
        return toggleStatus(_that);
      case DeleteWordEvent() when delete != null:
        return delete(_that);
      case RestoreWordEvent() when restore != null:
        return restore(_that);
      case SearchLexicon() when search != null:
        return search(_that);
      case FilterLexicon() when filter != null:
        return filter(_that);
      case AddWordManuallyEvent() when addManually != null:
        return addManually(_that);
      case UpdateWordEvent() when update != null:
        return update(_that);
      case SortLexicon() when sort != null:
        return sort(_that);
      case FetchMoreLexicon() when fetchMore != null:
        return fetchMore(_that);
      case ExcludeWordEvent() when exclude != null:
        return exclude(_that);
      case UpdateWordCategory() when updateCategory != null:
        return updateCategory(_that);
      case StartReview() when startReview != null:
        return startReview(_that);
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
  TResult map<TResult extends Object?>({
    required TResult Function(LoadLexicon value) load,
    required TResult Function(LexiconUpdateReceived value) updateReceived,
    required TResult Function(LexiconStatsUpdateReceived value)
        statsUpdateReceived,
    required TResult Function(LexiconErrorReceived value) errorReceived,
    required TResult Function(ToggleWordStatusEvent value) toggleStatus,
    required TResult Function(DeleteWordEvent value) delete,
    required TResult Function(RestoreWordEvent value) restore,
    required TResult Function(SearchLexicon value) search,
    required TResult Function(FilterLexicon value) filter,
    required TResult Function(AddWordManuallyEvent value) addManually,
    required TResult Function(UpdateWordEvent value) update,
    required TResult Function(SortLexicon value) sort,
    required TResult Function(FetchMoreLexicon value) fetchMore,
    required TResult Function(ExcludeWordEvent value) exclude,
    required TResult Function(UpdateWordCategory value) updateCategory,
    required TResult Function(StartReview value) startReview,
  }) {
    final _that = this;
    switch (_that) {
      case LoadLexicon():
        return load(_that);
      case LexiconUpdateReceived():
        return updateReceived(_that);
      case LexiconStatsUpdateReceived():
        return statsUpdateReceived(_that);
      case LexiconErrorReceived():
        return errorReceived(_that);
      case ToggleWordStatusEvent():
        return toggleStatus(_that);
      case DeleteWordEvent():
        return delete(_that);
      case RestoreWordEvent():
        return restore(_that);
      case SearchLexicon():
        return search(_that);
      case FilterLexicon():
        return filter(_that);
      case AddWordManuallyEvent():
        return addManually(_that);
      case UpdateWordEvent():
        return update(_that);
      case SortLexicon():
        return sort(_that);
      case FetchMoreLexicon():
        return fetchMore(_that);
      case ExcludeWordEvent():
        return exclude(_that);
      case UpdateWordCategory():
        return updateCategory(_that);
      case StartReview():
        return startReview(_that);
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
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadLexicon value)? load,
    TResult? Function(LexiconUpdateReceived value)? updateReceived,
    TResult? Function(LexiconStatsUpdateReceived value)? statsUpdateReceived,
    TResult? Function(LexiconErrorReceived value)? errorReceived,
    TResult? Function(ToggleWordStatusEvent value)? toggleStatus,
    TResult? Function(DeleteWordEvent value)? delete,
    TResult? Function(RestoreWordEvent value)? restore,
    TResult? Function(SearchLexicon value)? search,
    TResult? Function(FilterLexicon value)? filter,
    TResult? Function(AddWordManuallyEvent value)? addManually,
    TResult? Function(UpdateWordEvent value)? update,
    TResult? Function(SortLexicon value)? sort,
    TResult? Function(FetchMoreLexicon value)? fetchMore,
    TResult? Function(ExcludeWordEvent value)? exclude,
    TResult? Function(UpdateWordCategory value)? updateCategory,
    TResult? Function(StartReview value)? startReview,
  }) {
    final _that = this;
    switch (_that) {
      case LoadLexicon() when load != null:
        return load(_that);
      case LexiconUpdateReceived() when updateReceived != null:
        return updateReceived(_that);
      case LexiconStatsUpdateReceived() when statsUpdateReceived != null:
        return statsUpdateReceived(_that);
      case LexiconErrorReceived() when errorReceived != null:
        return errorReceived(_that);
      case ToggleWordStatusEvent() when toggleStatus != null:
        return toggleStatus(_that);
      case DeleteWordEvent() when delete != null:
        return delete(_that);
      case RestoreWordEvent() when restore != null:
        return restore(_that);
      case SearchLexicon() when search != null:
        return search(_that);
      case FilterLexicon() when filter != null:
        return filter(_that);
      case AddWordManuallyEvent() when addManually != null:
        return addManually(_that);
      case UpdateWordEvent() when update != null:
        return update(_that);
      case SortLexicon() when sort != null:
        return sort(_that);
      case FetchMoreLexicon() when fetchMore != null:
        return fetchMore(_that);
      case ExcludeWordEvent() when exclude != null:
        return exclude(_that);
      case UpdateWordCategory() when updateCategory != null:
        return updateCategory(_that);
      case StartReview() when startReview != null:
        return startReview(_that);
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
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? load,
    TResult Function(List<WordEntity> words, WordFilter? filter, WordSort? sort,
            String? query)?
        updateReceived,
    TResult Function(LexiconStats stats)? statsUpdateReceived,
    TResult Function(String message)? errorReceived,
    TResult Function(int wordId)? toggleStatus,
    TResult Function(int wordId)? delete,
    TResult Function(String text, int previousId, int previousFrequency,
            bool wasFullyDeleted)?
        restore,
    TResult Function(String query)? search,
    TResult Function(WordFilter filter)? filter,
    TResult Function(String word)? addManually,
    TResult Function(
            int wordId,
            String? text,
            String? meaning,
            String? description,
            List<String>? definitions,
            List<String>? examples,
            List<String>? translations,
            List<String>? synonyms)?
        update,
    TResult Function(WordSort sort)? sort,
    TResult Function()? fetchMore,
    TResult Function(int wordId)? exclude,
    TResult Function(int wordId, WordCategory category)? updateCategory,
    TResult Function(int wordId)? startReview,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case LoadLexicon() when load != null:
        return load();
      case LexiconUpdateReceived() when updateReceived != null:
        return updateReceived(
            _that.words, _that.filter, _that.sort, _that.query);
      case LexiconStatsUpdateReceived() when statsUpdateReceived != null:
        return statsUpdateReceived(_that.stats);
      case LexiconErrorReceived() when errorReceived != null:
        return errorReceived(_that.message);
      case ToggleWordStatusEvent() when toggleStatus != null:
        return toggleStatus(_that.wordId);
      case DeleteWordEvent() when delete != null:
        return delete(_that.wordId);
      case RestoreWordEvent() when restore != null:
        return restore(_that.text, _that.previousId, _that.previousFrequency,
            _that.wasFullyDeleted);
      case SearchLexicon() when search != null:
        return search(_that.query);
      case FilterLexicon() when filter != null:
        return filter(_that.filter);
      case AddWordManuallyEvent() when addManually != null:
        return addManually(_that.word);
      case UpdateWordEvent() when update != null:
        return update(
            _that.wordId,
            _that.text,
            _that.meaning,
            _that.description,
            _that.definitions,
            _that.examples,
            _that.translations,
            _that.synonyms);
      case SortLexicon() when sort != null:
        return sort(_that.sort);
      case FetchMoreLexicon() when fetchMore != null:
        return fetchMore();
      case ExcludeWordEvent() when exclude != null:
        return exclude(_that.wordId);
      case UpdateWordCategory() when updateCategory != null:
        return updateCategory(_that.wordId, _that.category);
      case StartReview() when startReview != null:
        return startReview(_that.wordId);
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
  TResult when<TResult extends Object?>({
    required TResult Function() load,
    required TResult Function(List<WordEntity> words, WordFilter? filter,
            WordSort? sort, String? query)
        updateReceived,
    required TResult Function(LexiconStats stats) statsUpdateReceived,
    required TResult Function(String message) errorReceived,
    required TResult Function(int wordId) toggleStatus,
    required TResult Function(int wordId) delete,
    required TResult Function(String text, int previousId,
            int previousFrequency, bool wasFullyDeleted)
        restore,
    required TResult Function(String query) search,
    required TResult Function(WordFilter filter) filter,
    required TResult Function(String word) addManually,
    required TResult Function(
            int wordId,
            String? text,
            String? meaning,
            String? description,
            List<String>? definitions,
            List<String>? examples,
            List<String>? translations,
            List<String>? synonyms)
        update,
    required TResult Function(WordSort sort) sort,
    required TResult Function() fetchMore,
    required TResult Function(int wordId) exclude,
    required TResult Function(int wordId, WordCategory category) updateCategory,
    required TResult Function(int wordId) startReview,
  }) {
    final _that = this;
    switch (_that) {
      case LoadLexicon():
        return load();
      case LexiconUpdateReceived():
        return updateReceived(
            _that.words, _that.filter, _that.sort, _that.query);
      case LexiconStatsUpdateReceived():
        return statsUpdateReceived(_that.stats);
      case LexiconErrorReceived():
        return errorReceived(_that.message);
      case ToggleWordStatusEvent():
        return toggleStatus(_that.wordId);
      case DeleteWordEvent():
        return delete(_that.wordId);
      case RestoreWordEvent():
        return restore(_that.text, _that.previousId, _that.previousFrequency,
            _that.wasFullyDeleted);
      case SearchLexicon():
        return search(_that.query);
      case FilterLexicon():
        return filter(_that.filter);
      case AddWordManuallyEvent():
        return addManually(_that.word);
      case UpdateWordEvent():
        return update(
            _that.wordId,
            _that.text,
            _that.meaning,
            _that.description,
            _that.definitions,
            _that.examples,
            _that.translations,
            _that.synonyms);
      case SortLexicon():
        return sort(_that.sort);
      case FetchMoreLexicon():
        return fetchMore();
      case ExcludeWordEvent():
        return exclude(_that.wordId);
      case UpdateWordCategory():
        return updateCategory(_that.wordId, _that.category);
      case StartReview():
        return startReview(_that.wordId);
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
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? load,
    TResult? Function(List<WordEntity> words, WordFilter? filter,
            WordSort? sort, String? query)?
        updateReceived,
    TResult? Function(LexiconStats stats)? statsUpdateReceived,
    TResult? Function(String message)? errorReceived,
    TResult? Function(int wordId)? toggleStatus,
    TResult? Function(int wordId)? delete,
    TResult? Function(String text, int previousId, int previousFrequency,
            bool wasFullyDeleted)?
        restore,
    TResult? Function(String query)? search,
    TResult? Function(WordFilter filter)? filter,
    TResult? Function(String word)? addManually,
    TResult? Function(
            int wordId,
            String? text,
            String? meaning,
            String? description,
            List<String>? definitions,
            List<String>? examples,
            List<String>? translations,
            List<String>? synonyms)?
        update,
    TResult? Function(WordSort sort)? sort,
    TResult? Function()? fetchMore,
    TResult? Function(int wordId)? exclude,
    TResult? Function(int wordId, WordCategory category)? updateCategory,
    TResult? Function(int wordId)? startReview,
  }) {
    final _that = this;
    switch (_that) {
      case LoadLexicon() when load != null:
        return load();
      case LexiconUpdateReceived() when updateReceived != null:
        return updateReceived(
            _that.words, _that.filter, _that.sort, _that.query);
      case LexiconStatsUpdateReceived() when statsUpdateReceived != null:
        return statsUpdateReceived(_that.stats);
      case LexiconErrorReceived() when errorReceived != null:
        return errorReceived(_that.message);
      case ToggleWordStatusEvent() when toggleStatus != null:
        return toggleStatus(_that.wordId);
      case DeleteWordEvent() when delete != null:
        return delete(_that.wordId);
      case RestoreWordEvent() when restore != null:
        return restore(_that.text, _that.previousId, _that.previousFrequency,
            _that.wasFullyDeleted);
      case SearchLexicon() when search != null:
        return search(_that.query);
      case FilterLexicon() when filter != null:
        return filter(_that.filter);
      case AddWordManuallyEvent() when addManually != null:
        return addManually(_that.word);
      case UpdateWordEvent() when update != null:
        return update(
            _that.wordId,
            _that.text,
            _that.meaning,
            _that.description,
            _that.definitions,
            _that.examples,
            _that.translations,
            _that.synonyms);
      case SortLexicon() when sort != null:
        return sort(_that.sort);
      case FetchMoreLexicon() when fetchMore != null:
        return fetchMore();
      case ExcludeWordEvent() when exclude != null:
        return exclude(_that.wordId);
      case UpdateWordCategory() when updateCategory != null:
        return updateCategory(_that.wordId, _that.category);
      case StartReview() when startReview != null:
        return startReview(_that.wordId);
      case _:
        return null;
    }
  }
}

/// @nodoc

class LoadLexicon implements LexiconEvent {
  const LoadLexicon();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is LoadLexicon);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'LexiconEvent.load()';
  }
}

/// @nodoc

class LexiconUpdateReceived implements LexiconEvent {
  const LexiconUpdateReceived(
      {required final List<WordEntity> words,
      this.filter,
      this.sort,
      this.query})
      : _words = words;

  final List<WordEntity> _words;
  List<WordEntity> get words {
    if (_words is EqualUnmodifiableListView) return _words;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_words);
  }

  final WordFilter? filter;
  final WordSort? sort;
  final String? query;

  /// Create a copy of LexiconEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $LexiconUpdateReceivedCopyWith<LexiconUpdateReceived> get copyWith =>
      _$LexiconUpdateReceivedCopyWithImpl<LexiconUpdateReceived>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is LexiconUpdateReceived &&
            const DeepCollectionEquality().equals(other._words, _words) &&
            (identical(other.filter, filter) || other.filter == filter) &&
            (identical(other.sort, sort) || other.sort == sort) &&
            (identical(other.query, query) || other.query == query));
  }

  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_words), filter, sort, query);

  @override
  String toString() {
    return 'LexiconEvent.updateReceived(words: $words, filter: $filter, sort: $sort, query: $query)';
  }
}

/// @nodoc
abstract mixin class $LexiconUpdateReceivedCopyWith<$Res>
    implements $LexiconEventCopyWith<$Res> {
  factory $LexiconUpdateReceivedCopyWith(LexiconUpdateReceived value,
          $Res Function(LexiconUpdateReceived) _then) =
      _$LexiconUpdateReceivedCopyWithImpl;
  @useResult
  $Res call(
      {List<WordEntity> words,
      WordFilter? filter,
      WordSort? sort,
      String? query});
}

/// @nodoc
class _$LexiconUpdateReceivedCopyWithImpl<$Res>
    implements $LexiconUpdateReceivedCopyWith<$Res> {
  _$LexiconUpdateReceivedCopyWithImpl(this._self, this._then);

  final LexiconUpdateReceived _self;
  final $Res Function(LexiconUpdateReceived) _then;

  /// Create a copy of LexiconEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? words = null,
    Object? filter = freezed,
    Object? sort = freezed,
    Object? query = freezed,
  }) {
    return _then(LexiconUpdateReceived(
      words: null == words
          ? _self._words
          : words // ignore: cast_nullable_to_non_nullable
              as List<WordEntity>,
      filter: freezed == filter
          ? _self.filter
          : filter // ignore: cast_nullable_to_non_nullable
              as WordFilter?,
      sort: freezed == sort
          ? _self.sort
          : sort // ignore: cast_nullable_to_non_nullable
              as WordSort?,
      query: freezed == query
          ? _self.query
          : query // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class LexiconStatsUpdateReceived implements LexiconEvent {
  const LexiconStatsUpdateReceived(this.stats);

  final LexiconStats stats;

  /// Create a copy of LexiconEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $LexiconStatsUpdateReceivedCopyWith<LexiconStatsUpdateReceived>
      get copyWith =>
          _$LexiconStatsUpdateReceivedCopyWithImpl<LexiconStatsUpdateReceived>(
              this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is LexiconStatsUpdateReceived &&
            (identical(other.stats, stats) || other.stats == stats));
  }

  @override
  int get hashCode => Object.hash(runtimeType, stats);

  @override
  String toString() {
    return 'LexiconEvent.statsUpdateReceived(stats: $stats)';
  }
}

/// @nodoc
abstract mixin class $LexiconStatsUpdateReceivedCopyWith<$Res>
    implements $LexiconEventCopyWith<$Res> {
  factory $LexiconStatsUpdateReceivedCopyWith(LexiconStatsUpdateReceived value,
          $Res Function(LexiconStatsUpdateReceived) _then) =
      _$LexiconStatsUpdateReceivedCopyWithImpl;
  @useResult
  $Res call({LexiconStats stats});

  $LexiconStatsCopyWith<$Res> get stats;
}

/// @nodoc
class _$LexiconStatsUpdateReceivedCopyWithImpl<$Res>
    implements $LexiconStatsUpdateReceivedCopyWith<$Res> {
  _$LexiconStatsUpdateReceivedCopyWithImpl(this._self, this._then);

  final LexiconStatsUpdateReceived _self;
  final $Res Function(LexiconStatsUpdateReceived) _then;

  /// Create a copy of LexiconEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? stats = null,
  }) {
    return _then(LexiconStatsUpdateReceived(
      null == stats
          ? _self.stats
          : stats // ignore: cast_nullable_to_non_nullable
              as LexiconStats,
    ));
  }

  /// Create a copy of LexiconEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LexiconStatsCopyWith<$Res> get stats {
    return $LexiconStatsCopyWith<$Res>(_self.stats, (value) {
      return _then(_self.copyWith(stats: value));
    });
  }
}

/// @nodoc

class LexiconErrorReceived implements LexiconEvent {
  const LexiconErrorReceived(this.message);

  final String message;

  /// Create a copy of LexiconEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $LexiconErrorReceivedCopyWith<LexiconErrorReceived> get copyWith =>
      _$LexiconErrorReceivedCopyWithImpl<LexiconErrorReceived>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is LexiconErrorReceived &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @override
  String toString() {
    return 'LexiconEvent.errorReceived(message: $message)';
  }
}

/// @nodoc
abstract mixin class $LexiconErrorReceivedCopyWith<$Res>
    implements $LexiconEventCopyWith<$Res> {
  factory $LexiconErrorReceivedCopyWith(LexiconErrorReceived value,
          $Res Function(LexiconErrorReceived) _then) =
      _$LexiconErrorReceivedCopyWithImpl;
  @useResult
  $Res call({String message});
}

/// @nodoc
class _$LexiconErrorReceivedCopyWithImpl<$Res>
    implements $LexiconErrorReceivedCopyWith<$Res> {
  _$LexiconErrorReceivedCopyWithImpl(this._self, this._then);

  final LexiconErrorReceived _self;
  final $Res Function(LexiconErrorReceived) _then;

  /// Create a copy of LexiconEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
  }) {
    return _then(LexiconErrorReceived(
      null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class ToggleWordStatusEvent implements LexiconEvent {
  const ToggleWordStatusEvent(this.wordId);

  final int wordId;

  /// Create a copy of LexiconEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ToggleWordStatusEventCopyWith<ToggleWordStatusEvent> get copyWith =>
      _$ToggleWordStatusEventCopyWithImpl<ToggleWordStatusEvent>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ToggleWordStatusEvent &&
            (identical(other.wordId, wordId) || other.wordId == wordId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, wordId);

  @override
  String toString() {
    return 'LexiconEvent.toggleStatus(wordId: $wordId)';
  }
}

/// @nodoc
abstract mixin class $ToggleWordStatusEventCopyWith<$Res>
    implements $LexiconEventCopyWith<$Res> {
  factory $ToggleWordStatusEventCopyWith(ToggleWordStatusEvent value,
          $Res Function(ToggleWordStatusEvent) _then) =
      _$ToggleWordStatusEventCopyWithImpl;
  @useResult
  $Res call({int wordId});
}

/// @nodoc
class _$ToggleWordStatusEventCopyWithImpl<$Res>
    implements $ToggleWordStatusEventCopyWith<$Res> {
  _$ToggleWordStatusEventCopyWithImpl(this._self, this._then);

  final ToggleWordStatusEvent _self;
  final $Res Function(ToggleWordStatusEvent) _then;

  /// Create a copy of LexiconEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? wordId = null,
  }) {
    return _then(ToggleWordStatusEvent(
      null == wordId
          ? _self.wordId
          : wordId // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class DeleteWordEvent implements LexiconEvent {
  const DeleteWordEvent(this.wordId);

  final int wordId;

  /// Create a copy of LexiconEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DeleteWordEventCopyWith<DeleteWordEvent> get copyWith =>
      _$DeleteWordEventCopyWithImpl<DeleteWordEvent>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DeleteWordEvent &&
            (identical(other.wordId, wordId) || other.wordId == wordId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, wordId);

  @override
  String toString() {
    return 'LexiconEvent.delete(wordId: $wordId)';
  }
}

/// @nodoc
abstract mixin class $DeleteWordEventCopyWith<$Res>
    implements $LexiconEventCopyWith<$Res> {
  factory $DeleteWordEventCopyWith(
          DeleteWordEvent value, $Res Function(DeleteWordEvent) _then) =
      _$DeleteWordEventCopyWithImpl;
  @useResult
  $Res call({int wordId});
}

/// @nodoc
class _$DeleteWordEventCopyWithImpl<$Res>
    implements $DeleteWordEventCopyWith<$Res> {
  _$DeleteWordEventCopyWithImpl(this._self, this._then);

  final DeleteWordEvent _self;
  final $Res Function(DeleteWordEvent) _then;

  /// Create a copy of LexiconEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? wordId = null,
  }) {
    return _then(DeleteWordEvent(
      null == wordId
          ? _self.wordId
          : wordId // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class RestoreWordEvent implements LexiconEvent {
  const RestoreWordEvent(this.text,
      {required this.previousId,
      required this.previousFrequency,
      required this.wasFullyDeleted});

  final String text;
  final int previousId;
  final int previousFrequency;
  final bool wasFullyDeleted;

  /// Create a copy of LexiconEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RestoreWordEventCopyWith<RestoreWordEvent> get copyWith =>
      _$RestoreWordEventCopyWithImpl<RestoreWordEvent>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RestoreWordEvent &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.previousId, previousId) ||
                other.previousId == previousId) &&
            (identical(other.previousFrequency, previousFrequency) ||
                other.previousFrequency == previousFrequency) &&
            (identical(other.wasFullyDeleted, wasFullyDeleted) ||
                other.wasFullyDeleted == wasFullyDeleted));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, text, previousId, previousFrequency, wasFullyDeleted);

  @override
  String toString() {
    return 'LexiconEvent.restore(text: $text, previousId: $previousId, previousFrequency: $previousFrequency, wasFullyDeleted: $wasFullyDeleted)';
  }
}

/// @nodoc
abstract mixin class $RestoreWordEventCopyWith<$Res>
    implements $LexiconEventCopyWith<$Res> {
  factory $RestoreWordEventCopyWith(
          RestoreWordEvent value, $Res Function(RestoreWordEvent) _then) =
      _$RestoreWordEventCopyWithImpl;
  @useResult
  $Res call(
      {String text,
      int previousId,
      int previousFrequency,
      bool wasFullyDeleted});
}

/// @nodoc
class _$RestoreWordEventCopyWithImpl<$Res>
    implements $RestoreWordEventCopyWith<$Res> {
  _$RestoreWordEventCopyWithImpl(this._self, this._then);

  final RestoreWordEvent _self;
  final $Res Function(RestoreWordEvent) _then;

  /// Create a copy of LexiconEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? text = null,
    Object? previousId = null,
    Object? previousFrequency = null,
    Object? wasFullyDeleted = null,
  }) {
    return _then(RestoreWordEvent(
      null == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      previousId: null == previousId
          ? _self.previousId
          : previousId // ignore: cast_nullable_to_non_nullable
              as int,
      previousFrequency: null == previousFrequency
          ? _self.previousFrequency
          : previousFrequency // ignore: cast_nullable_to_non_nullable
              as int,
      wasFullyDeleted: null == wasFullyDeleted
          ? _self.wasFullyDeleted
          : wasFullyDeleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class SearchLexicon implements LexiconEvent {
  const SearchLexicon(this.query);

  final String query;

  /// Create a copy of LexiconEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SearchLexiconCopyWith<SearchLexicon> get copyWith =>
      _$SearchLexiconCopyWithImpl<SearchLexicon>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SearchLexicon &&
            (identical(other.query, query) || other.query == query));
  }

  @override
  int get hashCode => Object.hash(runtimeType, query);

  @override
  String toString() {
    return 'LexiconEvent.search(query: $query)';
  }
}

/// @nodoc
abstract mixin class $SearchLexiconCopyWith<$Res>
    implements $LexiconEventCopyWith<$Res> {
  factory $SearchLexiconCopyWith(
          SearchLexicon value, $Res Function(SearchLexicon) _then) =
      _$SearchLexiconCopyWithImpl;
  @useResult
  $Res call({String query});
}

/// @nodoc
class _$SearchLexiconCopyWithImpl<$Res>
    implements $SearchLexiconCopyWith<$Res> {
  _$SearchLexiconCopyWithImpl(this._self, this._then);

  final SearchLexicon _self;
  final $Res Function(SearchLexicon) _then;

  /// Create a copy of LexiconEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? query = null,
  }) {
    return _then(SearchLexicon(
      null == query
          ? _self.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class FilterLexicon implements LexiconEvent {
  const FilterLexicon(this.filter);

  final WordFilter filter;

  /// Create a copy of LexiconEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $FilterLexiconCopyWith<FilterLexicon> get copyWith =>
      _$FilterLexiconCopyWithImpl<FilterLexicon>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is FilterLexicon &&
            (identical(other.filter, filter) || other.filter == filter));
  }

  @override
  int get hashCode => Object.hash(runtimeType, filter);

  @override
  String toString() {
    return 'LexiconEvent.filter(filter: $filter)';
  }
}

/// @nodoc
abstract mixin class $FilterLexiconCopyWith<$Res>
    implements $LexiconEventCopyWith<$Res> {
  factory $FilterLexiconCopyWith(
          FilterLexicon value, $Res Function(FilterLexicon) _then) =
      _$FilterLexiconCopyWithImpl;
  @useResult
  $Res call({WordFilter filter});
}

/// @nodoc
class _$FilterLexiconCopyWithImpl<$Res>
    implements $FilterLexiconCopyWith<$Res> {
  _$FilterLexiconCopyWithImpl(this._self, this._then);

  final FilterLexicon _self;
  final $Res Function(FilterLexicon) _then;

  /// Create a copy of LexiconEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? filter = null,
  }) {
    return _then(FilterLexicon(
      null == filter
          ? _self.filter
          : filter // ignore: cast_nullable_to_non_nullable
              as WordFilter,
    ));
  }
}

/// @nodoc

class AddWordManuallyEvent implements LexiconEvent {
  const AddWordManuallyEvent(this.word);

  final String word;

  /// Create a copy of LexiconEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AddWordManuallyEventCopyWith<AddWordManuallyEvent> get copyWith =>
      _$AddWordManuallyEventCopyWithImpl<AddWordManuallyEvent>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AddWordManuallyEvent &&
            (identical(other.word, word) || other.word == word));
  }

  @override
  int get hashCode => Object.hash(runtimeType, word);

  @override
  String toString() {
    return 'LexiconEvent.addManually(word: $word)';
  }
}

/// @nodoc
abstract mixin class $AddWordManuallyEventCopyWith<$Res>
    implements $LexiconEventCopyWith<$Res> {
  factory $AddWordManuallyEventCopyWith(AddWordManuallyEvent value,
          $Res Function(AddWordManuallyEvent) _then) =
      _$AddWordManuallyEventCopyWithImpl;
  @useResult
  $Res call({String word});
}

/// @nodoc
class _$AddWordManuallyEventCopyWithImpl<$Res>
    implements $AddWordManuallyEventCopyWith<$Res> {
  _$AddWordManuallyEventCopyWithImpl(this._self, this._then);

  final AddWordManuallyEvent _self;
  final $Res Function(AddWordManuallyEvent) _then;

  /// Create a copy of LexiconEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? word = null,
  }) {
    return _then(AddWordManuallyEvent(
      null == word
          ? _self.word
          : word // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class UpdateWordEvent implements LexiconEvent {
  const UpdateWordEvent(this.wordId,
      {this.text,
      this.meaning,
      this.description,
      final List<String>? definitions,
      final List<String>? examples,
      final List<String>? translations,
      final List<String>? synonyms})
      : _definitions = definitions,
        _examples = examples,
        _translations = translations,
        _synonyms = synonyms;

  final int wordId;
  final String? text;
  final String? meaning;
  final String? description;
  final List<String>? _definitions;
  List<String>? get definitions {
    final value = _definitions;
    if (value == null) return null;
    if (_definitions is EqualUnmodifiableListView) return _definitions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _examples;
  List<String>? get examples {
    final value = _examples;
    if (value == null) return null;
    if (_examples is EqualUnmodifiableListView) return _examples;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _translations;
  List<String>? get translations {
    final value = _translations;
    if (value == null) return null;
    if (_translations is EqualUnmodifiableListView) return _translations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _synonyms;
  List<String>? get synonyms {
    final value = _synonyms;
    if (value == null) return null;
    if (_synonyms is EqualUnmodifiableListView) return _synonyms;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  /// Create a copy of LexiconEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $UpdateWordEventCopyWith<UpdateWordEvent> get copyWith =>
      _$UpdateWordEventCopyWithImpl<UpdateWordEvent>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is UpdateWordEvent &&
            (identical(other.wordId, wordId) || other.wordId == wordId) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.meaning, meaning) || other.meaning == meaning) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other._definitions, _definitions) &&
            const DeepCollectionEquality().equals(other._examples, _examples) &&
            const DeepCollectionEquality()
                .equals(other._translations, _translations) &&
            const DeepCollectionEquality().equals(other._synonyms, _synonyms));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      wordId,
      text,
      meaning,
      description,
      const DeepCollectionEquality().hash(_definitions),
      const DeepCollectionEquality().hash(_examples),
      const DeepCollectionEquality().hash(_translations),
      const DeepCollectionEquality().hash(_synonyms));

  @override
  String toString() {
    return 'LexiconEvent.update(wordId: $wordId, text: $text, meaning: $meaning, description: $description, definitions: $definitions, examples: $examples, translations: $translations, synonyms: $synonyms)';
  }
}

/// @nodoc
abstract mixin class $UpdateWordEventCopyWith<$Res>
    implements $LexiconEventCopyWith<$Res> {
  factory $UpdateWordEventCopyWith(
          UpdateWordEvent value, $Res Function(UpdateWordEvent) _then) =
      _$UpdateWordEventCopyWithImpl;
  @useResult
  $Res call(
      {int wordId,
      String? text,
      String? meaning,
      String? description,
      List<String>? definitions,
      List<String>? examples,
      List<String>? translations,
      List<String>? synonyms});
}

/// @nodoc
class _$UpdateWordEventCopyWithImpl<$Res>
    implements $UpdateWordEventCopyWith<$Res> {
  _$UpdateWordEventCopyWithImpl(this._self, this._then);

  final UpdateWordEvent _self;
  final $Res Function(UpdateWordEvent) _then;

  /// Create a copy of LexiconEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? wordId = null,
    Object? text = freezed,
    Object? meaning = freezed,
    Object? description = freezed,
    Object? definitions = freezed,
    Object? examples = freezed,
    Object? translations = freezed,
    Object? synonyms = freezed,
  }) {
    return _then(UpdateWordEvent(
      null == wordId
          ? _self.wordId
          : wordId // ignore: cast_nullable_to_non_nullable
              as int,
      text: freezed == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String?,
      meaning: freezed == meaning
          ? _self.meaning
          : meaning // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      definitions: freezed == definitions
          ? _self._definitions
          : definitions // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      examples: freezed == examples
          ? _self._examples
          : examples // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      translations: freezed == translations
          ? _self._translations
          : translations // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      synonyms: freezed == synonyms
          ? _self._synonyms
          : synonyms // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc

class SortLexicon implements LexiconEvent {
  const SortLexicon(this.sort);

  final WordSort sort;

  /// Create a copy of LexiconEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SortLexiconCopyWith<SortLexicon> get copyWith =>
      _$SortLexiconCopyWithImpl<SortLexicon>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SortLexicon &&
            (identical(other.sort, sort) || other.sort == sort));
  }

  @override
  int get hashCode => Object.hash(runtimeType, sort);

  @override
  String toString() {
    return 'LexiconEvent.sort(sort: $sort)';
  }
}

/// @nodoc
abstract mixin class $SortLexiconCopyWith<$Res>
    implements $LexiconEventCopyWith<$Res> {
  factory $SortLexiconCopyWith(
          SortLexicon value, $Res Function(SortLexicon) _then) =
      _$SortLexiconCopyWithImpl;
  @useResult
  $Res call({WordSort sort});
}

/// @nodoc
class _$SortLexiconCopyWithImpl<$Res> implements $SortLexiconCopyWith<$Res> {
  _$SortLexiconCopyWithImpl(this._self, this._then);

  final SortLexicon _self;
  final $Res Function(SortLexicon) _then;

  /// Create a copy of LexiconEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? sort = null,
  }) {
    return _then(SortLexicon(
      null == sort
          ? _self.sort
          : sort // ignore: cast_nullable_to_non_nullable
              as WordSort,
    ));
  }
}

/// @nodoc

class FetchMoreLexicon implements LexiconEvent {
  const FetchMoreLexicon();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is FetchMoreLexicon);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'LexiconEvent.fetchMore()';
  }
}

/// @nodoc

class ExcludeWordEvent implements LexiconEvent {
  const ExcludeWordEvent(this.wordId);

  final int wordId;

  /// Create a copy of LexiconEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ExcludeWordEventCopyWith<ExcludeWordEvent> get copyWith =>
      _$ExcludeWordEventCopyWithImpl<ExcludeWordEvent>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ExcludeWordEvent &&
            (identical(other.wordId, wordId) || other.wordId == wordId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, wordId);

  @override
  String toString() {
    return 'LexiconEvent.exclude(wordId: $wordId)';
  }
}

/// @nodoc
abstract mixin class $ExcludeWordEventCopyWith<$Res>
    implements $LexiconEventCopyWith<$Res> {
  factory $ExcludeWordEventCopyWith(
          ExcludeWordEvent value, $Res Function(ExcludeWordEvent) _then) =
      _$ExcludeWordEventCopyWithImpl;
  @useResult
  $Res call({int wordId});
}

/// @nodoc
class _$ExcludeWordEventCopyWithImpl<$Res>
    implements $ExcludeWordEventCopyWith<$Res> {
  _$ExcludeWordEventCopyWithImpl(this._self, this._then);

  final ExcludeWordEvent _self;
  final $Res Function(ExcludeWordEvent) _then;

  /// Create a copy of LexiconEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? wordId = null,
  }) {
    return _then(ExcludeWordEvent(
      null == wordId
          ? _self.wordId
          : wordId // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class UpdateWordCategory implements LexiconEvent {
  const UpdateWordCategory(this.wordId, this.category);

  final int wordId;
  final WordCategory category;

  /// Create a copy of LexiconEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $UpdateWordCategoryCopyWith<UpdateWordCategory> get copyWith =>
      _$UpdateWordCategoryCopyWithImpl<UpdateWordCategory>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is UpdateWordCategory &&
            (identical(other.wordId, wordId) || other.wordId == wordId) &&
            (identical(other.category, category) ||
                other.category == category));
  }

  @override
  int get hashCode => Object.hash(runtimeType, wordId, category);

  @override
  String toString() {
    return 'LexiconEvent.updateCategory(wordId: $wordId, category: $category)';
  }
}

/// @nodoc
abstract mixin class $UpdateWordCategoryCopyWith<$Res>
    implements $LexiconEventCopyWith<$Res> {
  factory $UpdateWordCategoryCopyWith(
          UpdateWordCategory value, $Res Function(UpdateWordCategory) _then) =
      _$UpdateWordCategoryCopyWithImpl;
  @useResult
  $Res call({int wordId, WordCategory category});
}

/// @nodoc
class _$UpdateWordCategoryCopyWithImpl<$Res>
    implements $UpdateWordCategoryCopyWith<$Res> {
  _$UpdateWordCategoryCopyWithImpl(this._self, this._then);

  final UpdateWordCategory _self;
  final $Res Function(UpdateWordCategory) _then;

  /// Create a copy of LexiconEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? wordId = null,
    Object? category = null,
  }) {
    return _then(UpdateWordCategory(
      null == wordId
          ? _self.wordId
          : wordId // ignore: cast_nullable_to_non_nullable
              as int,
      null == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as WordCategory,
    ));
  }
}

/// @nodoc

class StartReview implements LexiconEvent {
  const StartReview(this.wordId);

  final int wordId;

  /// Create a copy of LexiconEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $StartReviewCopyWith<StartReview> get copyWith =>
      _$StartReviewCopyWithImpl<StartReview>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is StartReview &&
            (identical(other.wordId, wordId) || other.wordId == wordId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, wordId);

  @override
  String toString() {
    return 'LexiconEvent.startReview(wordId: $wordId)';
  }
}

/// @nodoc
abstract mixin class $StartReviewCopyWith<$Res>
    implements $LexiconEventCopyWith<$Res> {
  factory $StartReviewCopyWith(
          StartReview value, $Res Function(StartReview) _then) =
      _$StartReviewCopyWithImpl;
  @useResult
  $Res call({int wordId});
}

/// @nodoc
class _$StartReviewCopyWithImpl<$Res> implements $StartReviewCopyWith<$Res> {
  _$StartReviewCopyWithImpl(this._self, this._then);

  final StartReview _self;
  final $Res Function(StartReview) _then;

  /// Create a copy of LexiconEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? wordId = null,
  }) {
    return _then(StartReview(
      null == wordId
          ? _self.wordId
          : wordId // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on

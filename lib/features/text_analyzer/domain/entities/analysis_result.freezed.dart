// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'analysis_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AnalysisResult {
  int get id;
  String get title;
  int get totalWords;
  int get uniqueWords;
  int get unknownWords;
  int get knownWords;
  int get newWordsCount;
  List<WordWithLocalFreq> get words;

  /// Create a copy of AnalysisResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AnalysisResultCopyWith<AnalysisResult> get copyWith =>
      _$AnalysisResultCopyWithImpl<AnalysisResult>(
          this as AnalysisResult, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AnalysisResult &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.totalWords, totalWords) ||
                other.totalWords == totalWords) &&
            (identical(other.uniqueWords, uniqueWords) ||
                other.uniqueWords == uniqueWords) &&
            (identical(other.unknownWords, unknownWords) ||
                other.unknownWords == unknownWords) &&
            (identical(other.knownWords, knownWords) ||
                other.knownWords == knownWords) &&
            (identical(other.newWordsCount, newWordsCount) ||
                other.newWordsCount == newWordsCount) &&
            const DeepCollectionEquality().equals(other.words, words));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      totalWords,
      uniqueWords,
      unknownWords,
      knownWords,
      newWordsCount,
      const DeepCollectionEquality().hash(words));

  @override
  String toString() {
    return 'AnalysisResult(id: $id, title: $title, totalWords: $totalWords, uniqueWords: $uniqueWords, unknownWords: $unknownWords, knownWords: $knownWords, newWordsCount: $newWordsCount, words: $words)';
  }
}

/// @nodoc
abstract mixin class $AnalysisResultCopyWith<$Res> {
  factory $AnalysisResultCopyWith(
          AnalysisResult value, $Res Function(AnalysisResult) _then) =
      _$AnalysisResultCopyWithImpl;
  @useResult
  $Res call(
      {int id,
      String title,
      int totalWords,
      int uniqueWords,
      int unknownWords,
      int knownWords,
      int newWordsCount,
      List<WordWithLocalFreq> words});
}

/// @nodoc
class _$AnalysisResultCopyWithImpl<$Res>
    implements $AnalysisResultCopyWith<$Res> {
  _$AnalysisResultCopyWithImpl(this._self, this._then);

  final AnalysisResult _self;
  final $Res Function(AnalysisResult) _then;

  /// Create a copy of AnalysisResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? totalWords = null,
    Object? uniqueWords = null,
    Object? unknownWords = null,
    Object? knownWords = null,
    Object? newWordsCount = null,
    Object? words = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      totalWords: null == totalWords
          ? _self.totalWords
          : totalWords // ignore: cast_nullable_to_non_nullable
              as int,
      uniqueWords: null == uniqueWords
          ? _self.uniqueWords
          : uniqueWords // ignore: cast_nullable_to_non_nullable
              as int,
      unknownWords: null == unknownWords
          ? _self.unknownWords
          : unknownWords // ignore: cast_nullable_to_non_nullable
              as int,
      knownWords: null == knownWords
          ? _self.knownWords
          : knownWords // ignore: cast_nullable_to_non_nullable
              as int,
      newWordsCount: null == newWordsCount
          ? _self.newWordsCount
          : newWordsCount // ignore: cast_nullable_to_non_nullable
              as int,
      words: null == words
          ? _self.words
          : words // ignore: cast_nullable_to_non_nullable
              as List<WordWithLocalFreq>,
    ));
  }
}

/// Adds pattern-matching-related methods to [AnalysisResult].
extension AnalysisResultPatterns on AnalysisResult {
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
    TResult Function(_AnalysisResult value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AnalysisResult() when $default != null:
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
    TResult Function(_AnalysisResult value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AnalysisResult():
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
    TResult? Function(_AnalysisResult value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AnalysisResult() when $default != null:
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
            int id,
            String title,
            int totalWords,
            int uniqueWords,
            int unknownWords,
            int knownWords,
            int newWordsCount,
            List<WordWithLocalFreq> words)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AnalysisResult() when $default != null:
        return $default(
            _that.id,
            _that.title,
            _that.totalWords,
            _that.uniqueWords,
            _that.unknownWords,
            _that.knownWords,
            _that.newWordsCount,
            _that.words);
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
            int id,
            String title,
            int totalWords,
            int uniqueWords,
            int unknownWords,
            int knownWords,
            int newWordsCount,
            List<WordWithLocalFreq> words)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AnalysisResult():
        return $default(
            _that.id,
            _that.title,
            _that.totalWords,
            _that.uniqueWords,
            _that.unknownWords,
            _that.knownWords,
            _that.newWordsCount,
            _that.words);
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
            int id,
            String title,
            int totalWords,
            int uniqueWords,
            int unknownWords,
            int knownWords,
            int newWordsCount,
            List<WordWithLocalFreq> words)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AnalysisResult() when $default != null:
        return $default(
            _that.id,
            _that.title,
            _that.totalWords,
            _that.uniqueWords,
            _that.unknownWords,
            _that.knownWords,
            _that.newWordsCount,
            _that.words);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _AnalysisResult extends AnalysisResult {
  const _AnalysisResult(
      {required this.id,
      required this.title,
      required this.totalWords,
      required this.uniqueWords,
      required this.unknownWords,
      required this.knownWords,
      required this.newWordsCount,
      required final List<WordWithLocalFreq> words})
      : _words = words,
        super._();

  @override
  final int id;
  @override
  final String title;
  @override
  final int totalWords;
  @override
  final int uniqueWords;
  @override
  final int unknownWords;
  @override
  final int knownWords;
  @override
  final int newWordsCount;
  final List<WordWithLocalFreq> _words;
  @override
  List<WordWithLocalFreq> get words {
    if (_words is EqualUnmodifiableListView) return _words;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_words);
  }

  /// Create a copy of AnalysisResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AnalysisResultCopyWith<_AnalysisResult> get copyWith =>
      __$AnalysisResultCopyWithImpl<_AnalysisResult>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AnalysisResult &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.totalWords, totalWords) ||
                other.totalWords == totalWords) &&
            (identical(other.uniqueWords, uniqueWords) ||
                other.uniqueWords == uniqueWords) &&
            (identical(other.unknownWords, unknownWords) ||
                other.unknownWords == unknownWords) &&
            (identical(other.knownWords, knownWords) ||
                other.knownWords == knownWords) &&
            (identical(other.newWordsCount, newWordsCount) ||
                other.newWordsCount == newWordsCount) &&
            const DeepCollectionEquality().equals(other._words, _words));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      totalWords,
      uniqueWords,
      unknownWords,
      knownWords,
      newWordsCount,
      const DeepCollectionEquality().hash(_words));

  @override
  String toString() {
    return 'AnalysisResult(id: $id, title: $title, totalWords: $totalWords, uniqueWords: $uniqueWords, unknownWords: $unknownWords, knownWords: $knownWords, newWordsCount: $newWordsCount, words: $words)';
  }
}

/// @nodoc
abstract mixin class _$AnalysisResultCopyWith<$Res>
    implements $AnalysisResultCopyWith<$Res> {
  factory _$AnalysisResultCopyWith(
          _AnalysisResult value, $Res Function(_AnalysisResult) _then) =
      __$AnalysisResultCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int id,
      String title,
      int totalWords,
      int uniqueWords,
      int unknownWords,
      int knownWords,
      int newWordsCount,
      List<WordWithLocalFreq> words});
}

/// @nodoc
class __$AnalysisResultCopyWithImpl<$Res>
    implements _$AnalysisResultCopyWith<$Res> {
  __$AnalysisResultCopyWithImpl(this._self, this._then);

  final _AnalysisResult _self;
  final $Res Function(_AnalysisResult) _then;

  /// Create a copy of AnalysisResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? totalWords = null,
    Object? uniqueWords = null,
    Object? unknownWords = null,
    Object? knownWords = null,
    Object? newWordsCount = null,
    Object? words = null,
  }) {
    return _then(_AnalysisResult(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      totalWords: null == totalWords
          ? _self.totalWords
          : totalWords // ignore: cast_nullable_to_non_nullable
              as int,
      uniqueWords: null == uniqueWords
          ? _self.uniqueWords
          : uniqueWords // ignore: cast_nullable_to_non_nullable
              as int,
      unknownWords: null == unknownWords
          ? _self.unknownWords
          : unknownWords // ignore: cast_nullable_to_non_nullable
              as int,
      knownWords: null == knownWords
          ? _self.knownWords
          : knownWords // ignore: cast_nullable_to_non_nullable
              as int,
      newWordsCount: null == newWordsCount
          ? _self.newWordsCount
          : newWordsCount // ignore: cast_nullable_to_non_nullable
              as int,
      words: null == words
          ? _self._words
          : words // ignore: cast_nullable_to_non_nullable
              as List<WordWithLocalFreq>,
    ));
  }
}

// dart format on

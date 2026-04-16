// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'review_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReviewEvent {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is ReviewEvent);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'ReviewEvent()';
  }
}

/// @nodoc
class $ReviewEventCopyWith<$Res> {
  $ReviewEventCopyWith(ReviewEvent _, $Res Function(ReviewEvent) __);
}

/// Adds pattern-matching-related methods to [ReviewEvent].
extension ReviewEventPatterns on ReviewEvent {
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
    TResult Function(LoadDueReviews value)? loadDueReviews,
    TResult Function(SubmitReview value)? submitReview,
    TResult Function(SkipReview value)? skipReview,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case LoadDueReviews() when loadDueReviews != null:
        return loadDueReviews(_that);
      case SubmitReview() when submitReview != null:
        return submitReview(_that);
      case SkipReview() when skipReview != null:
        return skipReview(_that);
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
    required TResult Function(LoadDueReviews value) loadDueReviews,
    required TResult Function(SubmitReview value) submitReview,
    required TResult Function(SkipReview value) skipReview,
  }) {
    final _that = this;
    switch (_that) {
      case LoadDueReviews():
        return loadDueReviews(_that);
      case SubmitReview():
        return submitReview(_that);
      case SkipReview():
        return skipReview(_that);
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
    TResult? Function(LoadDueReviews value)? loadDueReviews,
    TResult? Function(SubmitReview value)? submitReview,
    TResult? Function(SkipReview value)? skipReview,
  }) {
    final _that = this;
    switch (_that) {
      case LoadDueReviews() when loadDueReviews != null:
        return loadDueReviews(_that);
      case SubmitReview() when submitReview != null:
        return submitReview(_that);
      case SkipReview() when skipReview != null:
        return skipReview(_that);
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
    TResult Function()? loadDueReviews,
    TResult Function(int wordId, int quality)? submitReview,
    TResult Function(int wordId)? skipReview,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case LoadDueReviews() when loadDueReviews != null:
        return loadDueReviews();
      case SubmitReview() when submitReview != null:
        return submitReview(_that.wordId, _that.quality);
      case SkipReview() when skipReview != null:
        return skipReview(_that.wordId);
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
    required TResult Function() loadDueReviews,
    required TResult Function(int wordId, int quality) submitReview,
    required TResult Function(int wordId) skipReview,
  }) {
    final _that = this;
    switch (_that) {
      case LoadDueReviews():
        return loadDueReviews();
      case SubmitReview():
        return submitReview(_that.wordId, _that.quality);
      case SkipReview():
        return skipReview(_that.wordId);
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
    TResult? Function()? loadDueReviews,
    TResult? Function(int wordId, int quality)? submitReview,
    TResult? Function(int wordId)? skipReview,
  }) {
    final _that = this;
    switch (_that) {
      case LoadDueReviews() when loadDueReviews != null:
        return loadDueReviews();
      case SubmitReview() when submitReview != null:
        return submitReview(_that.wordId, _that.quality);
      case SkipReview() when skipReview != null:
        return skipReview(_that.wordId);
      case _:
        return null;
    }
  }
}

/// @nodoc

class LoadDueReviews implements ReviewEvent {
  const LoadDueReviews();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is LoadDueReviews);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'ReviewEvent.loadDueReviews()';
  }
}

/// @nodoc

class SubmitReview implements ReviewEvent {
  const SubmitReview({required this.wordId, required this.quality});

  final int wordId;
  final int quality;

  /// Create a copy of ReviewEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SubmitReviewCopyWith<SubmitReview> get copyWith =>
      _$SubmitReviewCopyWithImpl<SubmitReview>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SubmitReview &&
            (identical(other.wordId, wordId) || other.wordId == wordId) &&
            (identical(other.quality, quality) || other.quality == quality));
  }

  @override
  int get hashCode => Object.hash(runtimeType, wordId, quality);

  @override
  String toString() {
    return 'ReviewEvent.submitReview(wordId: $wordId, quality: $quality)';
  }
}

/// @nodoc
abstract mixin class $SubmitReviewCopyWith<$Res>
    implements $ReviewEventCopyWith<$Res> {
  factory $SubmitReviewCopyWith(
          SubmitReview value, $Res Function(SubmitReview) _then) =
      _$SubmitReviewCopyWithImpl;
  @useResult
  $Res call({int wordId, int quality});
}

/// @nodoc
class _$SubmitReviewCopyWithImpl<$Res> implements $SubmitReviewCopyWith<$Res> {
  _$SubmitReviewCopyWithImpl(this._self, this._then);

  final SubmitReview _self;
  final $Res Function(SubmitReview) _then;

  /// Create a copy of ReviewEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? wordId = null,
    Object? quality = null,
  }) {
    return _then(SubmitReview(
      wordId: null == wordId
          ? _self.wordId
          : wordId // ignore: cast_nullable_to_non_nullable
              as int,
      quality: null == quality
          ? _self.quality
          : quality // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class SkipReview implements ReviewEvent {
  const SkipReview(this.wordId);

  final int wordId;

  /// Create a copy of ReviewEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SkipReviewCopyWith<SkipReview> get copyWith =>
      _$SkipReviewCopyWithImpl<SkipReview>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SkipReview &&
            (identical(other.wordId, wordId) || other.wordId == wordId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, wordId);

  @override
  String toString() {
    return 'ReviewEvent.skipReview(wordId: $wordId)';
  }
}

/// @nodoc
abstract mixin class $SkipReviewCopyWith<$Res>
    implements $ReviewEventCopyWith<$Res> {
  factory $SkipReviewCopyWith(
          SkipReview value, $Res Function(SkipReview) _then) =
      _$SkipReviewCopyWithImpl;
  @useResult
  $Res call({int wordId});
}

/// @nodoc
class _$SkipReviewCopyWithImpl<$Res> implements $SkipReviewCopyWith<$Res> {
  _$SkipReviewCopyWithImpl(this._self, this._then);

  final SkipReview _self;
  final $Res Function(SkipReview) _then;

  /// Create a copy of ReviewEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? wordId = null,
  }) {
    return _then(SkipReview(
      null == wordId
          ? _self.wordId
          : wordId // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'word_commands.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AddWordCommand {
  String get text;
  bool get isExcluded;

  /// Create a copy of AddWordCommand
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AddWordCommandCopyWith<AddWordCommand> get copyWith =>
      _$AddWordCommandCopyWithImpl<AddWordCommand>(
          this as AddWordCommand, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AddWordCommand &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.isExcluded, isExcluded) ||
                other.isExcluded == isExcluded));
  }

  @override
  int get hashCode => Object.hash(runtimeType, text, isExcluded);

  @override
  String toString() {
    return 'AddWordCommand(text: $text, isExcluded: $isExcluded)';
  }
}

/// @nodoc
abstract mixin class $AddWordCommandCopyWith<$Res> {
  factory $AddWordCommandCopyWith(
          AddWordCommand value, $Res Function(AddWordCommand) _then) =
      _$AddWordCommandCopyWithImpl;
  @useResult
  $Res call({String text, bool isExcluded});
}

/// @nodoc
class _$AddWordCommandCopyWithImpl<$Res>
    implements $AddWordCommandCopyWith<$Res> {
  _$AddWordCommandCopyWithImpl(this._self, this._then);

  final AddWordCommand _self;
  final $Res Function(AddWordCommand) _then;

  /// Create a copy of AddWordCommand
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? text = null,
    Object? isExcluded = null,
  }) {
    return _then(_self.copyWith(
      text: null == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      isExcluded: null == isExcluded
          ? _self.isExcluded
          : isExcluded // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [AddWordCommand].
extension AddWordCommandPatterns on AddWordCommand {
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
    TResult Function(_AddWordCommand value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AddWordCommand() when $default != null:
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
    TResult Function(_AddWordCommand value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AddWordCommand():
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
    TResult? Function(_AddWordCommand value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AddWordCommand() when $default != null:
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
    TResult Function(String text, bool isExcluded)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AddWordCommand() when $default != null:
        return $default(_that.text, _that.isExcluded);
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
    TResult Function(String text, bool isExcluded) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AddWordCommand():
        return $default(_that.text, _that.isExcluded);
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
    TResult? Function(String text, bool isExcluded)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AddWordCommand() when $default != null:
        return $default(_that.text, _that.isExcluded);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _AddWordCommand implements AddWordCommand {
  const _AddWordCommand({required this.text, this.isExcluded = false});

  @override
  final String text;
  @override
  @JsonKey()
  final bool isExcluded;

  /// Create a copy of AddWordCommand
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AddWordCommandCopyWith<_AddWordCommand> get copyWith =>
      __$AddWordCommandCopyWithImpl<_AddWordCommand>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AddWordCommand &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.isExcluded, isExcluded) ||
                other.isExcluded == isExcluded));
  }

  @override
  int get hashCode => Object.hash(runtimeType, text, isExcluded);

  @override
  String toString() {
    return 'AddWordCommand(text: $text, isExcluded: $isExcluded)';
  }
}

/// @nodoc
abstract mixin class _$AddWordCommandCopyWith<$Res>
    implements $AddWordCommandCopyWith<$Res> {
  factory _$AddWordCommandCopyWith(
          _AddWordCommand value, $Res Function(_AddWordCommand) _then) =
      __$AddWordCommandCopyWithImpl;
  @override
  @useResult
  $Res call({String text, bool isExcluded});
}

/// @nodoc
class __$AddWordCommandCopyWithImpl<$Res>
    implements _$AddWordCommandCopyWith<$Res> {
  __$AddWordCommandCopyWithImpl(this._self, this._then);

  final _AddWordCommand _self;
  final $Res Function(_AddWordCommand) _then;

  /// Create a copy of AddWordCommand
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? text = null,
    Object? isExcluded = null,
  }) {
    return _then(_AddWordCommand(
      text: null == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      isExcluded: null == isExcluded
          ? _self.isExcluded
          : isExcluded // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
mixin _$RestoreWordCommand {
  String get text;
  int get previousId;
  int get previousFrequency;
  bool get wasFullyDeleted;

  /// Create a copy of RestoreWordCommand
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RestoreWordCommandCopyWith<RestoreWordCommand> get copyWith =>
      _$RestoreWordCommandCopyWithImpl<RestoreWordCommand>(
          this as RestoreWordCommand, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RestoreWordCommand &&
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
    return 'RestoreWordCommand(text: $text, previousId: $previousId, previousFrequency: $previousFrequency, wasFullyDeleted: $wasFullyDeleted)';
  }
}

/// @nodoc
abstract mixin class $RestoreWordCommandCopyWith<$Res> {
  factory $RestoreWordCommandCopyWith(
          RestoreWordCommand value, $Res Function(RestoreWordCommand) _then) =
      _$RestoreWordCommandCopyWithImpl;
  @useResult
  $Res call(
      {String text,
      int previousId,
      int previousFrequency,
      bool wasFullyDeleted});
}

/// @nodoc
class _$RestoreWordCommandCopyWithImpl<$Res>
    implements $RestoreWordCommandCopyWith<$Res> {
  _$RestoreWordCommandCopyWithImpl(this._self, this._then);

  final RestoreWordCommand _self;
  final $Res Function(RestoreWordCommand) _then;

  /// Create a copy of RestoreWordCommand
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? text = null,
    Object? previousId = null,
    Object? previousFrequency = null,
    Object? wasFullyDeleted = null,
  }) {
    return _then(_self.copyWith(
      text: null == text
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

/// Adds pattern-matching-related methods to [RestoreWordCommand].
extension RestoreWordCommandPatterns on RestoreWordCommand {
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
    TResult Function(_RestoreWordCommand value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RestoreWordCommand() when $default != null:
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
    TResult Function(_RestoreWordCommand value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RestoreWordCommand():
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
    TResult? Function(_RestoreWordCommand value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RestoreWordCommand() when $default != null:
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
    TResult Function(String text, int previousId, int previousFrequency,
            bool wasFullyDeleted)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RestoreWordCommand() when $default != null:
        return $default(_that.text, _that.previousId, _that.previousFrequency,
            _that.wasFullyDeleted);
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
    TResult Function(String text, int previousId, int previousFrequency,
            bool wasFullyDeleted)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RestoreWordCommand():
        return $default(_that.text, _that.previousId, _that.previousFrequency,
            _that.wasFullyDeleted);
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
    TResult? Function(String text, int previousId, int previousFrequency,
            bool wasFullyDeleted)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RestoreWordCommand() when $default != null:
        return $default(_that.text, _that.previousId, _that.previousFrequency,
            _that.wasFullyDeleted);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _RestoreWordCommand implements RestoreWordCommand {
  const _RestoreWordCommand(
      {required this.text,
      required this.previousId,
      required this.previousFrequency,
      required this.wasFullyDeleted});

  @override
  final String text;
  @override
  final int previousId;
  @override
  final int previousFrequency;
  @override
  final bool wasFullyDeleted;

  /// Create a copy of RestoreWordCommand
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$RestoreWordCommandCopyWith<_RestoreWordCommand> get copyWith =>
      __$RestoreWordCommandCopyWithImpl<_RestoreWordCommand>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _RestoreWordCommand &&
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
    return 'RestoreWordCommand(text: $text, previousId: $previousId, previousFrequency: $previousFrequency, wasFullyDeleted: $wasFullyDeleted)';
  }
}

/// @nodoc
abstract mixin class _$RestoreWordCommandCopyWith<$Res>
    implements $RestoreWordCommandCopyWith<$Res> {
  factory _$RestoreWordCommandCopyWith(
          _RestoreWordCommand value, $Res Function(_RestoreWordCommand) _then) =
      __$RestoreWordCommandCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String text,
      int previousId,
      int previousFrequency,
      bool wasFullyDeleted});
}

/// @nodoc
class __$RestoreWordCommandCopyWithImpl<$Res>
    implements _$RestoreWordCommandCopyWith<$Res> {
  __$RestoreWordCommandCopyWithImpl(this._self, this._then);

  final _RestoreWordCommand _self;
  final $Res Function(_RestoreWordCommand) _then;

  /// Create a copy of RestoreWordCommand
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? text = null,
    Object? previousId = null,
    Object? previousFrequency = null,
    Object? wasFullyDeleted = null,
  }) {
    return _then(_RestoreWordCommand(
      text: null == text
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
mixin _$UpdateWordCommand {
  int get id;
  String? get text;
  String? get meaning;
  String? get description;
  List<String>? get definitions;
  List<String>? get examples;
  List<String>? get translations;
  List<String>? get synonyms;
  String? get category;
  bool? get isKnown;
  bool? get isExcluded;
  ReviewSchedule? get reviewSchedule;

  /// Create a copy of UpdateWordCommand
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $UpdateWordCommandCopyWith<UpdateWordCommand> get copyWith =>
      _$UpdateWordCommandCopyWithImpl<UpdateWordCommand>(
          this as UpdateWordCommand, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is UpdateWordCommand &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.meaning, meaning) || other.meaning == meaning) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other.definitions, definitions) &&
            const DeepCollectionEquality().equals(other.examples, examples) &&
            const DeepCollectionEquality()
                .equals(other.translations, translations) &&
            const DeepCollectionEquality().equals(other.synonyms, synonyms) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.isKnown, isKnown) || other.isKnown == isKnown) &&
            (identical(other.isExcluded, isExcluded) ||
                other.isExcluded == isExcluded) &&
            (identical(other.reviewSchedule, reviewSchedule) ||
                other.reviewSchedule == reviewSchedule));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      text,
      meaning,
      description,
      const DeepCollectionEquality().hash(definitions),
      const DeepCollectionEquality().hash(examples),
      const DeepCollectionEquality().hash(translations),
      const DeepCollectionEquality().hash(synonyms),
      category,
      isKnown,
      isExcluded,
      reviewSchedule);

  @override
  String toString() {
    return 'UpdateWordCommand(id: $id, text: $text, meaning: $meaning, description: $description, definitions: $definitions, examples: $examples, translations: $translations, synonyms: $synonyms, category: $category, isKnown: $isKnown, isExcluded: $isExcluded, reviewSchedule: $reviewSchedule)';
  }
}

/// @nodoc
abstract mixin class $UpdateWordCommandCopyWith<$Res> {
  factory $UpdateWordCommandCopyWith(
          UpdateWordCommand value, $Res Function(UpdateWordCommand) _then) =
      _$UpdateWordCommandCopyWithImpl;
  @useResult
  $Res call(
      {int id,
      String? text,
      String? meaning,
      String? description,
      List<String>? definitions,
      List<String>? examples,
      List<String>? translations,
      List<String>? synonyms,
      String? category,
      bool? isKnown,
      bool? isExcluded,
      ReviewSchedule? reviewSchedule});

  $ReviewScheduleCopyWith<$Res>? get reviewSchedule;
}

/// @nodoc
class _$UpdateWordCommandCopyWithImpl<$Res>
    implements $UpdateWordCommandCopyWith<$Res> {
  _$UpdateWordCommandCopyWithImpl(this._self, this._then);

  final UpdateWordCommand _self;
  final $Res Function(UpdateWordCommand) _then;

  /// Create a copy of UpdateWordCommand
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? text = freezed,
    Object? meaning = freezed,
    Object? description = freezed,
    Object? definitions = freezed,
    Object? examples = freezed,
    Object? translations = freezed,
    Object? synonyms = freezed,
    Object? category = freezed,
    Object? isKnown = freezed,
    Object? isExcluded = freezed,
    Object? reviewSchedule = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
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
          ? _self.definitions
          : definitions // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      examples: freezed == examples
          ? _self.examples
          : examples // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      translations: freezed == translations
          ? _self.translations
          : translations // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      synonyms: freezed == synonyms
          ? _self.synonyms
          : synonyms // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      category: freezed == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      isKnown: freezed == isKnown
          ? _self.isKnown
          : isKnown // ignore: cast_nullable_to_non_nullable
              as bool?,
      isExcluded: freezed == isExcluded
          ? _self.isExcluded
          : isExcluded // ignore: cast_nullable_to_non_nullable
              as bool?,
      reviewSchedule: freezed == reviewSchedule
          ? _self.reviewSchedule
          : reviewSchedule // ignore: cast_nullable_to_non_nullable
              as ReviewSchedule?,
    ));
  }

  /// Create a copy of UpdateWordCommand
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ReviewScheduleCopyWith<$Res>? get reviewSchedule {
    if (_self.reviewSchedule == null) {
      return null;
    }

    return $ReviewScheduleCopyWith<$Res>(_self.reviewSchedule!, (value) {
      return _then(_self.copyWith(reviewSchedule: value));
    });
  }
}

/// Adds pattern-matching-related methods to [UpdateWordCommand].
extension UpdateWordCommandPatterns on UpdateWordCommand {
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
    TResult Function(_UpdateWordCommand value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _UpdateWordCommand() when $default != null:
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
    TResult Function(_UpdateWordCommand value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UpdateWordCommand():
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
    TResult? Function(_UpdateWordCommand value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UpdateWordCommand() when $default != null:
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
            String? text,
            String? meaning,
            String? description,
            List<String>? definitions,
            List<String>? examples,
            List<String>? translations,
            List<String>? synonyms,
            String? category,
            bool? isKnown,
            bool? isExcluded,
            ReviewSchedule? reviewSchedule)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _UpdateWordCommand() when $default != null:
        return $default(
            _that.id,
            _that.text,
            _that.meaning,
            _that.description,
            _that.definitions,
            _that.examples,
            _that.translations,
            _that.synonyms,
            _that.category,
            _that.isKnown,
            _that.isExcluded,
            _that.reviewSchedule);
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
            String? text,
            String? meaning,
            String? description,
            List<String>? definitions,
            List<String>? examples,
            List<String>? translations,
            List<String>? synonyms,
            String? category,
            bool? isKnown,
            bool? isExcluded,
            ReviewSchedule? reviewSchedule)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UpdateWordCommand():
        return $default(
            _that.id,
            _that.text,
            _that.meaning,
            _that.description,
            _that.definitions,
            _that.examples,
            _that.translations,
            _that.synonyms,
            _that.category,
            _that.isKnown,
            _that.isExcluded,
            _that.reviewSchedule);
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
            String? text,
            String? meaning,
            String? description,
            List<String>? definitions,
            List<String>? examples,
            List<String>? translations,
            List<String>? synonyms,
            String? category,
            bool? isKnown,
            bool? isExcluded,
            ReviewSchedule? reviewSchedule)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UpdateWordCommand() when $default != null:
        return $default(
            _that.id,
            _that.text,
            _that.meaning,
            _that.description,
            _that.definitions,
            _that.examples,
            _that.translations,
            _that.synonyms,
            _that.category,
            _that.isKnown,
            _that.isExcluded,
            _that.reviewSchedule);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _UpdateWordCommand implements UpdateWordCommand {
  const _UpdateWordCommand(
      {required this.id,
      this.text,
      this.meaning,
      this.description,
      final List<String>? definitions,
      final List<String>? examples,
      final List<String>? translations,
      final List<String>? synonyms,
      this.category,
      this.isKnown,
      this.isExcluded,
      this.reviewSchedule})
      : _definitions = definitions,
        _examples = examples,
        _translations = translations,
        _synonyms = synonyms;

  @override
  final int id;
  @override
  final String? text;
  @override
  final String? meaning;
  @override
  final String? description;
  final List<String>? _definitions;
  @override
  List<String>? get definitions {
    final value = _definitions;
    if (value == null) return null;
    if (_definitions is EqualUnmodifiableListView) return _definitions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _examples;
  @override
  List<String>? get examples {
    final value = _examples;
    if (value == null) return null;
    if (_examples is EqualUnmodifiableListView) return _examples;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _translations;
  @override
  List<String>? get translations {
    final value = _translations;
    if (value == null) return null;
    if (_translations is EqualUnmodifiableListView) return _translations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _synonyms;
  @override
  List<String>? get synonyms {
    final value = _synonyms;
    if (value == null) return null;
    if (_synonyms is EqualUnmodifiableListView) return _synonyms;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? category;
  @override
  final bool? isKnown;
  @override
  final bool? isExcluded;
  @override
  final ReviewSchedule? reviewSchedule;

  /// Create a copy of UpdateWordCommand
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$UpdateWordCommandCopyWith<_UpdateWordCommand> get copyWith =>
      __$UpdateWordCommandCopyWithImpl<_UpdateWordCommand>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _UpdateWordCommand &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.meaning, meaning) || other.meaning == meaning) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other._definitions, _definitions) &&
            const DeepCollectionEquality().equals(other._examples, _examples) &&
            const DeepCollectionEquality()
                .equals(other._translations, _translations) &&
            const DeepCollectionEquality().equals(other._synonyms, _synonyms) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.isKnown, isKnown) || other.isKnown == isKnown) &&
            (identical(other.isExcluded, isExcluded) ||
                other.isExcluded == isExcluded) &&
            (identical(other.reviewSchedule, reviewSchedule) ||
                other.reviewSchedule == reviewSchedule));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      text,
      meaning,
      description,
      const DeepCollectionEquality().hash(_definitions),
      const DeepCollectionEquality().hash(_examples),
      const DeepCollectionEquality().hash(_translations),
      const DeepCollectionEquality().hash(_synonyms),
      category,
      isKnown,
      isExcluded,
      reviewSchedule);

  @override
  String toString() {
    return 'UpdateWordCommand(id: $id, text: $text, meaning: $meaning, description: $description, definitions: $definitions, examples: $examples, translations: $translations, synonyms: $synonyms, category: $category, isKnown: $isKnown, isExcluded: $isExcluded, reviewSchedule: $reviewSchedule)';
  }
}

/// @nodoc
abstract mixin class _$UpdateWordCommandCopyWith<$Res>
    implements $UpdateWordCommandCopyWith<$Res> {
  factory _$UpdateWordCommandCopyWith(
          _UpdateWordCommand value, $Res Function(_UpdateWordCommand) _then) =
      __$UpdateWordCommandCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int id,
      String? text,
      String? meaning,
      String? description,
      List<String>? definitions,
      List<String>? examples,
      List<String>? translations,
      List<String>? synonyms,
      String? category,
      bool? isKnown,
      bool? isExcluded,
      ReviewSchedule? reviewSchedule});

  @override
  $ReviewScheduleCopyWith<$Res>? get reviewSchedule;
}

/// @nodoc
class __$UpdateWordCommandCopyWithImpl<$Res>
    implements _$UpdateWordCommandCopyWith<$Res> {
  __$UpdateWordCommandCopyWithImpl(this._self, this._then);

  final _UpdateWordCommand _self;
  final $Res Function(_UpdateWordCommand) _then;

  /// Create a copy of UpdateWordCommand
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? text = freezed,
    Object? meaning = freezed,
    Object? description = freezed,
    Object? definitions = freezed,
    Object? examples = freezed,
    Object? translations = freezed,
    Object? synonyms = freezed,
    Object? category = freezed,
    Object? isKnown = freezed,
    Object? isExcluded = freezed,
    Object? reviewSchedule = freezed,
  }) {
    return _then(_UpdateWordCommand(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
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
      category: freezed == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      isKnown: freezed == isKnown
          ? _self.isKnown
          : isKnown // ignore: cast_nullable_to_non_nullable
              as bool?,
      isExcluded: freezed == isExcluded
          ? _self.isExcluded
          : isExcluded // ignore: cast_nullable_to_non_nullable
              as bool?,
      reviewSchedule: freezed == reviewSchedule
          ? _self.reviewSchedule
          : reviewSchedule // ignore: cast_nullable_to_non_nullable
              as ReviewSchedule?,
    ));
  }

  /// Create a copy of UpdateWordCommand
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ReviewScheduleCopyWith<$Res>? get reviewSchedule {
    if (_self.reviewSchedule == null) {
      return null;
    }

    return $ReviewScheduleCopyWith<$Res>(_self.reviewSchedule!, (value) {
      return _then(_self.copyWith(reviewSchedule: value));
    });
  }
}

// dart format on

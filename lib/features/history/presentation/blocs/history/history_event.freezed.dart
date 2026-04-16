// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'history_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HistoryEvent {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is HistoryEvent);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'HistoryEvent()';
  }
}

/// @nodoc
class $HistoryEventCopyWith<$Res> {
  $HistoryEventCopyWith(HistoryEvent _, $Res Function(HistoryEvent) __);
}

/// Adds pattern-matching-related methods to [HistoryEvent].
extension HistoryEventPatterns on HistoryEvent {
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
    TResult Function(LoadHistory value)? load,
    TResult Function(LoadMoreHistory value)? loadMore,
    TResult Function(HistoryUpdateReceived value)? updateReceived,
    TResult Function(HistoryErrorReceived value)? errorReceived,
    TResult Function(HistoryStatsUpdateReceived value)? statsUpdateReceived,
    TResult Function(DeleteHistoryItemEvent value)? deleteItem,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case LoadHistory() when load != null:
        return load(_that);
      case LoadMoreHistory() when loadMore != null:
        return loadMore(_that);
      case HistoryUpdateReceived() when updateReceived != null:
        return updateReceived(_that);
      case HistoryErrorReceived() when errorReceived != null:
        return errorReceived(_that);
      case HistoryStatsUpdateReceived() when statsUpdateReceived != null:
        return statsUpdateReceived(_that);
      case DeleteHistoryItemEvent() when deleteItem != null:
        return deleteItem(_that);
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
    required TResult Function(LoadHistory value) load,
    required TResult Function(LoadMoreHistory value) loadMore,
    required TResult Function(HistoryUpdateReceived value) updateReceived,
    required TResult Function(HistoryErrorReceived value) errorReceived,
    required TResult Function(HistoryStatsUpdateReceived value)
        statsUpdateReceived,
    required TResult Function(DeleteHistoryItemEvent value) deleteItem,
  }) {
    final _that = this;
    switch (_that) {
      case LoadHistory():
        return load(_that);
      case LoadMoreHistory():
        return loadMore(_that);
      case HistoryUpdateReceived():
        return updateReceived(_that);
      case HistoryErrorReceived():
        return errorReceived(_that);
      case HistoryStatsUpdateReceived():
        return statsUpdateReceived(_that);
      case DeleteHistoryItemEvent():
        return deleteItem(_that);
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
    TResult? Function(LoadHistory value)? load,
    TResult? Function(LoadMoreHistory value)? loadMore,
    TResult? Function(HistoryUpdateReceived value)? updateReceived,
    TResult? Function(HistoryErrorReceived value)? errorReceived,
    TResult? Function(HistoryStatsUpdateReceived value)? statsUpdateReceived,
    TResult? Function(DeleteHistoryItemEvent value)? deleteItem,
  }) {
    final _that = this;
    switch (_that) {
      case LoadHistory() when load != null:
        return load(_that);
      case LoadMoreHistory() when loadMore != null:
        return loadMore(_that);
      case HistoryUpdateReceived() when updateReceived != null:
        return updateReceived(_that);
      case HistoryErrorReceived() when errorReceived != null:
        return errorReceived(_that);
      case HistoryStatsUpdateReceived() when statsUpdateReceived != null:
        return statsUpdateReceived(_that);
      case DeleteHistoryItemEvent() when deleteItem != null:
        return deleteItem(_that);
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
    TResult Function()? loadMore,
    TResult Function(List<HistoryItem> items)? updateReceived,
    TResult Function(String message)? errorReceived,
    TResult Function()? statsUpdateReceived,
    TResult Function(int id, bool deleteUniqueWords)? deleteItem,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case LoadHistory() when load != null:
        return load();
      case LoadMoreHistory() when loadMore != null:
        return loadMore();
      case HistoryUpdateReceived() when updateReceived != null:
        return updateReceived(_that.items);
      case HistoryErrorReceived() when errorReceived != null:
        return errorReceived(_that.message);
      case HistoryStatsUpdateReceived() when statsUpdateReceived != null:
        return statsUpdateReceived();
      case DeleteHistoryItemEvent() when deleteItem != null:
        return deleteItem(_that.id, _that.deleteUniqueWords);
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
    required TResult Function() loadMore,
    required TResult Function(List<HistoryItem> items) updateReceived,
    required TResult Function(String message) errorReceived,
    required TResult Function() statsUpdateReceived,
    required TResult Function(int id, bool deleteUniqueWords) deleteItem,
  }) {
    final _that = this;
    switch (_that) {
      case LoadHistory():
        return load();
      case LoadMoreHistory():
        return loadMore();
      case HistoryUpdateReceived():
        return updateReceived(_that.items);
      case HistoryErrorReceived():
        return errorReceived(_that.message);
      case HistoryStatsUpdateReceived():
        return statsUpdateReceived();
      case DeleteHistoryItemEvent():
        return deleteItem(_that.id, _that.deleteUniqueWords);
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
    TResult? Function()? loadMore,
    TResult? Function(List<HistoryItem> items)? updateReceived,
    TResult? Function(String message)? errorReceived,
    TResult? Function()? statsUpdateReceived,
    TResult? Function(int id, bool deleteUniqueWords)? deleteItem,
  }) {
    final _that = this;
    switch (_that) {
      case LoadHistory() when load != null:
        return load();
      case LoadMoreHistory() when loadMore != null:
        return loadMore();
      case HistoryUpdateReceived() when updateReceived != null:
        return updateReceived(_that.items);
      case HistoryErrorReceived() when errorReceived != null:
        return errorReceived(_that.message);
      case HistoryStatsUpdateReceived() when statsUpdateReceived != null:
        return statsUpdateReceived();
      case DeleteHistoryItemEvent() when deleteItem != null:
        return deleteItem(_that.id, _that.deleteUniqueWords);
      case _:
        return null;
    }
  }
}

/// @nodoc

class LoadHistory implements HistoryEvent {
  const LoadHistory();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is LoadHistory);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'HistoryEvent.load()';
  }
}

/// @nodoc

class LoadMoreHistory implements HistoryEvent {
  const LoadMoreHistory();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is LoadMoreHistory);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'HistoryEvent.loadMore()';
  }
}

/// @nodoc

class HistoryUpdateReceived implements HistoryEvent {
  const HistoryUpdateReceived({required final List<HistoryItem> items})
      : _items = items;

  final List<HistoryItem> _items;
  List<HistoryItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  /// Create a copy of HistoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $HistoryUpdateReceivedCopyWith<HistoryUpdateReceived> get copyWith =>
      _$HistoryUpdateReceivedCopyWithImpl<HistoryUpdateReceived>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is HistoryUpdateReceived &&
            const DeepCollectionEquality().equals(other._items, _items));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_items));

  @override
  String toString() {
    return 'HistoryEvent.updateReceived(items: $items)';
  }
}

/// @nodoc
abstract mixin class $HistoryUpdateReceivedCopyWith<$Res>
    implements $HistoryEventCopyWith<$Res> {
  factory $HistoryUpdateReceivedCopyWith(HistoryUpdateReceived value,
          $Res Function(HistoryUpdateReceived) _then) =
      _$HistoryUpdateReceivedCopyWithImpl;
  @useResult
  $Res call({List<HistoryItem> items});
}

/// @nodoc
class _$HistoryUpdateReceivedCopyWithImpl<$Res>
    implements $HistoryUpdateReceivedCopyWith<$Res> {
  _$HistoryUpdateReceivedCopyWithImpl(this._self, this._then);

  final HistoryUpdateReceived _self;
  final $Res Function(HistoryUpdateReceived) _then;

  /// Create a copy of HistoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? items = null,
  }) {
    return _then(HistoryUpdateReceived(
      items: null == items
          ? _self._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<HistoryItem>,
    ));
  }
}

/// @nodoc

class HistoryErrorReceived implements HistoryEvent {
  const HistoryErrorReceived({required this.message});

  final String message;

  /// Create a copy of HistoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $HistoryErrorReceivedCopyWith<HistoryErrorReceived> get copyWith =>
      _$HistoryErrorReceivedCopyWithImpl<HistoryErrorReceived>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is HistoryErrorReceived &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @override
  String toString() {
    return 'HistoryEvent.errorReceived(message: $message)';
  }
}

/// @nodoc
abstract mixin class $HistoryErrorReceivedCopyWith<$Res>
    implements $HistoryEventCopyWith<$Res> {
  factory $HistoryErrorReceivedCopyWith(HistoryErrorReceived value,
          $Res Function(HistoryErrorReceived) _then) =
      _$HistoryErrorReceivedCopyWithImpl;
  @useResult
  $Res call({String message});
}

/// @nodoc
class _$HistoryErrorReceivedCopyWithImpl<$Res>
    implements $HistoryErrorReceivedCopyWith<$Res> {
  _$HistoryErrorReceivedCopyWithImpl(this._self, this._then);

  final HistoryErrorReceived _self;
  final $Res Function(HistoryErrorReceived) _then;

  /// Create a copy of HistoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
  }) {
    return _then(HistoryErrorReceived(
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class HistoryStatsUpdateReceived implements HistoryEvent {
  const HistoryStatsUpdateReceived();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is HistoryStatsUpdateReceived);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'HistoryEvent.statsUpdateReceived()';
  }
}

/// @nodoc

class DeleteHistoryItemEvent implements HistoryEvent {
  const DeleteHistoryItemEvent(this.id, {this.deleteUniqueWords = false});

  final int id;
  @JsonKey()
  final bool deleteUniqueWords;

  /// Create a copy of HistoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DeleteHistoryItemEventCopyWith<DeleteHistoryItemEvent> get copyWith =>
      _$DeleteHistoryItemEventCopyWithImpl<DeleteHistoryItemEvent>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DeleteHistoryItemEvent &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.deleteUniqueWords, deleteUniqueWords) ||
                other.deleteUniqueWords == deleteUniqueWords));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, deleteUniqueWords);

  @override
  String toString() {
    return 'HistoryEvent.deleteItem(id: $id, deleteUniqueWords: $deleteUniqueWords)';
  }
}

/// @nodoc
abstract mixin class $DeleteHistoryItemEventCopyWith<$Res>
    implements $HistoryEventCopyWith<$Res> {
  factory $DeleteHistoryItemEventCopyWith(DeleteHistoryItemEvent value,
          $Res Function(DeleteHistoryItemEvent) _then) =
      _$DeleteHistoryItemEventCopyWithImpl;
  @useResult
  $Res call({int id, bool deleteUniqueWords});
}

/// @nodoc
class _$DeleteHistoryItemEventCopyWithImpl<$Res>
    implements $DeleteHistoryItemEventCopyWith<$Res> {
  _$DeleteHistoryItemEventCopyWithImpl(this._self, this._then);

  final DeleteHistoryItemEvent _self;
  final $Res Function(DeleteHistoryItemEvent) _then;

  /// Create a copy of HistoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? deleteUniqueWords = null,
  }) {
    return _then(DeleteHistoryItemEvent(
      null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      deleteUniqueWords: null == deleteUniqueWords
          ? _self.deleteUniqueWords
          : deleteUniqueWords // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on

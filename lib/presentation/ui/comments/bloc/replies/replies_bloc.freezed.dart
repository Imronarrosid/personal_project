// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'replies_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RepliesState {
  RepliesStatus get status;
  List<Reply> get replies;
  bool get isLastReply;
  String? get errorMessage;

  /// Create a copy of RepliesState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RepliesStateCopyWith<RepliesState> get copyWith =>
      _$RepliesStateCopyWithImpl<RepliesState>(
          this as RepliesState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RepliesState &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other.replies, replies) &&
            (identical(other.isLastReply, isLastReply) ||
                other.isLastReply == isLastReply) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(runtimeType, status,
      const DeepCollectionEquality().hash(replies), isLastReply, errorMessage);

  @override
  String toString() {
    return 'RepliesState(status: $status, replies: $replies, isLastReply: $isLastReply, errorMessage: $errorMessage)';
  }
}

/// @nodoc
abstract mixin class $RepliesStateCopyWith<$Res> {
  factory $RepliesStateCopyWith(
          RepliesState value, $Res Function(RepliesState) _then) =
      _$RepliesStateCopyWithImpl;
  @useResult
  $Res call(
      {RepliesStatus status,
      List<Reply> replies,
      bool isLastReply,
      String? errorMessage});
}

/// @nodoc
class _$RepliesStateCopyWithImpl<$Res> implements $RepliesStateCopyWith<$Res> {
  _$RepliesStateCopyWithImpl(this._self, this._then);

  final RepliesState _self;
  final $Res Function(RepliesState) _then;

  /// Create a copy of RepliesState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? replies = null,
    Object? isLastReply = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_self.copyWith(
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as RepliesStatus,
      replies: null == replies
          ? _self.replies
          : replies // ignore: cast_nullable_to_non_nullable
              as List<Reply>,
      isLastReply: null == isLastReply
          ? _self.isLastReply
          : isLastReply // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _self.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [RepliesState].
extension RepliesStatePatterns on RepliesState {
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
    TResult Function(_RepliesState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RepliesState() when $default != null:
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
    TResult Function(_RepliesState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RepliesState():
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
    TResult? Function(_RepliesState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RepliesState() when $default != null:
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
    TResult Function(RepliesStatus status, List<Reply> replies,
            bool isLastReply, String? errorMessage)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RepliesState() when $default != null:
        return $default(
            _that.status, _that.replies, _that.isLastReply, _that.errorMessage);
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
    TResult Function(RepliesStatus status, List<Reply> replies,
            bool isLastReply, String? errorMessage)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RepliesState():
        return $default(
            _that.status, _that.replies, _that.isLastReply, _that.errorMessage);
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
    TResult? Function(RepliesStatus status, List<Reply> replies,
            bool isLastReply, String? errorMessage)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RepliesState() when $default != null:
        return $default(
            _that.status, _that.replies, _that.isLastReply, _that.errorMessage);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _RepliesState implements RepliesState {
  const _RepliesState(
      {this.status = RepliesStatus.initial,
      final List<Reply> replies = const <Reply>[],
      this.isLastReply = false,
      this.errorMessage})
      : _replies = replies;

  @override
  @JsonKey()
  final RepliesStatus status;
  final List<Reply> _replies;
  @override
  @JsonKey()
  List<Reply> get replies {
    if (_replies is EqualUnmodifiableListView) return _replies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_replies);
  }

  @override
  @JsonKey()
  final bool isLastReply;
  @override
  final String? errorMessage;

  /// Create a copy of RepliesState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$RepliesStateCopyWith<_RepliesState> get copyWith =>
      __$RepliesStateCopyWithImpl<_RepliesState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _RepliesState &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._replies, _replies) &&
            (identical(other.isLastReply, isLastReply) ||
                other.isLastReply == isLastReply) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(runtimeType, status,
      const DeepCollectionEquality().hash(_replies), isLastReply, errorMessage);

  @override
  String toString() {
    return 'RepliesState(status: $status, replies: $replies, isLastReply: $isLastReply, errorMessage: $errorMessage)';
  }
}

/// @nodoc
abstract mixin class _$RepliesStateCopyWith<$Res>
    implements $RepliesStateCopyWith<$Res> {
  factory _$RepliesStateCopyWith(
          _RepliesState value, $Res Function(_RepliesState) _then) =
      __$RepliesStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {RepliesStatus status,
      List<Reply> replies,
      bool isLastReply,
      String? errorMessage});
}

/// @nodoc
class __$RepliesStateCopyWithImpl<$Res>
    implements _$RepliesStateCopyWith<$Res> {
  __$RepliesStateCopyWithImpl(this._self, this._then);

  final _RepliesState _self;
  final $Res Function(_RepliesState) _then;

  /// Create a copy of RepliesState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? status = null,
    Object? replies = null,
    Object? isLastReply = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_RepliesState(
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as RepliesStatus,
      replies: null == replies
          ? _self._replies
          : replies // ignore: cast_nullable_to_non_nullable
              as List<Reply>,
      isLastReply: null == isLastReply
          ? _self.isLastReply
          : isLastReply // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _self.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
mixin _$RepliesEvent {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is RepliesEvent);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'RepliesEvent()';
  }
}

/// @nodoc
class $RepliesEventCopyWith<$Res> {
  $RepliesEventCopyWith(RepliesEvent _, $Res Function(RepliesEvent) __);
}

/// Adds pattern-matching-related methods to [RepliesEvent].
extension RepliesEventPatterns on RepliesEvent {
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
    TResult Function(_LoadRepliesEvent value)? loadReplies,
    TResult Function(_HideRepliesEvent value)? hideReplies,
    TResult Function(_AddReplyEvent value)? addReply,
    TResult Function(_RemoveReplyEvent value)? removeReply,
    TResult Function(_LikeReplyEvent value)? likeReply,
    TResult Function(_UpdateReplyEvent value)? updateReply,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LoadRepliesEvent() when loadReplies != null:
        return loadReplies(_that);
      case _HideRepliesEvent() when hideReplies != null:
        return hideReplies(_that);
      case _AddReplyEvent() when addReply != null:
        return addReply(_that);
      case _RemoveReplyEvent() when removeReply != null:
        return removeReply(_that);
      case _LikeReplyEvent() when likeReply != null:
        return likeReply(_that);
      case _UpdateReplyEvent() when updateReply != null:
        return updateReply(_that);
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
    required TResult Function(_LoadRepliesEvent value) loadReplies,
    required TResult Function(_HideRepliesEvent value) hideReplies,
    required TResult Function(_AddReplyEvent value) addReply,
    required TResult Function(_RemoveReplyEvent value) removeReply,
    required TResult Function(_LikeReplyEvent value) likeReply,
    required TResult Function(_UpdateReplyEvent value) updateReply,
  }) {
    final _that = this;
    switch (_that) {
      case _LoadRepliesEvent():
        return loadReplies(_that);
      case _HideRepliesEvent():
        return hideReplies(_that);
      case _AddReplyEvent():
        return addReply(_that);
      case _RemoveReplyEvent():
        return removeReply(_that);
      case _LikeReplyEvent():
        return likeReply(_that);
      case _UpdateReplyEvent():
        return updateReply(_that);
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
    TResult? Function(_LoadRepliesEvent value)? loadReplies,
    TResult? Function(_HideRepliesEvent value)? hideReplies,
    TResult? Function(_AddReplyEvent value)? addReply,
    TResult? Function(_RemoveReplyEvent value)? removeReply,
    TResult? Function(_LikeReplyEvent value)? likeReply,
    TResult? Function(_UpdateReplyEvent value)? updateReply,
  }) {
    final _that = this;
    switch (_that) {
      case _LoadRepliesEvent() when loadReplies != null:
        return loadReplies(_that);
      case _HideRepliesEvent() when hideReplies != null:
        return hideReplies(_that);
      case _AddReplyEvent() when addReply != null:
        return addReply(_that);
      case _RemoveReplyEvent() when removeReply != null:
        return removeReply(_that);
      case _LikeReplyEvent() when likeReply != null:
        return likeReply(_that);
      case _UpdateReplyEvent() when updateReply != null:
        return updateReply(_that);
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
    TResult Function(String postId, String commentId)? loadReplies,
    TResult Function()? hideReplies,
    TResult Function(String commentId, Reply reply)? addReply,
    TResult Function(String commentId, String replyId)? removeReply,
    TResult Function(
            String replyId, String postId, String commentId, bool isLiked)?
        likeReply,
    TResult Function(Reply reply)? updateReply,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LoadRepliesEvent() when loadReplies != null:
        return loadReplies(_that.postId, _that.commentId);
      case _HideRepliesEvent() when hideReplies != null:
        return hideReplies();
      case _AddReplyEvent() when addReply != null:
        return addReply(_that.commentId, _that.reply);
      case _RemoveReplyEvent() when removeReply != null:
        return removeReply(_that.commentId, _that.replyId);
      case _LikeReplyEvent() when likeReply != null:
        return likeReply(
            _that.replyId, _that.postId, _that.commentId, _that.isLiked);
      case _UpdateReplyEvent() when updateReply != null:
        return updateReply(_that.reply);
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
    required TResult Function(String postId, String commentId) loadReplies,
    required TResult Function() hideReplies,
    required TResult Function(String commentId, Reply reply) addReply,
    required TResult Function(String commentId, String replyId) removeReply,
    required TResult Function(
            String replyId, String postId, String commentId, bool isLiked)
        likeReply,
    required TResult Function(Reply reply) updateReply,
  }) {
    final _that = this;
    switch (_that) {
      case _LoadRepliesEvent():
        return loadReplies(_that.postId, _that.commentId);
      case _HideRepliesEvent():
        return hideReplies();
      case _AddReplyEvent():
        return addReply(_that.commentId, _that.reply);
      case _RemoveReplyEvent():
        return removeReply(_that.commentId, _that.replyId);
      case _LikeReplyEvent():
        return likeReply(
            _that.replyId, _that.postId, _that.commentId, _that.isLiked);
      case _UpdateReplyEvent():
        return updateReply(_that.reply);
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
    TResult? Function(String postId, String commentId)? loadReplies,
    TResult? Function()? hideReplies,
    TResult? Function(String commentId, Reply reply)? addReply,
    TResult? Function(String commentId, String replyId)? removeReply,
    TResult? Function(
            String replyId, String postId, String commentId, bool isLiked)?
        likeReply,
    TResult? Function(Reply reply)? updateReply,
  }) {
    final _that = this;
    switch (_that) {
      case _LoadRepliesEvent() when loadReplies != null:
        return loadReplies(_that.postId, _that.commentId);
      case _HideRepliesEvent() when hideReplies != null:
        return hideReplies();
      case _AddReplyEvent() when addReply != null:
        return addReply(_that.commentId, _that.reply);
      case _RemoveReplyEvent() when removeReply != null:
        return removeReply(_that.commentId, _that.replyId);
      case _LikeReplyEvent() when likeReply != null:
        return likeReply(
            _that.replyId, _that.postId, _that.commentId, _that.isLiked);
      case _UpdateReplyEvent() when updateReply != null:
        return updateReply(_that.reply);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _LoadRepliesEvent implements RepliesEvent {
  const _LoadRepliesEvent({required this.postId, required this.commentId});

  final String postId;
  final String commentId;

  /// Create a copy of RepliesEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$LoadRepliesEventCopyWith<_LoadRepliesEvent> get copyWith =>
      __$LoadRepliesEventCopyWithImpl<_LoadRepliesEvent>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _LoadRepliesEvent &&
            (identical(other.postId, postId) || other.postId == postId) &&
            (identical(other.commentId, commentId) ||
                other.commentId == commentId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, postId, commentId);

  @override
  String toString() {
    return 'RepliesEvent.loadReplies(postId: $postId, commentId: $commentId)';
  }
}

/// @nodoc
abstract mixin class _$LoadRepliesEventCopyWith<$Res>
    implements $RepliesEventCopyWith<$Res> {
  factory _$LoadRepliesEventCopyWith(
          _LoadRepliesEvent value, $Res Function(_LoadRepliesEvent) _then) =
      __$LoadRepliesEventCopyWithImpl;
  @useResult
  $Res call({String postId, String commentId});
}

/// @nodoc
class __$LoadRepliesEventCopyWithImpl<$Res>
    implements _$LoadRepliesEventCopyWith<$Res> {
  __$LoadRepliesEventCopyWithImpl(this._self, this._then);

  final _LoadRepliesEvent _self;
  final $Res Function(_LoadRepliesEvent) _then;

  /// Create a copy of RepliesEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? postId = null,
    Object? commentId = null,
  }) {
    return _then(_LoadRepliesEvent(
      postId: null == postId
          ? _self.postId
          : postId // ignore: cast_nullable_to_non_nullable
              as String,
      commentId: null == commentId
          ? _self.commentId
          : commentId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _HideRepliesEvent implements RepliesEvent {
  const _HideRepliesEvent();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _HideRepliesEvent);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'RepliesEvent.hideReplies()';
  }
}

/// @nodoc

class _AddReplyEvent implements RepliesEvent {
  const _AddReplyEvent({required this.commentId, required this.reply});

  final String commentId;
  final Reply reply;

  /// Create a copy of RepliesEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AddReplyEventCopyWith<_AddReplyEvent> get copyWith =>
      __$AddReplyEventCopyWithImpl<_AddReplyEvent>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AddReplyEvent &&
            (identical(other.commentId, commentId) ||
                other.commentId == commentId) &&
            (identical(other.reply, reply) || other.reply == reply));
  }

  @override
  int get hashCode => Object.hash(runtimeType, commentId, reply);

  @override
  String toString() {
    return 'RepliesEvent.addReply(commentId: $commentId, reply: $reply)';
  }
}

/// @nodoc
abstract mixin class _$AddReplyEventCopyWith<$Res>
    implements $RepliesEventCopyWith<$Res> {
  factory _$AddReplyEventCopyWith(
          _AddReplyEvent value, $Res Function(_AddReplyEvent) _then) =
      __$AddReplyEventCopyWithImpl;
  @useResult
  $Res call({String commentId, Reply reply});
}

/// @nodoc
class __$AddReplyEventCopyWithImpl<$Res>
    implements _$AddReplyEventCopyWith<$Res> {
  __$AddReplyEventCopyWithImpl(this._self, this._then);

  final _AddReplyEvent _self;
  final $Res Function(_AddReplyEvent) _then;

  /// Create a copy of RepliesEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? commentId = null,
    Object? reply = null,
  }) {
    return _then(_AddReplyEvent(
      commentId: null == commentId
          ? _self.commentId
          : commentId // ignore: cast_nullable_to_non_nullable
              as String,
      reply: null == reply
          ? _self.reply
          : reply // ignore: cast_nullable_to_non_nullable
              as Reply,
    ));
  }
}

/// @nodoc

class _RemoveReplyEvent implements RepliesEvent {
  const _RemoveReplyEvent({required this.commentId, required this.replyId});

  final String commentId;
  final String replyId;

  /// Create a copy of RepliesEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$RemoveReplyEventCopyWith<_RemoveReplyEvent> get copyWith =>
      __$RemoveReplyEventCopyWithImpl<_RemoveReplyEvent>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _RemoveReplyEvent &&
            (identical(other.commentId, commentId) ||
                other.commentId == commentId) &&
            (identical(other.replyId, replyId) || other.replyId == replyId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, commentId, replyId);

  @override
  String toString() {
    return 'RepliesEvent.removeReply(commentId: $commentId, replyId: $replyId)';
  }
}

/// @nodoc
abstract mixin class _$RemoveReplyEventCopyWith<$Res>
    implements $RepliesEventCopyWith<$Res> {
  factory _$RemoveReplyEventCopyWith(
          _RemoveReplyEvent value, $Res Function(_RemoveReplyEvent) _then) =
      __$RemoveReplyEventCopyWithImpl;
  @useResult
  $Res call({String commentId, String replyId});
}

/// @nodoc
class __$RemoveReplyEventCopyWithImpl<$Res>
    implements _$RemoveReplyEventCopyWith<$Res> {
  __$RemoveReplyEventCopyWithImpl(this._self, this._then);

  final _RemoveReplyEvent _self;
  final $Res Function(_RemoveReplyEvent) _then;

  /// Create a copy of RepliesEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? commentId = null,
    Object? replyId = null,
  }) {
    return _then(_RemoveReplyEvent(
      commentId: null == commentId
          ? _self.commentId
          : commentId // ignore: cast_nullable_to_non_nullable
              as String,
      replyId: null == replyId
          ? _self.replyId
          : replyId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _LikeReplyEvent implements RepliesEvent {
  const _LikeReplyEvent(
      {required this.replyId,
      required this.postId,
      required this.commentId,
      required this.isLiked});

  final String replyId;
  final String postId;
  final String commentId;
  final bool isLiked;

  /// Create a copy of RepliesEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$LikeReplyEventCopyWith<_LikeReplyEvent> get copyWith =>
      __$LikeReplyEventCopyWithImpl<_LikeReplyEvent>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _LikeReplyEvent &&
            (identical(other.replyId, replyId) || other.replyId == replyId) &&
            (identical(other.postId, postId) || other.postId == postId) &&
            (identical(other.commentId, commentId) ||
                other.commentId == commentId) &&
            (identical(other.isLiked, isLiked) || other.isLiked == isLiked));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, replyId, postId, commentId, isLiked);

  @override
  String toString() {
    return 'RepliesEvent.likeReply(replyId: $replyId, postId: $postId, commentId: $commentId, isLiked: $isLiked)';
  }
}

/// @nodoc
abstract mixin class _$LikeReplyEventCopyWith<$Res>
    implements $RepliesEventCopyWith<$Res> {
  factory _$LikeReplyEventCopyWith(
          _LikeReplyEvent value, $Res Function(_LikeReplyEvent) _then) =
      __$LikeReplyEventCopyWithImpl;
  @useResult
  $Res call({String replyId, String postId, String commentId, bool isLiked});
}

/// @nodoc
class __$LikeReplyEventCopyWithImpl<$Res>
    implements _$LikeReplyEventCopyWith<$Res> {
  __$LikeReplyEventCopyWithImpl(this._self, this._then);

  final _LikeReplyEvent _self;
  final $Res Function(_LikeReplyEvent) _then;

  /// Create a copy of RepliesEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? replyId = null,
    Object? postId = null,
    Object? commentId = null,
    Object? isLiked = null,
  }) {
    return _then(_LikeReplyEvent(
      replyId: null == replyId
          ? _self.replyId
          : replyId // ignore: cast_nullable_to_non_nullable
              as String,
      postId: null == postId
          ? _self.postId
          : postId // ignore: cast_nullable_to_non_nullable
              as String,
      commentId: null == commentId
          ? _self.commentId
          : commentId // ignore: cast_nullable_to_non_nullable
              as String,
      isLiked: null == isLiked
          ? _self.isLiked
          : isLiked // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _UpdateReplyEvent implements RepliesEvent {
  const _UpdateReplyEvent({required this.reply});

  final Reply reply;

  /// Create a copy of RepliesEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$UpdateReplyEventCopyWith<_UpdateReplyEvent> get copyWith =>
      __$UpdateReplyEventCopyWithImpl<_UpdateReplyEvent>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _UpdateReplyEvent &&
            (identical(other.reply, reply) || other.reply == reply));
  }

  @override
  int get hashCode => Object.hash(runtimeType, reply);

  @override
  String toString() {
    return 'RepliesEvent.updateReply(reply: $reply)';
  }
}

/// @nodoc
abstract mixin class _$UpdateReplyEventCopyWith<$Res>
    implements $RepliesEventCopyWith<$Res> {
  factory _$UpdateReplyEventCopyWith(
          _UpdateReplyEvent value, $Res Function(_UpdateReplyEvent) _then) =
      __$UpdateReplyEventCopyWithImpl;
  @useResult
  $Res call({Reply reply});
}

/// @nodoc
class __$UpdateReplyEventCopyWithImpl<$Res>
    implements _$UpdateReplyEventCopyWith<$Res> {
  __$UpdateReplyEventCopyWithImpl(this._self, this._then);

  final _UpdateReplyEvent _self;
  final $Res Function(_UpdateReplyEvent) _then;

  /// Create a copy of RepliesEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? reply = null,
  }) {
    return _then(_UpdateReplyEvent(
      reply: null == reply
          ? _self.reply
          : reply // ignore: cast_nullable_to_non_nullable
              as Reply,
    ));
  }
}

// dart format on

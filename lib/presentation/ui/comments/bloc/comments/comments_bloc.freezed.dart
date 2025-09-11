// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'comments_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CommentsState {
  CommentsStatus get status;
  List<Comment> get comments;

  /// Create a copy of CommentsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CommentsStateCopyWith<CommentsState> get copyWith =>
      _$CommentsStateCopyWithImpl<CommentsState>(
          this as CommentsState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CommentsState &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other.comments, comments));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, status, const DeepCollectionEquality().hash(comments));

  @override
  String toString() {
    return 'CommentsState(status: $status, comments: $comments)';
  }
}

/// @nodoc
abstract mixin class $CommentsStateCopyWith<$Res> {
  factory $CommentsStateCopyWith(
          CommentsState value, $Res Function(CommentsState) _then) =
      _$CommentsStateCopyWithImpl;
  @useResult
  $Res call({CommentsStatus status, List<Comment> comments});
}

/// @nodoc
class _$CommentsStateCopyWithImpl<$Res>
    implements $CommentsStateCopyWith<$Res> {
  _$CommentsStateCopyWithImpl(this._self, this._then);

  final CommentsState _self;
  final $Res Function(CommentsState) _then;

  /// Create a copy of CommentsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? comments = null,
  }) {
    return _then(_self.copyWith(
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as CommentsStatus,
      comments: null == comments
          ? _self.comments
          : comments // ignore: cast_nullable_to_non_nullable
              as List<Comment>,
    ));
  }
}

/// Adds pattern-matching-related methods to [CommentsState].
extension CommentsStatePatterns on CommentsState {
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
    TResult Function(_CommentsState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CommentsState() when $default != null:
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
    TResult Function(_CommentsState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CommentsState():
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
    TResult? Function(_CommentsState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CommentsState() when $default != null:
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
    TResult Function(CommentsStatus status, List<Comment> comments)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CommentsState() when $default != null:
        return $default(_that.status, _that.comments);
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
    TResult Function(CommentsStatus status, List<Comment> comments) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CommentsState():
        return $default(_that.status, _that.comments);
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
    TResult? Function(CommentsStatus status, List<Comment> comments)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CommentsState() when $default != null:
        return $default(_that.status, _that.comments);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _CommentsState implements CommentsState {
  const _CommentsState(
      {this.status = CommentsStatus.initial,
      final List<Comment> comments = const <Comment>[]})
      : _comments = comments;

  @override
  @JsonKey()
  final CommentsStatus status;
  final List<Comment> _comments;
  @override
  @JsonKey()
  List<Comment> get comments {
    if (_comments is EqualUnmodifiableListView) return _comments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_comments);
  }

  /// Create a copy of CommentsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CommentsStateCopyWith<_CommentsState> get copyWith =>
      __$CommentsStateCopyWithImpl<_CommentsState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CommentsState &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._comments, _comments));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, status, const DeepCollectionEquality().hash(_comments));

  @override
  String toString() {
    return 'CommentsState(status: $status, comments: $comments)';
  }
}

/// @nodoc
abstract mixin class _$CommentsStateCopyWith<$Res>
    implements $CommentsStateCopyWith<$Res> {
  factory _$CommentsStateCopyWith(
          _CommentsState value, $Res Function(_CommentsState) _then) =
      __$CommentsStateCopyWithImpl;
  @override
  @useResult
  $Res call({CommentsStatus status, List<Comment> comments});
}

/// @nodoc
class __$CommentsStateCopyWithImpl<$Res>
    implements _$CommentsStateCopyWith<$Res> {
  __$CommentsStateCopyWithImpl(this._self, this._then);

  final _CommentsState _self;
  final $Res Function(_CommentsState) _then;

  /// Create a copy of CommentsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? status = null,
    Object? comments = null,
  }) {
    return _then(_CommentsState(
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as CommentsStatus,
      comments: null == comments
          ? _self._comments
          : comments // ignore: cast_nullable_to_non_nullable
              as List<Comment>,
    ));
  }
}

/// @nodoc
mixin _$CommentsEvent {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is CommentsEvent);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'CommentsEvent()';
  }
}

/// @nodoc
class $CommentsEventCopyWith<$Res> {
  $CommentsEventCopyWith(CommentsEvent _, $Res Function(CommentsEvent) __);
}

/// Adds pattern-matching-related methods to [CommentsEvent].
extension CommentsEventPatterns on CommentsEvent {
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
    TResult Function(_LoadCommentsEvent value)? loadComments,
    TResult Function(_AddCommentEvent value)? addComment,
    TResult Function(_AddReplyEvent value)? addReply,
    TResult Function(_RemoveCommentEvent value)? removeComment,
    TResult Function(_LikeCommentEvent value)? likeComment,
    TResult Function(_UpdateCommentEvent value)? updateComment,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LoadCommentsEvent() when loadComments != null:
        return loadComments(_that);
      case _AddCommentEvent() when addComment != null:
        return addComment(_that);
      case _AddReplyEvent() when addReply != null:
        return addReply(_that);
      case _RemoveCommentEvent() when removeComment != null:
        return removeComment(_that);
      case _LikeCommentEvent() when likeComment != null:
        return likeComment(_that);
      case _UpdateCommentEvent() when updateComment != null:
        return updateComment(_that);
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
    required TResult Function(_LoadCommentsEvent value) loadComments,
    required TResult Function(_AddCommentEvent value) addComment,
    required TResult Function(_AddReplyEvent value) addReply,
    required TResult Function(_RemoveCommentEvent value) removeComment,
    required TResult Function(_LikeCommentEvent value) likeComment,
    required TResult Function(_UpdateCommentEvent value) updateComment,
  }) {
    final _that = this;
    switch (_that) {
      case _LoadCommentsEvent():
        return loadComments(_that);
      case _AddCommentEvent():
        return addComment(_that);
      case _AddReplyEvent():
        return addReply(_that);
      case _RemoveCommentEvent():
        return removeComment(_that);
      case _LikeCommentEvent():
        return likeComment(_that);
      case _UpdateCommentEvent():
        return updateComment(_that);
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
    TResult? Function(_LoadCommentsEvent value)? loadComments,
    TResult? Function(_AddCommentEvent value)? addComment,
    TResult? Function(_AddReplyEvent value)? addReply,
    TResult? Function(_RemoveCommentEvent value)? removeComment,
    TResult? Function(_LikeCommentEvent value)? likeComment,
    TResult? Function(_UpdateCommentEvent value)? updateComment,
  }) {
    final _that = this;
    switch (_that) {
      case _LoadCommentsEvent() when loadComments != null:
        return loadComments(_that);
      case _AddCommentEvent() when addComment != null:
        return addComment(_that);
      case _AddReplyEvent() when addReply != null:
        return addReply(_that);
      case _RemoveCommentEvent() when removeComment != null:
        return removeComment(_that);
      case _LikeCommentEvent() when likeComment != null:
        return likeComment(_that);
      case _UpdateCommentEvent() when updateComment != null:
        return updateComment(_that);
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
    TResult Function(String postId)? loadComments,
    TResult Function(Comment comment)? addComment,
    TResult Function(String commentId, Comment comment)? addReply,
    TResult Function(String commentId)? removeComment,
    TResult Function(String commentId, String postId, bool isLiked)?
        likeComment,
    TResult Function(Comment comment)? updateComment,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LoadCommentsEvent() when loadComments != null:
        return loadComments(_that.postId);
      case _AddCommentEvent() when addComment != null:
        return addComment(_that.comment);
      case _AddReplyEvent() when addReply != null:
        return addReply(_that.commentId, _that.comment);
      case _RemoveCommentEvent() when removeComment != null:
        return removeComment(_that.commentId);
      case _LikeCommentEvent() when likeComment != null:
        return likeComment(_that.commentId, _that.postId, _that.isLiked);
      case _UpdateCommentEvent() when updateComment != null:
        return updateComment(_that.comment);
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
    required TResult Function(String postId) loadComments,
    required TResult Function(Comment comment) addComment,
    required TResult Function(String commentId, Comment comment) addReply,
    required TResult Function(String commentId) removeComment,
    required TResult Function(String commentId, String postId, bool isLiked)
        likeComment,
    required TResult Function(Comment comment) updateComment,
  }) {
    final _that = this;
    switch (_that) {
      case _LoadCommentsEvent():
        return loadComments(_that.postId);
      case _AddCommentEvent():
        return addComment(_that.comment);
      case _AddReplyEvent():
        return addReply(_that.commentId, _that.comment);
      case _RemoveCommentEvent():
        return removeComment(_that.commentId);
      case _LikeCommentEvent():
        return likeComment(_that.commentId, _that.postId, _that.isLiked);
      case _UpdateCommentEvent():
        return updateComment(_that.comment);
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
    TResult? Function(String postId)? loadComments,
    TResult? Function(Comment comment)? addComment,
    TResult? Function(String commentId, Comment comment)? addReply,
    TResult? Function(String commentId)? removeComment,
    TResult? Function(String commentId, String postId, bool isLiked)?
        likeComment,
    TResult? Function(Comment comment)? updateComment,
  }) {
    final _that = this;
    switch (_that) {
      case _LoadCommentsEvent() when loadComments != null:
        return loadComments(_that.postId);
      case _AddCommentEvent() when addComment != null:
        return addComment(_that.comment);
      case _AddReplyEvent() when addReply != null:
        return addReply(_that.commentId, _that.comment);
      case _RemoveCommentEvent() when removeComment != null:
        return removeComment(_that.commentId);
      case _LikeCommentEvent() when likeComment != null:
        return likeComment(_that.commentId, _that.postId, _that.isLiked);
      case _UpdateCommentEvent() when updateComment != null:
        return updateComment(_that.comment);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _LoadCommentsEvent implements CommentsEvent {
  const _LoadCommentsEvent({required this.postId});

  final String postId;

  /// Create a copy of CommentsEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$LoadCommentsEventCopyWith<_LoadCommentsEvent> get copyWith =>
      __$LoadCommentsEventCopyWithImpl<_LoadCommentsEvent>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _LoadCommentsEvent &&
            (identical(other.postId, postId) || other.postId == postId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, postId);

  @override
  String toString() {
    return 'CommentsEvent.loadComments(postId: $postId)';
  }
}

/// @nodoc
abstract mixin class _$LoadCommentsEventCopyWith<$Res>
    implements $CommentsEventCopyWith<$Res> {
  factory _$LoadCommentsEventCopyWith(
          _LoadCommentsEvent value, $Res Function(_LoadCommentsEvent) _then) =
      __$LoadCommentsEventCopyWithImpl;
  @useResult
  $Res call({String postId});
}

/// @nodoc
class __$LoadCommentsEventCopyWithImpl<$Res>
    implements _$LoadCommentsEventCopyWith<$Res> {
  __$LoadCommentsEventCopyWithImpl(this._self, this._then);

  final _LoadCommentsEvent _self;
  final $Res Function(_LoadCommentsEvent) _then;

  /// Create a copy of CommentsEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? postId = null,
  }) {
    return _then(_LoadCommentsEvent(
      postId: null == postId
          ? _self.postId
          : postId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _AddCommentEvent implements CommentsEvent {
  const _AddCommentEvent({required this.comment});

  final Comment comment;

  /// Create a copy of CommentsEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AddCommentEventCopyWith<_AddCommentEvent> get copyWith =>
      __$AddCommentEventCopyWithImpl<_AddCommentEvent>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AddCommentEvent &&
            (identical(other.comment, comment) || other.comment == comment));
  }

  @override
  int get hashCode => Object.hash(runtimeType, comment);

  @override
  String toString() {
    return 'CommentsEvent.addComment(comment: $comment)';
  }
}

/// @nodoc
abstract mixin class _$AddCommentEventCopyWith<$Res>
    implements $CommentsEventCopyWith<$Res> {
  factory _$AddCommentEventCopyWith(
          _AddCommentEvent value, $Res Function(_AddCommentEvent) _then) =
      __$AddCommentEventCopyWithImpl;
  @useResult
  $Res call({Comment comment});
}

/// @nodoc
class __$AddCommentEventCopyWithImpl<$Res>
    implements _$AddCommentEventCopyWith<$Res> {
  __$AddCommentEventCopyWithImpl(this._self, this._then);

  final _AddCommentEvent _self;
  final $Res Function(_AddCommentEvent) _then;

  /// Create a copy of CommentsEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? comment = null,
  }) {
    return _then(_AddCommentEvent(
      comment: null == comment
          ? _self.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as Comment,
    ));
  }
}

/// @nodoc

class _AddReplyEvent implements CommentsEvent {
  const _AddReplyEvent({required this.commentId, required this.comment});

  final String commentId;
  final Comment comment;

  /// Create a copy of CommentsEvent
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
            (identical(other.comment, comment) || other.comment == comment));
  }

  @override
  int get hashCode => Object.hash(runtimeType, commentId, comment);

  @override
  String toString() {
    return 'CommentsEvent.addReply(commentId: $commentId, comment: $comment)';
  }
}

/// @nodoc
abstract mixin class _$AddReplyEventCopyWith<$Res>
    implements $CommentsEventCopyWith<$Res> {
  factory _$AddReplyEventCopyWith(
          _AddReplyEvent value, $Res Function(_AddReplyEvent) _then) =
      __$AddReplyEventCopyWithImpl;
  @useResult
  $Res call({String commentId, Comment comment});
}

/// @nodoc
class __$AddReplyEventCopyWithImpl<$Res>
    implements _$AddReplyEventCopyWith<$Res> {
  __$AddReplyEventCopyWithImpl(this._self, this._then);

  final _AddReplyEvent _self;
  final $Res Function(_AddReplyEvent) _then;

  /// Create a copy of CommentsEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? commentId = null,
    Object? comment = null,
  }) {
    return _then(_AddReplyEvent(
      commentId: null == commentId
          ? _self.commentId
          : commentId // ignore: cast_nullable_to_non_nullable
              as String,
      comment: null == comment
          ? _self.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as Comment,
    ));
  }
}

/// @nodoc

class _RemoveCommentEvent implements CommentsEvent {
  const _RemoveCommentEvent({required this.commentId});

  final String commentId;

  /// Create a copy of CommentsEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$RemoveCommentEventCopyWith<_RemoveCommentEvent> get copyWith =>
      __$RemoveCommentEventCopyWithImpl<_RemoveCommentEvent>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _RemoveCommentEvent &&
            (identical(other.commentId, commentId) ||
                other.commentId == commentId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, commentId);

  @override
  String toString() {
    return 'CommentsEvent.removeComment(commentId: $commentId)';
  }
}

/// @nodoc
abstract mixin class _$RemoveCommentEventCopyWith<$Res>
    implements $CommentsEventCopyWith<$Res> {
  factory _$RemoveCommentEventCopyWith(
          _RemoveCommentEvent value, $Res Function(_RemoveCommentEvent) _then) =
      __$RemoveCommentEventCopyWithImpl;
  @useResult
  $Res call({String commentId});
}

/// @nodoc
class __$RemoveCommentEventCopyWithImpl<$Res>
    implements _$RemoveCommentEventCopyWith<$Res> {
  __$RemoveCommentEventCopyWithImpl(this._self, this._then);

  final _RemoveCommentEvent _self;
  final $Res Function(_RemoveCommentEvent) _then;

  /// Create a copy of CommentsEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? commentId = null,
  }) {
    return _then(_RemoveCommentEvent(
      commentId: null == commentId
          ? _self.commentId
          : commentId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _LikeCommentEvent implements CommentsEvent {
  const _LikeCommentEvent(
      {required this.commentId, required this.postId, required this.isLiked});

  final String commentId;
  final String postId;
  final bool isLiked;

  /// Create a copy of CommentsEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$LikeCommentEventCopyWith<_LikeCommentEvent> get copyWith =>
      __$LikeCommentEventCopyWithImpl<_LikeCommentEvent>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _LikeCommentEvent &&
            (identical(other.commentId, commentId) ||
                other.commentId == commentId) &&
            (identical(other.postId, postId) || other.postId == postId) &&
            (identical(other.isLiked, isLiked) || other.isLiked == isLiked));
  }

  @override
  int get hashCode => Object.hash(runtimeType, commentId, postId, isLiked);

  @override
  String toString() {
    return 'CommentsEvent.likeComment(commentId: $commentId, postId: $postId, isLiked: $isLiked)';
  }
}

/// @nodoc
abstract mixin class _$LikeCommentEventCopyWith<$Res>
    implements $CommentsEventCopyWith<$Res> {
  factory _$LikeCommentEventCopyWith(
          _LikeCommentEvent value, $Res Function(_LikeCommentEvent) _then) =
      __$LikeCommentEventCopyWithImpl;
  @useResult
  $Res call({String commentId, String postId, bool isLiked});
}

/// @nodoc
class __$LikeCommentEventCopyWithImpl<$Res>
    implements _$LikeCommentEventCopyWith<$Res> {
  __$LikeCommentEventCopyWithImpl(this._self, this._then);

  final _LikeCommentEvent _self;
  final $Res Function(_LikeCommentEvent) _then;

  /// Create a copy of CommentsEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? commentId = null,
    Object? postId = null,
    Object? isLiked = null,
  }) {
    return _then(_LikeCommentEvent(
      commentId: null == commentId
          ? _self.commentId
          : commentId // ignore: cast_nullable_to_non_nullable
              as String,
      postId: null == postId
          ? _self.postId
          : postId // ignore: cast_nullable_to_non_nullable
              as String,
      isLiked: null == isLiked
          ? _self.isLiked
          : isLiked // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _UpdateCommentEvent implements CommentsEvent {
  const _UpdateCommentEvent({required this.comment});

  final Comment comment;

  /// Create a copy of CommentsEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$UpdateCommentEventCopyWith<_UpdateCommentEvent> get copyWith =>
      __$UpdateCommentEventCopyWithImpl<_UpdateCommentEvent>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _UpdateCommentEvent &&
            (identical(other.comment, comment) || other.comment == comment));
  }

  @override
  int get hashCode => Object.hash(runtimeType, comment);

  @override
  String toString() {
    return 'CommentsEvent.updateComment(comment: $comment)';
  }
}

/// @nodoc
abstract mixin class _$UpdateCommentEventCopyWith<$Res>
    implements $CommentsEventCopyWith<$Res> {
  factory _$UpdateCommentEventCopyWith(
          _UpdateCommentEvent value, $Res Function(_UpdateCommentEvent) _then) =
      __$UpdateCommentEventCopyWithImpl;
  @useResult
  $Res call({Comment comment});
}

/// @nodoc
class __$UpdateCommentEventCopyWithImpl<$Res>
    implements _$UpdateCommentEventCopyWith<$Res> {
  __$UpdateCommentEventCopyWithImpl(this._self, this._then);

  final _UpdateCommentEvent _self;
  final $Res Function(_UpdateCommentEvent) _then;

  /// Create a copy of CommentsEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? comment = null,
  }) {
    return _then(_UpdateCommentEvent(
      comment: null == comment
          ? _self.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as Comment,
    ));
  }
}

// dart format on

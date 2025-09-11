// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'comment_input_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CommentInputState {
  CommentInputStatus get status;
  String get text;
  Comment? get comment;
  bool get isReply;
  String? get postId;
  String? get repliedUserName;
  String? get repliedCommentId;
  String? get repliedUserId;

  /// Create a copy of CommentInputState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CommentInputStateCopyWith<CommentInputState> get copyWith =>
      _$CommentInputStateCopyWithImpl<CommentInputState>(
          this as CommentInputState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CommentInputState &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            (identical(other.isReply, isReply) || other.isReply == isReply) &&
            (identical(other.postId, postId) || other.postId == postId) &&
            (identical(other.repliedUserName, repliedUserName) ||
                other.repliedUserName == repliedUserName) &&
            (identical(other.repliedCommentId, repliedCommentId) ||
                other.repliedCommentId == repliedCommentId) &&
            (identical(other.repliedUserId, repliedUserId) ||
                other.repliedUserId == repliedUserId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, status, text, comment, isReply,
      postId, repliedUserName, repliedCommentId, repliedUserId);

  @override
  String toString() {
    return 'CommentInputState(status: $status, text: $text, comment: $comment, isReply: $isReply, postId: $postId, repliedUserName: $repliedUserName, repliedCommentId: $repliedCommentId, repliedUserId: $repliedUserId)';
  }
}

/// @nodoc
abstract mixin class $CommentInputStateCopyWith<$Res> {
  factory $CommentInputStateCopyWith(
          CommentInputState value, $Res Function(CommentInputState) _then) =
      _$CommentInputStateCopyWithImpl;
  @useResult
  $Res call(
      {CommentInputStatus status,
      String text,
      Comment? comment,
      bool isReply,
      String? postId,
      String? repliedUserName,
      String? repliedCommentId,
      String? repliedUserId});
}

/// @nodoc
class _$CommentInputStateCopyWithImpl<$Res>
    implements $CommentInputStateCopyWith<$Res> {
  _$CommentInputStateCopyWithImpl(this._self, this._then);

  final CommentInputState _self;
  final $Res Function(CommentInputState) _then;

  /// Create a copy of CommentInputState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? text = null,
    Object? comment = freezed,
    Object? isReply = null,
    Object? postId = freezed,
    Object? repliedUserName = freezed,
    Object? repliedCommentId = freezed,
    Object? repliedUserId = freezed,
  }) {
    return _then(_self.copyWith(
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as CommentInputStatus,
      text: null == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      comment: freezed == comment
          ? _self.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as Comment?,
      isReply: null == isReply
          ? _self.isReply
          : isReply // ignore: cast_nullable_to_non_nullable
              as bool,
      postId: freezed == postId
          ? _self.postId
          : postId // ignore: cast_nullable_to_non_nullable
              as String?,
      repliedUserName: freezed == repliedUserName
          ? _self.repliedUserName
          : repliedUserName // ignore: cast_nullable_to_non_nullable
              as String?,
      repliedCommentId: freezed == repliedCommentId
          ? _self.repliedCommentId
          : repliedCommentId // ignore: cast_nullable_to_non_nullable
              as String?,
      repliedUserId: freezed == repliedUserId
          ? _self.repliedUserId
          : repliedUserId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [CommentInputState].
extension CommentInputStatePatterns on CommentInputState {
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
    TResult Function(_CommentInputState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CommentInputState() when $default != null:
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
    TResult Function(_CommentInputState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CommentInputState():
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
    TResult? Function(_CommentInputState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CommentInputState() when $default != null:
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
            CommentInputStatus status,
            String text,
            Comment? comment,
            bool isReply,
            String? postId,
            String? repliedUserName,
            String? repliedCommentId,
            String? repliedUserId)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CommentInputState() when $default != null:
        return $default(
            _that.status,
            _that.text,
            _that.comment,
            _that.isReply,
            _that.postId,
            _that.repliedUserName,
            _that.repliedCommentId,
            _that.repliedUserId);
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
            CommentInputStatus status,
            String text,
            Comment? comment,
            bool isReply,
            String? postId,
            String? repliedUserName,
            String? repliedCommentId,
            String? repliedUserId)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CommentInputState():
        return $default(
            _that.status,
            _that.text,
            _that.comment,
            _that.isReply,
            _that.postId,
            _that.repliedUserName,
            _that.repliedCommentId,
            _that.repliedUserId);
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
            CommentInputStatus status,
            String text,
            Comment? comment,
            bool isReply,
            String? postId,
            String? repliedUserName,
            String? repliedCommentId,
            String? repliedUserId)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CommentInputState() when $default != null:
        return $default(
            _that.status,
            _that.text,
            _that.comment,
            _that.isReply,
            _that.postId,
            _that.repliedUserName,
            _that.repliedCommentId,
            _that.repliedUserId);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _CommentInputState implements CommentInputState {
  const _CommentInputState(
      {this.status = CommentInputStatus.initial,
      this.text = '',
      this.comment,
      this.isReply = false,
      this.postId,
      this.repliedUserName,
      this.repliedCommentId,
      this.repliedUserId});

  @override
  @JsonKey()
  final CommentInputStatus status;
  @override
  @JsonKey()
  final String text;
  @override
  final Comment? comment;
  @override
  @JsonKey()
  final bool isReply;
  @override
  final String? postId;
  @override
  final String? repliedUserName;
  @override
  final String? repliedCommentId;
  @override
  final String? repliedUserId;

  /// Create a copy of CommentInputState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CommentInputStateCopyWith<_CommentInputState> get copyWith =>
      __$CommentInputStateCopyWithImpl<_CommentInputState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CommentInputState &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            (identical(other.isReply, isReply) || other.isReply == isReply) &&
            (identical(other.postId, postId) || other.postId == postId) &&
            (identical(other.repliedUserName, repliedUserName) ||
                other.repliedUserName == repliedUserName) &&
            (identical(other.repliedCommentId, repliedCommentId) ||
                other.repliedCommentId == repliedCommentId) &&
            (identical(other.repliedUserId, repliedUserId) ||
                other.repliedUserId == repliedUserId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, status, text, comment, isReply,
      postId, repliedUserName, repliedCommentId, repliedUserId);

  @override
  String toString() {
    return 'CommentInputState(status: $status, text: $text, comment: $comment, isReply: $isReply, postId: $postId, repliedUserName: $repliedUserName, repliedCommentId: $repliedCommentId, repliedUserId: $repliedUserId)';
  }
}

/// @nodoc
abstract mixin class _$CommentInputStateCopyWith<$Res>
    implements $CommentInputStateCopyWith<$Res> {
  factory _$CommentInputStateCopyWith(
          _CommentInputState value, $Res Function(_CommentInputState) _then) =
      __$CommentInputStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {CommentInputStatus status,
      String text,
      Comment? comment,
      bool isReply,
      String? postId,
      String? repliedUserName,
      String? repliedCommentId,
      String? repliedUserId});
}

/// @nodoc
class __$CommentInputStateCopyWithImpl<$Res>
    implements _$CommentInputStateCopyWith<$Res> {
  __$CommentInputStateCopyWithImpl(this._self, this._then);

  final _CommentInputState _self;
  final $Res Function(_CommentInputState) _then;

  /// Create a copy of CommentInputState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? status = null,
    Object? text = null,
    Object? comment = freezed,
    Object? isReply = null,
    Object? postId = freezed,
    Object? repliedUserName = freezed,
    Object? repliedCommentId = freezed,
    Object? repliedUserId = freezed,
  }) {
    return _then(_CommentInputState(
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as CommentInputStatus,
      text: null == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      comment: freezed == comment
          ? _self.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as Comment?,
      isReply: null == isReply
          ? _self.isReply
          : isReply // ignore: cast_nullable_to_non_nullable
              as bool,
      postId: freezed == postId
          ? _self.postId
          : postId // ignore: cast_nullable_to_non_nullable
              as String?,
      repliedUserName: freezed == repliedUserName
          ? _self.repliedUserName
          : repliedUserName // ignore: cast_nullable_to_non_nullable
              as String?,
      repliedCommentId: freezed == repliedCommentId
          ? _self.repliedCommentId
          : repliedCommentId // ignore: cast_nullable_to_non_nullable
              as String?,
      repliedUserId: freezed == repliedUserId
          ? _self.repliedUserId
          : repliedUserId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
mixin _$CommentInputEvent {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is CommentInputEvent);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'CommentInputEvent()';
  }
}

/// @nodoc
class $CommentInputEventCopyWith<$Res> {
  $CommentInputEventCopyWith(
      CommentInputEvent _, $Res Function(CommentInputEvent) __);
}

/// Adds pattern-matching-related methods to [CommentInputEvent].
extension CommentInputEventPatterns on CommentInputEvent {
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
    TResult Function(_OpenInput value)? openIput,
    TResult Function(_TextChanged value)? textChanged,
    TResult Function(_SubmitComment value)? submitComment,
    TResult Function(_SubmitReply value)? submitReply,
    TResult Function(_ClearInput value)? clearInput,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OpenInput() when openIput != null:
        return openIput(_that);
      case _TextChanged() when textChanged != null:
        return textChanged(_that);
      case _SubmitComment() when submitComment != null:
        return submitComment(_that);
      case _SubmitReply() when submitReply != null:
        return submitReply(_that);
      case _ClearInput() when clearInput != null:
        return clearInput(_that);
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
    required TResult Function(_OpenInput value) openIput,
    required TResult Function(_TextChanged value) textChanged,
    required TResult Function(_SubmitComment value) submitComment,
    required TResult Function(_SubmitReply value) submitReply,
    required TResult Function(_ClearInput value) clearInput,
  }) {
    final _that = this;
    switch (_that) {
      case _OpenInput():
        return openIput(_that);
      case _TextChanged():
        return textChanged(_that);
      case _SubmitComment():
        return submitComment(_that);
      case _SubmitReply():
        return submitReply(_that);
      case _ClearInput():
        return clearInput(_that);
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
    TResult? Function(_OpenInput value)? openIput,
    TResult? Function(_TextChanged value)? textChanged,
    TResult? Function(_SubmitComment value)? submitComment,
    TResult? Function(_SubmitReply value)? submitReply,
    TResult? Function(_ClearInput value)? clearInput,
  }) {
    final _that = this;
    switch (_that) {
      case _OpenInput() when openIput != null:
        return openIput(_that);
      case _TextChanged() when textChanged != null:
        return textChanged(_that);
      case _SubmitComment() when submitComment != null:
        return submitComment(_that);
      case _SubmitReply() when submitReply != null:
        return submitReply(_that);
      case _ClearInput() when clearInput != null:
        return clearInput(_that);
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
    TResult Function(String postId, bool isReply, String? repliedUserName,
            String? repliedCommentId, String? repliedUserId)?
        openIput,
    TResult Function(String text)? textChanged,
    TResult Function(String commentMessage)? submitComment,
    TResult Function(String commentMessage)? submitReply,
    TResult Function()? clearInput,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OpenInput() when openIput != null:
        return openIput(_that.postId, _that.isReply, _that.repliedUserName,
            _that.repliedCommentId, _that.repliedUserId);
      case _TextChanged() when textChanged != null:
        return textChanged(_that.text);
      case _SubmitComment() when submitComment != null:
        return submitComment(_that.commentMessage);
      case _SubmitReply() when submitReply != null:
        return submitReply(_that.commentMessage);
      case _ClearInput() when clearInput != null:
        return clearInput();
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
    required TResult Function(
            String postId,
            bool isReply,
            String? repliedUserName,
            String? repliedCommentId,
            String? repliedUserId)
        openIput,
    required TResult Function(String text) textChanged,
    required TResult Function(String commentMessage) submitComment,
    required TResult Function(String commentMessage) submitReply,
    required TResult Function() clearInput,
  }) {
    final _that = this;
    switch (_that) {
      case _OpenInput():
        return openIput(_that.postId, _that.isReply, _that.repliedUserName,
            _that.repliedCommentId, _that.repliedUserId);
      case _TextChanged():
        return textChanged(_that.text);
      case _SubmitComment():
        return submitComment(_that.commentMessage);
      case _SubmitReply():
        return submitReply(_that.commentMessage);
      case _ClearInput():
        return clearInput();
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
    TResult? Function(String postId, bool isReply, String? repliedUserName,
            String? repliedCommentId, String? repliedUserId)?
        openIput,
    TResult? Function(String text)? textChanged,
    TResult? Function(String commentMessage)? submitComment,
    TResult? Function(String commentMessage)? submitReply,
    TResult? Function()? clearInput,
  }) {
    final _that = this;
    switch (_that) {
      case _OpenInput() when openIput != null:
        return openIput(_that.postId, _that.isReply, _that.repliedUserName,
            _that.repliedCommentId, _that.repliedUserId);
      case _TextChanged() when textChanged != null:
        return textChanged(_that.text);
      case _SubmitComment() when submitComment != null:
        return submitComment(_that.commentMessage);
      case _SubmitReply() when submitReply != null:
        return submitReply(_that.commentMessage);
      case _ClearInput() when clearInput != null:
        return clearInput();
      case _:
        return null;
    }
  }
}

/// @nodoc

class _OpenInput implements CommentInputEvent {
  const _OpenInput(
      {required this.postId,
      this.isReply = false,
      this.repliedUserName,
      this.repliedCommentId,
      this.repliedUserId});

  final String postId;
  @JsonKey()
  final bool isReply;
  final String? repliedUserName;
  final String? repliedCommentId;
  final String? repliedUserId;

  /// Create a copy of CommentInputEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$OpenInputCopyWith<_OpenInput> get copyWith =>
      __$OpenInputCopyWithImpl<_OpenInput>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _OpenInput &&
            (identical(other.postId, postId) || other.postId == postId) &&
            (identical(other.isReply, isReply) || other.isReply == isReply) &&
            (identical(other.repliedUserName, repliedUserName) ||
                other.repliedUserName == repliedUserName) &&
            (identical(other.repliedCommentId, repliedCommentId) ||
                other.repliedCommentId == repliedCommentId) &&
            (identical(other.repliedUserId, repliedUserId) ||
                other.repliedUserId == repliedUserId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, postId, isReply, repliedUserName,
      repliedCommentId, repliedUserId);

  @override
  String toString() {
    return 'CommentInputEvent.openIput(postId: $postId, isReply: $isReply, repliedUserName: $repliedUserName, repliedCommentId: $repliedCommentId, repliedUserId: $repliedUserId)';
  }
}

/// @nodoc
abstract mixin class _$OpenInputCopyWith<$Res>
    implements $CommentInputEventCopyWith<$Res> {
  factory _$OpenInputCopyWith(
          _OpenInput value, $Res Function(_OpenInput) _then) =
      __$OpenInputCopyWithImpl;
  @useResult
  $Res call(
      {String postId,
      bool isReply,
      String? repliedUserName,
      String? repliedCommentId,
      String? repliedUserId});
}

/// @nodoc
class __$OpenInputCopyWithImpl<$Res> implements _$OpenInputCopyWith<$Res> {
  __$OpenInputCopyWithImpl(this._self, this._then);

  final _OpenInput _self;
  final $Res Function(_OpenInput) _then;

  /// Create a copy of CommentInputEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? postId = null,
    Object? isReply = null,
    Object? repliedUserName = freezed,
    Object? repliedCommentId = freezed,
    Object? repliedUserId = freezed,
  }) {
    return _then(_OpenInput(
      postId: null == postId
          ? _self.postId
          : postId // ignore: cast_nullable_to_non_nullable
              as String,
      isReply: null == isReply
          ? _self.isReply
          : isReply // ignore: cast_nullable_to_non_nullable
              as bool,
      repliedUserName: freezed == repliedUserName
          ? _self.repliedUserName
          : repliedUserName // ignore: cast_nullable_to_non_nullable
              as String?,
      repliedCommentId: freezed == repliedCommentId
          ? _self.repliedCommentId
          : repliedCommentId // ignore: cast_nullable_to_non_nullable
              as String?,
      repliedUserId: freezed == repliedUserId
          ? _self.repliedUserId
          : repliedUserId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _TextChanged implements CommentInputEvent {
  const _TextChanged({required this.text});

  final String text;

  /// Create a copy of CommentInputEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TextChangedCopyWith<_TextChanged> get copyWith =>
      __$TextChangedCopyWithImpl<_TextChanged>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TextChanged &&
            (identical(other.text, text) || other.text == text));
  }

  @override
  int get hashCode => Object.hash(runtimeType, text);

  @override
  String toString() {
    return 'CommentInputEvent.textChanged(text: $text)';
  }
}

/// @nodoc
abstract mixin class _$TextChangedCopyWith<$Res>
    implements $CommentInputEventCopyWith<$Res> {
  factory _$TextChangedCopyWith(
          _TextChanged value, $Res Function(_TextChanged) _then) =
      __$TextChangedCopyWithImpl;
  @useResult
  $Res call({String text});
}

/// @nodoc
class __$TextChangedCopyWithImpl<$Res> implements _$TextChangedCopyWith<$Res> {
  __$TextChangedCopyWithImpl(this._self, this._then);

  final _TextChanged _self;
  final $Res Function(_TextChanged) _then;

  /// Create a copy of CommentInputEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? text = null,
  }) {
    return _then(_TextChanged(
      text: null == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _SubmitComment implements CommentInputEvent {
  const _SubmitComment({required this.commentMessage});

  final String commentMessage;

  /// Create a copy of CommentInputEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SubmitCommentCopyWith<_SubmitComment> get copyWith =>
      __$SubmitCommentCopyWithImpl<_SubmitComment>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SubmitComment &&
            (identical(other.commentMessage, commentMessage) ||
                other.commentMessage == commentMessage));
  }

  @override
  int get hashCode => Object.hash(runtimeType, commentMessage);

  @override
  String toString() {
    return 'CommentInputEvent.submitComment(commentMessage: $commentMessage)';
  }
}

/// @nodoc
abstract mixin class _$SubmitCommentCopyWith<$Res>
    implements $CommentInputEventCopyWith<$Res> {
  factory _$SubmitCommentCopyWith(
          _SubmitComment value, $Res Function(_SubmitComment) _then) =
      __$SubmitCommentCopyWithImpl;
  @useResult
  $Res call({String commentMessage});
}

/// @nodoc
class __$SubmitCommentCopyWithImpl<$Res>
    implements _$SubmitCommentCopyWith<$Res> {
  __$SubmitCommentCopyWithImpl(this._self, this._then);

  final _SubmitComment _self;
  final $Res Function(_SubmitComment) _then;

  /// Create a copy of CommentInputEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? commentMessage = null,
  }) {
    return _then(_SubmitComment(
      commentMessage: null == commentMessage
          ? _self.commentMessage
          : commentMessage // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _SubmitReply implements CommentInputEvent {
  const _SubmitReply({required this.commentMessage});

  final String commentMessage;

  /// Create a copy of CommentInputEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SubmitReplyCopyWith<_SubmitReply> get copyWith =>
      __$SubmitReplyCopyWithImpl<_SubmitReply>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SubmitReply &&
            (identical(other.commentMessage, commentMessage) ||
                other.commentMessage == commentMessage));
  }

  @override
  int get hashCode => Object.hash(runtimeType, commentMessage);

  @override
  String toString() {
    return 'CommentInputEvent.submitReply(commentMessage: $commentMessage)';
  }
}

/// @nodoc
abstract mixin class _$SubmitReplyCopyWith<$Res>
    implements $CommentInputEventCopyWith<$Res> {
  factory _$SubmitReplyCopyWith(
          _SubmitReply value, $Res Function(_SubmitReply) _then) =
      __$SubmitReplyCopyWithImpl;
  @useResult
  $Res call({String commentMessage});
}

/// @nodoc
class __$SubmitReplyCopyWithImpl<$Res> implements _$SubmitReplyCopyWith<$Res> {
  __$SubmitReplyCopyWithImpl(this._self, this._then);

  final _SubmitReply _self;
  final $Res Function(_SubmitReply) _then;

  /// Create a copy of CommentInputEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? commentMessage = null,
  }) {
    return _then(_SubmitReply(
      commentMessage: null == commentMessage
          ? _self.commentMessage
          : commentMessage // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _ClearInput implements CommentInputEvent {
  const _ClearInput();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _ClearInput);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'CommentInputEvent.clearInput()';
  }
}

// dart format on

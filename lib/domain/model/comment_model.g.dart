// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
      comment: json['comment'] as String,
      datePublished: (json['datePublished'] as num).toInt(),
      likes: json['likes'] as List<dynamic>,
      likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
      uid: json['uid'] as String,
      id: json['id'] as String?,
      repliesCount: (json['repliesCount'] as num).toInt(),
      authorName: json['authorName'] as String? ?? '',
      avatar: json['avatar'] as String?,
      isLiked: json['isLiked'] as bool? ?? false,
    );

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
      'comment': instance.comment,
      'datePublished': instance.datePublished,
      'likes': instance.likes,
      'uid': instance.uid,
      'id': instance.id,
      'repliesCount': instance.repliesCount,
      'likesCount': instance.likesCount,
      'isLiked': instance.isLiked,
      'authorName': instance.authorName,
      'avatar': instance.avatar,
    };

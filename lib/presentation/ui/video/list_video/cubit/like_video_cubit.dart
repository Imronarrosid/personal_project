import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:personal_project/domain/reporsitory/video_repository.dart';

part 'like_video_state.dart';

class LikeVideoCubit extends Cubit<LikeVideoState> {
  LikeVideoCubit(this.repository) : super(LikeVideoInitial());

  /// bool to store current like state.
  bool? _clientState;

  Future<void> likePost(
      {required String postId,
      required bool stateFromDatabase,
      required int databaseLikeCount}) async {
    _clientState ??= stateFromDatabase;
    repository.likeVideo(postId);

    if (_clientState == true && stateFromDatabase == true) {
      emit(UnilkedVideo(likeCount: databaseLikeCount - 1));
      _clientState = false;
    } else if (_clientState == false && stateFromDatabase == true) {
      emit(VideoIsLiked(likeCount: databaseLikeCount));
      _clientState = true;
    } else if (_clientState == true && stateFromDatabase == false) {
      emit(UnilkedVideo(likeCount: databaseLikeCount));
      _clientState = false;
    } else if (_clientState == false && stateFromDatabase == false) {
      emit(VideoIsLiked(likeCount: databaseLikeCount + 1));
      _clientState = true;
    }
  }

  Future<void> doubleTapToLike(
      {required String postId,
      required bool dataBaseState,
      required int databaseLikeCount}) async {
    _clientState ??= dataBaseState;

    if (_clientState == false && dataBaseState == false) {
      repository.doubleTaplikeVideo(postId);

      emit(VideoIsLiked(likeCount: databaseLikeCount + 1));
      _clientState = true;
    } else {
      //do nothing
    }
    if (_clientState == false && dataBaseState == true) {
      repository.doubleTaplikeVideo(postId);

      emit(VideoIsLiked(likeCount: databaseLikeCount));
      _clientState = true;
    } else {
      //do nothing
    }
    emit(const ShowDobleTapLikeWidget(isVisible: true));
    Future.delayed(const Duration(milliseconds: 300), () {
      emit(const ShowDobleTapLikeWidget(isVisible: false));
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      emit(RemoveDoubleTapLikeWidget());
    });
  }

  final VideoRepository repository;
}

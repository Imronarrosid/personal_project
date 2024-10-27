import 'package:flutter/material.dart';
import 'package:personal_project/data/repository/coment_repository.dart';

import '../../../data/repository/coments_paging_repository.dart';
import '../../../domain/model/comment_model.dart';

class LocalCommentsNotifier extends ChangeNotifier {
  final List<Comment> _localComments = [];

  List<Comment> get localComments => _localComments;

  void addLocalComments(Comment newComment,
      {required ComentsPagingRepository commentRepository}) {
    _localComments.insert(0, newComment);
    commentRepository.controller!.itemList!.insert(0, newComment);
    notifyListeners();
  }

  void clearLocalComments() {
    _localComments.clear();
    notifyListeners();
  }
}

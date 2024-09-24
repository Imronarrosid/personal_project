import 'package:flutter/material.dart';
import 'package:personal_project/data/repository/user_video_paging_repository.dart';

class ProfileVideoListVotifier extends ChangeNotifier {
  static ProfileVideoListVotifier instance = ProfileVideoListVotifier();

  From _videoFro = From.user;

  From get videoFrom => _videoFro;

  void changeVideoFrom(From from) {
    _videoFro = from;
    notifyListeners();
  }
}

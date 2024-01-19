import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/domain/model/play_single_data.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/shared_components/video_player_item.dart';
import 'package:personal_project/presentation/ui/comments/comments_page.dart';

class PlaySingleVideoPage extends StatelessWidget {
  final PlaySingleData data;
  const PlaySingleVideoPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      body: VideoPlayerItem(
        index: data.index,
        url: data.videoData.uid,
        item: data.videoData,
        isForLogedUserVideo: data.isForLogedUserVideo,
      ),
      persistentFooterButtons: <Widget>[
        InkWell(
          splashFactory: NoSplash.splashFactory,
          splashColor: Colors.transparent,
          overlayColor:
              const MaterialStatePropertyAll<Color>(Colors.transparent),
          onTap: () {
            showCommentsBottomSheet(
              context,
              postId: data.videoData.id!,
            );
          },
          child: Container(
            height: Dimens.DIMENS_50,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(
              left: Dimens.DIMENS_12,
            ),
            alignment: Alignment.centerLeft,
            child: Text(LocaleKeys.message_add_comments.tr()),
          ),
        )
      ],
    );
  }
}

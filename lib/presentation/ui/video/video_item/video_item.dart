import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:personal_project/domain/model/video_model.dart';
import 'package:personal_project/presentation/responsive/responsive_layout.dart';
import 'package:personal_project/presentation/ui/video/video_item/responsive/video_item_desktop.dart';
import 'package:personal_project/presentation/ui/video/video_item/responsive/video_item_mobile.dart';

class ResponsiveVideoItem extends StatelessWidget {
  final int index;
  final Video videoData;
  const ResponsiveVideoItem({
    super.key,
    required this.index,
    required this.videoData,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: VideoItemMobile(
        index: index,
        videoData: videoData,
      ),
      desktopBody: VideoItemDesktop(
        index: index,
        videoData: videoData,
        isForLogedUserVideo: true,
      ),
    );
  }
}

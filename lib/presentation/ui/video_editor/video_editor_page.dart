import 'package:flutter/widgets.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:personal_project/presentation/responsive/responsive_layout.dart';
import 'package:personal_project/presentation/ui/video_editor/responsive/video_editor_desktop.dart';
import 'package:personal_project/presentation/ui/video_editor/responsive/video_editor_mobile.dart';

class VideoEditor extends StatelessWidget {
  final XFile? file;
  const VideoEditor({
    super.key,
    this.file,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Video Editor'),
    );
    // return ResponsiveLayout(
    //   mobileBody: VideoEditorMobile(
    //     file: file,
    //   ),
    //   desktopBody: VideoEditorDesktop(file: file),
    // );
  }
}

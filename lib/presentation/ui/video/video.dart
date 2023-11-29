import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';

import 'list_video/list_video.dart';

class VideoPage extends StatelessWidget {
  const VideoPage({super.key});
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: COLOR_black_ff121212,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: COLOR_white_fff5f5f5,
        title: Text(LocaleKeys.title_video.tr()),
      ),
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: ListVideo(),
      ),
    );
  }
}

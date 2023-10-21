import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/shared_components/keep_alive_page.dart';

import 'list_video/list_video.dart';

class VideoPage extends StatelessWidget {
  VideoPage({super.key});
  @override
  final pageStorageBucket = PageStorageBucket();
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: COLOR_black_ff121212,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: COLOR_white_fff5f5f5,
        title: Text(LocaleKeys.title_video.tr()),
      ),
      body: Container(
        width: size.width,
        height: size.height,
        child: ListVideo(),
      ),
    );
  }
}

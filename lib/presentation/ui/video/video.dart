import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/ui/video/list_video/bloc/paging_bloc.dart';

import 'list_video/list_video.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        toolbarHeight: 0,
        bottom: TabBar(
            // indicator: BoxDecoration(
            //   border: Border.all(color: Colors.transparent)
            // ),
            controller: _tabController,
            padding: EdgeInsets.symmetric(horizontal: Dimens.DIMENS_45),
            isScrollable: false,
            dividerColor: Colors.transparent,
            tabs:  <Widget>[
              Tab(
                text: LocaleKeys.label_following.tr(),
              ),
              Tab(
                text: LocaleKeys.label_for_you.tr(),
              ),
            ]),
      ),
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            ListVideo(from: VideoFrom.following),
            ListVideo(from: VideoFrom.forYou),
          ]),
    );
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/responsive/dimension.dart';
import 'package:personal_project/presentation/responsive/responsive_layout.dart';
import 'package:personal_project/presentation/router/app_router.dart';
import 'package:personal_project/presentation/router/route_utils.dart';
import 'package:personal_project/presentation/shared_components/keep_alive_page.dart';
import 'package:personal_project/presentation/ui/video/list_video/bloc/paging_bloc.dart';
import 'package:provider/provider.dart';
import 'package:solar_icons/solar_icons.dart';

import 'list_video/list_video.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String droDownValue = LocaleKeys.label_for_you.tr();

  @override
  void initState() {
    _tabController = TabController(initialIndex: 1, length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool desktopScreen = mobileWidth < MediaQuery.of(context).size.width;
    return BackButtonListener(
      onBackButtonPressed: () async {
        AppRouter appRouter = Provider.of<AppRouter>(context, listen: false);
        appRouter.onBackButtonPressed(context);

        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: desktopScreen
            ? null
            : PreferredSize(
                preferredSize: Size(MediaQuery.of(context).size.width, 60),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: AppBar(
                        backgroundColor: Colors.transparent,
                        toolbarHeight: 0,
                        bottom: TabBar(

                            // indicator: BoxDecoration(
                            //   border: Border.all(color: Colors.transparent)
                            // ),
                            labelColor: COLOR_white_fff5f5f5,
                            indicatorColor: COLOR_white_fff5f5f5,
                            overlayColor: const MaterialStatePropertyAll<Color>(
                                Colors.transparent),
                            controller: _tabController,
                            splashFactory: NoSplash.splashFactory,
                            padding: EdgeInsets.symmetric(
                                horizontal: Dimens.DIMENS_45),
                            isScrollable: false,
                            dividerColor: Colors.transparent,
                            tabAlignment: TabAlignment.center,
                            tabs: <Widget>[
                              Tab(
                                text: LocaleKeys.label_following.tr(),
                              ),
                              Tab(
                                text: LocaleKeys.label_for_you.tr(),
                              ),
                            ]),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: IconButton(
                            onPressed: () {
                              context.push(APP_PAGE.search.toPath);
                            },
                            icon: const Icon(SolarIconsOutline.magnifier)),
                      ),
                    )
                  ],
                ),
              ),
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            TabBarView(
                physics: desktopScreen
                    ? const NeverScrollableScrollPhysics()
                    : const AlwaysScrollableScrollPhysics(),
                controller: _tabController,
                children: const [
                  KeepAlivePage(child: ListVideo(from: VideoFrom.following)),
                  KeepAlivePage(child: ListVideo(from: VideoFrom.forYou)),
                ]),
            ResponsiveLayout(
              desktopBody: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    width: Dimens.DIMENS_150,
                    height: Dimens.DIMENS_42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.tertiary,
                        borderRadius: BorderRadius.circular(50)),
                    child: DropdownButton<String>(
                      dropdownColor: Theme.of(context).colorScheme.tertiary,
                      elevation: 0,
                      icon: const Icon(Icons.arrow_drop_down_rounded),
                      underline: Container(),
                      value: droDownValue,
                      onChanged: (value) {
                        setState(() {
                          droDownValue = value!;
                          if (value == LocaleKeys.label_for_you.tr()) {
                            _tabController.animateTo(1);
                          } else if (value == LocaleKeys.label_following.tr()) {
                            _tabController.animateTo(0);
                          }
                        });
                      },
                      items: <String>[
                        LocaleKeys.label_for_you.tr(),
                        LocaleKeys.label_following.tr(),
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              mobileBody: const SizedBox(
                width: 0,
                height: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_frame/device_frame.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_project/config/bloc_status_enum.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/constant/font_size.dart';
import 'package:personal_project/domain/model/add_details_model.dart';
import 'package:personal_project/domain/model/game_fav_modal.dart';
import 'package:personal_project/domain/model/video_model.dart';
import 'package:personal_project/domain/reporsitory/auth_reposotory.dart';
import 'package:personal_project/presentation/assets/images.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/router/route_utils.dart';
import 'package:personal_project/presentation/ui/add_details/bloc/upload_bloc.dart';
import 'package:personal_project/presentation/ui/add_details/cubit/check_box_cubit.dart';
import 'package:personal_project/presentation/ui/add_details/select_game/cubit/select_game_cubit.dart';
import 'package:personal_project/presentation/ui/auth/auth.dart';
import 'package:personal_project/presentation/ui/select_cover/cubit/select_cover_cubit.dart';
import 'package:personal_project/presentation/ui/select_cover/select_cover_page.dart';
import 'package:personal_project/presentation/ui/video/video_item/responsive/video_item_desktop.dart';
import 'package:personal_project/presentation/ui/video/video_item/responsive/video_item_mobile.dart';
import 'package:personal_project/utils/get_thumbnails.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:video_player/video_player.dart';

class AddDetailsDesktop extends StatefulWidget {
  final AddDetails data;
  const AddDetailsDesktop({super.key, required this.data});

  @override
  State<AddDetailsDesktop> createState() => _AddDetailsDesktopState();
}

class _AddDetailsDesktopState extends State<AddDetailsDesktop> {
  final TextEditingController textEditingController = TextEditingController();

  GameFav? selectedGame;
  String? category;
  late File? coverFile;

  @override
  void initState() {
    BlocProvider.of<SelectGameCubit>(context).initSelectGame();
    coverFile = widget.data.thumbnail;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return BlocProvider(
      create: (_) => CheckBoxCubit(),
      child: GestureDetector(
        onTap: () {
          // Dismiss the keyboard when tapping outside of text fields
          debugPrint('unfocus');
          FocusScope.of(context).unfocus();
        },
        child: MultiBlocListener(
          listeners: [
            BlocListener<UploadBloc, UploadState>(
              listener: (_, state) {
                if (state is Uploading) {
                  context.go(APP_PAGE.home.toPath);
                }
              },
            ),
            BlocListener<SelectGameCubit, SelectGameState>(
              listener: (_, state) {
                if (state.status == SelectGameStatus.selected) {
                  selectedGame = state.selectedGame!;
                }
              },
            ),
            BlocListener<SelectCoverCubit, SelectCoverState>(
              listener: (_, state) {
                if (state.status == BlocStatus.selected) {
                  coverFile = File(state.coverPath!);
                }
              },
              child: Container(),
            )
          ],
          child: Builder(builder: (context) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 8.0,
                  right: 8,
                  bottom: 8,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Scaffold(
                    resizeToAvoidBottomInset: false,
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                    // appBar: AppBar(
                    //   title: Text(LocaleKeys.title_upload.tr()),
                    //   elevation: 0,
                    //   centerTitle: true,
                    // ),
                    body: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 24,
                        ),
                        Expanded(
                          child: ListView(shrinkWrap: true, children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 12, top: 24, bottom: 12),
                              child: Text(
                                LocaleKeys.label_cover.tr(),
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              width: size.width,
                              height: Dimens.DIMENS_250,
                              padding: EdgeInsets.symmetric(
                                  horizontal: Dimens.DIMENS_12),
                              child: Row(children: [
                                Stack(
                                  children: [
                                    _coverView(context, coverFile!),
                                    _selectCover(context),
                                  ],
                                ),
                              ]),
                            ),
                            SizedBox(
                              height: Dimens.DIMENS_12,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 12, top: 18, bottom: 12),
                              child: Text(
                                'Descriptions',
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: Dimens.DIMENS_12),
                              child: Container(
                                padding: const EdgeInsets.all(18),
                                height: 200,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background),
                                child: TextField(
                                  maxLength: 1500,
                                  maxLines: 10,
                                  controller: textEditingController,
                                  decoration: InputDecoration(
                                      contentPadding: EdgeInsets.zero,
                                      border: const OutlineInputBorder(
                                          borderSide: BorderSide.none),
                                      hintText: LocaleKeys
                                          .message_write_something
                                          .tr()),
                                ),
                              ),
                            ),
                            BlocBuilder<CheckBoxCubit, CheckBoxState>(
                              builder: (_, state) {
                                return CheckboxListTile(
                                  tileColor: Colors.transparent,
                                  title:
                                      Text(LocaleKeys.label_entertainment.tr()),
                                  checkColor:
                                      Theme.of(context).colorScheme.tertiary,
                                  value: state.status == BlocStatus.active,
                                  onChanged: (isActive) {
                                    BlocProvider.of<CheckBoxCubit>(context)
                                        .checkBoxHandle();
                                    if (isActive!) {
                                      BlocProvider.of<SelectGameCubit>(context)
                                          .initSelectGame();
                                      category = 'Entertainment';
                                    } else {
                                      category = 'Gaming';
                                    }
                                  },
                                );
                              },
                            ),
                            BlocBuilder<CheckBoxCubit, CheckBoxState>(
                              builder: (context, state) {
                                if (state.status == BlocStatus.active) {
                                  return Opacity(
                                    opacity: 0.4,
                                    child: ListTile(
                                      tileColor: Colors.transparent,
                                      leading:
                                          const Icon(BootstrapIcons.controller),
                                      title: Text(
                                          LocaleKeys.message_game_title.tr()),
                                      trailing: const Icon(
                                          Icons.keyboard_arrow_right),
                                    ),
                                  );
                                }
                                return BlocBuilder<SelectGameCubit,
                                    SelectGameState>(
                                  builder: (context, state) {
                                    if (state.status ==
                                        SelectGameStatus.selected) {
                                      return ListTile(
                                        tileColor: Colors.transparent,
                                        leading: CircleAvatar(
                                          backgroundColor: COLOR_grey,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            child: CachedNetworkImage(
                                              imageUrl: state
                                                  .selectedGame!.gameImage!,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                            ),
                                          ),
                                        ),
                                        trailing: IconButton(
                                            iconSize: Dimens.DIMENS_18,
                                            onPressed: () {
                                              BlocProvider.of<SelectGameCubit>(
                                                      context)
                                                  .initSelectGame();
                                            },
                                            style: IconButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                              minimumSize: Size(
                                                  Dimens.DIMENS_30,
                                                  Dimens.DIMENS_30),
                                              maximumSize: Size(
                                                  Dimens.DIMENS_30,
                                                  Dimens.DIMENS_30),
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .tertiary,
                                            ),
                                            icon: const Icon(Icons.close)),
                                        title: Text(
                                            state.selectedGame!.gameTitle!),
                                        onTap: () {
                                          context
                                              .push(APP_PAGE.selectGame.toPath);
                                        },
                                      );
                                    }
                                    return ListTile(
                                      tileColor: Colors.transparent,
                                      leading:
                                          const Icon(BootstrapIcons.controller),
                                      title: Text(
                                          LocaleKeys.message_game_title.tr()),
                                      trailing: const Icon(
                                          Icons.keyboard_arrow_right),
                                      onTap: () {
                                        context
                                            .push(APP_PAGE.selectGame.toPath);
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                            SizedBox(
                              height: Dimens.DIMENS_28,
                            ),
                            Container(
                              width: 400,
                              padding: EdgeInsets.symmetric(
                                  horizontal: Dimens.DIMENS_12),
                              child: Container(
                                height: Dimens.DIMENS_38,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onTertiary,
                                    borderRadius: BorderRadius.circular(50)),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                      splashColor:
                                          COLOR_white_fff5f5f5.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(50),
                                      onTap: () {
                                        var isUserEmpty = RepositoryProvider.of<
                                                AuthRepository>(context)
                                            .currentUser;
                                        if (isUserEmpty == null) {
                                          showAuthBottomSheetFunc(context);
                                        } else {
                                          //will upload videos
                                          BlocProvider.of<UploadBloc>(context)
                                              .add(
                                            UploadVideoEvent(
                                              thumbnail: coverFile!.path,
                                              videoPath:
                                                  widget.data.videoFile.path,
                                              caption:
                                                  textEditingController.text,
                                              game: selectedGame,
                                              category: category,
                                            ),
                                          );
                                          debugPrint('Uploading');
                                        }
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: Dimens.DIMENS_38,
                                        child: Text(
                                          LocaleKeys.title_upload.tr(),
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .surface,
                                              fontSize: FontSize.FONT_SIZE_12),
                                        ),
                                      )),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: Dimens.DIMENS_28,
                            ),
                          ]),
                        ),
                        Preview(
                          videoUrl: widget.data.videoFile.path,
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  AspectRatio _coverView(BuildContext context, File file) {
    return AspectRatio(
      aspectRatio: 4 / 6,
      child: GestureDetector(onTap: () {
        context.push(
          APP_PAGE.videoPreview.toPath,
          extra: widget.data.videoFile,
        );
      }, child: Builder(
        builder: (_) {
          if (kIsWeb) {
            return SizedBox(
              width: Dimens.DIMENS_85,
              height: Dimens.DIMENS_120,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image(
                    image: NetworkImage(
                      file.path,
                    ),
                    fit: BoxFit.cover),
              ),
            );
          }
          return SizedBox(
            width: Dimens.DIMENS_85,
            height: Dimens.DIMENS_120,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(file, fit: BoxFit.cover),
            ),
          );
        },
      )),
    );
  }

  Align _selectCover(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Material(
        color: Theme.of(context).colorScheme.tertiary.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            context.push(
              APP_PAGE.selectCover.toPath,
              extra: XFile(
                widget.data.videoFile.path,
              ),
            );
          },
          child: AspectRatio(
            aspectRatio: 4 / 6,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    SolarIconsBold.gallery,
                  ),
                  SizedBox(
                    height: Dimens.DIMENS_5,
                  ),
                  Text(
                    LocaleKeys.label_slect_cover.tr(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Preview extends StatefulWidget {
  final String videoUrl;
  const Preview({
    super.key,
    required this.videoUrl,
  });

  @override
  State<Preview> createState() => _PreviewState();
}

class _PreviewState extends State<Preview> with SingleTickerProviderStateMixin {
  late final TabController _controller;
  @override
  void initState() {
    _controller = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      height: 500,
      padding: EdgeInsets.symmetric(horizontal: Dimens.DIMENS_12),
      child: Column(
        children: <Widget>[
          const SizedBox(
            height: 24,
          ),
          const SizedBox(
            width: double.infinity,
            child: Text(
              'Preview',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(
            height: 14,
          ),
          Expanded(
            flex: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Theme.of(context).colorScheme.background),
              child: TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiary,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  labelColor: Theme.of(context).colorScheme.onSurface,
                  controller: _controller,
                  tabs: const [
                    Tab(
                      text: 'Mobile',
                    ),
                    Tab(
                      text: 'Desktop',
                    ),
                  ]),
            ),
          ),
          SizedBox(
            height: Dimens.DIMENS_12,
          ),
          Expanded(
            child: TabBarView(
              controller: _controller,
              children: [
                MobilePreview(
                  videoUrl: widget.videoUrl,
                ),
                DesktopPreview(
                  videoUrl: widget.videoUrl,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DesktopPreview extends StatefulWidget {
  final String videoUrl;
  const DesktopPreview({
    super.key,
    required this.videoUrl,
  });

  @override
  State<DesktopPreview> createState() => _DesktopPreviewState();
}

class _DesktopPreviewState extends State<DesktopPreview> {
  late final VideoPlayerController _videoController;
  @override
  void initState() {
    _videoController = VideoPlayerController.networkUrl(Uri.parse(
      widget.videoUrl,
    ))
      ..initialize().then((value) => setState(() {}))
      ..setLooping(true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DeviceFrame(
      device: DeviceInfo.genericDesktopMonitor(
        platform: TargetPlatform.macOS,
        name: 'Wide',
        id: 'wide',
        screenSize: const Size(1620, 780),
        windowPosition: Rect.fromCenter(
          center: const Offset(
            1620 * 0.5,
            780 * 0.5,
          ),
          width: 1620,
          height: 780,
        ),
      ),
      orientation: Orientation.portrait,
      screen: Builder(
        builder: (deviceContext) => Scaffold(
          body: Scaffold(
            body: Row(
              children: [
                Expanded(
                  flex: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: 220,
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiary,
                          borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            height: 75,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Image.asset(Images.IC_GAMEPIUN512X521),
                            ),
                          ),
                          ListTile(
                            selected: true,
                            leading: const Icon(SolarIconsBold.home2),
                            title: Text(LocaleKeys.label_home.tr(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            onTap: () {
                              debugPrint('Home');
                            },
                          ),
                          ListTile(
                            title: Text(LocaleKeys.label_search.tr(),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                )),
                            leading: Icon(
                              SolarIconsOutline.roundedMagnifier,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                          ListTile(
                              title: Text(LocaleKeys.label_chat.tr(),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                  )),
                              leading: Icon(
                                SolarIconsOutline.chatLine,
                                color: Colors.white.withOpacity(0.7),
                              )),
                          ListTile(
                              title: Text(
                                LocaleKeys.label_account.tr(),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                              leading: Icon(
                                SolarIconsOutline.user,
                                color: Colors.white.withOpacity(0.7),
                              )),
                          ListTile(
                            title: Text(LocaleKeys.title_upload.tr()),
                            leading: Icon(
                              SolarIconsOutline.addSquare,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: AspectRatio(
                                    aspectRatio: 9 / 16,
                                    child: Container(
                                      color: Colors.black,
                                      alignment: Alignment.center,
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: SizedBox.expand(
                                          child: FittedBox(
                                            fit: BoxFit.fitWidth,
                                            child: SizedBox(
                                              height: _videoController
                                                      .value.isInitialized
                                                  ? _videoController
                                                      .value.size.height
                                                  : 0,
                                              width: _videoController
                                                      .value.isInitialized
                                                  ? _videoController
                                                      .value.size.width
                                                  : 0,
                                              child: GestureDetector(
                                                onTap: () {
                                                  _videoController.value.isPlaying
                                                      ? _videoController.pause()
                                                      : _videoController.play();
                                                },
                                                child: VideoPlayer(
                                                  _videoController,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                AspectRatio(
                                  aspectRatio: 9 / 16,
                                  child: SizedBox(
                                    height: _videoController.value.size.height,
                                    width: _videoController.value.size.width,
                                    child: InkWell(
                                      hoverColor: Colors.transparent,
                                      splashColor: Colors.transparent,
                                      overlayColor:
                                          const MaterialStatePropertyAll<Color>(
                                        Colors.transparent,
                                      ),
                                      onTap: () {
                                        debugPrint('desktop preview');
                                        _videoController.value.isPlaying
                                            ? _videoController.pause()
                                            : _videoController.play();
                                      },
                                      child: SizedBox(
                                        height:
                                            _videoController.value.size.height,
                                        width: _videoController.value.size.width,
                                      ),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 12, bottom: 16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          children: [
                                            GestureDetector(
                                              child: Text(
                                                '@username',
                                                style: TextStyle(
                                                    color: COLOR_white_fff5f5f5,
                                                    fontSize: 14),
                                              ),
                                            ),
                                            SizedBox(
                                              width: Dimens.DIMENS_10,
                                            ),
                                            Container(
                                              height: Dimens.DIMENS_28,
                                              padding: EdgeInsets.symmetric(
                                                horizontal: Dimens.DIMENS_16,
                                              ),
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary),
                                              child: Text(
                                                LocaleKeys.label_follow.tr(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                              ),
                                            ),
                                          ],
                                        ),
                                        GestureDetector(
                                          onTap: () {},
                                          child: SizedBox(
                                            width: Dimens.DIMENS_150,
                                            height: Dimens.DIMENS_24,
                                            child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    BootstrapIcons.controller,
                                                    color: COLOR_white_fff5f5f5,
                                                    size: 16,
                                                  ),
                                                  SizedBox(
                                                    width: Dimens.DIMENS_10,
                                                  ),
                                                  Text(
                                                    'GameTitle',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w300,
                                                      fontSize: 12,
                                                      color: COLOR_white_fff5f5f5,
                                                    ),
                                                  ),
                                                ]),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Builder(
                                    builder: (context) {
                                      if (_videoController.value.isInitialized) {
                                        return SizedBox(
                                          width: 400,
                                          height: 3,
                                          child: VideoProgressIndicator(
                                            _videoController,
                                            padding: EdgeInsets.zero,
                                            colors: VideoProgressColors(
                                                bufferedColor:
                                                    COLOR_white_fff5f5f5
                                                        .withOpacity(0.3),
                                                playedColor:
                                                    COLOR_white_fff5f5f5),
                                            allowScrubbing: true,
                                          ),
                                        );
                                      }
                                      return Container();
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            width: Dimens.DIMENS_50,
                            height: double.infinity,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  child: Icon(SolarIconsBold.user),
                                ),
                                SizedBox(
                                  height: 12,
                                ),
                                Icon(
                                  SolarIconsBold.heart,
                                  size: 34,
                                ),
                                Text('1000'),
                                SizedBox(
                                  height: 12,
                                ),
                                Icon(
                                  SolarIconsBold.chatRound,
                                  size: 34,
                                ),
                                Text('1000'),
                                SizedBox(
                                  height: 12,
                                ),
                                Transform.flip(
                                  flipX: true,
                                  child: Icon(
                                    BootstrapIcons.reply_fill,
                                    size: 34,
                                  ),
                                ),
                                Text('1000'),
                                SizedBox(
                                  height: 12,
                                ),
                                Container(
                                  width: Dimens.DIMENS_30,
                                  height: Dimens.DIMENS_30,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: COLOR_white_fff5f5f5),
                                    borderRadius: BorderRadius.circular(8),
                                    color:
                                        const Color.fromARGB(255, 27, 26, 26),
                                  ),
                                  child: Icon(
                                    BootstrapIcons.controller,
                                    color: COLOR_white_fff5f5f5,
                                    size: Dimens.DIMENS_15,
                                  ),
                                ),
                                SizedBox(
                                  height: Dimens.DIMENS_18,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      IgnorePointer(
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
                              icon: const Icon(Icons.arrow_drop_down_rounded),
                              underline: Container(),
                              value: LocaleKeys.label_for_you.tr(),
                              onChanged: (value) {},
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
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }
}

class MobilePreview extends StatefulWidget {
  final String videoUrl;
  const MobilePreview({
    super.key,
    required this.videoUrl,
  });

  @override
  State<MobilePreview> createState() => _MobilePreviewState();
}

class _MobilePreviewState extends State<MobilePreview>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final VideoPlayerController _videoController;
  @override
  void initState() {
    _videoController = VideoPlayerController.networkUrl(Uri.parse(
      widget.videoUrl,
    ))
      ..initialize()
      ..setLooping(true);

    _tabController = TabController(initialIndex: 1, length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DeviceFrame(
      device: Devices.ios.iPhone13ProMax,
      orientation: Orientation.portrait,
      screen: Builder(
        builder: (deviceContext) => Scaffold(
          body: Scaffold(
            extendBodyBehindAppBar: true,
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              toolbarHeight: 0,
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(kToolbarHeight),
                child: IgnorePointer(
                  ignoring: true,
                  child: TabBar(
                      onTap: null,
                      labelColor: Theme.of(context).colorScheme.onSurface,
                      indicatorColor: Theme.of(context).colorScheme.onSurface,
                      controller: _tabController,
                      overlayColor: const MaterialStatePropertyAll<Color>(
                          Colors.transparent),
                      splashFactory: NoSplash.splashFactory,
                      padding:
                          EdgeInsets.symmetric(horizontal: Dimens.DIMENS_45),
                      isScrollable: false,
                      dividerColor: Colors.transparent,
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
            ),
            body: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: double.infinity,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: () {
                        _videoController.value.isPlaying
                            ? _videoController.pause()
                            : _videoController.play();
                      },
                      child: VideoPlayer(
                        _videoController,
                      ),
                    ),
                  ),
                  InkWell(
                      hoverColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      overlayColor: const MaterialStatePropertyAll<Color>(
                        Colors.transparent,
                      ),
                      onTap: () => _videoController.value.isPlaying
                          ? _videoController.pause()
                          : _videoController.play(),
                      child: const SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                      )),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 24,
                            child: Icon(SolarIconsBold.user),
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          Icon(
                            SolarIconsBold.heart,
                            size: 34,
                          ),
                          Text('1000'),
                          SizedBox(
                            height: 12,
                          ),
                          Icon(
                            SolarIconsBold.chatRound,
                            size: 34,
                          ),
                          Text('1000'),
                          SizedBox(
                            height: 12,
                          ),
                          Transform.flip(
                            flipX: true,
                            child: Icon(
                              BootstrapIcons.reply_fill,
                              size: 34,
                            ),
                          ),
                          Text('1000'),
                          SizedBox(
                            height: 12,
                          ),
                          Container(
                            width: Dimens.DIMENS_30,
                            height: Dimens.DIMENS_30,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border.all(color: COLOR_white_fff5f5f5),
                              borderRadius: BorderRadius.circular(8),
                              color: const Color.fromARGB(255, 27, 26, 26),
                            ),
                            child: Icon(
                              BootstrapIcons.controller,
                              color: COLOR_white_fff5f5f5,
                              size: Dimens.DIMENS_15,
                            ),
                          ),
                          SizedBox(
                            height: Dimens.DIMENS_18,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12, bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                child: Text(
                                  '@username',
                                  style: TextStyle(
                                      color: COLOR_white_fff5f5f5,
                                      fontSize: 14),
                                ),
                              ),
                              SizedBox(
                                width: Dimens.DIMENS_10,
                              ),
                              Container(
                                height: Dimens.DIMENS_28,
                                padding: EdgeInsets.symmetric(
                                  horizontal: Dimens.DIMENS_16,
                                ),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color:
                                        Theme.of(context).colorScheme.primary),
                                child: Text(
                                  LocaleKeys.label_follow.tr(),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: SizedBox(
                              width: Dimens.DIMENS_150,
                              height: Dimens.DIMENS_24,
                              child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      BootstrapIcons.controller,
                                      color: COLOR_white_fff5f5f5,
                                      size: 16,
                                    ),
                                    SizedBox(
                                      width: Dimens.DIMENS_10,
                                    ),
                                    Text(
                                      'GameTitle',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w300,
                                        fontSize: 12,
                                        color: COLOR_white_fff5f5f5,
                                      ),
                                    ),
                                  ]),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      height: 3,
                      child: VideoProgressIndicator(
                        _videoController,
                        padding: EdgeInsets.zero,
                        colors: VideoProgressColors(
                            bufferedColor:
                                COLOR_white_fff5f5f5.withOpacity(0.3),
                            playedColor: COLOR_white_fff5f5f5),
                        allowScrubbing: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: IgnorePointer(
              child: BottomNavigationBar(
                elevation: 2,
                unselectedItemColor: COLOR_white_fff5f5f5.withOpacity(0.6),
                selectedItemColor: COLOR_white_fff5f5f5,
                type: BottomNavigationBarType.fixed,
                selectedFontSize: 12,
                unselectedFontSize: 12,
                backgroundColor: COLOR_black_ff121212,
                showSelectedLabels: false,
                showUnselectedLabels: false,
                items: [
                  BottomNavigationBarItem(
                    icon: const Icon(SolarIconsOutline.home),
                    activeIcon: const Icon(
                      SolarIconsBold.home,
                    ),
                    label: LocaleKeys.label_home.tr(),
                    tooltip: LocaleKeys.label_home.tr(),
                  ),
                  BottomNavigationBarItem(
                      icon: const Icon(
                        SolarIconsOutline.magnifier,
                      ),
                      label: LocaleKeys.label_search.tr()),
                  BottomNavigationBarItem(
                    icon: const Icon(
                      SolarIconsOutline.addSquare,
                      size: 24,
                    ),
                    label: '',
                    tooltip: LocaleKeys.title_upload.tr(),
                  ),
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(bottom: Dimens.DIMENS_3),
                      child: const Icon(SolarIconsOutline.chatLine),
                    ),
                    label: LocaleKeys.label_chat.tr(),
                    tooltip: LocaleKeys.label_chat.tr(),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(SolarIconsOutline.user),
                    label: LocaleKeys.label_profile.tr(),
                    tooltip: LocaleKeys.label_profile.tr(),
                  ),
                ],
                currentIndex: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }
}

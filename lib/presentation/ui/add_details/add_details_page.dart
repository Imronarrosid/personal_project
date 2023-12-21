import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/constant/font_size.dart';
import 'package:personal_project/domain/model/preview_model.dart';
import 'package:personal_project/domain/reporsitory/auth_reposotory.dart';
import 'package:personal_project/presentation/assets/images.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/router/route_utils.dart';
import 'package:personal_project/presentation/ui/add_details/bloc/upload_bloc.dart';
import 'package:personal_project/presentation/ui/add_details/select_game/cubit/select_game_cubit.dart';
import 'package:personal_project/presentation/ui/auth/auth.dart';
import 'package:personal_project/utils/get_thumbnails.dart';

class AddDetailsPage extends StatelessWidget {
  final File videoFile;
  AddDetailsPage({super.key, required this.videoFile});

  final TextEditingController textEditingController = TextEditingController();
  String selectedGame = '';

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    Future<File> thumbnail = getTumbnail(videoFile.path);
    return GestureDetector(
      onTap: () {
        // Dismiss the keyboard when tapping outside of text fields
        debugPrint('unfocus');
        FocusScope.of(context).unfocus();
      },
      child: MultiBlocListener(
        listeners: [
          BlocListener<UploadBloc, UploadState>(
            listener: (context, state) {
              if (state is Uploading) {
                context.go(APP_PAGE.home.toPath);
              }
            },
          ),
          BlocListener<SelectGameCubit, SelectGameState>(
            listener: (context, state) {
              if (state.status == SelectGameStatus.selected) {
                selectedGame = state.selectedGame!.gameTitle!;
              }
            },
          ),
        ],
        child: Scaffold(
          appBar: AppBar(
            title: Text(LocaleKeys.title_upload.tr()),
            foregroundColor: COLOR_black,
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
          body: Container(
            width: size.width,
            height: size.height,
            padding: EdgeInsets.symmetric(horizontal: Dimens.DIMENS_12),
            child: Column(children: [
              SizedBox(
                width: size.width,
                height: Dimens.DIMENS_120,
                child: Row(children: [
                  SizedBox(
                    width: Dimens.DIMENS_85,
                    height: Dimens.DIMENS_120,
                    child: GestureDetector(
                      onTap: () {
                        context.push(
                          APP_PAGE.videoPreview.toPath,
                          extra: videoFile,
                        );
                      },
                      child: FutureBuilder(
                        future: getTumbnail(videoFile.path),
                        builder: (context, snapshot) {
                          var thumbnailFile = snapshot.data;

                          return snapshot.hasData
                              ? SizedBox(
                                  width: Dimens.DIMENS_85,
                                  height: Dimens.DIMENS_120,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(thumbnailFile!,
                                        fit: BoxFit.cover),
                                  ),
                                )
                              : const Center(
                                  child: CircularProgressIndicator(),
                                );
                        },
                      ),
                    ),
                  ),
                  Expanded(
                      child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: Dimens.DIMENS_12),
                    child: TextField(
                      maxLines: 5,
                      controller: textEditingController,
                      decoration: InputDecoration(
                          border: const OutlineInputBorder(
                              borderSide: BorderSide.none),
                          hintText: LocaleKeys.message_write_something.tr()),
                    ),
                  ))
                ]),
              ),
              SizedBox(
                height: Dimens.DIMENS_12,
              ),
              const Divider(),
              BlocBuilder<SelectGameCubit, SelectGameState>(
                builder: (context, state) {
                  if (state.status == SelectGameStatus.selected) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: COLOR_grey,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: CachedNetworkImage(
                            imageUrl: state.selectedGame!.gameImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),
                      trailing: Icon(Icons.keyboard_arrow_right),
                      title: Text(state.selectedGame!.gameTitle!),
                      onTap: () {
                        context.push(APP_PAGE.selectGame.toPath);
                      },
                    );
                  }
                  return ListTile(
                    leading: Icon(MdiIcons.controller),
                    contentPadding: EdgeInsets.zero,
                    title: Text('Game title(optional)'),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    onTap: () {
                      context.push(APP_PAGE.selectGame.toPath);
                    },
                  );
                },
              ),
              SizedBox(
                height: Dimens.DIMENS_28,
              ),
              Container(
                height: Dimens.DIMENS_38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: COLOR_black_ff121212,
                    borderRadius: BorderRadius.circular(50)),
                child: FutureBuilder(
                    future: thumbnail,
                    builder: (context, asyncSnapshot) {
                      var data = asyncSnapshot.data;
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: COLOR_white_fff5f5f5.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(50),
                          onTap: () {
                            var isUserEmpty =
                                RepositoryProvider.of<AuthRepository>(context)
                                    .currentUser;
                            if (isUserEmpty == null) {
                              showAuthBottomSheetFunc(context);
                            } else if (asyncSnapshot.hasData) {
                              //will upload videos
                              BlocProvider.of<UploadBloc>(context).add(
                                UploadVideoEvent(
                                    thumbnail: data!.path,
                                    videoPath: videoFile.path,
                                    caption: textEditingController.text,
                                    game: selectedGame),
                              );
                              debugPrint('Uploading');
                            }
                          },
                          child: asyncSnapshot.hasData
                              ? SizedBox(
                                  height: Dimens.DIMENS_38,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        Images.IC_UPLOAD_2,
                                        width: Dimens.DIMENS_18,
                                      ),
                                      SizedBox(
                                        width: Dimens.DIMENS_6,
                                      ),
                                      Text(
                                        LocaleKeys.title_upload.tr(),
                                        style: TextStyle(
                                            color: COLOR_white_fff5f5f5,
                                            fontSize: FontSize.FONT_SIZE_12),
                                      ),
                                    ],
                                  ))
                              : SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: COLOR_white_fff5f5f5,
                                  ),
                                ),
                        ),
                      );
                    }),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

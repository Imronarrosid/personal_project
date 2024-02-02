import 'dart:io';

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_project/config/bloc_status_enum.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/constant/font_size.dart';
import 'package:personal_project/domain/model/add_details_model.dart';
import 'package:personal_project/domain/model/game_fav_modal.dart';
import 'package:personal_project/domain/reporsitory/auth_reposotory.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/router/route_utils.dart';
import 'package:personal_project/presentation/ui/add_details/bloc/upload_bloc.dart';
import 'package:personal_project/presentation/ui/add_details/cubit/check_box_cubit.dart';
import 'package:personal_project/presentation/ui/add_details/select_game/cubit/select_game_cubit.dart';
import 'package:personal_project/presentation/ui/auth/auth.dart';
import 'package:personal_project/presentation/ui/select_cover/cubit/select_cover_cubit.dart';
import 'package:personal_project/presentation/ui/select_cover/select_cover_page.dart';
import 'package:personal_project/utils/get_thumbnails.dart';

class AddDetailsPage extends StatefulWidget {
  final AddDetails data;
  const AddDetailsPage({super.key, required this.data});

  @override
  State<AddDetailsPage> createState() => _AddDetailsPageState();
}

class _AddDetailsPageState extends State<AddDetailsPage> {
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
            return Scaffold(
              appBar: AppBar(
                title: Text(LocaleKeys.title_upload.tr()),
                elevation: 0,
                centerTitle: true,
              ),
              body: SizedBox(
                width: size.width,
                height: size.height,
                child: Column(children: [
                  Container(
                    width: size.width,
                    height: Dimens.DIMENS_120,
                    padding: EdgeInsets.symmetric(horizontal: Dimens.DIMENS_12),
                    child: Row(children: [
                      Stack(
                        children: [
                          _coverView(context, coverFile!),
                          _selectCover(context),
                        ],
                      ),
                      Expanded(
                          child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: Dimens.DIMENS_12),
                        child: TextField(
                          maxLines: 5,
                          maxLength: 1500,
                          controller: textEditingController,
                          decoration: InputDecoration(
                              border: const OutlineInputBorder(borderSide: BorderSide.none),
                              hintText: LocaleKeys.message_write_something.tr()),
                        ),
                      ))
                    ]),
                  ),
                  SizedBox(
                    height: Dimens.DIMENS_12,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: Dimens.DIMENS_12),
                    child: const Divider(),
                  ),
                  BlocBuilder<CheckBoxCubit, CheckBoxState>(
                    builder: (_, state) {
                      return CheckboxListTile(
                        tileColor: Colors.transparent,
                        title: Text(LocaleKeys.label_entertainment.tr()),
                        checkColor: Theme.of(context).colorScheme.tertiary,
                        value: state.status == BlocStatus.active,
                        onChanged: (isActive) {
                          BlocProvider.of<CheckBoxCubit>(context).checkBoxHandle();
                          if (isActive!) {
                            BlocProvider.of<SelectGameCubit>(context).initSelectGame();
                            category = 'Entertainment';
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
                            leading: const Icon(BootstrapIcons.controller),
                            title: Text(LocaleKeys.message_game_title.tr()),
                            trailing: const Icon(Icons.keyboard_arrow_right),
                          ),
                        );
                      }
                      return BlocBuilder<SelectGameCubit, SelectGameState>(
                        builder: (context, state) {
                          if (state.status == SelectGameStatus.selected) {
                            return ListTile(
                              tileColor: Colors.transparent,
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
                              trailing: IconButton(
                                  iconSize: Dimens.DIMENS_18,
                                  onPressed: () {
                                    BlocProvider.of<SelectGameCubit>(context).initSelectGame();
                                  },
                                  style: IconButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size(Dimens.DIMENS_30, Dimens.DIMENS_30),
                                    maximumSize: Size(Dimens.DIMENS_30, Dimens.DIMENS_30),
                                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                                  ),
                                  icon: const Icon(Icons.close)),
                              title: Text(state.selectedGame!.gameTitle!),
                              onTap: () {
                                context.push(APP_PAGE.selectGame.toPath);
                              },
                            );
                          }
                          return ListTile(
                            tileColor: Colors.transparent,
                            leading: const Icon(BootstrapIcons.controller),
                            title: Text(LocaleKeys.message_game_title.tr()),
                            trailing: const Icon(Icons.keyboard_arrow_right),
                            onTap: () {
                              context.push(APP_PAGE.selectGame.toPath);
                            },
                          );
                        },
                      );
                    },
                  ),
                  SizedBox(
                    height: Dimens.DIMENS_28,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: Dimens.DIMENS_12),
                    child: Container(
                      height: Dimens.DIMENS_38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onTertiary,
                          borderRadius: BorderRadius.circular(50)),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                            splashColor: COLOR_white_fff5f5f5.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(50),
                            onTap: () {
                              var isUserEmpty =
                                  RepositoryProvider.of<AuthRepository>(context).currentUser;
                              if (isUserEmpty == null) {
                                showAuthBottomSheetFunc(context);
                              } else {
                                //will upload videos
                                BlocProvider.of<UploadBloc>(context).add(
                                  UploadVideoEvent(
                                    thumbnail: coverFile!.path,
                                    videoPath: widget.data.videoFile.path,
                                    caption: textEditingController.text,
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
                                    color: Theme.of(context).colorScheme.primary,
                                    fontSize: FontSize.FONT_SIZE_12),
                              ),
                            )),
                      ),
                    ),
                  ),
                ]),
              ),
            );
          }),
        ),
      ),
    );
  }

  SizedBox _coverView(BuildContext context, File file) {
    return SizedBox(
      width: Dimens.DIMENS_85,
      height: Dimens.DIMENS_120,
      child: GestureDetector(onTap: () {
        context.push(
          APP_PAGE.videoPreview.toPath,
          extra: widget.data.videoFile,
        );
      }, child: BlocBuilder<SelectCoverCubit, SelectCoverState>(
        builder: (_, state) {
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
      alignment: Alignment.bottomCenter,
      child: Material(
        color: Colors.black26,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
        child: InkWell(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
          onTap: () {
            context.push(
              APP_PAGE.selectCover.toPath,
              extra: XFile(
                widget.data.videoFile.path,
              ),
            );
          },
          child: Container(
            width: Dimens.DIMENS_85,
            height: Dimens.DIMENS_24,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: Text(
              LocaleKeys.label_cover.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

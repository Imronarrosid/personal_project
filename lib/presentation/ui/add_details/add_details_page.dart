import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/constant/font_size.dart';
import 'package:personal_project/domain/reporsitory/auth_reposotory.dart';
import 'package:personal_project/presentation/assets/images.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/router/route_utils.dart';
import 'package:personal_project/presentation/ui/add_details/bloc/upload_bloc.dart';
import 'package:personal_project/presentation/ui/auth/auth.dart';
import 'package:video_compress/video_compress.dart';

class AddDetailsPage extends StatelessWidget {
  final File videoFile;
  AddDetailsPage({super.key, required this.videoFile});

  final TextEditingController textEditingController = TextEditingController();

  Future<File> _getTumbnail() async {
    final thumbnailFile = await VideoCompress.getFileThumbnail(videoFile.path,
        quality: 50, // default(100)
        position: -1 // default(-1)
        );
    return thumbnailFile;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        // Dismiss the keyboard when tapping outside of text fields
        debugPrint('unfocus');
        FocusScope.of(context).unfocus();
      },
      child: BlocListener<UploadBloc, UploadState>(
        listener: (context, state) {
          if (state is Uploading) {
            context.go(APP_PAGE.home.toPath);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(LocaleKeys.title_upload.tr()),
            foregroundColor: COLOR_black,
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            actions: [
              Builder(builder: (context) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Material(
                    child: Container(
                      width: Dimens.DIMENS_60,
                      decoration: BoxDecoration(
                          color: COLOR_grey,
                          borderRadius: BorderRadius.circular(8)),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: COLOR_white_fff5f5f5,
                          onTap: () {
                            var isUserEmpty =
                                RepositoryProvider.of<AuthRepository>(context)
                                    .currentUser;
                            if (isUserEmpty == null) {
                              showAuthBottomSheetFunc(context);
                            } else {
                              //will upload videos
                              BlocProvider.of<UploadBloc>(context).add(
                                UploadVideoEvent(
                                    videoPath: videoFile.path,
                                    caption: textEditingController.text),
                              );
                              debugPrint('Uploading');
                            }
                          },
                          child: UnconstrainedBox(
                            child: SvgPicture.asset(
                              Images.IC_UPLOAD,
                              width: Dimens.DIMENS_24,
                              height: Dimens.DIMENS_24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
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
                    child: FutureBuilder(
                      future: _getTumbnail(),
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
              SizedBox(
                height: Dimens.DIMENS_28,
              ),
              Container(
                height: Dimens.DIMENS_38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: COLOR_black_ff121212,
                    borderRadius: BorderRadius.circular(50)),
                child: Material(
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
                      } else {
                        //will upload videos
                        BlocProvider.of<UploadBloc>(context).add(
                          UploadVideoEvent(
                              videoPath: videoFile.path,
                              caption: textEditingController.text),
                        );
                        debugPrint('Uploading');
                      }
                    },
                    child: SizedBox(
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
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

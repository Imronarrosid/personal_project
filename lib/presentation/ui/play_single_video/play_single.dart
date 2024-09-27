import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/domain/model/play_single_data.dart';
import 'package:personal_project/domain/model/video_model.dart';
import 'package:personal_project/domain/reporsitory/video_repository.dart';
import 'package:personal_project/domain/services/firebase/firebase_service.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/responsive/dimension.dart';
import 'package:personal_project/presentation/responsive/responsive_layout.dart';
import 'package:personal_project/presentation/router/app_router.dart';
import 'package:personal_project/presentation/shared_components/handel_back_button.dart';
import 'package:personal_project/presentation/shared_components/video_player_item.dart';
import 'package:personal_project/presentation/ui/comments/comments_page.dart';
import 'package:provider/provider.dart';

class PlaySingleVideoPage extends StatelessWidget {
  final PlaySingleData? data;
  const PlaySingleVideoPage({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    return HandleBackButton(
      child: Padding(
        padding: MediaQuery.of(context).size.width > mobileWidth
            ? const EdgeInsets.all(8.0)
            : EdgeInsets.zero,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.black,
          appBar: MediaQuery.of(context).size.width > mobileWidth
              ? null
              : AppBar(
                  leading:
                      BackButton(onPressed: () => _backButtonHanlde(context)),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
          body: Stack(
            children: [
              StreamBuilder<Video>(
                  stream: context.read<VideoRepository>().videoStream(
                      GoRouterState.of(context).pathParameters['postId'] ?? ''),
                  builder: (context, snapshot) {
                    final Video? data = snapshot.data;
                    if (!snapshot.hasData) {
                      return Container(
                        color: Theme.of(context).colorScheme.background,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    return Center(
                        child: Scaffold(
                      resizeToAvoidBottomInset: false,
                      extendBodyBehindAppBar: true,
                      backgroundColor:
                          MediaQuery.of(context).size.width > mobileWidth
                              ? Theme.of(context).colorScheme.background
                              : Colors.black,
                      body: VideoPlayerItem(
                        index: 0,
                        url: data!.uid,
                        item: data,
                        isForLogedUserVideo:
                            data.uid == (firebaseAuth.currentUser?.uid ?? ''),
                      ),
                      bottomNavigationBar: MediaQuery.of(context).size.width >
                              mobileWidth
                          ? null
                          : InkWell(
                              splashFactory: NoSplash.splashFactory,
                              splashColor: Colors.transparent,
                              overlayColor:
                                  const MaterialStatePropertyAll<Color>(
                                      Colors.transparent),
                              onTap: () {
                                showCommentsBottomSheet(
                                  context,
                                  postId: data.id!,
                                );
                              },
                              child: Container(
                                decoration:
                                    BoxDecoration(color: COLOR_black_900),
                                height: Dimens.DIMENS_50,
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.only(
                                  left: Dimens.DIMENS_12,
                                ),
                                alignment: Alignment.centerLeft,
                                child:
                                    Text(LocaleKeys.message_add_comments.tr()),
                              ),
                            ),
                    ));
                  }),
              ResponsiveLayout(
                mobileBody: const SizedBox(
                  height: 0,
                  width: 0,
                ),
                desktopBody: SafeArea(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: BackButton(
                      onPressed: () => _backButtonHanlde(context),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _backButtonHanlde(BuildContext context) {
    final AppRouter appRouter = Provider.of(context, listen: false);

    appRouter.onBackButtonPressed(context);
  }
}

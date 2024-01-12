import 'dart:async';

import 'package:chips_choice/chips_choice.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/domain/model/game_fav_modal.dart';
import 'package:personal_project/domain/reporsitory/user_repository.dart';
import 'package:personal_project/domain/services/app/app_service.dart';
import 'package:personal_project/presentation/assets/images.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/router/route_utils.dart';
import 'package:provider/provider.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key});

  @override
  State<OnBoardingPage> createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  List<String> titleList = [];
  late final PageController _controller;
  int _currentPage = 0;

  @override
  void initState() {
    _controller = PageController(initialPage: 0);
    toSecondPage();
    super.initState();
  }

  void toSecondPage() {
    Future.delayed(const Duration(milliseconds: 3300), () {
      _controller.animateToPage(
        2,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    UserRepository userRepository =
        RepositoryProvider.of<UserRepository>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: Dimens.DIMENS_12),
          child: GestureDetector(
            onTap: cancel,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                LocaleKeys.label_skip.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.6)),
              ),
            ),
          ),
        ),
        leadingWidth: Dimens.DIMENS_70,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: Dimens.DIMENS_12),
            child: InkWell(
              onTap: titleList.isNotEmpty
                  ? _saveSelected
                  : () {
                      if (_currentPage == 0) {
                        setState(() {
                          _controller.animateToPage(
                            2,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          );
                        });
                      }
                      {}
                    },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: Dimens.DIMENS_42,
                padding: EdgeInsets.symmetric(horizontal: Dimens.DIMENS_15),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: titleList.isEmpty
                        ? Theme.of(context).colorScheme.tertiary
                        : Theme.of(context).colorScheme.onTertiary),
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    LocaleKeys.label_next.tr(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 150,
              child: PageView(
                controller: _controller,
                onPageChanged: (value) {
                  setState(() {
                    _currentPage = value;
                  });
                },
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height - 200,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          SizedBox(
                            height: Dimens.DIMENS_60,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Text(
                              LocaleKeys.message_gaming_and_win.tr(),
                              textAlign: TextAlign.left,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge!
                                  .apply(fontWeightDelta: 2),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Text(
                              LocaleKeys.message_share_gaming_content.tr(),
                              textAlign: TextAlign.left,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .apply(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.7)),
                            ),
                          ),
                          Image.asset(
                            Images.IC_GAMEPIUN,
                            width: Dimens.DIMENS_250,
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height - 200,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(
                                left: Dimens.DIMENS_12, top: Dimens.DIMENS_12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  LocaleKeys.label_favorite_games.tr(),
                                  style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900),
                                ),
                                SizedBox(
                                  height: Dimens.DIMENS_16,
                                ),
                                Text(
                                  LocaleKeys.message_select_your_game_favorite
                                      .tr(),
                                  style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900),
                                ),
                              ],
                            ),
                          ),
                          FutureBuilder(
                              future: userRepository.getAllGameFav(),
                              builder: (context, snapshot) {
                                List<GameFav> gameFav = snapshot.data ?? [];
                                List<String> gameOptions = [];
                                for (var element in gameFav) {
                                  gameOptions.add(element.gameTitle!);
                                }
                                if (snapshot.hasData && gameFav.isNotEmpty) {
                                  return ChipsChoice<String>.multiple(
                                    value: titleList,
                                    onChanged: (val) =>
                                        setState(() => titleList = val),
                                    choiceItems:
                                        C2Choice.listFrom<String, String>(
                                      source: gameOptions,
                                      value: (i, v) => gameOptions[i],
                                      label: (i, v) => v,
                                      tooltip: (i, v) => v,
                                      avatarImage: (index, item) =>
                                          NetworkImage(
                                              gameFav[index].gameImage!),
                                    ),
                                    choiceStyle: C2ChipStyle.toned(
                                      selectedStyle: C2ChipStyle.filled(),
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(50),
                                      ),
                                    ),
                                    // leading: IconButton(
                                    //   tooltip: 'Add Choice',
                                    //   icon: const Icon(Icons.add_box_rounded),
                                    //   onPressed: () => setState(
                                    //     () => options.add('Opt #${options.length + 1}'),
                                    //   ),
                                    // ),
                                    // trailing: IconButton(
                                    //   tooltip: 'Remove Choice',
                                    //   icon: const Icon(Icons.remove_circle),
                                    //   onPressed: () => setState(() => options.removeLast()),
                                    // ),
                                    wrapped: true,
                                  );
                                } else {
                                  return const Expanded(
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                              }),
                        ]),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: Dimens.DIMENS_25,
              width: MediaQuery.of(context).size.width,
              child: DotsIndicator(
                dotsCount: 2,
                position: _currentPage,
                onTap: (position) {
                  setState(() {
                    _controller.animateToPage(position,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn);
                  });
                },
                decorator: DotsDecorator(
                  size: const Size.square(9.0),
                  activeSize: const Size(18.0, 9.0),
                  activeShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  activeColor: Theme.of(context).colorScheme.onTertiary,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void cancel() {
    final appService = Provider.of<AppService>(context, listen: false);
    appService.onboarding = true;
    context.pushReplacement(APP_PAGE.home.toPath);
  }

  void _saveSelected() {
    final appService = Provider.of<AppService>(context, listen: false);
    appService.onboarding = true;
    appService.saveSelectedGamefav(titleList);
    context.pushReplacement(APP_PAGE.home.toPath);
  }
}

import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/domain/model/game_fav_modal.dart';
import 'package:personal_project/domain/reporsitory/user_repository.dart';
import 'package:personal_project/domain/services/app/app_service.dart';
import 'package:personal_project/presentation/router/route_utils.dart';
import 'package:provider/provider.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key});

  @override
  State<OnBoardingPage> createState() => _OnBoardingPageState();
}

List<String> titleList = [];

class _OnBoardingPageState extends State<OnBoardingPage> {
  @override
  Widget build(BuildContext context) {
    final appService = Provider.of<AppService>(context);
    UserRepository userRepository =
        RepositoryProvider.of<UserRepository>(context);

    return Scaffold(
      appBar: AppBar(
        foregroundColor: COLOR_black_ff121212,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: cancel,
          child: Align(
            alignment: Alignment.center,
            child: Text(
              'Lewati',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: COLOR_black_ff121212.withOpacity(0.6)),
            ),
          ),
        ),
        leadingWidth: Dimens.DIMENS_70,
        actions: [
          GestureDetector(
            onTap: titleList.isNotEmpty ? _saveSelected : null,
            child: Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Selanjutnya',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: COLOR_black_ff121212),
                ),
              ),
            ),
          )
        ],
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding:
              EdgeInsets.only(left: Dimens.DIMENS_12, top: Dimens.DIMENS_12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Game Favorite',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              SizedBox(
                height: Dimens.DIMENS_16,
              ),
              const Text(
                'Pilih game favorit Kamu',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
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
                  onChanged: (val) => setState(() => titleList = val),
                  choiceItems: C2Choice.listFrom<String, String>(
                    source: gameOptions,
                    value: (i, v) => gameOptions[i],
                    label: (i, v) => v,
                    tooltip: (i, v) => v,
                    avatarImage: (index, item) =>
                        NetworkImage(gameFav[index].gameImage!),
                  ),
                  choiceStyle: C2ChipStyle.toned(
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
    );
  }

  void cancel() {
    final appService = Provider.of<AppService>(context);
    appService.onboarding = true;
    context.pushReplacement(APP_PAGE.home.toPath);
  }

  void _saveSelected() {
    final appService = Provider.of<AppService>(context);
    appService.onboarding = true;
    appService.saveSelectedGamefav(titleList);
    context.pushReplacement(APP_PAGE.home.toPath);
  }
}

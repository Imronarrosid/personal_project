import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/domain/model/game_fav_modal.dart';
import 'package:personal_project/domain/reporsitory/user_repository.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/ui/edit_profile/cubit/game_fav_cubit.dart';

class EditGameFavPage extends StatefulWidget {
  final List<GameFav> gameFav;
  const EditGameFavPage({super.key, required this.gameFav});

  @override
  State<EditGameFavPage> createState() => _EditGameFavPageState();
}

class _EditGameFavPageState extends State<EditGameFavPage> {
  List<String> titleList = [];

  ///Get list game title from previouse game selected.
  ///
  ///Store list to[titleList].
  void _getGameTitle() {
    for (var element in widget.gameFav) {
      titleList.add(element.gameTitle!);
    }
  }

  @override
  void initState() {
    _getGameTitle();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    UserRepository userRepository =
        RepositoryProvider.of<UserRepository>(context);
    return BlocListener<GameFavCubit, GameFavState>(
      listener: gameFavListener,
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: COLOR_black_ff121212,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: cancel,
            icon: Icon(MdiIcons.close),
          ),
          actions: [
            IconButton(
              onPressed: save,
              icon: Icon(MdiIcons.check),
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
                Text(
                  LocaleKeys.label_favorite_games.tr(),
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: Dimens.DIMENS_16,
                ),
                Text(
                  LocaleKeys.message_select_your_game_favorite.tr(),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          FutureBuilder(
              future: userRepository.getAllGameFav(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container();
                }
                List<GameFav> gameFav = snapshot.data!;
                List<String> gameOptions = [];
                for (var element in gameFav) {
                  gameOptions.add(element.gameTitle!);
                }
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
                    selectedStyle: C2ChipStyle.filled(),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(5),
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
              }),
        ]),
      ),
    );
  }

  void save() async {
    List<GameFav> games = [];
    UserRepository userRepository =
        RepositoryProvider.of<UserRepository>(context);
    final List<GameFav> allGames = await userRepository.getAllGameFav();
    for (var title in titleList) {
      GameFav game =
          allGames.firstWhere((element) => element.gameTitle == title);
      games.add(game);
    }
    if (mounted) {
      BlocProvider.of<GameFavCubit>(context).editGameFav(titleList, games);
    }
  }

  void cancel() {
    context.pop();
  }

  void gameFavListener(BuildContext context, GameFavState state) {
    if (state.sattus == GameFavSattus.loading) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
                child: CircularProgressIndicator(),
              ));
    } else if (state.sattus == GameFavSattus.succes) {
      context.pop();
      context.pop();
    } else if (state.sattus == GameFavSattus.error) {
      context.pop();
    }
  }
}

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/domain/model/game_fav_modal.dart';
import 'package:personal_project/domain/model/user.dart';
import 'package:personal_project/domain/reporsitory/auth_reposotory.dart';
import 'package:personal_project/domain/reporsitory/user_repository.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/responsive/dimension.dart';
import 'package:personal_project/presentation/shared_components/handel_back_button.dart';
import 'package:personal_project/presentation/ui/edit_profile/cubit/edit_bio_cubit.dart';
import 'package:personal_project/presentation/ui/edit_profile/cubit/edit_profile_pict_cubit.dart';
import 'package:personal_project/presentation/ui/edit_profile/cubit/edit_user_name_cubit.dart';
import 'package:personal_project/presentation/ui/edit_profile/cubit/game_fav_cubit.dart';
import 'package:personal_project/presentation/ui/edit_profile/edit_modal/edit_bio_modal.dart';
import 'package:personal_project/presentation/ui/edit_profile/edit_modal/edit_name_modal.dart';
import 'package:personal_project/presentation/ui/edit_profile/edit_modal/edit_profilr_picture_modal.dart';
import 'package:personal_project/presentation/ui/edit_profile/edit_modal/edit_user_name_modal.dart';
import 'package:personal_project/presentation/ui/edit_profile/cubit/edit_name_cubit.dart';
import 'package:provider/provider.dart';
import 'package:solar_icons/solar_icons.dart';

import '../../router/app_router.dart';
import 'edit_page/edit_game_fav_page.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  Timestamp? lastUpdate;

  Timestamp? userNameUpdatedAt;

  List<GameFav>? games;

  String? bio;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    final AuthRepository authRepository =
        RepositoryProvider.of<AuthRepository>(context);
    final UserRepository userRepository =
        RepositoryProvider.of<UserRepository>(context);

    return BlocListener<EditProfilePictCubit, EditProfilePictState>(
      listener: (context, state) {
        if (state.status == EditProfilePicStatus.loading) {
          Fluttertoast.showToast(
              msg:
                  '${LocaleKeys.message_uploading.tr()} ${LocaleKeys.label_profile_pict.tr().toLowerCase()}',
              textColor: Theme.of(context).colorScheme.primary,
              gravity: ToastGravity.TOP);
        }
        if (state.status == EditProfilePicStatus.success) {
          Fluttertoast.showToast(
              msg: LocaleKeys.message_profile_picture_chaged.tr(),
              textColor: Theme.of(context).colorScheme.primary,
              gravity: ToastGravity.TOP);
        }
      },
      child: HandleBackButton(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            leading: BackButton(
              onPressed: () {
                Provider.of<AppRouter>(context, listen: false)
                    .onBackButtonPressed(context);
              },
            ),
            title: Text(
              LocaleKeys.label_edit_profile.tr(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: FutureBuilder(
              future:
                  authRepository.getUserData(authRepository.currentUser!.uid),
              builder: (context, snapshot) {
                User? user = snapshot.data;
                if (snapshot.hasData) {
                  lastUpdate = snapshot.data!.nameUpdatedAt;
                  userNameUpdatedAt = snapshot.data?.userNameUpdatedAt;
                }
                if (!snapshot.hasData || snapshot.hasError) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: Dimens.DIMENS_12),
                  width: size.width,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: Dimens.DIMENS_16),
                        StreamBuilder<String>(
                            stream: userRepository.getAvatar(user!.id),
                            builder: (context, snapshot) {
                              String? avatar = snapshot.data;
                              if (!snapshot.hasData) {
                                return Align(
                                  alignment: Alignment.center,
                                  child: CircleAvatar(
                                    radius: Dimens.DIMENS_42,
                                    foregroundColor:
                                        Theme.of(context).colorScheme.tertiary,
                                    backgroundColor:
                                        Theme.of(context).colorScheme.tertiary,
                                  ),
                                );
                              }
                              return Align(
                                alignment: Alignment.center,
                                child: CircleAvatar(
                                  radius: Dimens.DIMENS_42,
                                  foregroundColor:
                                      Theme.of(context).colorScheme.tertiary,
                                  backgroundColor:
                                      Theme.of(context).colorScheme.tertiary,
                                  foregroundImage:
                                      CachedNetworkImageProvider(avatar!),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: () {
                                        showEditPPModal(context);
                                      },
                                      icon: const Icon(BootstrapIcons.camera),
                                    ),
                                  ),
                                ),
                              );
                            }),
                        ListTile(
                          isThreeLine: true,
                          title: Text(
                            LocaleKeys.label_name.tr(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          trailing: BlocConsumer<EditNameCubit, EditNameState>(
                            listener: (context, state) {
                              if (state.status ==
                                  EditNameStatus.nameEditSuccess) {
                                lastUpdate = Timestamp.now();
                              }
                            },
                            builder: (context, state) {
                              return IconButton(
                                  onPressed: () {
                                    // context.push(APP_PAGE.editName.toPath, extra: editNata);
                                    showEditNameModal(
                                        context,
                                        state.status ==
                                                EditNameStatus.nameEditSuccess
                                            ? state.name!
                                            : user.name!,
                                        lastUpdate!,
                                        user.createdAt!);
                                  },
                                  icon: const Icon(SolarIconsOutline.pen));
                            },
                          ),
                          subtitle: BlocBuilder<EditNameCubit, EditNameState>(
                            builder: (context, state) {
                              if (state.status == EditNameStatus.initial) {
                                return Text(
                                  user.name!,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                );
                              }
                              return Text(
                                state.status == EditNameStatus.nameEditSuccess
                                    ? state.name!
                                    : user.name!,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              );
                            },
                          ),
                        ),
                        ListTile(
                          isThreeLine: true,
                          trailing: BlocConsumer<EditUserNameCubit,
                              EditUserNameState>(
                            listener: (context, state) {
                              if (state.status == EditUserNameStatus.success) {
                                userNameUpdatedAt = Timestamp.now();
                              }
                            },
                            builder: (context, state) {
                              return IconButton(
                                  onPressed: () {
                                    showEditUserNameModal(context,
                                        userName: user.userName!,
                                        lastUpdate: userNameUpdatedAt!,
                                        userCreatedAt:
                                            snapshot.data!.createdAt!);
                                  },
                                  icon: const Icon(SolarIconsOutline.pen));
                            },
                          ),
                          title: Text(
                            LocaleKeys.label_user_name.tr(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle:
                              BlocBuilder<EditUserNameCubit, EditUserNameState>(
                            builder: (context, state) {
                              debugPrint('state ${state.status}');
                              if (state.status == EditUserNameStatus.initial) {
                                return Text(
                                  user.userName!,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                );
                              }
                              return Text(
                                state.status == EditUserNameStatus.success
                                    ? state.newUserName!
                                    : user.userName!,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              );
                            },
                          ),
                        ),
                        ListTile(
                          isThreeLine: true,
                          title: Text(
                            LocaleKeys.label_bio.tr(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          trailing: IconButton(
                              onPressed: () {
                                showEditBioMpdal(context, bio: bio!);
                              },
                              icon: const Icon(SolarIconsOutline.pen)),
                          subtitle: FutureBuilder(
                              future: userRepository
                                  .getBio(authRepository.currentUser!.uid),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  bio = snapshot.data;
                                }
                                if (!snapshot.hasData) {
                                  return Container();
                                }
                                debugPrint('abc bio $bio');
                                return BlocBuilder<EditBioCubit, EditBioState>(
                                  builder: (context, state) {
                                    if (state.status == EditBioStatus.succes) {
                                      bio = state.bio!;
                                    }
                                    debugPrint('abc $bio stts ${state.status}');
                                    return Text(
                                      bio!,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    );
                                  },
                                );
                              }),
                        ),
                        ListTile(
                          trailing: IconButton(
                              onPressed: () {
                                debugPrint(games.toString());
                                if (games != null) {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        if (MediaQuery.of(context).size.width >
                                            mobileWidth) {
                                          return Dialog(
                                            clipBehavior: Clip.hardEdge,
                                            child: SizedBox(
                                              width: 600,
                                              height: 800,
                                              child: BackButtonListener(
                                                onBackButtonPressed: () async {
                                                  context.pop();
                                                  return true;
                                                },
                                                child: EditGameFavPage(
                                                  gameFav: [...games!],
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                        return Dialog.fullscreen(
                                          child: BackButtonListener(
                                            onBackButtonPressed: () async {
                                              context.pop();
                                              return true;
                                            },
                                            child: EditGameFavPage(
                                              gameFav: [...games!],
                                            ),
                                          ),
                                        );
                                      });
                                }
                              },
                              icon: const Icon(SolarIconsOutline.pen)),
                          isThreeLine: true,
                          title: Text(
                            LocaleKeys.label_favorite_games.tr(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: FutureBuilder(
                              future: userRepository.getSelectedGames(
                                  authRepository.currentUser!.uid),
                              builder: (context, snapshot) {
                                debugPrint('poiuy  ${snapshot.data}');
                                if (snapshot.hasData) {
                                  games = snapshot.data;
                                }
                                if (!snapshot.hasData || snapshot.hasError) {
                                  return Container();
                                }

                                return BlocBuilder<GameFavCubit, GameFavState>(
                                  builder: (context, state) {
                                    if (state.sattus == GameFavSattus.succes) {
                                      games = state.gameFav!;
                                      return Wrap(
                                          spacing: Dimens.DIMENS_6,
                                          runSpacing: Dimens.DIMENS_6,
                                          children: List<Chip>.generate(
                                            games!.length,
                                            (index) => Chip(
                                              side: BorderSide.none,
                                              avatar: CircleAvatar(
                                                backgroundColor: COLOR_grey,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                  child: CachedNetworkImage(
                                                    imageUrl: games![index]
                                                        .gameImage!,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              label: Text(
                                                  games![index].gameTitle!),
                                            ),
                                          ).toList());
                                    }
                                    return Wrap(
                                        spacing: Dimens.DIMENS_6,
                                        runSpacing: Dimens.DIMENS_6,
                                        children: List<Chip>.generate(
                                          games!.length,
                                          (index) => Chip(
                                            side: BorderSide.none,
                                            avatar: CircleAvatar(
                                              backgroundColor: COLOR_grey,
                                              backgroundImage:
                                                  CachedNetworkImageProvider(
                                                      games![index].gameImage!),
                                            ),
                                            label:
                                                Text(games![index].gameTitle!),
                                          ),
                                        ).toList());
                                  },
                                );
                              }),
                        ),
                      ],
                    ),
                  ),
                );
              }),
        ),
      ),
    );
  }
}

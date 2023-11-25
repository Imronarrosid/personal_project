import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/domain/model/game_fav_modal.dart';
import 'package:personal_project/domain/model/profile_data_model.dart';
import 'package:personal_project/presentation/router/route_utils.dart';
import 'package:personal_project/presentation/ui/edit_profile/cubit/edit_bio_cubit.dart';
import 'package:personal_project/presentation/ui/edit_profile/cubit/edit_profile_pict_cubit.dart';
import 'package:personal_project/presentation/ui/edit_profile/cubit/edit_user_name_cubit.dart';
import 'package:personal_project/presentation/ui/edit_profile/cubit/game_fav_cubit.dart';
import 'package:personal_project/presentation/ui/edit_profile/edit_modal/edit_bio_modal.dart';
import 'package:personal_project/presentation/ui/edit_profile/edit_modal/edit_name_modal.dart';
import 'package:personal_project/presentation/ui/edit_profile/edit_modal/edit_profilr_picture_modal.dart';
import 'package:personal_project/presentation/ui/edit_profile/edit_modal/edit_user_name_modal.dart';
import 'package:personal_project/presentation/ui/edit_profile/cubit/edit_name_cubit.dart';
import 'package:personal_project/presentation/ui/edit_profile/edit_page/edit_game_fav_page.dart';

class EditProfile extends StatelessWidget {
  final ProfileData data;
  const EditProfile({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    Timestamp lastUpdate = data.updatedAt;
    Timestamp userNameUpdatedAt = data.userNameUpdatedAt;
    final List<Chip> chips = List<Chip>.generate(
      data.gameFav.length,
      (index) => Chip(
        avatar: CircleAvatar(
            backgroundColor: COLOR_grey,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: CachedNetworkImage(
                  imageUrl: data.gameFav[index].gameImage!,
                  fit: BoxFit.cover,
                ))),
        label: Text(data.gameFav[index].gameTitle!),
      ),
    ).toList();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Edit Profil'),
        foregroundColor: COLOR_black_ff121212,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: Dimens.DIMENS_12),
        width: size.width,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: Dimens.DIMENS_16),
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: 90,
                  height: 90,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: BlocBuilder<EditProfilePictCubit,
                            EditProfilePictState>(
                          builder: (context, state) {
                            if (state.status == EditProfilePicStatus.success) {
                              return Image.file(
                                state.imageFile!,
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                              );
                            }
                            return CachedNetworkImage(
                              imageUrl: data.photoUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            );
                          },
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              showEditPPModal(context);
                            },
                            icon: Icon(MdiIcons.cameraOutline)),
                      )
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nama'),
                      BlocBuilder<EditNameCubit, EditNameState>(
                        builder: (context, state) {
                          if (state.status == EditNameStatus.initial) {
                            return Text(
                              data.name,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            );
                          }
                          return Text(
                            state.status == EditNameStatus.nameEditSuccess
                                ? state.name!
                                : data.name,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          );
                        },
                      ),
                    ],
                  ),
                  BlocConsumer<EditNameCubit, EditNameState>(
                    listener: (context, state) {
                      if (state.status == EditNameStatus.nameEditSuccess) {
                        lastUpdate = Timestamp.now();
                      }
                    },
                    builder: (context, state) {
                      return IconButton(
                          onPressed: () {
                            // context.push(APP_PAGE.editName.toPath, extra: editNata);
                            showEditNameModal(
                                context,
                                state.status == EditNameStatus.nameEditSuccess
                                    ? state.name!
                                    : data.name,
                                lastUpdate);
                          },
                          icon: Icon(MdiIcons.pencilOutline));
                    },
                  )
                ],
              ),
              Divider(
                color: COLOR_grey,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nama pengguna'),
                      BlocBuilder<EditUserNameCubit, EditUserNameState>(
                        builder: (context, state) {
                          debugPrint('state ${state.status}');
                          if (state.status == EditUserNameStatus.initial) {
                            return Text(
                              data.userName,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            );
                          }
                          return Text(
                            state.status == EditUserNameStatus.success
                                ? state.newUserName!
                                : data.name,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          );
                        },
                      ),
                    ],
                  ),
                  BlocConsumer<EditUserNameCubit, EditUserNameState>(
                    listener: (context, state) {
                      if (state.status == EditUserNameStatus.success) {
                        userNameUpdatedAt = Timestamp.now();
                      }
                    },
                    builder: (context, state) {
                      return IconButton(
                          onPressed: () {
                            showEditUserNameModal(context,
                                userName: data.userName,
                                lastUpdate: data.userNameUpdatedAt);
                          },
                          icon: Icon(MdiIcons.pencilOutline));
                    },
                  )
                ],
              ),
              Divider(
                color: COLOR_grey,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bio'),
                      BlocBuilder<EditBioCubit, EditBioState>(
                        builder: (context, state) {
                          String bio = data.bio;
                          if (state.status == EditBioStatus.succes) {
                            bio = state.bio!;
                          }
                          return Text(
                            bio,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          );
                        },
                      ),
                    ],
                  ),
                  BlocBuilder<EditBioCubit, EditBioState>(
                    builder: (_, state) {
                      String bio = data.bio;
                      if (state.status == EditBioStatus.succes) {
                        bio = state.bio!;
                      }
                      return IconButton(
                          onPressed: () {
                            showEditBioMpdal(context, bio: bio);
                          },
                          icon: Icon(MdiIcons.pencilOutline));
                    },
                  )
                ],
              ),
              Divider(
                color: COLOR_grey,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Game favorit'),
                        BlocBuilder<GameFavCubit, GameFavState>(
                          builder: (context, state) {
                            if (state.sattus == GameFavSattus.succes) {
                              List<GameFav> games = state.gameFav!;
                              return Wrap(
                                  children: List<Chip>.generate(
                                games.length,
                                (index) => Chip(
                                  avatar: CircleAvatar(
                                    backgroundColor: COLOR_grey,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: CachedNetworkImage(
                                        imageUrl: games[index].gameImage!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  label: Text(games[index].gameTitle!),
                                ),
                              ).toList());
                            }
                            return Wrap(children: chips);
                          },
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        context.push(APP_PAGE.editGameFav.toPath,
                            extra: data.gameFav);
                      },
                      icon: Icon(MdiIcons.pencilOutline))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

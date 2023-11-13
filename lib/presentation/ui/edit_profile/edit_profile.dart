import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/domain/model/profile_data_model.dart';
import 'package:personal_project/presentation/router/route_utils.dart';
import 'package:personal_project/presentation/ui/comments/edit_modal/edit_bio_modal.dart';
import 'package:personal_project/presentation/ui/comments/edit_modal/edit_name_modal.dart';
import 'package:personal_project/presentation/ui/comments/edit_modal/edit_user_name_modal.dart';
import 'package:personal_project/presentation/ui/edit_profile/edit_page/edit_game_fav_page.dart';

class EditProfile extends StatelessWidget {
  final ProfileData data;
  const EditProfile({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profil'),
        foregroundColor: COLOR_black_ff121212,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: Dimens.DIMENS_12),
        width: size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: Dimens.DIMENS_16),
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: 70,
                height: 70,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: CachedNetworkImage(imageUrl: data.photoUrl),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Icon(MdiIcons.cameraOutline),
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
                    Text(
                      data.name,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                IconButton(
                    onPressed: () {
                      // context.push(APP_PAGE.editName.toPath, extra: editNata);
                      showEditNameModal(context);
                    },
                    icon: Icon(MdiIcons.pencilOutline))
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
                    Text(
                      data.name,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                IconButton(
                    onPressed: () {
                      showEditUserNameModal(context);
                    },
                    icon: Icon(MdiIcons.pencilOutline))
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
                    Text(
                      data.bio,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                IconButton(
                    onPressed: () {
                      showEditBioMpdal(context);
                    },
                    icon: Icon(MdiIcons.pencilOutline))
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
                      Wrap(
                        children: [
                          Chip(
                            avatar: CircleAvatar(
                                backgroundColor: Colors.blue.shade900,
                                child: const Text('HM')),
                            label: const Text('Mulligan'),
                          ),
                          Chip(
                            avatar: CircleAvatar(
                                backgroundColor: Colors.blue.shade900,
                                child: const Text('ML')),
                            label: const Text('Lafayette'),
                          ),
                          Chip(
                            avatar: CircleAvatar(
                                backgroundColor: Colors.blue.shade900,
                                child: const Text('ML')),
                            label: const Text('Lafayette'),
                          ),
                          Chip(
                            avatar: CircleAvatar(
                                backgroundColor: Colors.blue.shade900,
                                child: const Text('ML')),
                            label: const Text('Lafayette'),
                          ),
                          Chip(
                            avatar: CircleAvatar(
                                backgroundColor: Colors.blue.shade900,
                                child: const Text('HM')),
                            label: const Text(
                              'Mulligan',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return EditGameFavPage();
                      }));
                    },
                    icon: Icon(MdiIcons.pencilOutline))
              ],
            )
          ],
        ),
      ),
    );
  }
}

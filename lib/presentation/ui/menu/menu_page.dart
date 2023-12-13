import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/domain/reporsitory/auth_reposotory.dart';
import 'package:personal_project/domain/reporsitory/user_repository.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/router/route_utils.dart';
import 'package:personal_project/presentation/ui/auth/bloc/auth_bloc.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    AuthRepository authRepository =
        RepositoryProvider.of<AuthRepository>(context);
    final UserRepository userRepository =
        RepositoryProvider.of<UserRepository>(context);
//  User user =            authRepository.getVideoOwnerData(authRepository.currentUser!.uid);
    return Scaffold(
      backgroundColor: COLOR_white_fff5f5f5,
      appBar: AppBar(
        foregroundColor: COLOR_black_ff121212,
        backgroundColor: COLOR_white_fff5f5f5,
        elevation: 0,
        title: Text(LocaleKeys.title_menu.tr()),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimens.DIMENS_12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            height: Dimens.DIMENS_42,
          ),
          _menuTitle(LocaleKeys.label_account.tr()),
          SizedBox(
            height: Dimens.DIMENS_8,
          ),
          BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
            if (state.status == AuthStatus.notAuthenticated) {
              return ListTile(
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                leading: CircleAvatar(
                  backgroundColor: COLOR_grey,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Icon(MdiIcons.account),
                  ),
                ),
                title: Text(LocaleKeys.label_account.tr()),
              );
            }
            return ListTile(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              leading: CircleAvatar(
                backgroundColor: Colors.transparent,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: CachedNetworkImage(
                    imageUrl: userRepository.getPhotoURL,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
              title: Text('@${userRepository.getUserName}'),
              trailing: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                decoration: BoxDecoration(
                    color: COLOR_black_ff121212,
                    borderRadius: BorderRadius.circular(5)),
                child: Text(
                  LocaleKeys.label_logout.tr(),
                  style: TextStyle(color: COLOR_white_fff5f5f5),
                ),
              ),
            );
          }),
          SizedBox(
            height: Dimens.DIMENS_16,
          ),
          _menuTitle(LocaleKeys.label_settings.tr()),
          SizedBox(
            height: Dimens.DIMENS_8,
          ),
          ListTile(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            tileColor: Colors.white,
            leading: Icon(MdiIcons.web),
            title: Text(LocaleKeys.title_language.tr()),
            onTap: () {
              context.push(APP_PAGE.languagePage.toPath);
            },
          ),
          ListTile(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            tileColor: Colors.white,
            leading: Icon(MdiIcons.database),
            title: Text(LocaleKeys.title_storage.tr()),
            onTap: () {
              context.push(APP_PAGE.cachesPage.toPath);
            },
          ),
          SizedBox(
            height: Dimens.DIMENS_8,
          ),
          FutureBuilder(
              future: authRepository.isAdmin(authRepository.currentUser!.uid),
              builder: (context, AsyncSnapshot<bool> snapshot) {
                if (!snapshot.hasData ||
                    snapshot.hasError ||
                    snapshot.data == false) {
                  return Container();
                }

                return ListTile(
                  tileColor: COLOR_grey,
                  onTap: () {
                    context.push(APP_PAGE.addGameFav.toPath);
                  },
                );
              }),
        ]),
      ),
    );
  }

  Text _menuTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
    );
  }
}

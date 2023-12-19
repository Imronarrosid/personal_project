import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:personal_project/domain/model/user.dart' as models;
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
import 'package:personal_project/presentation/ui/auth/auth.dart';
import 'package:personal_project/presentation/ui/auth/bloc/auth_bloc.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({
    super.key,
  });

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String? name, userName, photoURL;
  Future<models.User>? futureUserData1;

  @override
  void initState() {
    final authRepository = RepositoryProvider.of<AuthRepository>(context);
    final bool isAuthenticated = authRepository.currentUser != null;

    if (isAuthenticated) {
      // name = widget.payload!.name;
      // userName = '@${widget.payload!.userName}';
      // photoURL = widget.payload!.photoURL;
      // debugPrint('photo ${photoURL}');

      final UserRepository repository =
          RepositoryProvider.of<UserRepository>(context);

      if (isAuthenticated) {
        futureUserData1 =
            repository.getUserData1(authRepository.currentUser!.uid);
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AuthRepository authRepository =
        RepositoryProvider.of<AuthRepository>(context);
    final UserRepository userRepository =
        RepositoryProvider.of<UserRepository>(context);
//  User user =            authRepository.getVideoOwnerData(authRepository.currentUser!.uid);
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          futureUserData1 = userRepository.getUserData1(state.user!.id);

          context.go(APP_PAGE.home.toPath);
        }
      },
      child: Scaffold(
        backgroundColor: COLOR_white_fff5f5f5,
        appBar: AppBar(
          foregroundColor: COLOR_black_ff121212,
          backgroundColor: COLOR_white_fff5f5f5,
          elevation: 0,
          title: Text(LocaleKeys.title_menu.tr()),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimens.DIMENS_12),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              height: Dimens.DIMENS_42,
            ),
            _menuTitle(LocaleKeys.label_account.tr()),
            SizedBox(
              height: Dimens.DIMENS_8,
            ),
            BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
              if (state.status == AuthStatus.authenticated) {
                return FutureBuilder(
                    future: futureUserData1,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        name = snapshot.data!.name;
                        userName = snapshot.data!.userName;
                        photoURL = snapshot.data!.photo;
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
                            child: !snapshot.hasData
                                ? CircleAvatar(
                                    backgroundColor: COLOR_grey,
                                  )
                                : CachedNetworkImage(
                                    imageUrl: photoURL!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                          ),
                        ),
                        title: _buildTitle(snapshot),
                        subtitle: _buildSubtitle(snapshot),
                        trailing: InkWell(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (_) {
                                  return AlertDialog(
                                    title: Text(LocaleKeys.label_logout.tr()),
                                    actions: [
                                      TextButton(
                                          onPressed: () => context.pop(),
                                          child: Text(
                                              LocaleKeys.label_cancel.tr())),
                                      TextButton(
                                          onPressed: () {
                                            BlocProvider.of<AuthBloc>(context)
                                                .add(LogOut());
                                            context.pop();
                                          },
                                          child:
                                              Text(LocaleKeys.label_oke.tr()))
                                    ],
                                  );
                                });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 7),
                            decoration: BoxDecoration(
                                color: COLOR_black_ff121212,
                                borderRadius: BorderRadius.circular(5)),
                            child: Text(
                              LocaleKeys.label_logout.tr(),
                              style: TextStyle(color: COLOR_white_fff5f5f5),
                            ),
                          ),
                        ),
                      );
                    });
              }
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
                trailing: InkWell(
                  onTap: () {
                    // context.pop();
                    showAuthBottomSheetFunc(context);
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                    decoration: BoxDecoration(
                        color: COLOR_black_ff121212,
                        borderRadius: BorderRadius.circular(5)),
                    child: Text(
                      LocaleKeys.label_login.tr(),
                      style: TextStyle(color: COLOR_white_fff5f5f5),
                    ),
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
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state.status == AuthStatus.notAuthenticated ||
                    state.status == AuthStatus.loading) {
                  return Container();
                }
                debugPrint('authuid1 ${state.user}');
                debugPrint('authuid2 ${authRepository.currentUser?.uid}');
                return FutureBuilder(
                    future: authRepository.isAdmin(
                        authRepository.currentUser?.uid ??
                            state.user?.id ??
                            ''),
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
                    });
              },
            ),
          ]),
        ),
      ),
    );
  }

  Text _buildSubtitle(AsyncSnapshot<models.User> snapshot) {
    return Text(
        '@${!snapshot.hasData ? LocaleKeys.label_user_name.tr() : userName}');
  }

  Text _buildTitle(AsyncSnapshot<models.User> snapshot) {
    return Text(!snapshot.hasData ? LocaleKeys.label_account.tr() : name!);
  }

  Text _menuTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
    );
  }
}

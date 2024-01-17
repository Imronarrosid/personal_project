import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/domain/reporsitory/auth_reposotory.dart';
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
  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    AuthRepository authRepository =
        RepositoryProvider.of<AuthRepository>(context);

//  User user =            authRepository.getVideoOwnerData(authRepository.currentUser!.uid);
    return Scaffold(
      appBar: AppBar(
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
            if (state.status == AuthStatus.authenticated) {
              return ListTile(
                tileColor: themeData.colorScheme.tertiary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    backgroundImage: CachedNetworkImageProvider(
                      state.user!.photo!,
                    )),
                title: _buildTitle(state.user!.name!),
                subtitle: _buildSubtitle(state.user!.userName!),
                trailing: const Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  context.push(APP_PAGE.editProfile.toPath);
                },
              );
            }
            return ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                child: Padding(
                  padding: EdgeInsets.only(bottom: Dimens.DIMENS_3),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: const Icon(BootstrapIcons.person_fill),
                  ),
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
                      color: Theme.of(context).colorScheme.onTertiary,
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
            leading: const Icon(BootstrapIcons.globe2),
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
            leading: const Icon(BootstrapIcons.database),
            title: Text(LocaleKeys.title_storage.tr()),
            onTap: () {
              context.push(APP_PAGE.cachesPage.toPath);
            },
          ),
          SizedBox(
            height: Dimens.DIMENS_16,
          ),
          _menuTitle(LocaleKeys.label_others.tr()),
          SizedBox(
            height: Dimens.DIMENS_8,
          ),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state.status == AuthStatus.notAuthenticated ||
                  state.status == AuthStatus.loading) {
                return ListTile(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  title: Text(LocaleKeys.label_login.tr()),
                  leading: const Icon(Icons.login),
                  onTap: () {
                    showAuthBottomSheetFunc(context);
                  },
                );
              }
              return ListTile(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                title: Text(LocaleKeys.label_logout.tr()),
                leading: const Icon(Icons.logout),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (_) {
                        return AlertDialog(
                          title: Text(LocaleKeys.label_logout.tr()),
                          actions: [
                            TextButton(
                                onPressed: () => context.pop(),
                                child: Text(LocaleKeys.label_cancel.tr())),
                            TextButton(
                                onPressed: () {
                                  BlocProvider.of<AuthBloc>(context)
                                      .add(LogOut());
                                  context.pop();
                                },
                                child: Text(LocaleKeys.label_oke.tr()))
                          ],
                        );
                      });
                },
              );
            },
          ),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state.status == AuthStatus.notAuthenticated ||
                  state.status == AuthStatus.loading) {
                return Container();
              }
              return FutureBuilder(
                  future: authRepository.isAdmin(
                      authRepository.currentUser?.uid ?? state.user?.id ?? ''),
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
    );
  }

  Text _buildSubtitle(String userName) {
    return Text('@$userName');
  }

  Text _buildTitle(String name) {
    return Text(name);
  }

  Text _menuTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
    );
  }
}

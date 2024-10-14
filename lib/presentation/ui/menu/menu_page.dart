import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/domain/reporsitory/auth_reposotory.dart';
import 'package:personal_project/domain/reporsitory/user_repository.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/responsive/dimension.dart';
import 'package:personal_project/presentation/responsive/responsive_layout.dart';
import 'package:personal_project/presentation/router/route_utils.dart';
import 'package:personal_project/presentation/shared_components/handel_back_button.dart';
import 'package:personal_project/presentation/ui/auth/auth.dart';
import 'package:personal_project/presentation/ui/auth/bloc/auth_bloc.dart';
import 'package:solar_icons/solar_icons.dart';

import '../../../domain/model/user.dart';
import '../../../domain/services/firebase/firebase_service.dart';

class MenuPage extends StatefulWidget {
  final int index;
  final Widget child;
  const MenuPage({
    super.key,
    required this.index,
    required this.child,
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
    UserRepository userRepository =
        RepositoryProvider.of<UserRepository>(context);

//  User user =            authRepository.getVideoOwnerData(authRepository.currentUser!.uid);
    return HandleBackButton(
      child: Scaffold(
        body: Row(
          children: [
            (MediaQuery.of(context).size.width < mobileWidth)
                ? const SizedBox(
                    height: 0,
                    width: 0,
                  )
                : SizedBox(
                    width: 300,
                    height: MediaQuery.of(context).size.height,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: Dimens.DIMENS_12),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppBar(
                              elevation: 0,
                              automaticallyImplyLeading:
                                  !(MediaQuery.of(context).size.width >
                                      mobileWidth),
                              title: Text(LocaleKeys.title_menu.tr()),
                            ),
                            SizedBox(
                              height: Dimens.DIMENS_42,
                            ),
                            _menuTitle(LocaleKeys.label_account.tr()),
                            SizedBox(
                              height: Dimens.DIMENS_8,
                            ),
                            _accountMenu(
                                userRepository, themeData, authRepository),
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
                              selected: widget.index == 1,
                              selectedTileColor: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.1),
                              leading: const Icon(Icons.language_rounded),
                              title: Text(LocaleKeys.title_language.tr()),
                              onTap: () {
                                context.go(
                                    '${APP_PAGE.menu.toPath}${APP_PAGE.languagePage.toPath}');
                              },
                            ),
                            ListTile(
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                ),
                              ),
                              selected: widget.index == 2,
                              selectedTileColor: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.1),
                              leading: const Icon(SolarIconsBold.database),
                              title: Text(LocaleKeys.title_storage.tr()),
                              onTap: () {
                                context.go(
                                    '${APP_PAGE.menu.toPath}${APP_PAGE.cachesPage.toPath}');
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
                                if (state.status == AuthStatus.authenticated) {
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
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text(
                                                  LocaleKeys.label_logout.tr()),
                                              actions: [
                                                TextButton(
                                                    onPressed: () =>
                                                        context.pop(),
                                                    child: Text(LocaleKeys
                                                        .label_cancel
                                                        .tr())),
                                                TextButton(
                                                    onPressed: () {
                                                      BlocProvider.of<AuthBloc>(
                                                              context)
                                                          .add(LogOut());
                                                      context.pop();
                                                    },
                                                    child: Text(LocaleKeys
                                                        .label_oke
                                                        .tr()))
                                              ],
                                            );
                                          });
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
                                  title: Text(LocaleKeys.label_login.tr()),
                                  leading: const Icon(SolarIconsBold.login_2),
                                  onTap: () {
                                    showAuthBottomSheetFunc(context);
                                  },
                                );
                              },
                            ),
                            BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, state) {
                                if (state.status ==
                                        AuthStatus.notAuthenticated ||
                                    state.status == AuthStatus.loading) {
                                  return Container();
                                }
                                return FutureBuilder(
                                    future: authRepository.isAdmin(
                                        authRepository.currentUser?.uid ??
                                            state.user?.id ??
                                            ''),
                                    builder: (context,
                                        AsyncSnapshot<bool> snapshot) {
                                      if (!snapshot.hasData ||
                                          snapshot.hasError ||
                                          snapshot.data == false) {
                                        return Container();
                                      }

                                      return ListTile(
                                        tileColor: COLOR_grey,
                                        onTap: () {
                                          context
                                              .push(APP_PAGE.addGameFav.toPath);
                                        },
                                      );
                                    });
                              },
                            ),
                          ]),
                    ),
                  ),
            MediaQuery.of(context).size.width < mobileWidth
                ? const SizedBox(
                    width: 0,
                    height: 0,
                  )
                : SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: VerticalDivider(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.24),
                        thickness: 0.2,
                      ),
                    ),
                  ),
            Expanded(child: widget.child)
          ],
        ),
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

  BlocBuilder<AuthBloc, AuthState> _accountMenu(UserRepository userRepository,
      ThemeData themeData, AuthRepository authRepository) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      if (state.status == AuthStatus.authenticated) {
        return StreamBuilder<User>(
            stream: userRepository
                .userDataStream(firebaseAuth.currentUser?.uid ?? ''),
            builder: (context, snapshot) {
              User? userdAdata = snapshot.data;

              return ListTile(
                tileColor: themeData.colorScheme.tertiary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                leading: Builder(builder: (_) {
                  if (userdAdata == null) {
                    return CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.tertiary,
                    );
                  }
                  return CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    backgroundImage: CachedNetworkImageProvider(
                      userdAdata!.photo!,
                    ),
                  );
                }),
                selectedColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.3),
                title: _buildTitle(authRepository.currentUser!.displayName!),
                subtitle: _buildSubtitle(
                    userdAdata?.userName ?? LocaleKeys.label_user_name.tr()),
                trailing: const Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  context
                      .go(APP_PAGE.menu.toPath + APP_PAGE.editProfile.toPath);
                },
              );
            });
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
        onTap: () {
          if (context.read<AuthRepository>().currentUser != null) {
            context.go(
              '${APP_PAGE.menu.toPath}${APP_PAGE.editProfile.toPath}',
            );
          } else {
            context.go(
              '${APP_PAGE.menu.toPath}${APP_PAGE.login.toPath}',
            );
          }
        },
        selectedTileColor:
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
        title: Text(LocaleKeys.label_account.tr()),
        trailing: InkWell(
          onTap: () {
            // context.pop();
            showAuthBottomSheetFunc(context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
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
    });
  }
}

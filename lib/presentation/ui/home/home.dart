import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/domain/model/profile_data_model.dart';
import 'package:personal_project/domain/model/user.dart';
import 'package:personal_project/domain/reporsitory/auth_reposotory.dart';
import 'package:personal_project/domain/reporsitory/user_repository.dart';
import 'package:personal_project/domain/services/firebase/firebase_service.dart';
import 'package:personal_project/presentation/assets/images.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/responsive/dimension.dart';
import 'package:personal_project/presentation/responsive/responsive_layout.dart';
import 'package:personal_project/presentation/router/app_router.dart';
import 'package:personal_project/presentation/router/route_utils.dart';
import 'package:personal_project/presentation/shared_components/custom_snackbar.dart';
import 'package:personal_project/presentation/ui/add_details/bloc/upload_bloc.dart';
import 'package:personal_project/presentation/ui/add_user_name/add_user_name_page.dart';
import 'package:personal_project/presentation/ui/auth/bloc/auth_bloc.dart';
import 'package:personal_project/presentation/ui/home/cubit/home_cubit.dart';
import 'package:personal_project/presentation/ui/mabar/mabar_page.dart';
import 'package:personal_project/presentation/ui/message/message.dart';
import 'package:personal_project/presentation/ui/profile/profile.dart';
import 'package:personal_project/presentation/ui/search/search.dart';
import 'package:personal_project/presentation/ui/upload/upload_modal.dart';
import 'package:personal_project/presentation/ui/video/video.dart';
import 'package:provider/provider.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:universal_html/html.dart' as html;
import 'package:firebase_auth/firebase_auth.dart' as firebase;

class HomePage extends StatefulWidget {
  final Widget? child;
  final int pageIndex;

  const HomePage({
    super.key,
    this.child,
    required this.pageIndex,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isTriggerReset = true;
  late final SidebarXController _sidebarXController;

  @override
  void initState() {
    super.initState();
  }

  void _sidebarXListener() async {
    _sidebarXController.selectIndex(widget.pageIndex);
    var currentUser = context.read<AuthRepository>().currentUser;

    _sidebarXController.addListener(() async {
      int selectedIndex = _sidebarXController.selectedIndex;
      switch (_sidebarXController.selectedIndex) {
        case 0:
          context.go(APP_PAGE.forYou.toPath);
          break;
        case 1:
          context.go(APP_PAGE.search.toPath);
          break;
        case 2:
          context.go(APP_PAGE.message.toPath);
          break;
        case 3:
          context.go(APP_PAGE.profile.toPath);
          if (currentUser == null) {
          } else {
            String? userName = await context
                .read<AuthRepository>()
                .getUserData(currentUser.uid)
                .then((value) => value.userName);
            if (!mounted) return;
            context.go('/u${APP_PAGE.profile.toPath}/$userName');
          }
          break;

        default:
      }

      BlocProvider.of<HomeCubit>(context).changePage(selectedIndex);
      if (_sidebarXController.selectedIndex == 0) {
        if (isTriggerReset) {
          BlocProvider.of<HomeCubit>(context).triggerReset(selectedIndex);
        }
        isTriggerReset = true;
      } else {
        isTriggerReset = false;
      }
    });
  }

  // Future<bool> _isLogedUser() async {
  //   var currentUser = context.read<AuthRepository>().currentUser;

  //   if (currentUser != null) {
  //     String? userName = await context
  //         .read<AuthRepository>()
  //         .getUserData(currentUser.uid)
  //         .then((value) => value.userName);
  //     final bool authenticatedUrl = window.location.href.endsWith(userName!);
  //     return authenticatedUrl;
  //   } else {
  //     return false;
  //   }
  // }

  // List<Widget> _pages(Object? value) {
  //   return <Widget>[
  //     const VideoPage(),
  //     const SearchPage(),
  //     Container(),
  //     const MessagePage(),
  //     const ProfilePage(),
  //     value != null
  //         ? ProfilePage(
  //             payload: ProfilePayload(
  //               user: value as User,
  //               isForOtherUser: true,
  //             ),
  //           )
  //         : const ProfilePage(),
  //   ];
  // }

  @override
  Widget build(BuildContext context) {
    debugPrint('botttominshome ${MediaQuery.of(context).viewInsets.bottom}');

    final UserRepository userRepository =
        RepositoryProvider.of<UserRepository>(context);
    final bool isMobileView = MediaQuery.of(context).size.width < mobileWidth;
    return BackButtonListener(
      onBackButtonPressed: () async {
        Provider.of<AppRouter>(context, listen: false)
            .onBackButtonPressed(context);
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Row(
          children: [
            if (isMobileView)
              const SizedBox(
                width: 0,
                height: 0,
              )
            else
              Expanded(
                flex: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: 220,
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiary,
                          borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            height: 75,
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Image.asset(
                                    Images.IC_GAMEPIUN512X521,
                                    width: 34,
                                  ),
                                ),
                                Text(
                                  'Gamepiun',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .apply(
                                          fontSizeDelta: 4,
                                          fontWeightDelta: 35),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          SideBarItem(
                            leadingIcon: const Icon(
                              SolarIconsOutline.home,
                            ),
                            selectedIcon: const Icon(
                              SolarIconsBold.home,
                            ),
                            selected: widget.pageIndex == 0,
                            title: LocaleKeys.label_home.tr(),
                            onTap: () => context.go(APP_PAGE.forYou.toPath),
                          ),
                          SideBarItem(
                            leadingIcon: const Icon(
                              SolarIconsOutline.roundedMagnifier,
                            ),
                            selectedIcon: const Icon(
                              SolarIconsBold.roundedMagnifier,
                            ),
                            selected: widget.pageIndex == 1,
                            title: LocaleKeys.label_search.tr(),
                            onTap: () => context.go(APP_PAGE.search.toPath),
                          ),
                          SideBarItem(
                            leadingIcon: const Icon(
                              SolarIconsOutline.gamepad,
                            ),
                            selectedIcon: const Icon(
                              SolarIconsBold.gamepad,
                            ),
                            selected: widget.pageIndex == 5,
                            title: 'Mabar',
                            onTap: () => context.go(APP_PAGE.mabarChat.toPath),
                          ),
                          SideBarItem(
                            leadingIcon: const Icon(
                              SolarIconsOutline.chatLine,
                            ),
                            selectedIcon: const Icon(
                              SolarIconsBold.chatLine,
                            ),
                            selected: widget.pageIndex == 2,
                            title: LocaleKeys.label_chat.tr(),
                            onTap: () => context.go(
                                APP_PAGE.message.toPath + APP_PAGE.chat.toPath),
                          ),
                          SideBarItem(
                            selected: widget.pageIndex == 3,
                            leadingIcon: const Icon(SolarIconsOutline.user),
                            selectedIcon: const Icon(SolarIconsBold.user),
                            title: LocaleKeys.label_account.tr(),
                            onTap: () async {
                              var currentUser =
                                  context.read<AuthRepository>().currentUser;
                              if (currentUser == null) {
                                context.go(APP_PAGE.profile.toPath);
                              } else {
                                String? userName = await context
                                    .read<AuthRepository>()
                                    .getUserData(currentUser.uid)
                                    .then((value) => value.userName);
                                if (!context.mounted) return;
                                context.go('/@$userName');
                              }
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 12, left: 12, right: 30),
                            child: Material(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(100),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(100),
                                onTap: () => context.go(APP_PAGE.upload.toPath),
                                child: Container(
                                  height: 38,
                                  alignment: Alignment.center,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Text(
                                    LocaleKeys.title_upload.tr(),
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          SideBarItem(
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(12),
                              ),
                            ),
                            leadingIcon: const Icon(
                              SolarIconsOutline.hamburgerMenu,
                            ),
                            title: LocaleKeys.label_settings.tr(),
                            onTap: () => context.go(APP_PAGE.menu.toPath),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            Expanded(
              child: MultiBlocListener(listeners: [
                BlocListener<UploadBloc, UploadState>(
                  listener: (context, state) {
                    if (state is Uploading) {
                      showUploadingSnackBar();
                    } else if (state is VideoUploaded) {
                      showUploadedSnackBar();
                    } else if (state is UploadError) {
                      Fluttertoast.showToast(
                        msg: 'Upload gagal ${state.error}',
                        backgroundColor: Colors.black45,
                        gravity: ToastGravity.TOP,
                      );
                    }
                  },
                ),
                BlocListener<AuthBloc, AuthState>(
                  listener: (context, state) {
                    debugPrint('asts ${state.status.name}');
                    if (state.status == AuthStatus.authenticated) {
                      if (state.isUserFirstLogin!) {
                        context.go(APP_PAGE.addUserName.toPath,
                            extra: state.user!.userName);

                        showLoginSuccessSnackBar();
                      }
                      if (!(state.isUserFirstLogin!) && state.isNotiFy!) {
                        // context.pop();
                        // context.pop();
                        showLoginSuccessSnackBar();
                        context.go(APP_PAGE.forYou.toPath);
                      }
                    } else if (state.status == AuthStatus.error) {
                      showLoginErrorSnackBar();
                    }

                    if (state.status == AuthStatus.loading && state.isNotiFy!) {
                      // context.pop();
                      debugPrint('kikiay');
                      showDialog(
                        context: context,
                        builder: (context) => WillPopScope(
                          onWillPop: () async => false,
                          child: BlocListener<AuthBloc, AuthState>(
                            listener: (context, state) {
                              if (state.status == AuthStatus.authenticated) {
                                context.pop();
                              }
                            },
                            child: const Dialog(
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ], child: widget.child!),
            ),
          ],
        ),
        bottomNavigationBar: _isRemoveNavBar()
            ? const SizedBox(
                width: 0,
                height: 0,
              )
            : ResponsiveLayout(
                desktopBody: const SizedBox(
                  width: 0,
                  height: 0,
                ),
                mobileBody: Transform.translate(
                  offset: Offset(
                      0,
                      (MediaQuery.of(context).viewInsets.bottom > 0) ||
                              GoRouter.of(context)
                                  .routeInformationProvider
                                  .value
                                  .uri
                                  .path
                                  .contains('upload')
                          ? 60
                          : 0),
                  child: BlocBuilder<HomeCubit, HomeState>(
                    builder: (_, state) {
                      debugPrint(
                          'adfjasjdfl ${GoRouter.of(context).routeInformationProvider.value.uri.path} ${GoRouter.of(context).routeInformationProvider.value.uri.path.contains('/upload')}');
                      return Theme(
                        data: ThemeData(useMaterial3: false),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                  color: Theme.of(context).colorScheme.tertiary,
                                  width: 0.2),
                            ),
                          ),
                          child: BottomNavigationBar(
                            elevation: 2,
                            unselectedItemColor:
                                COLOR_white_fff5f5f5.withOpacity(0.6),
                            selectedItemColor: COLOR_white_fff5f5f5,
                            type: BottomNavigationBarType.fixed,
                            selectedFontSize: 12,
                            unselectedFontSize: 12,
                            backgroundColor: COLOR_black_ff121212,
                            showSelectedLabels: false,
                            showUnselectedLabels: false,
                            items: [
                              BottomNavigationBarItem(
                                icon: const Icon(SolarIconsOutline.home),
                                activeIcon: const Icon(
                                  SolarIconsBold.home,
                                ),
                                label: LocaleKeys.label_home.tr(),
                                tooltip: LocaleKeys.label_home.tr(),
                              ),
                              const BottomNavigationBarItem(
                                icon: Icon(
                                  SolarIconsOutline.gamepad,
                                ),
                                activeIcon: Icon(
                                  SolarIconsBold.gamepad,
                                ),
                                label: "Mabar",
                                tooltip: "Mabar",
                              ),
                              BottomNavigationBarItem(
                                icon: const Icon(
                                  SolarIconsBold.addSquare,
                                  size: 28,
                                ),
                                label: '',
                                tooltip: LocaleKeys.title_upload.tr(),
                              ),
                              BottomNavigationBarItem(
                                icon: const Icon(SolarIconsOutline.chatLine),
                                activeIcon: const Icon(SolarIconsBold.chatLine),
                                label: LocaleKeys.label_chat.tr(),
                                tooltip: LocaleKeys.label_chat.tr(),
                              ),
                              BottomNavigationBarItem(
                                icon: BlocBuilder<AuthBloc, AuthState>(
                                  builder: (_, authState) {
                                    if (authState.status ==
                                        AuthStatus.authenticated) {
                                      AuthRepository authRepository =
                                          RepositoryProvider.of<AuthRepository>(
                                              context);
                                      return StreamBuilder(
                                          stream: userRepository.getAvatar(
                                              authRepository.currentUser!.uid),
                                          builder: (_, snapshot) {
                                            String? avatar = snapshot.data;
                                            if (!snapshot.hasData ||
                                                snapshot.hasError) {
                                              return const Icon(
                                                  SolarIconsBold.user);
                                            }
                                            return Container(
                                              padding: EdgeInsets.all(
                                                  Dimens.DIMENS_1),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: _getIndex() == 4
                                                      ? Theme.of(context)
                                                          .colorScheme
                                                          .primary
                                                      : Colors.transparent,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                              ),
                                              child: CircleAvatar(
                                                radius: Dimens.DIMENS_11,
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .tertiary,
                                                backgroundImage:
                                                    CachedNetworkImageProvider(
                                                  avatar!,
                                                ),
                                              ),
                                            );
                                          });
                                    }
                                    return const Icon(SolarIconsOutline.user);
                                  },
                                ),
                                label: LocaleKeys.label_profile.tr(),
                                tooltip: LocaleKeys.label_profile.tr(),
                              ),
                            ],
                            currentIndex: _getIndex(),
                            onTap: (value) async {
                              var currentUser =
                                  context.read<AuthRepository>().currentUser;

                              switch (value) {
                                case 0:
                                  context.go(APP_PAGE.forYou.toPath);
                                  break;
                                case 1:
                                  context.go(APP_PAGE.mabarChat.toPath);

                                  break;
                                case 3:
                                  context.go(APP_PAGE.message.toPath);
                                  break;
                                case 4:
                                  if (currentUser == null) {
                                    context
                                        .go('${APP_PAGE.profile.toPath}/login');
                                  } else {
                                    String? userName = await context
                                        .read<AuthRepository>()
                                        .getUserData(currentUser.uid)
                                        .then((value) => value.userName);
                                    if (!context.mounted) return;
                                    context.go('/@$userName');
                                  }
                                  break;
                                default:
                              }
                              if (value == 2) {
                                // Navigator.push(context, MaterialPageRoute(builder: (context)=>UploadPage()));
                                // BlocProvider.of<CameraBloc>(context).add(const OpenRearCameraEvent());
                                // await availableCameras().then((value) => context
                                //     .push(APP_PAGE.upload.toPath, extra: value));
                                showUploadModal(context);
                              } else {
                                // setState(() {
                                //   selectedindex = value;
                                // });
                                BlocProvider.of<HomeCubit>(context)
                                    .changePage(value);
                                if (value == 0) {
                                  if (isTriggerReset) {
                                    BlocProvider.of<HomeCubit>(context)
                                        .triggerReset(value);
                                  }
                                  isTriggerReset = true;
                                } else {
                                  isTriggerReset = false;
                                }
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
      ),
    );
  }

  bool _isRemoveNavBar() {
    return MediaQuery.of(context).viewInsets.bottom > 0 ||
        GoRouter.of(context)
            .routeInformationProvider
            .value
            .uri
            .path
            .contains('upload') ||
        GoRouter.of(context)
            .routeInformationProvider
            .value
            .uri
            .path
            .contains('settings') ||
        GoRouter.of(context)
            .routeInformationProvider
            .value
            .uri
            .path
            .contains('edit-profile') ||
        GoRouter.of(context)
            .routeInformationProvider
            .value
            .uri
            .path
            .contains('chat') ||
        GoRouter.of(context)
            .routeInformationProvider
            .value
            .uri
            .path
            .contains('edit-profile') ||
        GoRouter.of(context)
            .routeInformationProvider
            .value
            .uri
            .path
            .contains('video-item') ||
        GoRouter.of(context)
            .routeInformationProvider
            .value
            .uri
            .path
            .contains('start');
  }

  _getIndex() {
    String? userName = context.read<AuthRepository>().currentUserData?.userName;
    String routeName =
        GoRouter.of(context).routeInformationProvider.value.uri.path;
    if (routeName == APP_PAGE.forYou.toPath) {
      return 0;
    } else if (routeName == APP_PAGE.mabarChat.toPath) {
      return 1;
    } else if (routeName.contains(APP_PAGE.message.toPath)) {
      return 3;
    } else if ((userName != null && routeName.contains(userName)) ||
        routeName.contains('login')) {
      return 4;
    }
    return 0;
  }
}

class SideBarItem extends StatelessWidget {
  const SideBarItem({
    super.key,
    this.selected = false,
    this.title = '',
    this.selectedTitleColor,
    this.titleTextStyle,
    this.onTap,
    this.leadingIcon,
    this.selectedIcon,
    this.shape,
  });

  final bool selected;
  final String title;
  final Icon? leadingIcon;
  final Icon? selectedIcon;
  final Color? selectedTitleColor;
  final TextStyle? titleTextStyle;
  final ShapeBorder? shape;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        shape: shape,
        title: Text(title),
        titleTextStyle: titleTextStyle?.apply(color: selectedTitleColor) ??
            TextStyle(
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
        leading: !selected
            ? Icon(
                leadingIcon?.icon,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(
                      0.7,
                    ),
              )
            : selectedIcon ??
                const SizedBox(
                  width: 0,
                  height: 0,
                ),
        onTap: onTap,
        selected: selected,
      ),
    );
  }
}

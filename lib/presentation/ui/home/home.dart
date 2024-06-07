import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/domain/model/profile_data_model.dart';
import 'package:personal_project/domain/model/user.dart';
import 'package:personal_project/domain/reporsitory/user_repository.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/responsive/dimension.dart';
import 'package:personal_project/presentation/responsive/responsive_layout.dart';
import 'package:personal_project/presentation/router/route_utils.dart';
import 'package:personal_project/presentation/shared_components/custom_snackbar.dart';
import 'package:personal_project/presentation/ui/add_details/bloc/upload_bloc.dart';
import 'package:personal_project/presentation/ui/auth/bloc/auth_bloc.dart';
import 'package:personal_project/presentation/ui/home/cubit/home_cubit.dart';
import 'package:personal_project/presentation/ui/message/message.dart';
import 'package:personal_project/presentation/ui/profile/profile.dart';
import 'package:personal_project/presentation/ui/search/search.dart';
import 'package:personal_project/presentation/ui/upload/upload_modal.dart';
import 'package:personal_project/presentation/ui/video/video.dart';
import 'package:sidebarx/sidebarx.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isTriggerReset = true;
  @override
  void initState() {
    _sidebarXController.addListener(() {
      int selectedIndex = _sidebarXController.selectedIndex;
      if (_sidebarXController.selectedIndex == 2) {
        // Navigator.push(context, MaterialPageRoute(builder: (context)=>UploadPage()));
        // BlocProvider.of<CameraBloc>(context).add(const OpenRearCameraEvent());
        // await availableCameras().then((value) => context
        //     .push(APP_PAGE.upload.toPath, extra: value));
        showUploadModal(context);
      } else {
        // setState(() {
        //   selectedindex = value;
        // });
        BlocProvider.of<HomeCubit>(context).changePage(selectedIndex);
        if (_sidebarXController.selectedIndex == 0) {
          if (isTriggerReset) {
            BlocProvider.of<HomeCubit>(context).triggerReset(selectedIndex);
          }
          isTriggerReset = true;
        } else {
          isTriggerReset = false;
        }
      }
    });
    super.initState();
  }

  final SidebarXController _sidebarXController =
      SidebarXController(selectedIndex: 0, extended: false);

  List<Widget> _pages(Object? value) {
    return <Widget>[
      const VideoPage(),
      const SearchPage(),
      Container(),
      const MessagePage(),
      const ProfilePage(),
      value != null
          ? ProfilePage(
              payload: ProfilePayload(
                user: value as User,
                isForOtherUser: true,
              ),
            )
          : const ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final UserRepository userRepository =
        RepositoryProvider.of<UserRepository>(context);
    final bool isMobileView = MediaQuery.of(context).size.width < mobileWidth;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Row(
        children: [
          if (isMobileView)
            const SizedBox(
              width: 0,
              height: 0,
            )
          else
            _sidebarX(),
          Expanded(
            child: MultiBlocListener(
              listeners: [
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
                      }
                      if (state.isNotiFy!) {
                        context.pop();
                        context.pop();
                        showLoginSuccessSnackBar();
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
                          child: const Dialog(
                            elevation: 0,
                            backgroundColor: Colors.transparent,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
              child: BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  debugPrint("navigate "+state.extra.toString());
                  return IndexedStack(
                    index: state.index,
                    children: _pages(state.extra),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: ResponsiveLayout(
        desktopBody: const SizedBox(
          width: 0,
          height: 0,
        ),
        mobileBody: BlocBuilder<HomeCubit, HomeState>(
          builder: (_, state) {
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
                  unselectedItemColor: COLOR_white_fff5f5f5.withOpacity(0.6),
                  selectedItemColor: COLOR_white_fff5f5f5,
                  type: BottomNavigationBarType.fixed,
                  selectedFontSize: 12,
                  unselectedFontSize: 12,
                  backgroundColor: COLOR_black_ff121212,
                  showSelectedLabels: false,
                  showUnselectedLabels: false,
                  items: [
                    BottomNavigationBarItem(
                      icon: const Icon(BootstrapIcons.house_door),
                      activeIcon: const Icon(
                        BootstrapIcons.house_door_fill,
                      ),
                      label: LocaleKeys.label_home.tr(),
                      tooltip: LocaleKeys.label_home.tr(),
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(
                        BootstrapIcons.search,
                      ),
                      activeIcon: const Icon(
                        BootstrapIcons.search,
                      ),
                      label: LocaleKeys.label_search.tr(),
                      tooltip: LocaleKeys.label_search.tr(),
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(
                        BootstrapIcons.plus_circle,
                        size: 24,
                      ),
                      label: '',
                      tooltip: LocaleKeys.title_upload.tr(),
                    ),
                    BottomNavigationBarItem(
                      icon: Padding(
                        padding: EdgeInsets.only(bottom: Dimens.DIMENS_3),
                        child: const Icon(BootstrapIcons.chat),
                      ),
                      activeIcon: Padding(
                        padding: EdgeInsets.only(bottom: Dimens.DIMENS_3),
                        child: const Icon(BootstrapIcons.chat_fill),
                      ),
                      label: LocaleKeys.label_chat.tr(),
                      tooltip: LocaleKeys.label_chat.tr(),
                    ),
                    BottomNavigationBarItem(
                      icon: BlocBuilder<AuthBloc, AuthState>(
                        builder: (_, authState) {
                          if (authState.status == AuthStatus.authenticated) {
                            return StreamBuilder(
                                stream: userRepository
                                    .getAvatar(authState.user!.id),
                                builder: (_, snapshot) {
                                  String? avatar = snapshot.data;
                                  if (!snapshot.hasData || snapshot.hasError) {
                                    return const Icon(BootstrapIcons.person);
                                  }
                                  return Container(
                                    padding: EdgeInsets.all(Dimens.DIMENS_1),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: state.index == 4
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : Colors.transparent,
                                      ),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: CircleAvatar(
                                      radius: Dimens.DIMENS_11,
                                      backgroundColor: Theme.of(context)
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
                          return const Icon(BootstrapIcons.person);
                        },
                      ),
                      label: LocaleKeys.label_profile.tr(),
                      tooltip: LocaleKeys.label_profile.tr(),
                    ),
                  ],
                  currentIndex: state.index,
                  onTap: (value) async {
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
                      BlocProvider.of<HomeCubit>(context).changePage(value);
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
    );
  }

  SidebarX _sidebarX() {
    return SidebarX(
      controller: _sidebarXController,
      showToggleButton: false,
      theme: SidebarXTheme(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(20),
        ),
        textStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        selectedTextStyle: const TextStyle(color: Colors.white),
        hoverTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        itemTextPadding: const EdgeInsets.only(left: 30),
        selectedItemTextPadding: const EdgeInsets.only(left: 30),
        itemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.blue),
        ),
        selectedItemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.white.withOpacity(0.37),
          ),
          gradient: const LinearGradient(
            colors: [
              Colors.purple,
              Colors.blue,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.28),
              blurRadius: 30,
            )
          ],
        ),
        iconTheme: IconThemeData(
          color: Colors.white.withOpacity(0.7),
          size: 20,
        ),
        selectedIconTheme: const IconThemeData(
          color: Colors.white,
          size: 20,
        ),
      ),
      extendedTheme: const SidebarXTheme(
        width: 200,
        decoration: BoxDecoration(
          color: Colors.blue,
        ),
      ),
      headerBuilder: (context, extended) {
        return SizedBox(
          height: 100,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Image.asset('assets/images/avatar.png'),
          ),
        );
      },
      items: [
        SidebarXItem(
          icon: Icons.home,
          label: 'Home',
          onTap: () {
            debugPrint('Home');
          },
        ),
        const SidebarXItem(
          icon: Icons.search,
          label: 'Search',
        ),
        const SidebarXItem(
          icon: Icons.people,
          label: 'People',
        ),
        SidebarXItem(
          icon: Icons.favorite,
          label: 'Favorites',
        ),
        const SidebarXItem(
          iconWidget: FlutterLogo(size: 20),
          label: 'Flutter',
        ),
      ],
    );
  }
}

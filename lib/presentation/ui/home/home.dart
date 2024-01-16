import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/domain/reporsitory/auth_reposotory.dart';
import 'package:personal_project/domain/reporsitory/user_repository.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isTriggerReset = true;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final User? user =
        RepositoryProvider.of<AuthRepository>(context).currentUser;
    final UserRepository userRepository =
        RepositoryProvider.of<UserRepository>(context);
    List<Widget> pages = <Widget>[
      const VideoPage(),
      const SearchPage(),
      Container(),
      const MessagePage(),
      const ProfilePage(),
    ];
    return BlocBuilder<HomeCubit, HomeState>(
      bloc: HomeCubit(),
      builder: (context, navState) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: MultiBlocListener(
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
                return IndexedStack(
                  index: state.index,
                  children: pages,
                );
              },
            ),
          ),
          bottomNavigationBar: BlocBuilder<HomeCubit, HomeState>(
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
                                    if (!snapshot.hasData ||
                                        snapshot.hasError) {
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
                                        backgroundColor: Colors.transparent,
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
        );
      },
    );
  }
}

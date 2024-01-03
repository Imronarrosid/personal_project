import 'dart:async';

import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/domain/model/profile_data_model.dart';
import 'package:personal_project/domain/reporsitory/auth_reposotory.dart';
import 'package:personal_project/domain/reporsitory/user_repository.dart';
import 'package:personal_project/domain/services/app/app_service.dart';
import 'package:personal_project/domain/services/firebase/firebase_service.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/router/route_utils.dart';
import 'package:personal_project/presentation/shared_components/custom_snackbar.dart';
import 'package:personal_project/presentation/ui/add_details/bloc/upload_bloc.dart';
import 'package:personal_project/presentation/ui/auth/bloc/auth_bloc.dart';
import 'package:personal_project/presentation/ui/home/cubit/home_cubit.dart';
import 'package:personal_project/presentation/ui/message/message.dart';
import 'package:personal_project/presentation/ui/upload/bloc/camera_bloc.dart';
import 'package:personal_project/presentation/ui/upload/upload.dart';
import 'package:personal_project/presentation/ui/profile/profile.dart';
import 'package:personal_project/presentation/ui/search/search.dart';
import 'package:personal_project/presentation/ui/upload/upload_modal.dart';
import 'package:personal_project/presentation/ui/video/video.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    _onLogin();
    super.initState();
  }

  void _onLogin() async {
    final userRepository = RepositoryProvider.of<UserRepository>(context);
    final authRepository = RepositoryProvider.of<AuthRepository>(context);
    final User? currentUser = authRepository.currentUser;

    // if (currentUser != null) {
    //   final user = await firebaseFirestore
    //       .collection('users')
    //       .doc(currentUser.uid)
    //       .get();

    //   userRepository.name = user['name'];
    //   userRepository.photoUrl = user['photoUrl'];
    //   userRepository.username = user['userName'];
    //   userRepository.nameUpdated = user['updatedAt'];
    //   userRepository.ueserNameUpdated = user['userNameUpdatedAt'];
    // }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = <Widget>[
      const VideoPage(),
      const SearchPage(),
       Container(),
      const MessagePage(),
      const ProfilePage(),
    ];
    return BlocProvider(
      create: (context) => HomeCubit(),
      child: BlocBuilder<HomeCubit, HomeState>(
        bloc: HomeCubit(),
        builder: (context, navState) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            body: Stack(
              children: [
                Scaffold(
                  body: MultiBlocListener(
                    listeners: [
                      BlocListener<UploadBloc, UploadState>(
                        listener: (context, state) {
                          if (state is Uploading) {
                            showUploadingSnackBar(context);
                          } else if (state is VideoUploaded) {
                            showUploadedSnackBar(context);
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
                              showLoginSuccessSnackBar(context);
                            }
                          } else if (state.status == AuthStatus.error) {
                            showLoginErrorSnackBar(context);
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
                    builder: (context, state) {
                      return Theme(
                        data: ThemeData(useMaterial3: false),
                        child: BottomNavigationBar(
                          unselectedItemColor:
                              COLOR_white_fff5f5f5.withOpacity(0.6),
                          selectedItemColor: COLOR_white_fff5f5f5,
                          type: BottomNavigationBarType.fixed,
                          selectedFontSize: 12,
                          unselectedFontSize: 12,
                          backgroundColor: COLOR_black_ff121212,
                          items: [
                            BottomNavigationBarItem(
                                icon: Icon(MdiIcons.homeOutline),
                                activeIcon: Icon(MdiIcons.home),
                                label: LocaleKeys.label_home.tr()),
                            BottomNavigationBarItem(
                                icon: const Icon(Icons.search_rounded),
                                label: LocaleKeys.label_search.tr()),
                            const BottomNavigationBarItem(
                                icon: Icon(Icons.add), label: ''),
                            BottomNavigationBarItem(
                                icon: Icon(MdiIcons.messageTextOutline),
                                activeIcon: Icon(MdiIcons.messageText),
                                label: LocaleKeys.label_message.tr()),
                            BottomNavigationBarItem(
                                icon: Icon(MdiIcons.accountCircleOutline),
                                activeIcon: Icon(MdiIcons.accountCircle),
                                label: LocaleKeys.label_profile.tr()),
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
                              BlocProvider.of<HomeCubit>(context)
                                  .changePage(value);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state.status == AuthStatus.loading && state.isNotiFy!) {
                      return Container(
                        color: Colors.black38,
                        child: const Align(
                            alignment: Alignment.center,
                            child: CircularProgressIndicator()),
                      );
                    }
                    debugPrint('authstate ${state.status.name}');
                    return Container();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/domain/services/app/app_service.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/router/route_utils.dart';
import 'package:personal_project/presentation/shared_components/custom_snackbar.dart';
import 'package:personal_project/presentation/ui/add_details/bloc/upload_bloc.dart';
import 'package:personal_project/presentation/ui/auth/bloc/auth_bloc.dart';
import 'package:personal_project/presentation/ui/message/message.dart';
import 'package:personal_project/presentation/ui/upload/bloc/camera_bloc.dart';
import 'package:personal_project/presentation/ui/upload/upload.dart';
import 'package:personal_project/presentation/ui/profile/profile.dart';
import 'package:personal_project/presentation/ui/search/search.dart';
import 'package:personal_project/presentation/ui/video/video.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedindex = 0;
  List<Widget> pages = <Widget>[
    const VideoPage(),
    const SearchPage(),
    const MessagePage(),
    const MessagePage(),
    const ProfilePage(),
  ];
  @override
  Widget build(BuildContext context) {
    final appService = Provider.of<AppService>(context);
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
                    }
                  },
                ),
                BlocListener<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is Authenticated) {
                      showLoginSuccessSnackBar(context);
                    }else if(state is AuthError){
                      showLoginErrorSnackBar(context);
                    }
                    else if(state is NoInternet){
                      showLoginErrorSnackBar(context);
                    }
                  },
                ),
              ],
              child: pages[selectedindex],
            ),
            bottomNavigationBar: BottomNavigationBar(
              unselectedItemColor: COLOR_white_fff5f5f5.withOpacity(0.6),
              selectedItemColor: COLOR_white_fff5f5f5,
              type: BottomNavigationBarType.fixed,
              backgroundColor: COLOR_black_ff121212,
              items: [
                BottomNavigationBarItem(
                    icon: const Icon(Icons.home_outlined),
                    label: LocaleKeys.label_home.tr()),
                BottomNavigationBarItem(
                    icon: const Icon(Icons.search_rounded),
                    label: LocaleKeys.label_search.tr()),
                const BottomNavigationBarItem(icon: Icon(Icons.add), label: ''),
                BottomNavigationBarItem(
                    icon: const Icon(Icons.message),
                    label: LocaleKeys.label_message.tr()),
                BottomNavigationBarItem(
                    icon: const Icon(Icons.person_2_outlined),
                    label: LocaleKeys.label_profile.tr()),
              ],
              currentIndex: selectedindex,
              onTap: (value) async {
                if (value == 2) {
                  // Navigator.push(context, MaterialPageRoute(builder: (context)=>UploadPage()));
                  // BlocProvider.of<CameraBloc>(context).add(const OpenRearCameraEvent());
                  await availableCameras().then((value) =>
                      context.push(APP_PAGE.upload.toPath, extra: value));
                } else {
                  setState(() {
                    selectedindex = value;
                  });
                }
              },
            ),
          ),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state == LoginProcessing()) {
                return Container(
                  color: Colors.black38,
                  child: const Align(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator()),
                );
              }
              return Container();
            },
          ),
        ],
      ),
    );
  }
}

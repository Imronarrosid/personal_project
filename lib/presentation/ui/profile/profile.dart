import 'package:flutter/material.dart';
import 'package:personal_project/domain/model/profile_data_model.dart';
import 'package:personal_project/domain/model/user.dart';
import 'package:personal_project/presentation/responsive/responsive_layout.dart';
import 'package:personal_project/presentation/ui/profile/responsive/profile_desktop.dart';
import 'package:personal_project/presentation/ui/profile/responsive/profile_mobile.dart';

class ProfilePage extends StatelessWidget {
  final User? user;
  final String userName;
  const ProfilePage({
    super.key,
    this.user,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: ProfilePageMobile(
        key: UniqueKey(),
      ),
      desktopBody: ProfilePageDesktop(
        key: UniqueKey(),
        userName: userName,
        userDaata: user,
      ),
    );
  }
}

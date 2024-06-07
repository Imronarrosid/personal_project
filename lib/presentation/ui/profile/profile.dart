import 'package:flutter/material.dart';
import 'package:personal_project/domain/model/profile_data_model.dart';
import 'package:personal_project/presentation/responsive/responsive_layout.dart';
import 'package:personal_project/presentation/ui/profile/responsive/profile_desktop.dart';
import 'package:personal_project/presentation/ui/profile/responsive/profile_mobile.dart';

class ProfilePage extends StatelessWidget {
  final ProfilePayload? payload;
  const ProfilePage({super.key, this.payload});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: ProfilePageMobile(
        payload: payload,
      ),
      desktopBody: ProfilePageDesktop(
        payload: payload,
      ),
    );
  }
}

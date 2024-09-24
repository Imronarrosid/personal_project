import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:personal_project/domain/model/add_details_model.dart';
import 'package:personal_project/presentation/responsive/responsive_layout.dart';
import 'package:personal_project/presentation/ui/add_details/responsive/add_details_desktop.dart';
import 'package:personal_project/presentation/ui/add_details/responsive/add_details_mobile.dart';

class AddDetailsPage extends StatelessWidget {
  final AddDetails data;
  const AddDetailsPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: AddDetailsMobile(
        data: data,
      ),
      desktopBody: AddDetailsDesktop(
        data: data,
      ),
    );
  }
}

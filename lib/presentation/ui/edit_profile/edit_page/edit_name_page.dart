
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';

class EditName extends StatelessWidget {
  final String name;
  const EditName({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: name);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Name'),
        leading: IconButton(
          onPressed: () {
            context.pop();
            controller.dispose();
          },
          icon: Icon(MdiIcons.close),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(MdiIcons.check),
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimens.DIMENS_12),
        child: Column(children: [
          TextField(
            controller: controller,
            maxLength: 25,
            decoration: InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: COLOR_black_ff121212),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

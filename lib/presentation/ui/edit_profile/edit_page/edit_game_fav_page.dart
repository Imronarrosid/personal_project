import 'package:flutter/material.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';

class EditGameFavPage extends StatefulWidget {
  const EditGameFavPage({super.key});

  @override
  State<EditGameFavPage> createState() => _EditGameFavPageState();
}

class _EditGameFavPageState extends State<EditGameFavPage> {
  List<String> tags = ['Education'];
  List<int> tag = [1, 2, 3, 4, 5, 6, 7, 3, 5, 5];
  List<String> options = [
    'News',
    'Entertainment',
    'Politics',
    'Automotive',
    'Sports',
    'Education',
    'Fashion',
    'Travel',
    'Food',
    'Tech',
    'Science',
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: COLOR_black_ff121212,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              context.pop();
            },
            icon: Icon(MdiIcons.close)),
        actions: [IconButton(onPressed: () {}, icon: Icon(MdiIcons.check))],
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding:
              EdgeInsets.only(left: Dimens.DIMENS_12, top: Dimens.DIMENS_12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Game Favorite',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: Dimens.DIMENS_16,
              ),
              const Text(
                'Pilih game favorit untuk di tampilkan di profil',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        ChipsChoice<int>.multiple(
          value: tag,
          onChanged: (val) => setState(() => tag = val),
          choiceItems: C2Choice.listFrom<int, String>(
            source: options,
            value: (i, v) => i,
            label: (i, v) => v,
            tooltip: (i, v) => v,
            delete: (i, v) => () {
              setState(() => options.removeAt(i));
            },
          ),
          choiceStyle: C2ChipStyle.toned(
            borderRadius: const BorderRadius.all(
              Radius.circular(5),
            ),
          ),
          // leading: IconButton(
          //   tooltip: 'Add Choice',
          //   icon: const Icon(Icons.add_box_rounded),
          //   onPressed: () => setState(
          //     () => options.add('Opt #${options.length + 1}'),
          //   ),
          // ),
          // trailing: IconButton(
          //   tooltip: 'Remove Choice',
          //   icon: const Icon(Icons.remove_circle),
          //   onPressed: () => setState(() => options.removeLast()),
          // ),
          wrapped: true,
        ),
      ]),
    );
  }
}

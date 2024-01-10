import 'package:flutter/material.dart';
import 'package:personal_project/constant/dimens.dart';

void showModalBottomSheetMenu(
  BuildContext context, {
  double? height,
  String? menuTitle,
  List<Widget>? menu,
}) {
  showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: height ?? 200,
            padding: EdgeInsets.all(Dimens.DIMENS_12),
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: Dimens.DIMENS_50,
                    height: Dimens.DIMENS_5,
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.tertiary,
                        borderRadius: BorderRadius.circular(50)),
                  ),
                ),
                SizedBox(
                  height: Dimens.DIMENS_6,
                ),
                ...?menu,
                menuTitle == null
                    ? Container()
                    : Text(
                        menuTitle,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
              ],
            ),
          ),
        );
      });
}

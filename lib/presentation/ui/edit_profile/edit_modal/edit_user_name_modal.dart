import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/utils/validator_edit_user_name.dart';

void showEditUserNameModal(BuildContext context) {
  final controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (ctx) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: EdgeInsets.all(Dimens.DIMENS_12),
              decoration: BoxDecoration(
                  color: COLOR_white_fff5f5f5,
                  borderRadius: BorderRadius.circular(10)),
              height: 230,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: Dimens.DIMENS_50,
                        height: Dimens.DIMENS_8,
                        decoration: BoxDecoration(
                            color: COLOR_grey,
                            borderRadius: BorderRadius.circular(50)),
                      ),
                    ),
                    SizedBox(
                      height: Dimens.DIMENS_6,
                    ),
                    Text(
                      'Nama Pengguna',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      height: Dimens.DIMENS_8,
                    ),
                    Theme(
                      data: ThemeData().copyWith(
                          colorScheme: ThemeData()
                              .colorScheme
                              .copyWith(primary: COLOR_black_ff121212)),
                      child: Form(
                        key: _formKey,
                        child: TextFormField(
                          controller: controller,
                          validator: validateNoWhitespace,
                          onChanged: (value) {
                            _formKey.currentState!.validate();
                          },
                          autofocus: true,
                          decoration: InputDecoration(
                              prefixIcon: Icon(MdiIcons.at),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10))),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: Dimens.DIMENS_18,
                    ),
                    Container(
                      width: double.infinity,
                      height: Dimens.DIMENS_38,
                      alignment: Alignment.center,
                      child: Text(
                        'Simpan',
                        style: TextStyle(color: COLOR_white_fff5f5f5),
                      ),
                      decoration: BoxDecoration(
                          color: COLOR_black_ff121212,
                          borderRadius: BorderRadius.circular(50)),
                    )
                  ]),
            ),
          ),
        );
      });
}

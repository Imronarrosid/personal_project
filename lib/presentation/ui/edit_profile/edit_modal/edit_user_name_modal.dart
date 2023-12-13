import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/presentation/ui/edit_profile/cubit/edit_user_name_cubit.dart';
import 'package:personal_project/utils/validator_edit_user_name.dart';

void showEditUserNameModal(BuildContext context,
    {required String userName, required Timestamp lastUpdate}) async {
  final controller = TextEditingController(text: userName);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isCanEdit = await isCanEditUserName(lastUpdate);
  int daysCount = await daysUntilTwoWeeks(lastUpdate);

  debugPrint(lastUpdate.toDate().toString());

  if (!context.mounted) return;

  showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      elevation: 0,
      builder: (context) {
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
                          enabled: isCanEdit,
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
                      height: Dimens.DIMENS_8,
                    ),
                    isCanEdit
                        ? Text(
                            'Kamu bisa mengganti nama pengguna 14 hari sekali')
                        : Text(
                            'Kamu bisa mengganti nama pengguna $daysCount hari lagi'),
                    SizedBox(
                      height: Dimens.DIMENS_18,
                    ),
                    Material(
                      color: isCanEdit ? COLOR_black_ff121212 : COLOR_grey,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                      child: InkWell(
                        onTap: isCanEdit
                            ? () {
                                if (_formKey.currentState!.validate()) {
                                  BlocProvider.of<EditUserNameCubit>(context)
                                      .editUserName(controller.text);
                                }
                              }
                            : null,
                        child: Container(
                          width: double.infinity,
                          height: Dimens.DIMENS_38,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(50)),
                          child: BlocConsumer<EditUserNameCubit,
                              EditUserNameState>(
                            listener: (context, state) {
                              if (state.status == EditUserNameStatus.success) {
                                context.pop();
                              }
                            },
                            builder: (context, state) {
                              if (state.status == EditUserNameStatus.loading) {
                                return SizedBox(
                                  width: Dimens.DIMENS_18,
                                  height: Dimens.DIMENS_18,
                                  child: CircularProgressIndicator(
                                    color: COLOR_white_fff5f5f5,
                                  ),
                                );
                              }
                              return Text(
                                'Simpan',
                                style: TextStyle(
                                    color: isCanEdit
                                        ? COLOR_white_fff5f5f5
                                        : COLOR_black_ff121212),
                              );
                            },
                          ),
                        ),
                      ),
                    )
                  ]),
            ),
          ),
        );
      });
}

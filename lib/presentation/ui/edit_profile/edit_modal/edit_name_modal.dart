import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/presentation/ui/edit_profile/cubit/edit_name_cubit.dart';
import 'package:personal_project/utils/edit_name_check.dart';

void showEditNameModal(BuildContext context, String name, Timestamp timestamp) {
  final controller = TextEditingController(text: name);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? validator(String? value) {
    if (value!.trim().isEmpty) {
      return 'Nama tidak boleh diawali spasi.';
    } else if (value.isEmpty) {
      return 'Nama tidak boleh kosong.';
    }
    return null; // Return null if the input is valid
  }

  showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return BlocListener<EditNameCubit, EditNameState>(
          listener: (context, state) {
            if (state.status == EditNameStatus.nameEditSuccess) {
              context.pop();
            }
          },
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: EdgeInsets.all(Dimens.DIMENS_12),
                decoration: BoxDecoration(
                    color: COLOR_white_fff5f5f5,
                    borderRadius: BorderRadius.circular(10)),
                height: 250,
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
                        'Nama',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
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
                            validator: validator,
                            controller: controller,
                            onChanged: (value) {
                              _formKey.currentState!.validate();
                            },
                            enabled: isCanEditName(timestamp),
                            autofocus: true,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10))),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: Dimens.DIMENS_8,
                      ),
                      isCanEditName(timestamp)
                          ? Text('Kamu bisa mengganti nama 7 hari sekali')
                          : Text(
                              'Kamu dapat mengganti nama ${daysUntilOneWeeks(timestamp)} hari lagi'),
                      SizedBox(
                        height: Dimens.DIMENS_18,
                      ),
                      InkWell(
                        onTap: isCanEditName(timestamp)
                            ? () {
                                if (_formKey.currentState!.validate()) {
                                  BlocProvider.of<EditNameCubit>(context)
                                      .editName(controller.text);
                                  debugPrint('editname');
                                }
                              }
                            : null,
                        child: Container(
                          width: double.infinity,
                          height: Dimens.DIMENS_38,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: isCanEditName(timestamp)
                                  ? COLOR_black_ff121212
                                  : COLOR_grey,
                              borderRadius: BorderRadius.circular(50)),
                          child: BlocBuilder<EditNameCubit, EditNameState>(
                            builder: (context, state) {
                              debugPrint('state ${state.status}');
                              if (state.status == EditNameStatus.editProccess) {
                                return Container(
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
                                    color: isCanEditName(timestamp)
                                        ? COLOR_white_fff5f5f5
                                        : COLOR_black_ff121212),
                              );
                            },
                          ),
                        ),
                      )
                    ]),
              ),
            ),
          ),
        );
      });
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/presentation/ui/edit_profile/cubit/edit_user_name_cubit.dart';
import 'package:personal_project/utils/is_same_day.dart';
import 'package:personal_project/utils/validator_edit_user_name.dart';

void showEditUserNameModal(BuildContext context,
    {required String userName,
    required Timestamp lastUpdate,
    required Timestamp userCreatedAt}) async {
  final controller = TextEditingController(text: userName);
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isAvailable = false;

  bool isCanEdit = await isCanEditUserName(lastUpdate) ||
      isSameDay(lastUpdate.toDate(), userCreatedAt.toDate());
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
          child: BlocListener<EditUserNameCubit, EditUserNameState>(
            listener: (context, state) {
              if (state.status == EditUserNameStatus.userNameNotAvailable) {
                isAvailable = false;
                formKey.currentState!.validate();
              }
              if (state.status == EditUserNameStatus.availlable) {
                isAvailable = true;
                formKey.currentState!.validate();
              }
              debugPrint('qwerty ENC ${state.status.name}');
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: EdgeInsets.all(Dimens.DIMENS_12),
                decoration: BoxDecoration(
                    color: COLOR_white_fff5f5f5,
                    borderRadius: BorderRadius.circular(10)),
                height: 270,
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
                          key: formKey,
                          child: TextFormField(
                            enabled: isCanEdit,
                            controller: controller,
                            validator: (value) {
                              return _validator(value, isAvailable);
                            },
                            onChanged: (value) {
                              BlocProvider.of<EditUserNameCubit>(context)
                                  .checkUserNameAvailability(value);
                            },
                            autofocus: true,
                            decoration: InputDecoration(
                              prefixIcon: Icon(MdiIcons.at),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              suffix: BlocBuilder<EditUserNameCubit,
                                  EditUserNameState>(
                                builder: (context, state) {
                                  if (state.status ==
                                      EditUserNameStatus.loading) {
                                    return SizedBox(
                                        width: Dimens.DIMENS_12,
                                        height: Dimens.DIMENS_12,
                                        child:
                                            const CircularProgressIndicator());
                                  }
                                  return const SizedBox(
                                    width: 0,
                                    height: 0,
                                  );
                                },
                              ),
                            ),
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
                      BlocBuilder<EditUserNameCubit, EditUserNameState>(
                        builder: (context, state) {
                          return Material(
                            color: isCanEdit ||
                                    state.status ==
                                        EditUserNameStatus.availlable
                                ? COLOR_black_ff121212
                                : COLOR_grey,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50)),
                            child: InkWell(
                              onTap: isCanEdit
                                  ? () {
                                      if (formKey.currentState!.validate()) {
                                        BlocProvider.of<EditUserNameCubit>(
                                                context)
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
                                    if (state.status ==
                                        EditUserNameStatus.success) {
                                      context.pop();
                                    }
                                  },
                                  builder: (context, state) {
                                    if (state.status ==
                                        EditUserNameStatus.loading) {
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
                                          color: isCanEdit ||
                                                  state.status ==
                                                      EditUserNameStatus
                                                          .availlable
                                              ? COLOR_white_fff5f5f5
                                              : COLOR_black_ff121212),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    ]),
              ),
            ),
          ),
        );
      });
}

String? _validator(String? value, bool isAvailable) {
  if (value!.contains(RegExp(r'\s'))) {
    return 'Nama pengguna tidak boleh menggunakan spasi.';
  } else if (value.isEmpty) {
    return 'Nama Pengguna tidak boleh kosong.';
  } else if (value.trim().isEmpty) {
    return 'Nama pengguna tidak boleh diawali spasi.';
  } else if (isAvailable == false) {
    return 'User name not available.';
  }
  debugPrint('qwerty isacjaklv $isAvailable');
  return null; // Return null if the input is valid
}

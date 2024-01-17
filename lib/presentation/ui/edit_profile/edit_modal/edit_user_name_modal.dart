import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
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
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(10)),
                height: 270,
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
                      Text(
                        LocaleKeys.label_user_name.tr(),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: Dimens.DIMENS_8,
                      ),
                      Form(
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
                            prefixIcon: const Icon(BootstrapIcons.at),
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
                                      child: const CircularProgressIndicator());
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
                      SizedBox(
                        height: Dimens.DIMENS_8,
                      ),
                      isCanEdit
                          ? Text(LocaleKeys
                              .message_usename_can_update_every_14_days
                              .tr())
                          : Text(
                              LocaleKeys.message_username_can_update_days_later
                                  .tr(args: [daysCount.toString()]),
                            ),
                      SizedBox(
                        height: Dimens.DIMENS_18,
                      ),
                      BlocBuilder<EditUserNameCubit, EditUserNameState>(
                        builder: (context, state) {
                          return Material(
                            color: isCanEdit ||
                                    state.status ==
                                        EditUserNameStatus.availlable
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.tertiary,
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
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ),
                                      );
                                    }
                                    return Text(
                                      LocaleKeys.label_save.tr(),
                                      style: TextStyle(
                                          color: isCanEdit ||
                                                  state.status ==
                                                      EditUserNameStatus
                                                          .availlable
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .secondary
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
    return LocaleKeys.message_user_name_cant_contain_whitespace.tr();
  } else if (value.isEmpty) {
    return LocaleKeys.message_user_name_cant_empty.tr();
  } else if (value.trim().isEmpty) {
    return LocaleKeys.message_user_name_cant_empty.tr();
  } else if (isAvailable == false) {
    return LocaleKeys.message_user_name_not_available.tr();
  }
  debugPrint('qwerty isacjaklv $isAvailable');
  return null; // Return null if the input is valid
}

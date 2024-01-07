import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/ui/edit_profile/cubit/edit_name_cubit.dart';
import 'package:personal_project/utils/edit_name_check.dart';
import 'package:personal_project/utils/is_same_day.dart';

void showEditNameModal(BuildContext context, String name, Timestamp timestamp,
    Timestamp userCreatedAt) async {
  final controller = TextEditingController(text: name);

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String? validator(String? value) {
    if (value!.trim().isEmpty) {
      return LocaleKeys.message_dont_start_with_whitespace.tr();
    } else if (value.isEmpty) {
      return LocaleKeys.message_name_cant_empty.tr();
    }
    return null; // Return null if the input is valid
  }

  bool isCanEdit = await isCanEditName(timestamp) ||
      isSameDay(timestamp.toDate(), userCreatedAt.toDate());
  int daysCount = await daysUntilOneWeeks(timestamp);
  if (context.mounted) {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        elevation: 0,
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
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(10)),
                  height: 250,
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
                          LocaleKeys.label_name.tr(),
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: Dimens.DIMENS_8,
                        ),
                        Form(
                          key: formKey,
                          child: TextFormField(
                            validator: validator,
                            controller: controller,
                            onChanged: (value) {
                              formKey.currentState!.validate();
                            },
                            enabled: isCanEdit,
                            autofocus: true,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10))),
                          ),
                        ),
                        SizedBox(
                          height: Dimens.DIMENS_8,
                        ),
                        isCanEdit
                            ? Text(LocaleKeys.message_edit_can_name_every_7_day
                                .tr())
                            : Text(LocaleKeys.message_edit_name_day_later
                                .tr(args: [daysCount.toString()])),
                        SizedBox(
                          height: Dimens.DIMENS_18,
                        ),
                        InkWell(
                          onTap: isCanEdit
                              ? () {
                                  if (formKey.currentState!.validate() &&
                                      name != controller.text) {
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
                                color: isCanEdit
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.tertiary,
                                borderRadius: BorderRadius.circular(50)),
                            child: BlocBuilder<EditNameCubit, EditNameState>(
                              builder: (context, state) {
                                debugPrint('state ${state.status}');
                                if (state.status ==
                                    EditNameStatus.editProccess) {
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
                                      color: isCanEdit &&
                                              name != controller.text.trim()
                                          ? Theme.of(context)
                                              .colorScheme
                                              .secondary
                                          : COLOR_black_ff121212),
                                );
                              },
                            ),
                          ),
                        ),
                      ]),
                ),
              ),
            ),
          );
        });
  }
}

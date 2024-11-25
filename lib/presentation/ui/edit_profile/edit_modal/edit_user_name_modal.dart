import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/responsive/dimension.dart';
import 'package:personal_project/presentation/ui/edit_profile/cubit/edit_user_name_cubit.dart';
import 'package:personal_project/utils/is_same_day.dart';
import 'package:personal_project/utils/validator_edit_user_name.dart';

import '../../../../utils/debug_mode_print.dart';

void showEditUserNameModal(BuildContext context,
    {required String userName,
    required Timestamp lastUpdate,
    required Timestamp userCreatedAt}) async {
  bool isCanEdit = await isCanEditUserName(lastUpdate) ||
      isSameDay(lastUpdate.toDate(), userCreatedAt.toDate());
  int daysCount = await daysUntilTwoWeeks(lastUpdate);

  debugModePrint(lastUpdate.toDate().toString());

  if (!context.mounted) return;
  if (MediaQuery.of(context).size.width > mobileWidth) {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            surfaceTintColor: Colors.transparent,
            backgroundColor: Theme.of(context).colorScheme.surface,
            child: SizedBox(
              width: 400,
              height: 300,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: EditUserNameView(
                      isCanEdit: isCanEdit,
                      daysCount: daysCount,
                      userName: userName,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                          onPressed: () => context.pop(),
                          icon: const Icon(
                            Icons.close_rounded,
                          )),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  } else {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        context: context,
        elevation: 0,
        builder: (context) {
          return EditUserNameView(
            isCanEdit: isCanEdit,
            daysCount: daysCount,
            userName: userName,
            showDragHandle: true,
          );
        });
  }
}

class EditUserNameView extends StatefulWidget {
  const EditUserNameView({
    super.key,
    required this.isCanEdit,
    required this.daysCount,
    required this.userName,
    this.showDragHandle = false,
  });

  final bool isCanEdit;
  final int daysCount;
  final String userName;
  final bool showDragHandle;

  @override
  State<EditUserNameView> createState() => _EditUserNameViewState();
}

class _EditUserNameViewState extends State<EditUserNameView> {
  bool isAvailable = false;
  final ValueNotifier<bool> _listenable = ValueNotifier<bool>(true);
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late final TextEditingController controller;

  bool _isUserNameValid = true;

  @override
  void initState() {
    controller = TextEditingController(text: widget.userName);
    context.read<EditUserNameCubit>().resetState();
    super.initState();
  }

  @override
  void dispose() {
    _listenable.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          debugModePrint('qwerty ENC ${state.status.name}');
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            padding: EdgeInsets.all(Dimens.DIMENS_12),
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(10)),
            height: 270,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Builder(builder: (context) {
                return !widget.showDragHandle
                    ? const SizedBox.shrink()
                    : Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: Dimens.DIMENS_50,
                          height: Dimens.DIMENS_5,
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.tertiary,
                              borderRadius: BorderRadius.circular(50)),
                        ),
                      );
              }),
              SizedBox(
                height: Dimens.DIMENS_6,
              ),
              Text(
                LocaleKeys.label_user_name.tr(),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: Dimens.DIMENS_8,
              ),
              Form(
                key: formKey,
                child: BlocBuilder<EditUserNameCubit, EditUserNameState>(
                  builder: (context, state) {
                    return TextFormField(
                      enabled: widget.isCanEdit,
                      controller: controller,
                      maxLength: 24,
                      buildCounter: (context,
                          {required currentLength,
                          required isFocused,
                          required maxLength}) {
                        return const SizedBox.shrink();
                      },
                      validator: (value) {
                        return _validator(value, isAvailable);
                      },
                      onChanged: (value) {
                        if (value.trim() == widget.userName) {
                          _listenable.value = true;
                        } else {
                          _listenable.value = false;
                        }
                        BlocProvider.of<EditUserNameCubit>(context)
                            .checkUserNameAvailability(value);
                      },
                      autofocus: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(BootstrapIcons.at),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        suffix:
                            BlocBuilder<EditUserNameCubit, EditUserNameState>(
                          builder: (context, state) {
                            if (state.status == EditUserNameStatus.loading) {
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
                    );
                  },
                ),
              ),
              SizedBox(
                height: Dimens.DIMENS_8,
              ),
              _formMessage(),
              const Spacer(),
              _saveButton()
            ]),
          ),
        ),
      ),
    );
  }

  BlocBuilder<EditUserNameCubit, EditUserNameState> _saveButton() {
    return BlocBuilder<EditUserNameCubit, EditUserNameState>(
      builder: (context, state) {
        return ValueListenableBuilder<bool>(
            valueListenable: _listenable,
            builder: (context, isCurrentName, child) {
              debugModePrint(
                  'isvalid $_isUserNameValid iscurrntName$isCurrentName isavailable ${state.status == EditUserNameStatus.availlable}');
              return Material(
                color: _isUserNameValid &&
                        !isCurrentName &&
                        widget.isCanEdit &&
                        state.status == EditUserNameStatus.availlable
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.tertiary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: widget.isCanEdit && !isCurrentName
                      ? () {
                          if (formKey.currentState!.validate()) {
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
                    child: BlocConsumer<EditUserNameCubit, EditUserNameState>(
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
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          );
                        }
                        return Text(
                          LocaleKeys.label_save.tr(),
                          style: TextStyle(
                              color: _isUserNameValid &&
                                      !isCurrentName &&
                                      widget.isCanEdit &&
                                      state.status ==
                                          EditUserNameStatus.availlable
                                  ? Theme.of(context).colorScheme.secondary
                                  : COLOR_black_ff121212),
                        );
                      },
                    ),
                  ),
                ),
              );
            });
      },
    );
  }

  Padding _formMessage() {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0),
      child: widget.isCanEdit
          ? Text(LocaleKeys.message_usename_can_update_every_14_days.tr())
          : Text(
              LocaleKeys.message_username_can_update_days_later
                  .tr(args: [widget.daysCount.toString()]),
            ),
    );
  }

  String? _validator(String? value, bool isAvailable) {
    if (value!.contains(RegExp(r'\s'))) {
      _isUserNameValid = false;
      return LocaleKeys.message_user_name_cant_contain_whitespace.tr();
    } else if (value.isEmpty) {
      _isUserNameValid = false;
      return LocaleKeys.message_user_name_cant_empty.tr();
    } else if (value.trim().isEmpty) {
      _isUserNameValid = false;
      return LocaleKeys.message_user_name_cant_empty.tr();
    } else if (isAvailable == false) {
      _isUserNameValid = false;
      return LocaleKeys.message_user_name_not_available.tr();
    }
    _isUserNameValid = true;
    debugModePrint('qwerty isacjaklv $isAvailable');
    return null; // Return null if the input is valid
  }
}

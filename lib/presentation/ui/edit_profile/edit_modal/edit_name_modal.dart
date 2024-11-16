import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/responsive/dimension.dart';
import 'package:personal_project/presentation/ui/edit_profile/cubit/edit_name_cubit.dart';
import 'package:personal_project/utils/edit_name_check.dart';
import 'package:personal_project/utils/is_same_day.dart';

import '../../../../utils/debug_mode_print.dart';

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
  if (context.mounted && MediaQuery.of(context).size.width > mobileWidth) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Theme.of(context).colorScheme.surface,
        child: SizedBox(
          width: 400,
          height: 300,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: EditNameView(
                  formKey: formKey,
                  validator: validator,
                  controller: controller,
                  isCanEdit: isCanEdit,
                  daysCount: daysCount,
                  name: name,
                  isShowDragHandle: false,
                  width: 400,
                  height: 300,
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
      ),
    );
  } else {
    if (!context.mounted) return;
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        elevation: 0,
        context: context,
        builder: (context) {
          return EditNameView(
            formKey: formKey,
            validator: validator,
            controller: controller,
            isCanEdit: isCanEdit,
            daysCount: daysCount,
            name: name,
            height: 250,
          );
        });
  }
}

class EditNameView extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final String? Function(String? value) validator;
  final TextEditingController controller;
  final bool isCanEdit;
  final int daysCount;
  final String name;
  final bool isShowDragHandle;
  final double? height;
  final double? width;
  const EditNameView({
    super.key,
    required this.formKey,
    required this.validator,
    required this.controller,
    required this.isCanEdit,
    required this.daysCount,
    required this.name,
    this.isShowDragHandle = true,
    this.height,
    this.width,
  });

  @override
  State<EditNameView> createState() => _EditNameViewState();
}

class _EditNameViewState extends State<EditNameView> {
  late final ValueNotifier<String> valueListenableBuilder;

  @override
  void initState() {
    valueListenableBuilder = ValueNotifier<String>(widget.controller.text);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditNameCubit, EditNameState>(
      listener: (context, state) {
        if (state.status == EditNameStatus.nameEditSuccess) {
          context.pop();
        }
      },
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            padding: EdgeInsets.all(Dimens.DIMENS_12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            height: widget.height,
            width: widget.width,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              widget.isShowDragHandle
                  ? Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: Dimens.DIMENS_50,
                        height: Dimens.DIMENS_5,
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.tertiary,
                            borderRadius: BorderRadius.circular(50)),
                      ),
                    )
                  : const SizedBox.shrink(),
              SizedBox(
                height: Dimens.DIMENS_6,
              ),
              Text(
                LocaleKeys.label_name.tr(),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: Dimens.DIMENS_8,
              ),
              Form(
                key: widget.formKey,
                child: TextFormField(
                  validator: widget.validator,
                  controller: widget.controller,
                  maxLength: 24,
                  buildCounter: (context,
                      {required currentLength,
                      required isFocused,
                      required maxLength}) {
                    return const SizedBox.shrink();
                  },
                  onChanged: (value) {
                    widget.formKey.currentState!.validate();
                    valueListenableBuilder.value = value.trim();
                  },
                  enabled: widget.isCanEdit,
                  autofocus: true,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
              ),
              SizedBox(
                height: Dimens.DIMENS_8,
              ),
              widget.isCanEdit
                  ? Text(LocaleKeys.message_edit_can_name_every_7_day.tr())
                  : Text(
                      LocaleKeys.message_edit_name_day_later
                          .tr(args: [widget.daysCount.toString()]),
                    ),
              SizedBox(
                height: Dimens.DIMENS_18,
              ),
              const Spacer(),
              ValueListenableBuilder(
                  valueListenable: valueListenableBuilder,
                  builder: (context, value, child) {
                    return Material(
                      color: widget.isCanEdit && widget.name != value
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.tertiary,
                      borderRadius: BorderRadius.circular(50),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(50),
                        onTap: widget.isCanEdit && widget.name != value
                            ? () {
                                if (widget.formKey.currentState!.validate() &&
                                    widget.name != widget.controller.text) {
                                  BlocProvider.of<EditNameCubit>(context)
                                      .editName(widget.controller.text);
                                  debugModePrint('editname');
                                }
                              }
                            : null,
                        child: Container(
                          width: double.infinity,
                          height: Dimens.DIMENS_38,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: widget.isCanEdit &&
                                      widget.name !=
                                          widget.controller.text.trim()
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.tertiary,
                            ),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: BlocBuilder<EditNameCubit, EditNameState>(
                            builder: (context, state) {
                              debugModePrint('state ${state.status}');
                              if (state.status == EditNameStatus.editProccess) {
                                return SizedBox(
                                  width: Dimens.DIMENS_18,
                                  height: Dimens.DIMENS_18,
                                  child: CircularProgressIndicator(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                );
                              }
                              return Text(
                                LocaleKeys.label_save.tr(),
                                style: TextStyle(
                                  color: widget.isCanEdit &&
                                          widget.name !=
                                              widget.controller.text.trim()
                                      ? Theme.of(context).colorScheme.secondary
                                      : COLOR_black_ff121212,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  }),
            ]),
          ),
        ),
      ),
    );
  }
}

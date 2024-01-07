import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/ui/edit_profile/cubit/edit_bio_cubit.dart';

void showEditBioMpdal(BuildContext context, {required String bio}) {
  final TextEditingController controller = TextEditingController(text: bio);
  showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      elevation: 0,
      context: context,
      builder: (context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 300,
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
                    Text(
                      LocaleKeys.label_bio.tr(),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      height: Dimens.DIMENS_8,
                    ),
                    TextField(
                      controller: controller,
                      autofocus: true,
                      maxLines: 4,
                      minLines: 4,
                      maxLength: 150,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                    ),
                    SizedBox(
                      height: Dimens.DIMENS_18,
                    ),
                    Material(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                      color: Theme.of(context).colorScheme.primary,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(50),
                        onTap: () {
                          BlocProvider.of<EditBioCubit>(context)
                              .editBio(controller.text);
                        },
                        child: Container(
                          width: double.infinity,
                          height: Dimens.DIMENS_38,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(50)),
                          child: BlocConsumer<EditBioCubit, EditBioState>(
                            builder: (context, state) {
                              if (state.status == EditBioStatus.loading) {
                                return SizedBox(
                                    width: Dimens.DIMENS_18,
                                    height: Dimens.DIMENS_18,
                                    child: CircularProgressIndicator(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ));
                              }
                              return Text(
                                LocaleKeys.label_save.tr(),
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary),
                              );
                            },
                            listener:
                                (BuildContext context, EditBioState state) {
                              if (state.status == EditBioStatus.succes) {
                                context.pop();
                              }
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

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/data/repository/file_repository.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/ui/storage/cubit/storage_cubit.dart';

class CachesPage extends StatelessWidget {
  const CachesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => FileRepository()..calculateCacheSize(),
      child: BlocProvider(
        create: (_) => StorageCubit(
          RepositoryProvider.of<FileRepository>(context),
        )..getCacheSize(),
        child: Builder(builder: (context) {
          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              title: Text(LocaleKeys.title_storage.tr()),
            ),
            body: Column(
              children: [
                SizedBox(
                  height: Dimens.DIMENS_15,
                ),
                BlocBuilder<StorageCubit, StorageState>(
                  builder: (context, state) {
                    String size = '0.0';
                    if (state.status == StorageStatus.loaded) {
                      size = state.size!;
                    }
                    return Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: Dimens.DIMENS_12),
                      child: ListTile(
                        minVerticalPadding: Dimens.DIMENS_12,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        title: Padding(
                          padding: EdgeInsets.only(bottom: Dimens.DIMENS_12),
                          child: Row(
                            children: [
                              StreamBuilder<int>(
                                  initialData: 0,
                                  stream: RepositoryProvider.of<FileRepository>(
                                          context)
                                      .fileSizeStream,
                                  builder: (context, snapshot) {
                                    return Text(
                                        LocaleKeys.label_caches.tr(args: [
                                          state.status == StorageStatus.loaded
                                              ? size
                                              : fileMBSize(snapshot.data!)
                                        ]),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold));
                                  }),
                              const Spacer(),
                              Material(
                                color: COLOR_grey,
                                borderRadius: BorderRadius.circular(5),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(5),
                                  onTap: () {
                                    _clearCachesDialog(context);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 7),
                                    decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(5)),
                                    child: Text(
                                      LocaleKeys.label_delete.tr(),
                                      style: TextStyle(
                                          color: COLOR_black_ff121212),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        subtitle: Text(LocaleKeys.message_caches.tr()),
                      ),
                    );
                  },
                )
              ],
            ),
          );
        }),
      ),
    );
  }

  String fileMBSize(int bytes) {
    return (bytes / (1024 * 1024)).toStringAsFixed(1);
  }

  bool _clearCachesDialog(BuildContext context) {
    bool isClearCahce = false;
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text(LocaleKeys.message_delete_cache.tr()),
            actions: [
              TextButton(
                  onPressed: () => context.pop(),
                  child: Text(LocaleKeys.label_cancel.tr())),
              TextButton(
                  onPressed: () {
                    BlocProvider.of<StorageCubit>(context).clearCache();
                    context.pop();
                  },
                  child: Text(LocaleKeys.label_delete.tr()))
            ],
          );
        });
    return isClearCahce;
  }
}

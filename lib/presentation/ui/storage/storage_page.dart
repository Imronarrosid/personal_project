import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/data/repository/file_repository.dart';
import 'package:personal_project/presentation/ui/storage/cubit/storage_cubit.dart';

class CachesPage extends StatelessWidget {
  const CachesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => FileRepository(),
      child: BlocProvider(
        create: (_) => StorageCubit(
          RepositoryProvider.of<FileRepository>(context),
        )..getCacheSize(),
        child: Builder(builder: (context) {
          return Scaffold(
              backgroundColor: COLOR_white_fff5f5f5,
              appBar: AppBar(
                backgroundColor: COLOR_white_fff5f5f5,
                foregroundColor: COLOR_black_ff121212,
                elevation: 0,
                title: const Text('Penyimpanan'),
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
                      return ListTile(
                        tileColor: Colors.white,
                        minVerticalPadding: Dimens.DIMENS_12,
                        title: Padding(
                          padding: EdgeInsets.only(bottom: Dimens.DIMENS_12),
                          child: Row(
                            children: [
                              Text('Cache: ${size}MB',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
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
                                      'Hapus',
                                      style: TextStyle(
                                          color: COLOR_black_ff121212),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        subtitle: Text(
                            'Kamu dapat membersihkan cache, Akun tidak akan terpengaruh'),
                      );
                    },
                  )
                ],
              ));
        }),
      ),
    );
  }

  bool _clearCachesDialog(BuildContext context) {
    bool isClearCahce = false;
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text('Hapus cache?'),
            actions: [
              TextButton(
                  onPressed: () => context.pop(), child: const Text('Batal')),
              TextButton(
                  onPressed: () {
                    BlocProvider.of<StorageCubit>(context).clearCache();
                    context.pop();
                  },
                  child: const Text('Hapus'))
            ],
          );
        });
    return isClearCahce;
  }
}

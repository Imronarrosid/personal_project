import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:personal_project/data/repository/upload_repository.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';

class UploadingPage extends StatelessWidget {
  const UploadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Scaffold(
        appBar: AppBar(
          title: Text(LocaleKeys.message_uploading.tr()),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
        ),
        body: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Material(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(
                        LocaleKeys.message_uploading.tr(),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      tileColor: Theme.of(context).colorScheme.tertiary,
                      minLeadingWidth: 50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      leading: SizedBox(
                        width: 50,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Image.file(
                                UploadRepository.instance.thubnailOnUploading!,
                                width: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                            StreamBuilder(
                              stream: UploadRepository
                                  .instance.uploadProgressStream,
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return Container();
                                }
                                return SizedBox.expand(
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Text(
                                        '${snapshot.data!.toInt()}%',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      subtitle: SizedBox(
                        height: 30,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              UploadRepository
                                  .instance.videoOnUploading!.caption,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            StreamBuilder(
                              stream: UploadRepository
                                  .instance.uploadProgressStream,
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return Container();
                                }
                                return LinearProgressIndicator(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.5),
                                  value: snapshot.data! / 100,
                                  color: Theme.of(context).colorScheme.primary,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }
}

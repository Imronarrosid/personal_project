import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mime/mime.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/domain/model/chat_data_models.dart';
import 'package:personal_project/domain/model/profile_data_model.dart';
import 'package:personal_project/domain/reporsitory/auth_reposotory.dart';
import 'package:personal_project/domain/reporsitory/user_repository.dart';
import 'package:personal_project/presentation/l10n/locale_code.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/router/route_utils.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
    required this.data,
  });

  // final types.Room room;
  final ChatData data;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool _isAttachmentUploading = false;

  void _handleAtachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            padding: EdgeInsets.all(Dimens.DIMENS_12),
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(10)),
            height: 230,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
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
                  height: Dimens.DIMENS_30,
                ),
                Material(
                  child: ListTile(
                    leading: Icon(MdiIcons.image),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    )),
                    title: Text(LocaleKeys.label_photo.tr()),
                    onTap: () {
                      context.pop();
                      _handleImageSelection();
                    },
                  ),
                ),
                Material(
                  child: ListTile(
                    leading: Icon(MdiIcons.file),
                    title: Text(LocaleKeys.label_file.tr()),
                    onTap: () {
                      context.pop();
                      _handleFileSelection();
                    },
                  ),
                ),
                Material(
                  child: ListTile(
                    leading: Icon(MdiIcons.close),
                    title: Text(LocaleKeys.label_cancel.tr()),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    )),
                    onTap: () {
                      context.pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleFileSelection() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      _setAttachmentUploading(true);
      final name = result.files.single.name;
      final filePath = result.files.single.path!;
      final file = File(filePath);

      try {
        final reference = FirebaseStorage.instance.ref(name);
        await reference.putFile(file);
        final uri = await reference.getDownloadURL();

        final message = types.PartialFile(
          mimeType: lookupMimeType(filePath),
          name: name,
          size: result.files.single.size,
          uri: uri,
        );

        FirebaseChatCore.instance.sendMessage(message, widget.data.room.id);
        _setAttachmentUploading(false);
      } finally {
        _setAttachmentUploading(false);
      }
    }
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      _setAttachmentUploading(true);
      final file = File(result.path);
      final size = file.lengthSync();
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);
      final name = result.name;

      try {
        final reference = FirebaseStorage.instance.ref(name);
        await reference.putFile(file);
        final uri = await reference.getDownloadURL();

        final message = types.PartialImage(
          height: image.height.toDouble(),
          name: name,
          size: size,
          uri: uri,
          width: image.width.toDouble(),
        );

        FirebaseChatCore.instance.sendMessage(
          message,
          widget.data.room.id,
        );
        _setAttachmentUploading(false);
      } finally {
        _setAttachmentUploading(false);
      }
    }
  }

  void _handleMessageTap(BuildContext _, types.Message message) async {
    if (message is types.FileMessage) {
      var localPath = message.uri;

      if (message.uri.startsWith('http')) {
        try {
          final updatedMessage = message.copyWith(isLoading: true);
          FirebaseChatCore.instance.updateMessage(
            updatedMessage,
            widget.data.room.id,
          );

          final client = http.Client();
          final request = await client.get(Uri.parse(message.uri));
          final bytes = request.bodyBytes;
          final documentsDir = (await getApplicationDocumentsDirectory()).path;
          localPath = '$documentsDir/${message.name}';

          if (!File(localPath).existsSync()) {
            final file = File(localPath);
            await file.writeAsBytes(bytes);
          }
        } finally {
          final updatedMessage = message.copyWith(isLoading: false);
          FirebaseChatCore.instance.updateMessage(
            updatedMessage,
            widget.data.room.id,
          );
        }
      }

      await OpenFilex.open(localPath);
    }
  }

  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final updatedMessage = message.copyWith(previewData: previewData);

    FirebaseChatCore.instance
        .updateMessage(updatedMessage, widget.data.room.id);
  }

  void _handleSendPressed(types.PartialText message) {
    FirebaseChatCore.instance.sendMessage(
      message,
      widget.data.room.id,
    );
  }

  void _setAttachmentUploading(bool uploading) {
    setState(() {
      _isAttachmentUploading = uploading;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          title: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Ink(
              width: Dimens.DIMENS_42,
              height: Dimens.DIMENS_42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: CachedNetworkImageProvider(
                    widget.data.avatar,
                  ),
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: () {
                  _toProfile(context);
                },
              ),
            ),
            title: GestureDetector(
              onTap: () {
                _toProfile(context);
              },
              child: Text(
                widget.data.userName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          actions: [
            PopupMenuButton(
              elevation: 3,
              surfaceTintColor: Theme.of(context).colorScheme.secondary,
              itemBuilder: (_) {
                return [
                  PopupMenuItem(
                    height: Dimens.DIMENS_38,
                    onTap: () {
                      _toProfile(context);
                    },
                    child: Text(
                      LocaleKeys.label_see_profile.tr(),
                    ),
                  )
                ];
              },
            )
          ],
        ),
        body: StreamBuilder<types.Room>(
            stream: FirebaseChatCore.instance.room(widget.data.room.id),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return StreamBuilder<List<types.Message>>(
                stream: FirebaseChatCore.instance.messages(snapshot.data!),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return Chat(
                    dateLocale: context.locale.languageCode,
                    theme: _chatTheme(context),
                    avatarBuilder: _buildAvatar,
                    l10n: _getL10n(context),
                    showUserNames: true,
                    nameBuilder: _buildName,
                    showUserAvatars: true,
                    isAttachmentUploading: _isAttachmentUploading,
                    messages: snapshot.data ?? [],
                    hideBackgroundOnEmojiMessages: false,
                    onAttachmentPressed: _handleAtachmentPressed,
                    onMessageTap: _handleMessageTap,
                    onPreviewDataFetched: _handlePreviewDataFetched,
                    onSendPressed: _handleSendPressed,
                    user: types.User(
                      id: FirebaseChatCore.instance.firebaseUser?.uid ?? '',
                    ),
                  );
                },
              );
            }),
      );

  void _toProfile(BuildContext context) {
    final AuthRepository repo = RepositoryProvider.of<AuthRepository>(context);
    if (widget.data.room.type == types.RoomType.direct) {
      types.User user = widget.data.room.users
          .firstWhere((element) => element.id != repo.currentUser!.uid);
      context.push(
        APP_PAGE.profile.toPath,
        extra: ProfilePayload(
            uid: user.id,
            name: widget.data.name!,
            userName: widget.data.userName,
            photoURL: widget.data.avatar),
      );
    }
  }

  DefaultChatTheme _chatTheme(BuildContext context) {
    return DefaultChatTheme(
      primaryColor: Theme.of(context).colorScheme.onTertiary,
      inputBackgroundColor: Theme.of(context).colorScheme.tertiary,
      inputMargin: EdgeInsets.symmetric(
          horizontal: Dimens.DIMENS_6, vertical: Dimens.DIMENS_5),
      inputBorderRadius: BorderRadius.circular(50),
      backgroundColor: Theme.of(context).colorScheme.secondary,
    );
  }

  ChatL10n _getL10n(BuildContext context) {
    if (context.locale.languageCode == LOCALE.id.code) {
      return const ChatL10nId();
    } else if (context.locale.languageCode == LOCALE.en.code) {
      return const ChatL10nEn();
    } else {
      return const ChatL10nId();
    }
  }

  Widget _buildName(_) {
    if (widget.data.room.type == types.RoomType.direct) {
      return Text(
        widget.data.userName,
        style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
      );
    }
    return Container();
  }

  Widget _buildAvatar(types.User author) {
    final UserRepository repo = RepositoryProvider.of<UserRepository>(context);
    return StreamBuilder(
        stream: repo.getAvatar(author.id),
        builder: (context, AsyncSnapshot<String> snapshot) {
          String? avatar = snapshot.data;
          if (!snapshot.hasData) {
            return SizedBox(
              width: Dimens.DIMENS_38,
              height: Dimens.DIMENS_38,
            );
          }
          return Material(
            borderRadius: BorderRadius.circular(50),
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              radius: Dimens.DIMENS_20,
              onTap: () {
                _toProfile(context);
              },
              child: Container(
                width: Dimens.DIMENS_38,
                height: Dimens.DIMENS_38,
                padding: EdgeInsets.all(Dimens.DIMENS_5),
                child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: Dimens.DIMENS_13,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: CachedNetworkImage(
                      imageUrl: avatar!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }
}

import 'dart:io';

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/data/repository/chat_repository.dart';
import 'package:personal_project/domain/model/chat_data_models.dart';
import 'package:personal_project/domain/reporsitory/auth_reposotory.dart';
import 'package:personal_project/domain/reporsitory/user_repository.dart';
import 'package:personal_project/presentation/l10n/locale_code.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/router/route_utils.dart';
import 'package:personal_project/presentation/ui/chat/list_chat_notifier.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher.dart';

import '../../../utils/debug_mode_print.dart';
import '../../router/app_router.dart';

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
  ChatData? chatData;
  ListChatNotifier listChatNotifier = ListChatNotifier();

  @override
  void initState() {
    chatData = widget.data;
    super.initState();
  }

  void _handleAtachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      builder: (BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            padding: EdgeInsets.all(Dimens.DIMENS_12),
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
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
                    leading: const Icon(BootstrapIcons.image),
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
                    leading: const Icon(BootstrapIcons.folder),
                    title: Text(LocaleKeys.label_file.tr()),
                    onTap: () {
                      context.pop();
                      _handleFileSelection();
                    },
                  ),
                ),
                Material(
                  child: ListTile(
                    leading: const Icon(BootstrapIcons.x),
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
    final ChatRepository repo = RepositoryProvider.of<ChatRepository>(context);
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.isNotEmpty) {
      _setAttachmentUploading(true);
      final name = result.files.single.name;
      // final filePath = result.files.single.path!;
      // final file = File(filePath);

      try {
        final uri = kIsWeb
            ? await repo.uploadFileWeb(result.files.single.bytes!, name: name)
            : await repo.uploadFile(File(result.files.single.path!),
                name: name);

        final message = types.PartialFile(
          mimeType: await getMimeTypeFromUrl(
              Uri.dataFromBytes(result.files.single.bytes!).toString()),
          name: name,
          size: result.files.single.size,
          uri: uri,
        );

        FirebaseChatCore.instance.sendMessage(message, chatData!.room.id);
        _setAttachmentUploading(false);
      } finally {
        _setAttachmentUploading(false);
      }
    }
  }

  Future<String> getMimeTypeFromUrl(String url) async {
    var response = await http.head(Uri.parse(url));

    if (response.headers.containsKey('content-type')) {
      String? mimeType = response.headers['content-type'];
      // print('MIME Type: $mimeType');
      return mimeType!;
    } else {
      // print('MIME Type not found in headers');
      return '';
    }
  }

  void _handleImageSelection() async {
    final ChatRepository repo = RepositoryProvider.of<ChatRepository>(context);

    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      _setAttachmentUploading(true);
      final file = kIsWeb ? File('') : File(result.path);
      final size = await result.readAsBytes().then((value) => value.length);
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);
      final name = result.name;

      try {
        if (kIsWeb) {
          final uri = await repo.uploadImageWeb(bytes, name: name);

          final message = types.PartialImage(
            height: image.height.toDouble(),
            name: name,
            size: size,
            uri: uri,
            width: image.width.toDouble(),
          );

          FirebaseChatCore.instance.sendMessage(
            message,
            chatData!.room.id,
          );
        } else {
          final uri = await repo.uploadImage(file, name: name);

          final message = types.PartialImage(
            height: image.height.toDouble(),
            name: name,
            size: size,
            uri: uri,
            width: image.width.toDouble(),
          );

          FirebaseChatCore.instance.sendMessage(
            message,
            chatData!.room.id,
          );
        }
        _setAttachmentUploading(false);
      } finally {
        _setAttachmentUploading(false);
      }
    }
  }

  void _handleMessageTap(BuildContext _, types.Message message) async {
    if (message is types.FileMessage) {
      var localPath = message.uri;
      debugModePrint('urii ${message.uri}');
      if (message.uri.startsWith('http')) {
        try {
          if (!kIsWeb) {
            final updatedMessage = message.copyWith(isLoading: true);
            FirebaseChatCore.instance.updateMessage(
              updatedMessage,
              chatData!.room.id,
            );

            final client = http.Client();
            final request = await client.get(Uri.parse(message.uri));
            final bytes = request.bodyBytes;
            final documentsDir =
                (await getApplicationDocumentsDirectory()).path;
            localPath = '$documentsDir/${message.name}';

            if (!File(localPath).existsSync()) {
              final file = File(localPath);
              await file.writeAsBytes(bytes);
            }
          }
        } finally {
          final updatedMessage = message.copyWith(isLoading: false);
          FirebaseChatCore.instance.updateMessage(
            updatedMessage,
            chatData!.room.id,
          );
        }
      }
      if (kIsWeb) {
      html.AnchorElement(href: message.uri)
          ..setAttribute('download', message.name)
          ..click();
      }
      await OpenFilex.open(localPath);
    }
  }

  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final updatedMessage = message.copyWith(previewData: previewData);

    FirebaseChatCore.instance.updateMessage(updatedMessage, chatData!.room.id);
  }

  void _handleSendPressed(types.PartialText message) {
    FirebaseChatCore.instance.sendMessage(
      message,
      chatData!.room.id,
    );
  }

  void _setAttachmentUploading(bool uploading) {
    setState(() {
      _isAttachmentUploading = uploading;
    });
  }

  @override
  Widget build(BuildContext context) => BackButtonListener(
        onBackButtonPressed: () async {
          if (!kIsWeb) {
            context.pop();
            return true;
          }
          return true;
        },
        child: BackButtonListener(
          onBackButtonPressed: () async {
            final AppRouter appRouter = Provider.of(context, listen: false);

            appRouter.onBackButtonPressed(context);
            return true;
          },
          child: Scaffold(
            appBar: AppBar(
              leading: BackButton(
                onPressed: () {
                  final AppRouter appRouter =
                      Provider.of(context, listen: false);

                  appRouter.onBackButtonPressed(context);
                },
              ),
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
                        chatData!.avatar,
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
                    chatData!.userName,
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
                stream: FirebaseChatCore.instance.room(chatData!.room.id),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return ListenableBuilder(
                      listenable: listChatNotifier,
                      builder: (context, child) {
                        debugModePrint('Reach limit ${listChatNotifier.limit}');
                        return StreamBuilder<List<types.Message>>(
                          stream: FirebaseChatCore.instance.messages(
                              snapshot.data!,
                              limit: listChatNotifier.limit),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            debugModePrint(
                                'Reach lenght ${snapshot.data!.length}');
                            return Chat(
                              onEndReached: () async {
                                if (snapshot.connectionState !=
                                    ConnectionState.waiting) {
                                  listChatNotifier.onEndReached();
                                  debugModePrint('Reach end');
                                }
                              },
                              isLastPage: listChatNotifier.limit >
                                  snapshot.data!.length,
                              dateLocale: context.locale.languageCode,
                              theme: _chatTheme(context),
                              avatarBuilder: _buildAvatar,
                              l10n: _getL10n(context),
                              showUserNames: true,
                              nameBuilder: _buildName,
                              showUserAvatars: true,
                              textMessageOptions: TextMessageOptions(
                                onLinkPressed: (p0) {
                                  Uri url = Uri.parse(p0);
                                  launchUrl(url);
                                },
                              ),
                              inputOptions: const InputOptions(
                                maxLength: 4000,
                                sendButtonVisibilityMode:
                                    SendButtonVisibilityMode.always,
                              ),
                              isAttachmentUploading: _isAttachmentUploading,
                              messages: snapshot.data ?? [],
                              hideBackgroundOnEmojiMessages: false,
                              onAttachmentPressed: _handleAtachmentPressed,
                              onMessageTap: _handleMessageTap,
                              onPreviewDataFetched: _handlePreviewDataFetched,
                              onSendPressed: _handleSendPressed,
                              user: types.User(
                                id: FirebaseChatCore
                                        .instance.firebaseUser?.uid ??
                                    '',
                              ),
                            );
                          },
                        );
                      });
                }),
          ),
        ),
      );

  void _toProfile(BuildContext context) async {
    final AuthRepository repo = RepositoryProvider.of<AuthRepository>(context);
    final UserRepository userRepository =
        RepositoryProvider.of<UserRepository>(context);

    String userName;
    if (chatData!.room.type == types.RoomType.direct) {
      types.User user = chatData!.room.users
          .firstWhere((element) => element.id != repo.currentUser!.uid);

      userName = await userRepository.getUserNameOnly(user.id);
      if (!context.mounted) return;
      context.go(
        '${APP_PAGE.home.toPath}@$userName',
      );
    }
  }

  DefaultChatTheme _chatTheme(BuildContext context) {
    return DefaultChatTheme(
      receivedMessageLinkDescriptionTextStyle: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
      ),
      receivedMessageLinkTitleTextStyle: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
      ),
      attachmentButtonIcon: Container(
        width: Dimens.DIMENS_34,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
        ),
        child: const Icon(
          BootstrapIcons.paperclip,
        ),
      ),
      receivedMessageBodyTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface),
      userAvatarNameColors: [Theme.of(context).colorScheme.onSurface],
      secondaryColor: Theme.of(context).colorScheme.tertiary,
      primaryColor: Theme.of(context).colorScheme.primary,
      inputBackgroundColor: Theme.of(context).colorScheme.tertiary,
      inputMargin: EdgeInsets.symmetric(
          horizontal: Dimens.DIMENS_6, vertical: Dimens.DIMENS_5),
      inputBorderRadius: BorderRadius.circular(50),
      backgroundColor: Theme.of(context).colorScheme.surface,
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

  Widget _buildName(types.User user) {
    if (chatData!.room.type == types.RoomType.direct) {
      return Text(
        chatData!.userName,
        style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.88)),
      );
    }
    return const Text('');
  }

  Widget _buildAvatar(types.User author) {
    RepositoryProvider.of<UserRepository>(context);
    if (chatData!.room.type == types.RoomType.direct) {
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
                  imageUrl: chatData!.avatar,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          ),
        ),
      );
    }
    return SizedBox(
      width: Dimens.DIMENS_38,
      height: Dimens.DIMENS_38,
    );
  }
}

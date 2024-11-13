import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import 'dart:math';

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/data/repository/mabar_chat_repository.dart';
import 'package:personal_project/domain/reporsitory/user_repository.dart';
import 'package:personal_project/presentation/l10n/locale_code.dart';
import 'package:personal_project/presentation/responsive/dimension.dart';
import 'package:personal_project/presentation/router/app_router.dart';
import 'package:personal_project/presentation/shared_components/container_with_max_width.dart';
import 'package:personal_project/presentation/shared_components/not_authenticated_page.dart';
import 'package:personal_project/utils/number_format.dart';
import 'package:provider/provider.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utils/debug_mode_print.dart';
import '../auth/bloc/auth_bloc.dart';

class ChatView extends StatefulWidget {
  const ChatView({
    super.key,
  });

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> with WidgetsBindingObserver {
  MabarChatRepository repository = MabarChatRepository();
  TextEditingController textEditingController = TextEditingController();
  String name = 'test ${Random().nextInt(100)}';

  @override
  void initState() {
    //Listen chat channel
    repository.listenMessageEvent(() {});
    WidgetsBinding.instance.addObserver(this);
    repository.lisentJoinedRoom();
    repository.joinRoom();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (firebaseAuth.currentUser != null) {
    //     showChatSugestion(
    //       context,
    //       onMessageTap: (msg) => _sendHandle(msg),
    //     );
    //   }
    // });
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      repository.leaveRoom();
    }

    if (state == AppLifecycleState.resumed) {
      repository.joinRoom();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('botttomins ${MediaQuery.of(context).viewInsets.bottom}');
    return test();
  }

  Widget test() {
    try {
      // return Text('test');
      return RepositoryProvider(
        create: (_) => repository,
        child: Builder(builder: (context) {
          return BackButtonListener(
            onBackButtonPressed: () async {
              AppRouter appRouter =
                  Provider.of<AppRouter>(context, listen: false);
              appRouter.onBackButtonPressed(context);

              return true;
            },
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state.status == AuthStatus.authenticated) {
                  return Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.width > mobileWidth
                            ? 8
                            : 0,
                        right: MediaQuery.of(context).size.width > mobileWidth
                            ? 8
                            : 0),
                    child: ContainerWidthMaxWidth(
                      maxWidth: 940,
                      child: GestureDetector(
                        onTap: () => FocusScope.of(context).unfocus(),
                        child: Scaffold(
                          //For pop button
                          appBar: AppBar(
                            shape:
                                MediaQuery.of(context).size.width > mobileWidth
                                    ? const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(12),
                                        ),
                                      )
                                    : null,
                            leading: Icon(
                              SolarIconsBold.usersGroupTwoRounded,
                              size: Dimens.DIMENS_28,
                            ),
                            toolbarHeight: 65,
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Lobby'),
                                StreamBuilder(
                                    stream: repository.joinedRoomStream,
                                    builder: (context, snapshot) {
                                      int joinedCounts = snapshot.data ?? 0;
                                      if (!snapshot.hasData) {
                                        return Text(
                                          'Connecting...',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withOpacity(0.6),
                                          ),
                                        );
                                      }

                                      return Text(
                                        '${numberFormat(context.locale, joinedCounts)} users joined',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.6),
                                        ),
                                      );
                                    })
                              ],
                            ),
                            backgroundColor:
                                Theme.of(context).colorScheme.tertiary,
                          ),
                          body: StreamBuilder<List<types.Message>>(
                            initialData: const [],
                            stream: repository.messagesStream,
                            builder: (context, snapshot) {
                              debugModePrint('mabar ${snapshot.data}');
                              if (!snapshot.hasData) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              return Chat(
                                // key: UniqueKey(),
                                emptyState: Center(
                                  child: SizedBox(
                                    width: Dimens.DIMENS_250,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          SolarIconsBold.chatRound,
                                          size: Dimens.DIMENS_60,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.6),
                                        ),
                                        SizedBox(
                                          height: Dimens.DIMENS_12,
                                        ),
                                        Text(
                                          'Belum ada pesan',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withOpacity(0.6),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
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
                                // isAttachmentUploading: _isAttachmentUploading,
                                messages: snapshot.data ?? [],
                                hideBackgroundOnEmojiMessages: false,
                                // onAttachmentPressed: _handleAtachmentPressed,
                                // onMessageTap: _handleMessageTap,
                                // onPreviewDataFetched: _handlePreviewDataFetched,
                                onSendPressed: _handleSendPressed,
                                user: types.User(
                                  id: FirebaseChatCore
                                          .instance.firebaseUser?.uid ??
                                      '',
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  return const NotAuthenticatedPage();
                }
              },
            ),
          );
        }),
      );
    } catch (e) {
      return Text(e.toString());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    repository.leaveRoom();

    super.dispose();
  }
  // void _toProfile(BuildContext context) {
  //   final AuthRepository repo = RepositoryProvider.of<AuthRepository>(context);
  //   if (widget.data.room.type == types.RoomType.direct) {
  //     types.User user = widget.data.room.users
  //         .firstWhere((element) => element.id != repo.currentUser!.uid);
  //     context.push(
  //       APP_PAGE.profile.toPath,
  //       extra: ProfilePayload(
  //         user: models.User(
  //           id: user.id,
  //           name: widget.data.name,
  //           userName: widget.data.userName,
  //           photo: widget.data.avatar,
  //         ),
  //         isForOtherUser: true,
  //       ),
  //     );
  //   }
  // }

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
      primaryColor: Theme.of(context).colorScheme.tertiary,
      inputBackgroundColor: Theme.of(context).colorScheme.tertiary,
      inputMargin: EdgeInsets.symmetric(
          horizontal: Dimens.DIMENS_12, vertical: Dimens.DIMENS_8),
      inputBorderRadius: BorderRadius.circular(8),
      backgroundColor: Theme.of(context).colorScheme.background,
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
    return FutureBuilder<String>(
        initialData: '',
        future: UserRepository().getUserNameOnly(user.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          return Text(
            snapshot.data!,
            style: TextStyle(
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.88)),
          );
        });
  }

  void _handleSendPressed(types.PartialText message) {
    repository.sendMabarMessage(message, '001');
  }

  void _sendHandle(String message) {
    repository.sendMabarMessage(types.PartialText(text: message), '001');
    context.pop();
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
                context.go(
                  '/@${author.firstName}',
                );
                debugPrint('author ${author.firstName}');
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

  Widget buildInput() {
    return SafeArea(
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: textEditingController,
              maxLength: 1500,
              buildCounter: (context,
                      {required currentLength,
                      required isFocused,
                      required maxLength}) =>
                  const Text(''),
            ),
          ),
          Expanded(
            flex: 1,
            child: ElevatedButton(
              onPressed: () {
                textEditingController.clear();
                setState(() {});
              },
              child: const Text("Send"),
            ),
          )
        ],
      ),
    );
  }
}

class ChatThemplateItem extends StatelessWidget {
  final String msg;
  final Function(String msg) onTap;
  const ChatThemplateItem({
    super.key,
    required this.msg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(8),
      color: Theme.of(context).colorScheme.tertiary,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => onTap(msg),
        child: Container(
          width: Dimens.DIMENS_250,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8)),
          child: Text(msg),
        ),
      ),
    );
  }
}

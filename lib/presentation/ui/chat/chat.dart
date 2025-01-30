import 'dart:async';
import 'dart:io';

import 'package:chatview/chatview.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/data/repository/chat_repository.dart';
import 'package:personal_project/domain/model/user.dart';
import 'package:personal_project/domain/reporsitory/auth_reposotory.dart';
import 'package:personal_project/domain/reporsitory/user_repository.dart';
import 'package:personal_project/domain/services/firebase/firebase_service.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/responsive/dimension.dart';
import 'package:personal_project/presentation/router/app_router.dart';
import 'package:personal_project/presentation/ui/home/navbar_notifier/navbar_notifier.dart';
import 'package:personal_project/utils/debug_mode_print.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/model/chat_payload_model.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.data,
  });
  final ChatPayload data;
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  bool isDarkTheme = false;
  ChatController? _chatController;
  static Completer<bool> npCompletter = Completer<bool>();
  Future<bool> isNextPageLoading = npCompletter.future;
  int _currentLimit = 20; // Start with 20 messages
  final int _limitIncrement = 20; // Load 20 more messages each time
  late final ValueNotifier<int> _limitNotifier;
  double? chatScaffoldWidth;
  @override
  void initState() {
    _onOpenChat();
    _limitNotifier = ValueNotifier<int>(_limitIncrement);
    _chatController ??= ChatController(
      initialMessageList: [],
      scrollController: ScrollController(),
      currentUser: ChatUser(
        id: firebaseAuth.currentUser!.uid,
        name: context.read<AuthRepository>().currentUserData?.userName ?? '',
      ),
      otherUsers: [
        ChatUser(
          id: widget.data.room.users.firstWhere(
            (element) {
              return element.id != firebaseAuth.currentUser!.uid;
            },
          ).id,
          name: widget.data.userName,
        )
      ],
    );
    _chatController!.setTypingIndicator = false;
    context
        .read<UserRepository>()
        .otherUserSream(_chatController!.otherUsers[0].id)
        .listen(
      (event) {
        int last = DateTime.now()
            .difference(DateTime.fromMillisecondsSinceEpoch(
                event.lastTyping?.millisecondsSinceEpoch ??
                    DateTime.now().millisecondsSinceEpoch))
            .inSeconds;
        if ((event.isTyping ?? false) && last < 2) {
          _chatController!.setTypingIndicator = true;
        } else {
          _chatController!.setTypingIndicator = false;
        }
      },
    );
    super.initState();
  }

  _onOpenChat() {
    context.read<ChatRepository>().onOpenChat(room: widget.data.room);
  }

  void _showHideTypingIndicator() {
    _chatController!.setTypingIndicator = !_chatController!.showTypingIndicator;
  }

  void receiveMessage() async {
    _chatController!.addMessage(
      Message(
        id: DateTime.now().toString(),
        message: 'I will schedule the meeting.',
        createdAt: DateTime.now(),
        sentBy: widget.data.room.users.firstWhere(
          (element) {
            return element.id != firebaseAuth.currentUser!.uid;
          },
        ).id,
      ),
    );
    await Future.delayed(const Duration(milliseconds: 500));
    _chatController!.addReplySuggestions([
      const SuggestionItemData(text: 'Thanks.'),
      const SuggestionItemData(text: 'Thank you very much.'),
      const SuggestionItemData(text: 'Great.')
    ]);
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _limitNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Access the RenderBox of the Scaffold
      RenderBox box = context.findRenderObject() as RenderBox;
      chatScaffoldWidth = box.size.width;
      debugModePrint('Chat Scaffold width: $chatScaffoldWidth');
    });
    return Scaffold(
      body: ValueListenableBuilder(
          valueListenable: _limitNotifier,
          builder: (context, value, child) {
            final ChatRepository chatRepository =
                RepositoryProvider.of<ChatRepository>(context);
            return StreamBuilder(
                initialData: chatRepository.messagesLists,
                stream: chatRepository.messages(widget.data.room, limit: value),
                builder: (context, snapshot) {
                  if (!snapshot.hasData &&
                      chatRepository.messagesLists.isEmpty) {
                    return const CircularProgressIndicator();
                  }
                  List<Message> messages = chatRepository.messagesLists;

                  if (snapshot.connectionState != ConnectionState.waiting ||
                      snapshot.connectionState != ConnectionState.active) {
                    if (_chatController!.initialMessageList.isNotEmpty) {
                      _chatController!.initialMessageList.clear();
                    }
                    if (!npCompletter.isCompleted && snapshot.hasData) {
                      npCompletter.complete(true);
                      npCompletter = Completer<bool>();
                      isNextPageLoading = npCompletter.future;
                    }
                    _chatController!.initialMessageList.addAll(messages);
                  }
                  // debugModePrint('chat offset ${_scrollController.offset}');

                  return ChatView(
                    loadingWidget: Container(
                      padding: EdgeInsets.all(Dimens.DIMENS_3),
                      height: 26,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    isLastPage: _chatController!.initialMessageList.length <
                        _currentLimit,
                    loadMoreData: () async {
                      _currentLimit += _limitIncrement;
                      _limitNotifier.value = _currentLimit;
                      debugModePrint('load more $_currentLimit');
                      await isNextPageLoading;
                    },
                    chatController: _chatController!,
                    onSendTap: _onSendTap,
                    featureActiveConfig: const FeatureActiveConfig(
                      lastSeenAgoBuilderVisibility: false,
                      receiptsBuilderVisibility: true,
                      enableScrollToBottomButton: true,
                      enablePagination: true,
                    ),
                    scrollToBottomButtonConfig: ScrollToBottomButtonConfig(
                      backgroundColor: colorScheme.tertiary,
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: colorScheme.onSurface,
                        weight: 10,
                        size: 30,
                      ),
                    ),
                    chatViewState: messages.isNotEmpty
                        ? ChatViewState.hasMessages
                        : ChatViewState.loading,
                    chatViewStateConfig: ChatViewStateConfiguration(
                      noMessageWidgetConfig: ChatViewStateWidgetConfiguration(
                          title: LocaleKeys.message_no_message.tr()),
                      loadingWidgetConfig: ChatViewStateWidgetConfiguration(
                        loadingIndicatorColor: colorScheme.primary,
                      ),
                      onReloadButtonTap: () {},
                    ),
                    typeIndicatorConfig: TypeIndicatorConfiguration(
                      flashingCircleBrightColor:
                          colorScheme.primary.withOpacity(0.4),
                      flashingCircleDarkColor: colorScheme.primary,
                    ),
                    appBar: StreamBuilder<User>(
                        stream: context.read<UserRepository>().otherUserSream(
                            _chatController!.otherUsers.first.id),
                        builder: (context, snapshot) {
                          return ChatViewAppBar(
                            leading: BackButton(
                              onPressed: () => context
                                  .read<AppRouter>()
                                  .onBackButtonPressed(context),
                            ),
                            elevation: 0.3,
                            backGroundColor: colorScheme.surface,
                            profilePicture: widget.data.avatar,
                            backArrowColor: colorScheme.surface,
                            chatTitle: widget.data.userName,
                            chatTitleTextStyle: TextStyle(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              letterSpacing: 0.25,
                            ),
                            userStatus: getLastSeen(snapshot),
                            userStatusTextStyle:
                                const TextStyle(color: Colors.grey),
                          );
                        }),
                    chatBackgroundConfig: ChatBackgroundConfiguration(
                      loadingWidget: SizedBox(
                          height: MediaQuery.of(context).size.height,
                          child: Center(child: CircularProgressIndicator())),
                      width: chatScaffoldWidth,
                      groupedListOrder: GroupedListOrder.desc,
                      messageTimeIconColor: colorScheme.onSurface,
                      messageTimeTextStyle: TextStyle(
                        color: colorScheme.onSurface,
                      ),
                      defaultGroupSeparatorConfig:
                          DefaultGroupSeparatorConfiguration(
                        textStyle: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 17,
                        ),
                      ),
                      backgroundColor: colorScheme.surface,
                    ),
                    sendMessageConfig: SendMessageConfiguration(
                      imagePickerIconsConfig: ImagePickerIconsConfiguration(
                        cameraIconColor: colorScheme.onSurface,
                        galleryIconColor: colorScheme.onSurface,
                      ),
                      replyMessageColor: colorScheme.onSurface.withOpacity(0.6),
                      defaultSendButtonColor: colorScheme.onSurface,
                      replyDialogColor: colorScheme.surface,
                      replyTitleColor: colorScheme.onSurface,
                      textFieldBackgroundColor: colorScheme.tertiary,
                      closeIconColor: colorScheme.onSurface,
                      textFieldConfig: TextFieldConfiguration(
                        onMessageTyping: (status) {
                          /// Do with status
                          debugPrint(status.toString());
                          context.read<UserRepository>().setTypingIndicator(
                              status == TypeWriterStatus.typing ? true : false);
                        },
                        compositionThresholdTime: const Duration(seconds: 1),
                        textStyle: TextStyle(color: colorScheme.onSurface),
                      ),
                      micIconColor: colorScheme.onSurface,
                      voiceRecordingConfiguration: VoiceRecordingConfiguration(
                        backgroundColor: colorScheme.primary,
                        recorderIconColor: colorScheme.onSurface,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50)),
                        waveStyle: WaveStyle(
                          backgroundColor: colorScheme.primary,
                          showMiddleLine: false,
                          waveColor: colorScheme.onSurface,
                          extendWaveform: true,
                        ),
                      ),
                    ),
                    chatBubbleConfig: ChatBubbleConfiguration(
                      onDoubleTap: (message) {
                        chatRepository.doubleTapReactions(
                            roomId: widget.data.room.id,
                            message: message,
                            reaction: "\u{1F44D}");
                      },
                      outgoingChatBubbleConfig: ChatBubble(
                        linkPreviewConfig: LinkPreviewConfiguration(
                          proxyUrl:
                              !kIsWeb ? null : "https://proxy.corsfix.com/?",
                          backgroundColor: colorScheme.surface.withOpacity(0.2),
                          titleStyle: TextStyle(color: colorScheme.onSurface),
                          bodyStyle: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        receiptsWidgetConfig: ReceiptsWidgetConfig(
                            receiptsBuilder: (status) {
                              if (status == MessageStatus.pending) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 6.0),
                                  child: Icon(
                                    SolarIconsOutline.clockCircle,
                                    size: 14,
                                  ),
                                );
                              } else if (status == MessageStatus.delivered) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 6.0),
                                  child: Icon(
                                    size: 16,
                                    SolarIconsOutline.chatRead,
                                  ),
                                );
                              } else if (status == MessageStatus.read) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 6.0),
                                  child: Icon(
                                    SolarIconsOutline.chatRead,
                                    color: Colors.blue,
                                    size: 16,
                                  ),
                                );
                              }
                              return SizedBox.shrink();
                            },
                            showReceiptsIn: ShowReceiptsIn.all),
                        color: colorScheme.primary,
                      ),
                      inComingChatBubbleConfig: ChatBubble(
                        linkPreviewConfig: LinkPreviewConfiguration(
                          proxyUrl:
                              !kIsWeb ? null : "https://proxy.corsfix.com/?",
                          linkStyle: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.blue,
                          ),
                          backgroundColor: colorScheme.surface.withOpacity(0.2),
                          bodyStyle: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                          titleStyle: TextStyle(color: colorScheme.onSurface),
                        ),
                        textStyle: TextStyle(color: colorScheme.onSurface),
                        onMessageRead: (message) {
                          /// send your message reciepts to the other
                          if (message.createdAt.isAfter(widget
                              .data.room.unreadedTotal!
                              .firstWhere((element) =>
                                  element.uid == firebaseAuth.currentUser!.uid)
                              .lastReadedAt
                              .toDate())) {
                            chatRepository.updateChat(
                              message: message,
                              room: widget.data.room,
                            );
                            debugPrint('Message Read');
                          }
                        },
                        senderNameTextStyle:
                            TextStyle(color: colorScheme.onSurface),
                        color: colorScheme.tertiary,
                      ),
                    ),
                    replyPopupConfig: ReplyPopupConfiguration(
                      replyPopupBuilder: (message, sentByCurrentUser) =>
                          const SizedBox.shrink(),
                      backgroundColor: colorScheme.tertiary,
                      buttonTextStyle: TextStyle(color: colorScheme.onSurface),
                      topBorderColor: colorScheme.tertiary,
                    ),
                    reactionPopupConfig: ReactionPopupConfiguration(
                      overrideUserReactionCallback: true,
                      userReactionCallback: (message, emoji) {
                        chatRepository.setReactions(
                            roomId: widget.data.room.id,
                            message: message,
                            reaction: emoji);
                      },
                      shadow: BoxShadow(
                        color: colorScheme.tertiary,
                        blurRadius: 20,
                      ),
                      backgroundColor: colorScheme.tertiary,
                    ),
                    messageConfig: MessageConfiguration(
                      messageReactionConfig: MessageReactionConfiguration(
                        backgroundColor: colorScheme.tertiary,
                        borderColor: colorScheme.surface,
                        reactedUserCountTextStyle:
                            TextStyle(color: colorScheme.onSurface),
                        reactionCountTextStyle:
                            TextStyle(color: colorScheme.onSurface),
                        reactionsBottomSheetConfig:
                            ReactionsBottomSheetConfiguration(
                          removeReactedCurrentUserCallback:
                              (reactedUser, message) {
                            if (reactedUser.id ==
                                _chatController!.currentUser.id) {
                              chatRepository.removeReactions(
                                roomId: widget.data.room.id,
                                message: message,
                              );
                            }
                          },
                          backgroundColor: colorScheme.surface,
                          reactedUserTextStyle: TextStyle(
                            color: colorScheme.onSurface,
                          ),
                          reactionWidgetDecoration: BoxDecoration(
                            color: colorScheme.tertiary,
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.tertiary,
                                offset: const Offset(0, 20),
                                blurRadius: 40,
                              )
                            ],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      imageMessageConfig: ImageMessageConfiguration(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 15),
                        shareIconConfig: ShareIconConfiguration(
                          defaultIconBackgroundColor: colorScheme.tertiary,
                          defaultIconColor: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    profileCircleConfig: ProfileCircleConfiguration(
                      profileImageUrl: widget.data.avatar,
                    ),
                    repliedMessageConfig: RepliedMessageConfiguration(
                      backgroundColor: colorScheme.primary.withOpacity(0.5),
                      verticalBarColor: colorScheme.primary,
                      repliedMsgAutoScrollConfig: RepliedMsgAutoScrollConfig(
                        enableHighlightRepliedMsg: true,
                        highlightColor: colorScheme.primary,
                        highlightScale: 1.1,
                      ),
                      textStyle: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.25,
                      ),
                      replyTitleTextStyle:
                          TextStyle(color: colorScheme.onSurface),
                    ),
                    swipeToReplyConfig: SwipeToReplyConfiguration(
                        replyIconBackgroundColor: colorScheme.surface,
                        replyIconColor: colorScheme.primary,
                        replyIconProgressRingColor: colorScheme.primary),
                    replySuggestionsConfig: ReplySuggestionsConfig(
                      itemConfig: SuggestionItemConfig(
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: colorScheme.tertiary,
                          ),
                        ),
                        textStyle: TextStyle(
                          color: isDarkTheme ? Colors.white : Colors.black,
                        ),
                      ),
                      onTap: (item) => _onSendTap(
                          item.text, const ReplyMessage(), MessageType.text),
                    ),
                  );
                });
          }),
    );
  }

  String getLastSeen(AsyncSnapshot<User> snapshot) {
    if (!snapshot.hasData) {
      return '';
    }
    int minute = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(
            snapshot.data!.lastSeen!.millisecondsSinceEpoch))
        .inMinutes;

    double clock = minute / 60;
    double day = clock / 24;

    if (!snapshot.data!.isOnline! || snapshot.data!.isOnline! && minute > 10) {
      if (minute < 1) {
        return 'dilihat 1 menit yang lalu';
      } else if (minute < 60) {
        return 'dilihat $minute menit yang lalu';
      } else if (minute >= 60) {
        return 'dilihat ${clock.round()} jam yg lalu';
      } else if (clock > 24) {
        return 'dilihat $day hari yg lalu';
      }
      return 'dilihat $day hari yg lalu';
    } else {
      return 'online';
    }
  }

  void _onSendTap(
    String message,
    ReplyMessage replyMessage,
    MessageType messageType,
  ) async {
    final ChatRepository repo = RepositoryProvider.of<ChatRepository>(context);

    repo.sendMessage(
      Message(
        createdAt: DateTime.now(),
        message: message,
        sentBy: _chatController!.currentUser.id,
        replyMessage: replyMessage,
        messageType: messageType,
        voiceMessageDuration: const Duration(milliseconds: 0),
      ),
      widget.data.room.id,
    );

    // Future.delayed(const Duration(milliseconds: 300), () {
    //   _chatController!.initialMessageList.last.setStatus =
    //       MessageStatus.undelivered;
    // });
    // Future.delayed(const Duration(seconds: 1), () {
    //   _chatController!.initialMessageList.last.setStatus = MessageStatus.read;
    // });
  }
}

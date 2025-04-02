import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatview/chatview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:personal_project/utils/time_ago_formatter.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:timeago/timeago.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/model/chat_payload_model.dart';
import '../../../domain/model/room_model.dart';

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

  final List<StreamSubscription> streams = [];

  @override
  void initState() {
    _onOpenChat();
    _limitNotifier = ValueNotifier<int>(_limitIncrement);
    _chatController ??= ChatController(
      initialMessageList: [],
      scrollController: ScrollController(),
      currentUser: ChatUser(
        imageType: ImageType.network,
        id: firebaseAuth.currentUser!.uid,
        name: context.read<AuthRepository>().currentUserData?.userName ?? '',
      ),
      otherUsers: [
        ChatUser(
        profilePhoto: widget.data.avatar,
        imageType: ImageType.network,
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
    listenNewMessage(widget.data.room);
    super.initState();
  }

  _onOpenChat() {
    context.read<ChatRepository>().onOpenChat(room: widget.data.room);
  }

  void _showHideTypingIndicator() {
    _chatController!.setTypingIndicator = !_chatController!.showTypingIndicator;
  }

  void loadMoreMessage({
    required Room room,
    int? limit,
  }) async {
    context.read<ChatRepository>().messages(
        limit: _currentLimit,
        room,
        startAfter: [
          _chatController!.initialMessageList.first.createdAt
        ]).listen(
      (event) {
        _chatController!.setIsLoadMore = true;
        debugModePrint('isloadmore ${_chatController!.isLoadMore}');
        _chatController!.loadMoreData(event.reversed.toList());
        debugModePrint('isloadmore ${_chatController!.isLoadMore}');
        // final
        // Set<String> existingIds =
        //     _chatController!.initialMessageList.map((m) => m.id).toSet();
        // for (var element in event) {

        //   if (!existingIds.contains(element.id)) {
        //     _chatController!.addMessage(element);
        //   }
        // }
        Set<String> newMesageIds = event.map((message) => message.id).toSet();

        List<Message> commonMessages = _chatController!.initialMessageList
            .where((message) => newMesageIds.contains(message.id))
            .toList();

        _compareMessages(commonMessages, event);
      },
    );

    _currentLimit += _limitIncrement;
  }

  void listenNewMessage(Room room) async {
    final List<Message> initialMessages = await context
        .read<ChatRepository>()
        .initialMessages(room, limit: _limitIncrement);

    _chatController!.loadMoreData(initialMessages);
    if (!mounted) return;
    context.read<ChatRepository>().messages(
      room,
      endAt: [initialMessages.first.createdAt],
    ).listen(
      (event) {
        Set<String> existingIds =
            _chatController!.initialMessageList.map((m) => m.id).toSet();
        for (var element in event) {
          if (!existingIds.contains(element.id)) {
            _chatController!.addMessage(element);
          }
        }
        Set<String> newMesageIds = event.map((message) => message.id).toSet();

        List<Message> commonMessages = _chatController!.initialMessageList
            .where((message) => newMesageIds.contains(message.id))
            .toList();

        _compareMessages(commonMessages, event);
      },
    );
  }

  void _compareMessages(
      List<Message> previousMessages, List<Message> newMessages) {
    for (var newMessage in newMessages) {
      var previousMessage =
          previousMessages.firstWhere((message) => message.id == newMessage.id);

      if (previousMessage.id.isNotEmpty) {
        if (!listEquals(newMessage.reaction.reactions,
            previousMessage.reaction.reactions)) {
          print('Reaction update detected for message ${newMessage.createdAt}');
          // Add your action here for reaction update

          List<String> oldData = previousMessage.reaction.reactedUserIds;

          // New data list
          List<String> newData = newMessage.reaction.reactedUserIds;

          // Find added items
          List<String> addedItems =
              newData.where((item) => !oldData.contains(item)).toList();

          // Find removed items
          List<String> removedItems =
              oldData.where((item) => !newData.contains(item)).toList();

          // Find common items (potentially modified if you have more complex data)
          List<String> commonItems =
              newData.where((item) => oldData.contains(item)).toList();

          // Perform actions based on changes
          if (addedItems.isNotEmpty) {
            debugModePrint('Added items: $addedItems');
            // Perform action for added items
            _chatController!.setReaction(
                emoji: newMessage.reaction.reactions[newMessage
                    .reaction.reactedUserIds
                    .indexOf(addedItems.first)],
                messageId: newMessage.id,
                userId: addedItems.first);
          }

          if (removedItems.isNotEmpty) {
            debugModePrint('Removed items: $removedItems');
            _chatController!.setReaction(
                emoji: previousMessage.reaction.reactions[previousMessage
                    .reaction.reactedUserIds
                    .indexOf(removedItems.first)],
                messageId: previousMessage.id,
                userId: removedItems.first);
            // Perform action for removed items
          }

          if (commonItems.isNotEmpty) {
            debugModePrint('Common items: $commonItems');
            // Perform action for common items (e.g., check for modifications)
            for (var element in commonItems) {
              final int index =
                  newMessage.reaction.reactedUserIds.indexOf(element);
              final int oIndex =
                  previousMessage.reaction.reactedUserIds.indexOf(element);
              if (newMessage.reaction.reactions[index] !=
                  previousMessage.reaction.reactions[oIndex]) {
                _chatController!.setReaction(
                    emoji: newMessage.reaction.reactions[index],
                    messageId: newMessage.id,
                    userId: element);
              }
            }
          }
        } else {
          print('New message detected: ${newMessage.createdAt}');
          // Add your action here for new message
        }
        if (newMessage.status.name != previousMessage.status.name) {
          _chatController!.initialMessageList.firstWhere(
            (element) {
              return element.id == newMessage.id;
            },
          ).setStatus = newMessage.status;
          print('Receipt update detected for message ${newMessage.id}');
          // Add your action here for receipt update
        }
      }
    }
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
    return Scaffold(body: Builder(builder: (context) {
      final ChatRepository chatRepository =
          RepositoryProvider.of<ChatRepository>(context);
      return ChatView(
        loadingWidget: Container(
          padding: EdgeInsets.all(Dimens.DIMENS_3),
          height: 26,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        imageProviderBuilder: (
            {required conditional, required imageHeaders, required uri}) {
          if (uri.startsWith('http')) {
            return CachedNetworkImageProvider(
              uri,
              headers: imageHeaders,
            );
          }
          return FileImage(
            File(uri),
          );
        },
        loadMoreData: () async {
          debugModePrint('load more $_currentLimit');
          loadMoreMessage(room: widget.data.room); // await isNextPageLoading;
        },
        loadMoreImages: () async {
          final List<PreviewImage> images = await chatRepository.getMoreImages(
            room: widget.data.room,
            startAfter: Timestamp.fromMillisecondsSinceEpoch(
              _chatController!.imageList.first.createdAt,
            ),
          );
          _chatController!.loadMoreImages(images);
        },
        chatController: _chatController!,
        onSendTap: _onSendTap,
        featureActiveConfig: const FeatureActiveConfig(
          lastSeenAgoBuilderVisibility: false,
          receiptsBuilderVisibility: true,
          enableScrollToBottomButton: true,
          enablePagination: true,
          enableOtherUserProfileAvatar: true,
          enableOtherUserName: false
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
        chatViewState: ChatViewState.hasMessages,
        chatViewStateConfig: ChatViewStateConfiguration(
          noMessageWidgetConfig: ChatViewStateWidgetConfiguration(
              title: LocaleKeys.message_no_message.tr()),
          loadingWidgetConfig: ChatViewStateWidgetConfiguration(
            loadingIndicatorColor: colorScheme.primary,
          ),
          onReloadButtonTap: () {},
        ),
        typeIndicatorConfig: TypeIndicatorConfiguration(
          flashingCircleBrightColor: colorScheme.primary.withOpacity(0.4),
          flashingCircleDarkColor: colorScheme.primary,
        ),
        appBar: StreamBuilder<User>(
            stream: context
                .read<UserRepository>()
                .otherUserSream(_chatController!.otherUsers.first.id),
            builder: (context, snapshot) {
              return ChatViewAppBar(
                leading: BackButton(
                  onPressed: () =>
                      context.read<AppRouter>().onBackButtonPressed(context),
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
                userStatusTextStyle: const TextStyle(color: Colors.grey),
                imageProviderBuilder: (
                    {required conditional,
                    required imageHeaders,
                    required uri}) {
                  if (uri.startsWith('http')) {
                    return CachedNetworkImageProvider(
                      uri,
                      headers: imageHeaders,
                    );
                  }
                  return FileImage(
                    File(uri),
                  );
                },
              );
            }),
        chatBackgroundConfig: ChatBackgroundConfiguration(
          // sortEnable: true,

          width: chatScaffoldWidth,
          groupedListOrder: GroupedListOrder.asc,
          messageTimeIconColor: colorScheme.onSurface,
          messageTimeTextStyle: TextStyle(
            color: colorScheme.onSurface,
          ),
          defaultGroupSeparatorConfig: DefaultGroupSeparatorConfiguration(
            textStyle: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 17,
            ),
          ),
          backgroundColor: colorScheme.surface,
        ),
        mediaPreviewConfig: MediaPreviewConfig(
          defaultSendButtonColor: colorScheme.primary,
        ),
        sendMessageConfig: _sendMessageConfigutraion(colorScheme, context),
        chatBubbleConfig: ChatBubbleConfiguration(
          onDoubleTap: (message) {
            chatRepository.doubleTapReactions(
                roomId: widget.data.room.id,
                message: message,
                reaction: "\u{1F44D}");
          },
          outgoingChatBubbleConfig: ChatBubble(
            linkPreviewConfig: LinkPreviewConfiguration(
              proxyUrl: !kIsWeb ? null : "https://proxy.corsfix.com/?",
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
              proxyUrl: !kIsWeb ? null : "https://proxy.corsfix.com/?",
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
              if (message.createdAt.isAfter(widget.data.room.unreadedTotal!
                  .firstWhere(
                      (element) => element.uid == firebaseAuth.currentUser!.uid)
                  .lastReadedAt
                  .toDate())) {
                chatRepository.updateChat(
                  message: message,
                  room: widget.data.room,
                );
                debugPrint('Message Read');
              }
            },
            senderNameTextStyle: TextStyle(color: colorScheme.onSurface),
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
                roomId: widget.data.room.id, message: message, reaction: emoji);
          },
          shadow: BoxShadow(
            color: colorScheme.tertiary,
            blurRadius: 20,
          ),
          backgroundColor: colorScheme.tertiary,
        ),
        messageConfig: MessageConfiguration(
          voiceMessageConfig: _voiceMessageConfiguration(colorScheme),
          messageReactionConfig: MessageReactionConfiguration(
            backgroundColor: colorScheme.tertiary,
            borderColor: colorScheme.surface,
            reactedUserCountTextStyle: TextStyle(color: colorScheme.onSurface),
            reactionCountTextStyle: TextStyle(color: colorScheme.onSurface),
            reactionsBottomSheetConfig: ReactionsBottomSheetConfiguration(
              removeReactedCurrentUserCallback: (reactedUser, message) {
                if (reactedUser.id == _chatController!.currentUser.id) {
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
          imageMessageConfig: _imageMessageConfiguration(colorScheme),
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
          replyTitleTextStyle: TextStyle(color: colorScheme.onSurface),
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
            mediaPath: '',
            text: item.text,
            replyMessage: const ReplyMessage(),
            messageType: MessageType.text,
          ),
        ),
      );
    }));
  }

  SendMessageConfiguration _sendMessageConfigutraion(ColorScheme colorScheme, BuildContext context) {
    return SendMessageConfiguration(
        imagePickerIconsConfig: ImagePickerIconsConfiguration(
          cameraIconColor: colorScheme.onSurface,
          galleryIconColor: colorScheme.onSurface,
          cameraImagePickerIcon: Icon(SolarIconsOutline.camera),
          galleryImagePickerIcon: Icon(SolarIconsOutline.gallery),
        ),
        // replyMessageColor: colorScheme.onSurface.withOpacity(0.6),
        defaultSendButtonColor: colorScheme.onSurface,
        // replyDialogColor: colorScheme.surface,
        // replyTitleColor: colorScheme.onSurface,
        textFieldBackgroundColor: colorScheme.tertiary,
        // closeIconColor: colorScheme.onSurface,
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
        imagePickerConfiguration: ImagePickerConfiguration(
          
        ),
        // micIconColor: colorScheme.onSurface,
        voiceRecordingConfiguration: VoiceRecordingConfiguration(
          backgroundColor: colorScheme.primary,
          recorderIconColor: colorScheme.onSurface,
          micIcon: Icon(SolarIconsBold.microphone),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(50)),
          waveStyle: WaveStyle(
            backgroundColor: colorScheme.primary,
            showMiddleLine: false,
            waveColor: colorScheme.onSurface,
            extendWaveform: true,
          ),
        ),
      );
  }

  ImageMessageConfiguration _imageMessageConfiguration(ColorScheme colorScheme) {
    return ImageMessageConfiguration(
          hideShareIcon: true,
          imageProviderBuilder: (
              {required conditional, required imageHeaders, required uri}) {
            if (uri.startsWith('http')) {
              return CachedNetworkImageProvider(
                uri,
                headers: imageHeaders,
              );
            }
            return FileImage(
              File(uri),
            );
          },
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
          shareIconConfig: ShareIconConfiguration(
            
            onPressed: (message) {
              debugPrint('Share Image $message');
            },
            // icon: SizedBox.shrink(),
            defaultIconBackgroundColor: colorScheme.tertiary,
            defaultIconColor: colorScheme.onSurface,
          ),
        );
  }

  VoiceMessageConfiguration _voiceMessageConfiguration(
      ColorScheme colorScheme) {
    return VoiceMessageConfiguration(
      unDownoadedWaveColor: colorScheme.onSurface.withValues(
        alpha: 0.5,
      ),
      bgProgressColor: Colors.transparent,
      downloadIcon: Container(
        padding: EdgeInsets.only(top: 7.0, left: 8.0, right: 8.0, bottom: 9.0),
        decoration: BoxDecoration(
          color: colorScheme.onSurface.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Icon(
          SolarIconsOutline.downloadMinimalistic,
          color: colorScheme.onSurface,
          size: 20,
        ),
      ),
      voiceIcon: Icon(
        SolarIconsOutline.microphone3,
        color: colorScheme.onSurface,
        size: 20,
      ),
      playIcon: Icon(
        SolarIconsBold.play,
        color: colorScheme.onSurface,
        size: 16,
      ),
    );
  }

  String getLastSeen(AsyncSnapshot<User> snapshot) {
    if (!snapshot.hasData) {
      return '';
    }

    if (snapshot.data!.isOnline! &&
        !snapshot.data!.lastSeen!.toDate().isBefore(DateTime.now())) {
      return 'online';
    }

    return TimeAgoFormatter.lastSeenFormat(
      DateTime.fromMillisecondsSinceEpoch(
        snapshot.data!.lastSeen!.millisecondsSinceEpoch,
      ),
      locale: context.locale.toString(),
    );
  }

  void _onSendTap(
      // String message,
      // ReplyMessage replyMessage,
      // MessageType messageType,
      {required String mediaPath,
      required MessageType messageType,
      required ReplyMessage replyMessage,
      required String text}) async {
    final ChatRepository repo = RepositoryProvider.of<ChatRepository>(context);

    repo.sendMessage(
      Message(
        createdAt: DateTime.now(),
        mediaPath: mediaPath,
        text: text,
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

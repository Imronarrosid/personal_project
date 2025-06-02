import 'dart:async';

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatview/chatview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/domain/model/chat_data_models.dart';
import 'package:personal_project/domain/model/profile_data_model.dart';
import 'package:personal_project/domain/model/user.dart' as models;
import 'package:personal_project/domain/reporsitory/auth_reposotory.dart';
import 'package:personal_project/domain/reporsitory/user_repository.dart';
import 'package:personal_project/domain/services/firebase/firebase_service.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/router/app_router.dart';
import 'package:personal_project/presentation/router/route_utils.dart';
import 'package:personal_project/presentation/shared_components/not_authenticated_page.dart';
import 'package:personal_project/presentation/theme/user_profile_theme.dart';
import 'package:provider/provider.dart';

import '../../../../data/repository/chat_repository.dart';
import '../../../../domain/model/chat_payload_model.dart';
import '../../../../domain/model/room_model.dart';
import '../../../responsive/dimension.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../search_room/bloc/search_room_bloc.dart';
import '../../search_room/search_room_page.dart';

// import 'chat.dart';
// import 'login.dart';
// import 'users.dart';
// import 'util.dart';

class MessageDesktop extends StatefulWidget {
  final Widget child;
  const MessageDesktop({
    super.key,
    required this.child,
  });

  @override
  State<MessageDesktop> createState() => _MessageDesktopState();
}

class _MessageDesktopState extends State<MessageDesktop> {
  bool _error = false;
  bool _initialized = false;
  User? _user;
  final TextEditingController _textEditingController = TextEditingController();
  Timer? _debounce;
  final FocusNode _serchFocus = FocusNode();
  @override
  void initState() {
    initializeFlutterFire();
    super.initState();
  }

  void initializeFlutterFire() async {
    try {
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        setState(() {
          _user = user;
        });
      });
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      setState(() {
        _error = true;
      });
    }
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
  }

  Widget _buildAvatar(
    Room room, {
    required models.User user,
  }) {
    var color = Colors.transparent;

    if (room.type == RoomType.direct) {
      try {
        final otherUser = room.users.firstWhere(
          (u) => u.id != _user!.uid,
        );

        color = getUserAvatarNameColor(otherUser);
      } catch (e) {
        // Do nothing if other user is not found.
      }
    }

    final hasImage = room.imageUrl != null;

    return Container(
      width: Dimens.DIMENS_45,
      height: Dimens.DIMENS_45,
      alignment: Alignment.center,
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: () {
          if (room.type == types.RoomType.direct) {
            context.go(
              '${APP_PAGE.home.toPath}@${user.userName}',
              extra: ProfilePayload(
                user: user,
                isForOtherUser: true,
              ),
            );
          }
        },
        child: Container(
          width: Dimens.DIMENS_45,
          height: Dimens.DIMENS_45,
          padding: EdgeInsets.all(Dimens.DIMENS_5),
          alignment: Alignment.center,
          child: hasImage
              ? CircleAvatar(
                  backgroundColor: hasImage ? Colors.transparent : color,
                  radius: 20,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: CachedNetworkImage(imageUrl: room.imageUrl!)),
                )
              : CircleAvatar(
                  backgroundColor: hasImage ? Colors.transparent : color,
                  radius: 20,
                  backgroundImage: CachedNetworkImageProvider(user.photo!),
                ),
        ),
        // child: !hasImage
        //     ? Text(
        //         name.isEmpty ? '' : name[0].toUpperCase(),
        //         style: const TextStyle(color: Colors.white),
        //       )
        //     : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return Container();
    }

    if (!_initialized) {
      return Container();
    }
    final UserRepository userRepository =
        RepositoryProvider.of<UserRepository>(context);
    return BackButtonListener(
      onBackButtonPressed: () async {
        AppRouter appRouter = Provider.of<AppRouter>(context, listen: false);
        appRouter.onBackButtonPressed(context);

        return true;
      },
      child: Row(
        children: [
          _roomView(context, userRepository),
          MediaQuery.of(context).size.width < mediumWidth
              ? const SizedBox(
                  width: 0,
                  height: 0,
                )
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: VerticalDivider(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.24),
                      thickness: 0.2,
                    ),
                  ),
                ),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.only(top: 8.0, right: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: widget.child,
            ),
          )),
        ],
      ),
    );
  }

  SizedBox _roomView(BuildContext context, UserRepository userRepository) {
    if (MediaQuery.of(context).size.width < mediumWidth) {
      return const SizedBox(width: 0, height: 0);
    }
    return SizedBox(
      width: 400,
      child: BlocProvider(
        create: (context) =>
            SearchRoomBloc(RepositoryProvider.of<ChatRepository>(context))
              ..add(const InitSearchRoom()),
        child: Center(
          child: Scaffold(
            appBar: _appBar(context),
            body: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state.status == AuthStatus.authenticated) {
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        SizedBox(
                          height: Dimens.DIMENS_32,
                        ),
                        _searchBar(context),
                        BlocBuilder<SearchRoomBloc, SearchRoomState>(
                          builder: (context, state) {
                            if (state.status == SearchRoomStatus.loading) {
                              return SizedBox(
                                height: MediaQuery.of(context).size.height - 70,
                                child: const Center(
                                    child: CircularProgressIndicator()),
                              );
                            }

                            if (state.status == SearchRoomStatus.noItemFound) {
                              return SizedBox(
                                height: MediaQuery.of(context).size.height - 70,
                                child: Center(
                                  child: Text(
                                    LocaleKeys.message_not_found.tr(
                                        args: [_textEditingController.text]),
                                  ),
                                ),
                              );
                            }
                            if (state.status == SearchRoomStatus.success) {
                              return _searchResult(state);
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _suggestedRooms(context, userRepository),
                                Padding(
                                  padding:
                                      EdgeInsets.only(left: Dimens.DIMENS_12),
                                  child: Text(LocaleKeys.label_messages.tr()),
                                ),
                                StreamBuilder<List<Room>>(
                                  stream:
                                      context.read<ChatRepository>().rooms(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return Container(
                                          padding: EdgeInsets.only(
                                              top: Dimens.DIMENS_150),
                                          alignment: Alignment.center,
                                          child:
                                              const CircularProgressIndicator());
                                    }
                                    if (snapshot.data!.isEmpty) {
                                      return Container(
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.only(
                                            top: Dimens.DIMENS_150),
                                        margin: const EdgeInsets.only(
                                          bottom: 200,
                                        ),
                                        child: Text(
                                            LocaleKeys.message_no_message.tr()),
                                      );
                                    }

                                    return ListView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: snapshot.data!.length,
                                      itemBuilder: (context, index) {
                                        final room = snapshot.data![index];
                                        return _buildRoom(room);
                                      },
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  );
                } else {
                  return const NotAuthenticatedPage();
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Padding _searchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiary,
            borderRadius: BorderRadius.circular(50)),
        child: TextField(
          controller: _textEditingController,
          onChanged: (query) {
            final searchBloc = BlocProvider.of<SearchRoomBloc>(context);
            if (_debounce?.isActive ?? false) _debounce?.cancel();
            _debounce = Timer(const Duration(milliseconds: 500), () {
              // do something with query
              searchBloc.add(SearchRoom(query));
            });
          },
          decoration: InputDecoration(
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 8.0, top: 0.3),
              child: Icon(Icons.search_rounded),
            ),
            hintText: LocaleKeys.label_search.tr(),
            contentPadding: const EdgeInsets.all(5),
            suffixIcon: BlocBuilder<SearchRoomBloc, SearchRoomState>(
              builder: (context, state) {
                if (state.status == SearchRoomStatus.initial) {
                  return const SizedBox(
                    width: 0,
                    height: 0,
                  );
                }
                return GestureDetector(
                  onTap: () {
                    _textEditingController.clear();

                    context.read<SearchRoomBloc>().add(const InitSearchRoom());
                  },
                  child: const Icon(BootstrapIcons.x),
                );
              },
            ),
            suffixIconColor: COLOR_grey,
            border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(500)),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _serchFocus.dispose();
    super.dispose();
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      title: Text(LocaleKeys.label_messages.tr()),
    );
  }

  ListView _searchResult(SearchRoomState state) {
    return ListView.builder(
      itemCount: state.results!.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final user = state.results![index];
        return ListTile(
          tileColor: Colors.transparent,
          onTap: () async {
            // debugPrint('photo${result.photo}');
            // context.push(APP_PAGE.profile.toPath,
            //     extra: ProfilePayload(
            //       uid: result.id,
            //       name: result.name!,
            //       userName: result.userName!,
            //       photoURL: result.photo!,
            //     ));
            // debugPrint('profile');
            types.User otherUser = types.User(
                id: user.id,
                createdAt:
                    user.createdAt!.toDate().millisecondsSinceEpoch ~/ 1000,
                firstName: user.userName);
            if (!mounted) return;

            final room = await FirebaseChatCore.instance.createRoom(otherUser);

            if (!context.mounted) return;
            context.go(
              '${APP_PAGE.message.toPath}/u/${user.userName}',
              extra: ChatData(
                room: room,
                userName: user.userName!,
                avatar: user.photo!,
                name: user.name,
              ),
            );
            _textEditingController.clear();
            context.read<SearchRoomBloc>().add(const InitSearchRoom());
          },
          leading: CircleAvatar(
            backgroundColor: COLOR_grey,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: CachedNetworkImage(
                imageUrl: user.photo!,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          title: Text(user.name!),
          subtitle: Text(user.userName!),
        );
      },
    );
  }

  SizedBox _suggestedRooms(
      BuildContext context, UserRepository userRepository) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.DIMENS_105,
      child: FutureBuilder<List<models.User>>(
          future: userRepository.getUserListWithLimit(7),
          builder: (context, AsyncSnapshot<List<models.User>>? snapshot) {
            List<models.User>? users = snapshot?.data;

            if (!snapshot!.hasData || snapshot.hasError) {
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 7,
                itemBuilder: (context, index) => Container(
                    width: Dimens.DIMENS_85,
                    padding: EdgeInsets.all(Dimens.DIMENS_10),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: Dimens.DIMENS_28,
                          backgroundColor:
                              Theme.of(context).colorScheme.tertiary,
                        ),
                        SizedBox(
                          height: Dimens.DIMENS_6,
                        ),
                        Text(
                          '',
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      ],
                    )),
              );
            }

            return ListView(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              children: [
                ...List.generate(users!.length, (index) {
                  models.User user = users[index];
                  return InkWell(
                    onTap: () async {
                      types.User otherUser = types.User(
                          id: user.id,
                          createdAt:
                              user.createdAt!.toDate().millisecondsSinceEpoch ~/
                                  1000,
                          firstName: user.userName);
                      if (!mounted) return;

                      final room =
                          await context.read<ChatRepository>().createRoom(user);

                      if (!context.mounted) return;
                      context.read<ChatRepository>().setChatPayload =
                          ChatPayload(
                        room: await context
                            .read<ChatRepository>()
                            .createRoom(user),
                        userName: user.userName!,
                        avatar: user.photo!,
                        name: user.name,
                      );
                      if (!context.mounted) return;
                      context.go(
                        '/dm/${user.userName}',
                        // '${APP_PAGE.message.toPath}/${data.userName}',
                      );
                      // context.go(
                      //   '${APP_PAGE.message.toPath}/${user.userName}',
                      //   extra: ChatPayload(
                      //       room: room,
                      //       userName: user.userName!,
                      //       avatar: user.photo!,
                      //       name: user.name),
                      // );
                    },
                    child: Container(
                      width: Dimens.DIMENS_85,
                      padding: EdgeInsets.all(Dimens.DIMENS_10),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: Dimens.DIMENS_6,
                          ),
                          CircleAvatar(
                            radius: Dimens.DIMENS_28,
                            backgroundColor:
                                Theme.of(context).colorScheme.tertiary,
                            backgroundImage:
                                CachedNetworkImageProvider(user.photo!),
                          ),
                          SizedBox(
                            height: Dimens.DIMENS_6,
                          ),
                          Text(
                            user.userName!,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall,
                          )
                        ],
                      ),
                    ),
                  );
                }),
                users.isEmpty
                    ? Container(
                        width: MediaQuery.of(context).size.width,
                        alignment: Alignment.center,
                        child: Text(
                          LocaleKeys.message_no_suggestion.tr(),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Container(),
                users.length < 6
                    ? Container()
                    : InkWell(
                        onTap: () {
                          _serchFocus.requestFocus();
                        },
                        child: Container(
                          padding: EdgeInsets.all(Dimens.DIMENS_10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: Dimens.DIMENS_6,
                              ),
                              CircleAvatar(
                                backgroundColor:
                                    Theme.of(context).colorScheme.onTertiary,
                                radius: Dimens.DIMENS_28,
                                child: const Icon(BootstrapIcons.plus),
                              ),
                              SizedBox(
                                height: Dimens.DIMENS_6,
                              ),
                              Text(
                                LocaleKeys.label_others.tr(),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
              ],
            );
          }),
    );
  }

  FutureBuilder<models.User> _buildRoom(Room room) {
    return FutureBuilder(
        future: _getOtherUsersData(room),
        builder: (context, AsyncSnapshot<models.User> snapshot) {
          models.User? data = snapshot.data;
          if (!snapshot.hasData) {
            return Container();
          }
          return StreamBuilder<List<Message>>(
              initialData: const [],
              stream: context.read<ChatRepository>().getLastMessages(room),
              builder: (context, AsyncSnapshot<List<Message>> snapshot) {
                final UserRepository userRepository =
                    RepositoryProvider.of<UserRepository>(context);

                List<Message>? messages = snapshot.data;
                Message? message;
                if (snapshot.hasData && messages!.isNotEmpty) {
                  message = messages.first;
                }
                if (!snapshot.hasData && snapshot.data == null) {
                  return Container();
                }
                if (snapshot.hasError) {
                  return Container();
                }
                if (snapshot.data!.isEmpty) {
                  return Container();
                }
                return ListTile(
                  tileColor: Colors.transparent,
                  onTap: () async {
                    context.go(
                      '${APP_PAGE.message.toPath}/u/${data.userName}',
                      extra: ChatPayload(
                        room: await context
                            .read<ChatRepository>()
                            .createRoom(data),
                        userName: data.userName!,
                        avatar: data.photo!,
                        name: data.name,
                      ),
                    );
                  },
                  leading: _buildAvatar(
                    room,
                    user: data!,
                  ),
                  visualDensity: VisualDensity.compact,
                  title: SizedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(data.userName!),
                        _messageCreated(message, context)
                      ],
                    ),
                  ),
                  subtitle: FutureBuilder<String>(
                    future: userRepository.getUserNameOnly(message!.sentBy),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Container();
                      }
                      if (messages!.isEmpty) {
                        return Container();
                      }
                      return Row(
                        children: [
                          _buildMessage(snapshot, message!, room.type!),
                          const Spacer(),
                          _unreadedTotal(room)
                        ],
                      );
                    },
                  ),
                );
              });
        });
  }

  Widget _unreadedTotal(Room room) {
    final int total = (room.unreadedTotal!.firstWhere(
        (element) => element.uid == firebaseAuth.currentUser!.uid)).total;
    return total > 0
        ? Container(
            width: 16,
            height: 16,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Theme.of(context).colorScheme.primary),
            child: Text(
              total > 99 ? '99+' : total.toString(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.surface,
                fontWeight: FontWeight.w100,
                fontSize: 8,
              ),
            ),
          )
        : const SizedBox.shrink();
  }

  Text _messageCreated(Message? message, BuildContext context) {
    return _isSameDay(message?.createdAt.millisecondsSinceEpoch ??
            DateTime.now().millisecondsSinceEpoch)
        ? Text(
            DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch(
                message?.createdAt.millisecondsSinceEpoch ??
                    DateTime.now().millisecondsSinceEpoch)),
            style: Theme.of(context)
                .textTheme
                .bodySmall!
                .apply(color: Theme.of(context).colorScheme.primary),
          )
        : Text(
            DateFormat('EEE,MM/yy').format(
              DateTime.fromMillisecondsSinceEpoch(
                  message?.createdAt.millisecondsSinceEpoch ??
                      DateTime.now().millisecondsSinceEpoch),
            ),
            style: Theme.of(context)
                .textTheme
                .bodySmall!
                .apply(color: Theme.of(context).colorScheme.primary),
          );
  }

  Text _buildMessage(
      AsyncSnapshot<String> snapshot, Message message, RoomType roomType) {
    String currentUser =
        RepositoryProvider.of<AuthRepository>(context).currentUser!.uid;
    if (message.sentBy == currentUser) {
      return Text(
        '${LocaleKeys.label_you.tr()}: ${_getMessage(message.messageType, message: message)}',
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      );
    } else if (roomType == RoomType.group) {
      return Text(
        '${snapshot.data!}: ${_getMessage(message.messageType, message: message)}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
      );
    }
    return Text(' ${_getMessage(message.messageType, message: message)}',
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ));
  }

  bool _isSameDay(int createdAt) {
    return DateTime.fromMillisecondsSinceEpoch(createdAt).day ==
        DateTime.now().day;
  }

  String _getMessage(MessageType type, {required Message message}) {
    switch (type) {
      case MessageType.voice:
        return LocaleKeys.message_audio_message.tr();
      case MessageType.custom:
        return LocaleKeys.message_custom_message.tr();
      case MessageType.image:
        return LocaleKeys.message_send_image.tr();
      case MessageType.text:
        return Message.fromJson(message.toJson()).text;
    }
  }

  Future<models.User> _getOtherUsersData(Room room) async {
    try {
      String currentUser =
          RepositoryProvider.of<AuthRepository>(context).currentUser!.uid;

      String? uid;

      for (var element in room.users) {
        if (element.id != currentUser) {
          uid = element.id;
        }
      }

      DocumentSnapshot snap =
          await firebaseFirestore.collection('users').doc(uid).get();

      models.User otherUser = models.User.fromSnap(snap);

      return otherUser;
    } catch (e) {
      debugPrint(e.toString());
    }
    return models.User.empty;
  }
}

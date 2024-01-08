import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/domain/model/chat_data_models.dart';
import 'package:personal_project/domain/model/profile_data_model.dart';
import 'package:personal_project/domain/model/user.dart' as models;
import 'package:personal_project/domain/reporsitory/auth_reposotory.dart';
import 'package:personal_project/domain/reporsitory/user_repository.dart';
import 'package:personal_project/domain/services/firebase/firebase_service.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/router/route_utils.dart';
import 'package:personal_project/presentation/shared_components/not_authenticated_page.dart';
import 'package:personal_project/presentation/theme/user_profile_theme.dart';

// import 'chat.dart';
// import 'login.dart';
// import 'users.dart';
// import 'util.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  bool _error = false;
  bool _initialized = false;
  User? _user;

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

  Widget _buildAvatar(types.Room room,
      {required String profilePict, uid, name, userName}) {
    var color = Colors.transparent;

    if (room.type == types.RoomType.direct) {
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
            context.push(APP_PAGE.profile.toPath,
                extra: ProfilePayload(
                  uid: uid,
                  name: name,
                  userName: userName,
                  photoURL: profilePict,
                ));
          }
        },
        child: Container(
          width: Dimens.DIMENS_45,
          height: Dimens.DIMENS_45,
          padding: EdgeInsets.all(Dimens.DIMENS_5),
          alignment: Alignment.center,
          child: CircleAvatar(
            backgroundColor: hasImage ? Colors.transparent : color,

            radius: 20,
            child: hasImage
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: CachedNetworkImage(imageUrl: room.imageUrl!))
                : ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: CachedNetworkImage(imageUrl: profilePict)),
            // child: !hasImage
            //     ? Text(
            //         name.isEmpty ? '' : name[0].toUpperCase(),
            //         style: const TextStyle(color: Colors.white),
            //       )
            //     : null,
          ),
        ),
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
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _user == null
                ? null
                : () {
                    // Navigator.of(context).push(
                    //   MaterialPageRoute(
                    //     fullscreenDialog: true,
                    //     builder: (context) => const UsersPage(),
                    //   ),
                    // );
                    context.push(APP_PAGE.searchRoom.toPath);
                  },
          ),
        ],
        // leading: IconButton(
        //   icon: const Icon(Icons.logout),
        //   onPressed: _user == null ? null : logout,
        // ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: Text(LocaleKeys.label_message.tr()),
      ),
      body: _user == null
          ? const NotAuthenticatedPage()
          : SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        top: Dimens.DIMENS_18, left: Dimens.DIMENS_12),
                    child: const Text('Saran'),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: Dimens.DIMENS_105,
                    child: FutureBuilder<List<models.User>>(
                        future: userRepository.getUserListWithLimit(7),
                        builder: (context,
                            AsyncSnapshot<List<models.User>>? snapshot) {
                          List<models.User>? users = snapshot?.data;

                          if (!snapshot!.hasData || snapshot.hasError) {
                            return Container();
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
                                        createdAt: user.createdAt!
                                                .toDate()
                                                .millisecondsSinceEpoch ~/
                                            1000,
                                        firstName: user.userName);
                                    if (!mounted) return;

                                    final room = await FirebaseChatCore.instance
                                        .createRoom(otherUser);

                                    if (!mounted) return;
                                    context.push(
                                      APP_PAGE.chat.toPath,
                                      extra: ChatData(
                                          room: room,
                                          userName: user.userName!,
                                          avatar: user.photo!,
                                          name: user.name),
                                    );
                                  },
                                  child: Container(
                                    width: Dimens.DIMENS_85,
                                    padding: EdgeInsets.all(Dimens.DIMENS_10),
                                    alignment: Alignment.center,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: Dimens.DIMENS_6,
                                        ),
                                        CircleAvatar(
                                          radius: Dimens.DIMENS_28,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            child: CachedNetworkImage(
                                              imageUrl: user.photo!,
                                              width: double.infinity,
                                              height: double.infinity,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: Dimens.DIMENS_6,
                                        ),
                                        Text(
                                          user.userName!,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              }),
                              InkWell(
                                onTap: () {
                                  context.push(APP_PAGE.searchRoom.toPath);
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
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .onTertiary,
                                        radius: Dimens.DIMENS_28,
                                        child: Icon(MdiIcons.plus),
                                      ),
                                      SizedBox(
                                        height: Dimens.DIMENS_6,
                                      ),
                                      Text(
                                        LocaleKeys.label_others.tr(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: Dimens.DIMENS_12),
                    child: Text(LocaleKeys.label_message.tr()),
                  ),
                  StreamBuilder<List<types.Room>>(
                    stream: FirebaseChatCore.instance.rooms(),
                    initialData: const [],
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(
                            bottom: 200,
                          ),
                          child: const Text('No rooms'),
                        );
                      }

                      return ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
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
              ),
            ),
    );
  }

  FutureBuilder<models.User> _buildRoom(types.Room room) {
    return FutureBuilder(
        future: _getOtherUsersData(room),
        builder: (context, AsyncSnapshot<models.User> snapshot) {
          models.User? data = snapshot.data;
          if (!snapshot.hasData) {
            return Container();
          }
          return StreamBuilder<List<types.Message>>(
              initialData: const [],
              stream: FirebaseChatCore.instance.getLastMessages(room),
              builder: (context, AsyncSnapshot<List<types.Message>> snapshot) {
                final UserRepository userRepository =
                    RepositoryProvider.of<UserRepository>(context);

                List<types.Message>? messages = snapshot.data;
                types.Message? message;
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
                  onTap: () {
                    context.push(
                      APP_PAGE.chat.toPath,
                      extra: ChatData(
                        room: room,
                        userName: data.userName!,
                        avatar: data.photo!,
                        name: data.name,
                      ),
                    );
                  },
                  leading: _buildAvatar(
                    room,
                    profilePict: data!.photo!,
                    name: data.name,
                    uid: data.id,
                    userName: data.userName,
                  ),
                  visualDensity: VisualDensity.compact,
                  title: SizedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(room.name!.isNotEmpty
                            ? room.name ?? ''
                            : data.userName!),
                        _messageCreated(message, context)
                      ],
                    ),
                  ),
                  subtitle: FutureBuilder<String>(
                    future: userRepository.getUserNameOnly(message!.author.id),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Container();
                      }
                      if (messages!.isEmpty) {
                        return Container();
                      }
                      return _buildMessage(snapshot, message!, room.type!);
                    },
                  ),
                );
              });
        });
  }

  Text _messageCreated(types.Message? message, BuildContext context) {
    return _isSameDay(
            message?.createdAt ?? DateTime.now().millisecondsSinceEpoch)
        ? Text(
            DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch(
                message?.createdAt ?? DateTime.now().millisecondsSinceEpoch)),
            style:
                Theme.of(context).textTheme.bodySmall!.apply(color: COLOR_grey),
          )
        : Text(
            DateFormat('D/MM/yy').format(
              DateTime.fromMillisecondsSinceEpoch(
                  message!.createdAt ?? DateTime.now().millisecondsSinceEpoch),
            ),
            style:
                Theme.of(context).textTheme.bodySmall!.apply(color: COLOR_grey),
          );
  }

  Text _buildMessage(AsyncSnapshot<String> snapshot, types.Message message,
      types.RoomType roomType) {
    String currentUser =
        RepositoryProvider.of<AuthRepository>(context).currentUser!.uid;
    if (message.author.id == currentUser) {
      return Text(
        '${LocaleKeys.label_you.tr()}: ${_getMessage(message.type, message: message)}',
        overflow: TextOverflow.ellipsis,
      );
    } else if (roomType == types.RoomType.group) {
      return Text(
        '${snapshot.data!}: ${_getMessage(message.type, message: message)}',
        overflow: TextOverflow.ellipsis,
      );
    }
    return Text(
      '${snapshot.data!}: ${_getMessage(message.type, message: message)}',
      overflow: TextOverflow.ellipsis,
    );
  }

  bool _isSameDay(int createdAt) {
    return DateTime.fromMillisecondsSinceEpoch(createdAt).day ==
        DateTime.now().day;
  }

  String _getMessage(types.MessageType type, {required types.Message message}) {
    switch (type) {
      case types.MessageType.audio:
        return LocaleKeys.message_audio_message.tr();
      case types.MessageType.custom:
        return LocaleKeys.message_custom_message.tr();
      case types.MessageType.file:
        return LocaleKeys.message_send_file.tr();
      case types.MessageType.image:
        return LocaleKeys.message_send_image.tr();
      case types.MessageType.system:
        return LocaleKeys.message_system_message.tr();
      case types.MessageType.text:
        return types.TextMessage.fromJson(message.toJson()).text;
      case types.MessageType.unsupported:
        return LocaleKeys.message_unsupported_message.tr();
      case types.MessageType.video:
        return LocaleKeys.message_send_video.tr();
    }
  }

  Future<models.User> _getOtherUsersData(types.Room room) async {
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

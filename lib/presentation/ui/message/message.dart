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
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/domain/model/chat_data_models.dart';
import 'package:personal_project/domain/model/user.dart' as models;
import 'package:personal_project/domain/reporsitory/auth_reposotory.dart';
import 'package:personal_project/domain/reporsitory/user_repository.dart';
import 'package:personal_project/domain/services/firebase/firebase_service.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/router/route_utils.dart';
import 'package:personal_project/presentation/shared_components/not_authenticated_page.dart';
import 'package:personal_project/presentation/theme/user_profile_theme.dart';
import 'package:personal_project/presentation/ui/chat/chat_page.dart';
import 'package:timeago/timeago.dart';

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

  Widget _buildAvatar(types.Room room, String profilePict) {
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
    final name = room.name ?? '';

    return Container(
      margin: const EdgeInsets.only(right: 16),
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
          : StreamBuilder<List<types.Room>>(
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
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final room = snapshot.data![index];

                    return FutureBuilder(
                        future: _getOtherUsersData(room),
                        builder:
                            (context, AsyncSnapshot<models.User> snapshot) {
                          models.User? data = snapshot.data;
                          if (!snapshot.hasData) {
                            return Container();
                          }
                          return StreamBuilder<List<types.Message>>(
                              stream: FirebaseChatCore.instance
                                  .getLastMessages(room),
                              builder: (context,
                                  AsyncSnapshot<List<types.Message>> snapshot) {
                                final UserRepository userRepository =
                                    RepositoryProvider.of<UserRepository>(
                                        context);
                                types.Message? message = snapshot.data?.first;
                                if (!snapshot.hasData &&
                                    snapshot.data == null) {
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
                                      ),
                                    );
                                  },
                                  leading: _buildAvatar(room, data!.photo!),
                                  title: Expanded(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(room.name!.isNotEmpty
                                            ? room.name ?? ''
                                            : data.userName!),
                                        Text(
                                          DateFormat('HH:mm').format(DateTime
                                              .fromMillisecondsSinceEpoch(message
                                                      ?.createdAt ??
                                                  DateTime.now()
                                                      .millisecondsSinceEpoch)),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .apply(color: COLOR_grey),
                                        )
                                      ],
                                    ),
                                  ),
                                  subtitle: FutureBuilder<String>(
                                    future: userRepository.getUserNameOnly(
                                        message?.author.id ?? ''),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return Container();
                                      }
                                      return Text(
                                        '${snapshot.data!}: ${_getMessage(message!.type, message: message)}',
                                        overflow: TextOverflow.ellipsis,
                                      );
                                    },
                                  ),
                                );
                              });
                        });
                  },
                );
              },
            ),
    );
  }

  String _getMessage(types.MessageType type, {required types.Message message}) {
    switch (type) {
      case types.MessageType.audio:
        return 'Mengirim audio';
      case types.MessageType.custom:
        return 'Pesan custom';
      case types.MessageType.file:
        return 'Mengirim file';
      case types.MessageType.image:
        return 'Mengirim gambar';
      case types.MessageType.system:
        return 'Pesan system';
      case types.MessageType.text:
        return types.TextMessage.fromJson(message.toJson()).text;
      case types.MessageType.unsupported:
        return 'Pesan tidak di support';
      case types.MessageType.video:
        return "Mengirim video";
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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/data/repository/user_video_paging_repository.dart';
import 'package:personal_project/domain/model/user_data_model.dart';
import 'package:personal_project/domain/model/video_model.dart';
import 'package:personal_project/domain/reporsitory/auth_reposotory.dart';
import 'package:personal_project/domain/reporsitory/user_repository.dart';
import 'package:personal_project/domain/reporsitory/video_repository.dart';
import 'package:personal_project/domain/services/firebase/firebase_service.dart';
import 'package:personal_project/presentation/shared_components/keep_alive_page.dart';
import 'package:personal_project/presentation/shared_components/not_authenticated_page.dart';
import 'package:personal_project/presentation/ui/auth/bloc/auth_bloc.dart';
import 'package:personal_project/presentation/ui/profile/bloc/user_video_paging_bloc.dart';
import 'package:personal_project/presentation/ui/profile/cubit/follow_cubit.dart';
import 'package:personal_project/presentation/ui/profile/cubit/profile_cubit.dart';

class ProfilePage extends StatelessWidget {
  final String? uid;
  const ProfilePage({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final authRepository = RepositoryProvider.of<AuthRepository>(context);
    final UserRepository userRepository =
        RepositoryProvider.of<UserRepository>(context);
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ProfileCubit(),
        ),
        BlocProvider(
          create: (context) => FollowCubit(userRepository),
        ),
      ],
      child: Builder(builder: (context) {
        return BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            debugPrint(state.toString());
            if (state is Authenticated) {
              return FutureBuilder(
                  future: userRepository.getUserData(uid!),
                  builder: (context, snapshot) {
                    var data = snapshot.data;
                    if (!snapshot.hasData) {
                      return Scaffold(
                        appBar: AppBar(
                          backgroundColor: Colors.transparent,
                          foregroundColor: COLOR_black_ff121212,
                          elevation: 0,
                        ),
                        body: Container(
                            width: size.width,
                            height: size.height,
                            color: COLOR_white_fff5f5f5,
                            alignment: Alignment.center,
                            child: const CircularProgressIndicator()),
                      );
                    }

                    return Scaffold(
                      appBar: AppBar(
                        title: Text(data!.name),
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        foregroundColor: Colors.black,
                      ),
                      body: SizedBox(
                          width: size.width,
                          child: DefaultTabController(
                            length: 2,
                            child: NestedScrollView(
                              headerSliverBuilder:
                                  (context, innerBoxIsScrolled) {
                                return [
                                  SliverToBoxAdapter(
                                    child: Column(children: [
                                      topSectionView(data),
                                      SizedBox(
                                        height: Dimens.DIMENS_8,
                                      ),
                                      bioSectionView(),
                                      gameFavView(),
                                      if (uid ==
                                          authRepository.currentUser!.uid)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: Dimens.DIMENS_12,
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Container(
                                                height: Dimens.DIMENS_34,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                    color: COLOR_grey,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5)),
                                                child: Text(
                                                  'Edit Profil',
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: Dimens.DIMENS_6,
                                            ),
                                            Expanded(
                                              child: Container(
                                                  height: Dimens.DIMENS_34,
                                                  decoration: BoxDecoration(
                                                      color: COLOR_grey,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5)),
                                                  child: Icon(
                                                      MdiIcons.accountPlus)),
                                            ),
                                            SizedBox(
                                              width: Dimens.DIMENS_12,
                                            ),
                                          ],
                                        )
                                      else
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: Dimens.DIMENS_12,
                                            ),
                                            BlocBuilder<FollowCubit,
                                                FollowState>(
                                              builder: (context, state) {
                                                bool isFollowig;
                                                debugPrint(
                                                    'follow state $state');
                                                if (state is Followed) {
                                                  isFollowig = true;
                                                } else if (state
                                                    is UnFollowed) {
                                                  isFollowig = false;
                                                } else {
                                                  isFollowig = data.isFollowig;
                                                }

                                                return Expanded(
                                                  child: Material(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5)),
                                                    color: isFollowig
                                                        ? COLOR_grey
                                                        : COLOR_black_ff121212,
                                                    child: InkWell(
                                                      onTap: () {
                                                        if (isFollowig) {
                                                          showDialog(
                                                              context: context,
                                                              builder: (_) {
                                                                return AlertDialog(
                                                                  title: Text(
                                                                      'Berhenti Mengikuti ?'),
                                                                  actions: [
                                                                    TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        context
                                                                            .pop();
                                                                      },
                                                                      child: const Text(
                                                                          'Batal'),
                                                                    ),
                                                                    TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        BlocProvider.of<FollowCubit>(context).followButtonHandle(
                                                                            currentUserUid: authRepository
                                                                                .currentUser!.uid,
                                                                            uid:
                                                                                uid!,
                                                                            stateFromDatabase:
                                                                                data.isFollowig);
                                                                        context
                                                                            .pop();
                                                                      },
                                                                      child: const Text(
                                                                          'Oke'),
                                                                    )
                                                                  ],
                                                                );
                                                              });
                                                        } else {
                                                          BlocProvider.of<
                                                                      FollowCubit>(
                                                                  context)
                                                              .followButtonHandle(
                                                                  currentUserUid:
                                                                      authRepository
                                                                          .currentUser!
                                                                          .uid,
                                                                  uid: uid!,
                                                                  stateFromDatabase:
                                                                      data.isFollowig);
                                                        }
                                                      },
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      child: Container(
                                                        height:
                                                            Dimens.DIMENS_34,
                                                        alignment:
                                                            Alignment.center,
                                                        decoration: BoxDecoration(
                                                            color: Colors
                                                                .transparent,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5)),
                                                        child: Text(
                                                          isFollowig
                                                              ? 'Mengikuti'
                                                              : 'Ikuti',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              color: isFollowig
                                                                  ? COLOR_black_ff121212
                                                                  : COLOR_white_fff5f5f5),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            SizedBox(
                                              width: Dimens.DIMENS_6,
                                            ),
                                            Expanded(
                                              child: Container(
                                                height: Dimens.DIMENS_34,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                    color: COLOR_grey,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5)),
                                                child: Text(
                                                  'Pesan',
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: Dimens.DIMENS_12,
                                            ),
                                          ],
                                        ),
                                      SizedBox(
                                        height: Dimens.DIMENS_8,
                                      )
                                    ]),
                                  ),
                                  SliverAppBar(
                                    toolbarHeight: 0,
                                    floating: false,
                                    pinned: true,
                                    elevation: 0,
                                    backgroundColor: COLOR_white_fff5f5f5,
                                    bottom: TabBar(
                                      labelColor: COLOR_black_ff121212,
                                      indicatorColor: COLOR_black_ff121212,
                                      tabs: [
                                        Tab(text: 'Video'),
                                        Tab(text: 'Suka'),
                                      ],
                                    ),
                                  ),
                                ];
                              },
                              body: TabBarView(
                                children: [
                                  // Content for Tab 1
                                  KeepAlivePage(
                                    child: VideoListView(
                                      uid: uid!,
                                      from: From.user,
                                    ),
                                  ),
                                  // Content for Tab 2
                                  KeepAlivePage(
                                    child: VideoListView(
                                      uid: uid!,
                                      from: From.likes,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                    );
                  });
            }
            return const NotAuthenticatedPage();
          },
        );
      }),
    );
  }

  Padding gameFavView() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Dimens.DIMENS_8),
      child: BlocBuilder<ProfileCubit, ProfileState>(
        buildWhen: (previous, current) {
          if (current is ShowLessBio) {
            return false;
          } else if (current is ShowMoreBio) {
            return false;
          }
          return true;
        },
        builder: (context, state) {
          List<Widget> items = [
            Chip(
              avatar: CircleAvatar(
                  backgroundColor: Colors.blue.shade900,
                  child: const Text('HM')),
              label: const Text('Mulligan'),
            ),
            Chip(
              avatar: CircleAvatar(
                  backgroundColor: Colors.blue.shade900,
                  child: const Text('ML')),
              label: const Text('Lafayette'),
            ),
            Chip(
              avatar: CircleAvatar(
                  backgroundColor: Colors.blue.shade900,
                  child: const Text('ML')),
              label: const Text('Lafayette'),
            ),
            Chip(
              avatar: CircleAvatar(
                  backgroundColor: Colors.blue.shade900,
                  child: const Text('ML')),
              label: const Text('Lafayette'),
            ),
            Chip(
              avatar: CircleAvatar(
                  backgroundColor: Colors.blue.shade900,
                  child: const Text('HM')),
              label: const Text(
                'Mulligan',
              ),
            ),
          ];
          if (state is ShowMoreGameFav) {
            return Wrap(
              spacing: 3,
              children: [
                ...items,
                GestureDetector(
                  onTap: () {
                    BlocProvider.of<ProfileCubit>(context)
                        .seeMoreGameFavHandle();
                  },
                  child: const Chip(
                    label: Text('lebih sedikit'),
                  ),
                )
              ],
            );
          }
          return Wrap(
              spacing: 3.0, // gap between adjacent chips
              children: [
                ...items.getRange(0, 2).toList(),
                GestureDetector(
                  onTap: () {
                    BlocProvider.of<ProfileCubit>(context)
                        .seeMoreGameFavHandle();
                  },
                  child: Chip(
                    label: Icon(Icons.more_horiz),
                  ),
                )
              ]);
        },
      ),
    );
  }

  Padding bioSectionView() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Dimens.DIMENS_12),
      child: BlocBuilder<ProfileCubit, ProfileState>(
        buildWhen: (previous, current) {
          if (current is ShowLessGameFav) {
            return false;
          } else if (current is ShowMoreGameFav) {
            return false;
          }
          return true;
        },
        builder: (context, state) {
          double? height = 80;
          int? maxLines = 5;
          if (state is ShowMoreBio) {
            height = null;
            maxLines = null;
          } else if (state is ShowLessBio) {
            height = 80;
            maxLines = 5;
          }
          return LayoutBuilder(builder: (context, constraints) {
            const String text =
                "Lorem ipsum dolor sit amet\n consectetur adipisicing elit.\n Maxime mollitia, molestiae quas\n vel sint commodi repudiandae \nconsequuntur voluptatum laborum \nnumquam \nblanditiis harum quisquam eius sed \nodit fugiat iusto fuga praesentium \noptio, eaque rerum! Provident similique accusantium nemo autem.";
            final textPainter = TextPainter(
              text: TextSpan(
                text: text,
                style: TextStyle(fontSize: 14.0),
              ),
              textDirection: TextDirection.ltr,
            );
            textPainter.layout(maxWidth: double.infinity);
            final lines =
                (textPainter.size.height / textPainter.preferredLineHeight)
                    .ceil();

            debugPrint('text is overflow  ${lines > 5}');

            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: height,
                  child: Text(
                    'Lorem ipsum dolor sit amet\n consectetur adipisicing elit.\n Maxime mollitia, molestiae quas\n vel sint commodi repudiandae \nconsequuntur voluptatum laborum \nnumquam \nblanditiis harum quisquam eius sed \nodit fugiat iusto fuga praesentium optio, eaque rerum! Provident similique accusantium nemo autem.',
                    overflow: TextOverflow.ellipsis,
                    maxLines: maxLines,
                  ),
                ),
                if (lines > 5)
                  InkWell(
                    onTap: () => BlocProvider.of<ProfileCubit>(context)
                        .seeMoreBioHandle(),
                    child: Text(height != null
                        ? '...selengkapnya'
                        : '...lebih sedikit'),
                  )
                else
                  Container(),
              ],
            );
          });
        },
      ),
    );
  }

  Row topSectionView(UserData data) {
    return Row(
      children: [
        SizedBox(
          width: Dimens.DIMENS_12,
        ),
        Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.transparent,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: CachedNetworkImage(imageUrl: data!.photoURL)),
            ),
            Text(
              data.name,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ],
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                data.followers,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              Text(
                'Mengikuti',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                data.following,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              Text('Pengikut',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                data.likes,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              Text(
                'Suka',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        SizedBox(
          width: Dimens.DIMENS_12,
        ),
      ],
    );
  }
}

class VideoListView extends StatelessWidget {
  final String uid;
  final From from;
  VideoListView({super.key, required this.uid, required this.from});

  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => UserVideoPagingRepository(),
      child: BlocProvider(
        create: (context) => UserVideoPagingBloc(
            RepositoryProvider.of<UserVideoPagingRepository>(context))
          ..add(InitUserVideoPaging(uid: uid, from: from)),
        child: BlocBuilder<UserVideoPagingBloc, UserVideoPagingState>(
          builder: (context, state) {
            if (state is UserVideoPagingInitialed) {
              return RefreshIndicator(
                onRefresh: () {
                  if (from == From.likes) {
                    RepositoryProvider.of<UserVideoPagingRepository>(context)
                        .clearLikeVideo();
                  }
                  return Future.sync(() => state.controller.refresh());
                },
                child: PagedGridView<int, String>(
                    pagingController: state.controller,
                    builderDelegate: PagedChildBuilderDelegate(
                      itemBuilder: (context, item, index) {
                        // var doc = await firebaseFirestore.collection('videos').doc(item).get();
                        // Video video = Video.fromSnap(doc);
                        return AspectRatio(
                          aspectRatio: 16 / 9,
                          child: FutureBuilder(
                              future: firebaseFirestore
                                  .collection('videos')
                                  .doc(item)
                                  .get(),
                              builder: (context,
                                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                                late Video video;
                                if (snapshot.data != null) {
                                  video = Video.fromSnap(snapshot.data!);
                                }

                                if (!snapshot.hasData) {
                                  return Container();
                                }
                                return Container(
                                  child: CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      imageUrl: video.thumnail),
                                );
                              }),
                        );
                      },
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: 9 / 16,
                      crossAxisCount: 3,
                    )),
              );
            }
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}

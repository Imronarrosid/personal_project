import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/data/repository/user_video_paging_repository.dart';
import 'package:personal_project/domain/model/video_model.dart';
import 'package:personal_project/domain/reporsitory/auth_reposotory.dart';
import 'package:personal_project/presentation/shared_components/keep_alive_page.dart';
import 'package:personal_project/presentation/shared_components/not_authenticated_page.dart';
import 'package:personal_project/presentation/ui/auth/bloc/auth_bloc.dart';
import 'package:personal_project/presentation/ui/profile/bloc/user_video_paging_bloc.dart';

class ProfilePage extends StatelessWidget {
  final String? uid;
  const ProfilePage({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final authRepository = RepositoryProvider.of<AuthRepository>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SizedBox(
        width: size.width,
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            debugPrint(state.toString());
            if (state is Authenticated) {
              return FutureBuilder(
                  future: authRepository.getVideoOwnerData(uid!),
                  builder: (context, snapshot) {
                    var data = snapshot.data;
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }
                    return DefaultTabController(
                      length: 3,
                      child: NestedScrollView(
                        headerSliverBuilder: (context, innerBoxIsScrolled) {
                          return [
                            SliverToBoxAdapter(
                              child: Column(children: [
                                Row(
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
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              child: CachedNetworkImage(
                                                  imageUrl: data!.photo!)),
                                        ),
                                        Text(
                                          '${data.userName}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15),
                                        ),
                                      ],
                                    ),
                                    Expanded(
                                        child: Column(
                                      children: [
                                        Text(
                                          '0',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                          'Mengikuti',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    )),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Text(
                                            '0',
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          Text('Pengikut',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                        child: Column(
                                      children: [
                                        Text(
                                          '0',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        Text('Suka',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 12)),
                                      ],
                                    )),
                                    SizedBox(
                                      width: Dimens.DIMENS_12,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: Dimens.DIMENS_8,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: Dimens.DIMENS_12),
                                  child: Text(
                                      'Lorem ipsum dolor sit amet consectetur adipisicing elit. Maxime mollitia, molestiae quas vel sint commodi repudiandae consequuntur voluptatum laborum numquam blanditiis harum quisquam eius sed odit fugiat iusto fuga praesentium optio, eaque rerum! Provident similique accusantium nemo autem.'),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: Dimens.DIMENS_8),
                                  child: Wrap(
                                    spacing: 3.0, // gap between adjacent chips
                                    children: <Widget>[
                                      Chip(
                                        avatar: CircleAvatar(
                                            backgroundColor:
                                                Colors.blue.shade900,
                                            child: const Text('HM')),
                                        label: const Text('Mulligan'),
                                      ),
                                      Chip(
                                        avatar: CircleAvatar(
                                            backgroundColor:
                                                Colors.blue.shade900,
                                            child: const Text('ML')),
                                        label: const Text('Lafayette'),
                                      ),
                                      Chip(
                                        avatar: CircleAvatar(
                                            backgroundColor:
                                                Colors.blue.shade900,
                                            child: const Text('HM')),
                                        label: const Text(
                                          'Mulligan',
                                        ),
                                      ),
                                      Chip(
                                        label: Icon(Icons.more_horiz),
                                      )
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                                BorderRadius.circular(5)),
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
                                                  BorderRadius.circular(5)),
                                          child: Icon(MdiIcons.accountPlus)),
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
                                  Tab(text: 'Disimpan'),
                                ],
                              ),
                            ),
                          ];
                        },
                        body: TabBarView(
                          children: [
                            // Content for Tab 1
                            KeepAlivePage(
                                child:
                                    Expanded(child: VideoListView(uid: uid!))),
                            // Content for Tab 2
                            Center(child: Text('Tab 2 Content')),
                            // Content for Tab 3
                            Center(child: Text('Tab 3 Content')),
                          ],
                        ),
                      ),
                    );
                  });
            }
            return const NotAuthenticatedPage();
          },
        ),
      ),
    );
  }
}

class VideoListView extends StatelessWidget {
  final String uid;
  VideoListView({super.key, required this.uid});

  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => UserVideoPagingRepository(),
      child: BlocProvider(
        create: (context) => UserVideoPagingBloc(
            RepositoryProvider.of<UserVideoPagingRepository>(context))
          ..add(InitUserVideoPaging(uid: uid)),
        child: BlocBuilder<UserVideoPagingBloc, UserVideoPagingState>(
          builder: (context, state) {
            if (state is UserVideoPagingInitialed) {
              return RefreshIndicator(
                onRefresh: () => Future.sync(() => state.controller.refresh()),
                child: PagedGridView<int, Video>(
                    pagingController: state.controller,
                    builderDelegate: PagedChildBuilderDelegate(
                      itemBuilder: (context, item, index) {
                        return AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Container(
                            child: CachedNetworkImage(
                                fit: BoxFit.cover, imageUrl: item.thumnail),
                          ),
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

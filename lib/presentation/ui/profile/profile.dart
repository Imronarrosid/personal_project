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
  final String uid;
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
      body: FutureBuilder(
          future: authRepository.getVideoOwnerData(uid),
          builder: (context, snapshot) {
            var data = snapshot.data;
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }
            return SizedBox(
              width: size.width,
              height: size.height,
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  debugPrint(state.toString());
                  if (state is Authenticated) {
                    return Container(
                      child: Column(children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.transparent,
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child:
                                  CachedNetworkImage(imageUrl: data!.photo!)),
                        ),
                        Text('@${data.userName}'),
                        const Row(
                          children: [
                            SizedBox(
                              width: 40,
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
                                Text(
                                  'Pengikut',
                                  textAlign: TextAlign.center,
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
                                Text(
                                  'Suka',
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            )),
                            SizedBox(
                              width: 40,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: Dimens.DIMENS_8,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 40,
                            ),
                            Container(
                              width: 90,
                              height: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: COLOR_grey,
                                  borderRadius: BorderRadius.circular(5)),
                              child: Text(
                                'Edit Profil',
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(
                              width: Dimens.DIMENS_6,
                            ),
                            Container(
                                width: 50,
                                height: 40,
                                decoration: BoxDecoration(
                                    color: COLOR_grey,
                                    borderRadius: BorderRadius.circular(5)),
                                child: Icon(MdiIcons.accountPlus)),
                            SizedBox(
                              width: 40,
                            ),
                          ],
                        ),
                        DefaultTabController(
                          length: 3, // Number of tabs
                          child: Column(
                            children: <Widget>[
                              TabBar(
                                tabs: [
                                  Tab(text: 'Tab 1'),
                                  Tab(text: 'Tab 2'),
                                  Tab(text: 'Tab 3'),
                                ],
                              ),
                              // Tab Bar View
                              Container(
                                height: 400, // Adjust the height as needed
                                child: TabBarView(
                                  children: [
                                    // Content for Tab 1
                                    KeepAlivePage(
                                        child: Expanded(
                                            child: VideoListView(uid: uid))),
                                    // Content for Tab 2
                                    Center(child: Text('Tab 2 Content')),
                                    // Content for Tab 3
                                    Center(child: Text('Tab 3 Content')),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      ]),
                    );
                  }
                  return const NotAuthenticatedPage();
                },
              ),
            );
          }),
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
              return PagedGridView<int, Video>(
                  pagingController: state.controller,
                  shrinkWrap: true,
                  builderDelegate: PagedChildBuilderDelegate(
                    itemBuilder: (context, item, index) {
                      return AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Container(
                              child: CachedNetworkImage(
                                  fit: BoxFit.cover, imageUrl: item.thumnail)));
                    },
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 9 / 16,
                    crossAxisCount: 3,
                  ));
            }
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}

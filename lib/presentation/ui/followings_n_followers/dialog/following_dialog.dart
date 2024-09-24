import 'package:easy_localization/easy_localization.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/repository/following_n_followers_repository.dart';
import '../../../../domain/model/user.dart';
import '../../../../domain/reporsitory/user_repository.dart';
import '../../../l10n/stings.g.dart';
import '../../../shared_components/keep_alive_page.dart';
import '../followings_n_followers.dart';

void showFollowDialog(
  BuildContext context, {
  required String userName,
  required int initialIndex,
}) {
  showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: DefaultTabController(
            initialIndex: initialIndex,
            length: 2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Scaffold(
                // backgroundColor: size.width > mobileWidth ? Colors.transparent : null,
                body: ExtendedNestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverAppBar(
                        elevation: 1,
                        scrolledUnderElevation: 0,
                        pinned: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(12)),
                        ),
                        title: Text(userName),
                        bottom: TabBar(
                            dividerHeight: 1,
                            dividerColor: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.15),
                            overlayColor: MaterialStatePropertyAll<Color>(
                                Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.12)),
                            indicatorWeight: 2,
                            labelColor: Theme.of(context).colorScheme.onSurface,
                            indicator: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface, // Color of the indicator
                                  width: 1.5, // Thickness of the indicator
                                ),
                              ),
                            ),
                            indicatorSize: TabBarIndicatorSize.tab,
                            tabs: [
                              Tab(
                                text: LocaleKeys.label_followers.tr(),
                              ),
                              Tab(
                                text: LocaleKeys.label_following.tr(),
                              ),
                            ]),
                      ),
                    ];
                  },
                  onlyOneScrollInBody: true,
                  body: StreamBuilder<User>(
                      stream: context
                          .read<UserRepository>()
                          .userDataStreamByUsername(userName),
                      builder: (context, snapshot) {
                        User? data = snapshot.data;
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return TabBarView(children: [
                          KeepAlivePage(
                            child: FollowingNFollowersTab(
                              key: Key(TabFor.followers.name),
                              uid: data!.id,
                              tabFor: TabFor.followers,
                            ),
                          ),
                          KeepAlivePage(
                            child: FollowingNFollowersTab(
                              key: Key(TabFor.following.name),
                              uid: data.id,
                              tabFor: TabFor.following,
                            ),
                          ),
                        ]);
                      }),
                ),
              ),
            ),
          ),
        );
      });
}

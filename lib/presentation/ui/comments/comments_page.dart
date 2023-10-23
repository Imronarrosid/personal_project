import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/constant/dimens.dart';
import 'package:personal_project/data/repository/coment_repository.dart';
import 'package:personal_project/domain/reporsitory/auth_reposotory.dart';
import 'package:personal_project/presentation/ui/auth/auth.dart';
import 'package:personal_project/presentation/ui/comments/bloc/comment_bloc.dart';

class CommentBottomSheet extends StatelessWidget {
  final String postId;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textEditingController = TextEditingController();

  CommentBottomSheet({super.key, required this.postId});
  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => CommentRepository(postId: postId),
      child: BlocProvider(
        create: (context) =>
            CommentBloc(RepositoryProvider.of<CommentRepository>(context)),
        child: DraggableScrollableSheet(
          initialChildSize:
              0.5, // Initial height as a fraction of the screen height
          maxChildSize: 0.9, // Maximum height when fully expanded
          minChildSize: 0.4, // Minimum height when collapsed,
          snap: true,
          snapSizes: const <double>[0.5, 0.7, 0.9],
          builder: (BuildContext context, ScrollController scrollController) {
            bool isExpanded = false;

            scrollController.addListener(() {
              if (scrollController.hasClients) {
                if (scrollController.offset ==
                        scrollController.position.maxScrollExtent &&
                    scrollController.offset == 00) {
                  // Sheet is fully expanded
                  isExpanded = true;
                } else if (scrollController.offset ==
                    scrollController.position.minScrollExtent) {
                  // Sheet is at its initial state
                  isExpanded = false;
                }
              }
            });

            return Container(
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: CustomScrollView(
                      controller: scrollController,
                      slivers: <Widget>[
                        SliverAppBar(
                          title: Text('Sliver App Bar'),
                          floating: false,
                          pinned: true,
                          backgroundColor: Colors.white,
                          foregroundColor: COLOR_black_ff121212,
                          elevation: 0,

                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                          ),
                          bottom: PreferredSize(
                            preferredSize: Size(
                                MediaQuery.of(context).size.width,
                                Dimens.DIMENS_3),
                            child: Divider(
                              color: Colors.black,
                              height: Dimens.DIMENS_3,
                            ),
                          ),
                          // Customize your SliverAppBar here
                        ),

                        SliverFillRemaining(
                          child: ListView.builder(
                            controller: _scrollController,
                            itemBuilder: (context, index) => ListTile(
                              title: Text('List Item $index'),
                            ),
                            itemCount: 10,
                          ),
                        ),

                        // Add more slivers as needed
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        border: Border(
                            top: BorderSide(
                                color: COLOR_black_ff121212.withOpacity(0.4)))),
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: Row(
                      children: [
                        SizedBox(
                          width: Dimens.DIMENS_8,
                        ),
                        Expanded(
                          child: Padding(
                            padding:
                                EdgeInsets.symmetric(vertical: Dimens.DIMENS_6),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: COLOR_grey,
                                  borderRadius: BorderRadius.circular(10)),
                              child: TextField(
                                controller: _textEditingController,
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: Dimens.DIMENS_8),
                                    hintText: 'Tambahkan komentar',
                                    border: const OutlineInputBorder(
                                        borderSide: BorderSide.none)),
                                textAlignVertical: TextAlignVertical.center,
                                keyboardType: TextInputType.multiline,
                                minLines: 1,
                                maxLines: 3,
                                onTap: () {
                                  final isAuthenticated =
                                      RepositoryProvider.of<AuthRepository>(
                                                  context)
                                              .currentUser !=
                                          null;
                                  if (isAuthenticated) {
                                    BlocProvider.of<CommentBloc>(context)
                                        .add(AddComentEvent());
                                  } else {
                                    showAuthBottomSheetFunc(context);
                                  }
                                },
                                onChanged: (text) {
                                  if (text.endsWith('\n')) {
                                    // Handle the Enter key press

                                    print('Enter key pressed. ');
                                    // You can add your custom logic here
                                  }
                                },
                                onSubmitted: (_) {
                                  debugPrint('Submit');
                                },
                              ),
                            ),
                          ),
                        ),
                        BlocBuilder<CommentBloc, CommentState>(
                          builder: (context, state) {
                            if (state is AddComentState) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Material(
                                  child: IconButton(
                                      splashRadius: Dimens.DIMENS_70,
                                      onPressed: () {
                                        if (_textEditingController
                                            .text.isNotEmpty) {
                                          BlocProvider.of<CommentBloc>(context)
                                              .add(PostCommentEvent(
                                                  comment:
                                                      _textEditingController
                                                          .text));
                                          _textEditingController.clear();
                                        }
                                        debugPrint('plane');
                                      },
                                      icon: FaIcon(
                                        FontAwesomeIcons.paperPlane,
                                        color: COLOR_black_ff121212,
                                      )),
                                ),
                              );
                            }
                            return Container();
                          },
                        ),
                        SizedBox(
                          width: Dimens.DIMENS_8,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

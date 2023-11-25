import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/domain/reporsitory/search_repository.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/router/route_utils.dart';
import 'package:personal_project/presentation/ui/search/bloc/search_bloc.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => SearchRepository(),
      child: BlocProvider(
        create: (context) =>
            SearchBloc(RepositoryProvider.of<SearchRepository>(context)),
        child: Builder(builder: (context) {
          return Scaffold(
            appBar: AppBar(
                elevation: 0,
                toolbarHeight: 80,
                backgroundColor: COLOR_white_fff5f5f5,
                title: TextField(
                  onChanged: (query) {
                    final searchBloc = BlocProvider.of<SearchBloc>(context);
                    searchBloc.add(SearchEvent(query));
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    prefixIconColor: COLOR_black_ff121212,
                    hintText: LocaleKeys.label_search.tr(),
                    contentPadding: const EdgeInsets.all(5),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: COLOR_black_ff121212)),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: COLOR_black_ff121212)),
                  ),
                )),
            body: BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) {
                if (state.results.isNotEmpty) {
                  return ListView.builder(
                      itemCount: state.results.length,
                      itemBuilder: (ctx, index) {
                        final result = state.results[index];
                        return ListTile(
                          onTap: () {
                            context.push(APP_PAGE.profile.toPath,
                                extra: result.id);
                            debugPrint('profile');
                          },
                          leading: CircleAvatar(
                            backgroundColor: COLOR_grey,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: CachedNetworkImage(
                                imageUrl: result.photo!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          ),
                          title: Text(result.name!),
                          subtitle: Text(result.userName!),
                        );
                      });
                }
                return Container();
              },
            ),
          );
        }),
      ),
    );
  }
}

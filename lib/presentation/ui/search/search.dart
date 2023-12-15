import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/domain/model/profile_data_model.dart';
import 'package:personal_project/domain/reporsitory/search_repository.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/router/route_utils.dart';
import 'package:personal_project/presentation/ui/search/bloc/search_bloc.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => SearchRepository(),
      child: BlocProvider(
        create: (context) =>
            SearchBloc(RepositoryProvider.of<SearchRepository>(context)),
        child: Builder(builder: (context) {
          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
              backgroundColor: COLOR_white_fff5f5f5,
              appBar: AppBar(
                  elevation: 0,
                  toolbarHeight: 80,
                  backgroundColor: COLOR_white_fff5f5f5,
                  title: Container(
                    decoration: BoxDecoration(
                        color: COLOR_grey.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10)),
                    child: TextField(
                      controller: _textEditingController,
                      onChanged: (query) {
                        final searchBloc = BlocProvider.of<SearchBloc>(context);
                        searchBloc.add(SearchEvent(query));
                      },
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        prefixIconColor: COLOR_black_ff121212,
                        hintText: LocaleKeys.label_search.tr(),
                        contentPadding: const EdgeInsets.all(5),
                        suffixIcon: GestureDetector(
                            onTap: () {
                              _textEditingController.clear();
                            },
                            child: Icon(MdiIcons.close)),
                        suffixIconColor: COLOR_grey,
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  )),
              body: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  if (state.status == SearchStatus.noItemFound) {
                    return Center(
                        child: Text(
                            '"${_textEditingController.text}" Tidak ditemukan'));
                  }
                  if (state.status == SearchStatus.success) {
                    return ListView.builder(
                        itemCount: state.results!.length,
                        itemBuilder: (ctx, index) {
                          final result = state.results![index];
                          return ListTile(
                            onTap: () {
                              debugPrint('photo${result.photo}');
                              context.push(APP_PAGE.profile.toPath,
                                  extra: ProfilePayload(
                                    uid: result.id,
                                    name: result.name!,
                                    userName: result.userName!,
                                    photoURL: result.photo!,
                                  ));
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
            ),
          );
        }),
      ),
    );
  }
}

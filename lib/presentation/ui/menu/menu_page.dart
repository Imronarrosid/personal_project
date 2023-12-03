import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/domain/model/user.dart';
import 'package:personal_project/domain/reporsitory/auth_reposotory.dart';
import 'package:personal_project/presentation/router/route_utils.dart';
import 'package:personal_project/presentation/ui/auth/bloc/auth_bloc.dart';

class MenuPage extends StatelessWidget {
  final String? accImageUrl;
  const MenuPage({super.key, this.accImageUrl});

  @override
  Widget build(BuildContext context) {
    AuthRepository authRepository =
        RepositoryProvider.of<AuthRepository>(context);
//  User user =            authRepository.getVideoOwnerData(authRepository.currentUser!.uid);
    return Scaffold(
      appBar: AppBar(
        title: Text('Seting'),
      ),
      body: Column(children: [
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return ListTile(
              leading: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: CachedNetworkImage(
                      imageUrl: accImageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  )),
            );
          },
        ),
        ListTile(
          title: Text('Caches'),
          onTap: () {
            context.push(APP_PAGE.cachesPage.toPath);
          },
        ),
        FutureBuilder(
            future: authRepository.isAdmin(authRepository.currentUser!.uid),
            builder: (context, AsyncSnapshot<bool> snapshot) {
              if (!snapshot.hasData ||
                  snapshot.hasError ||
                  snapshot.data == false) {
                return Container();
              }

              return ListTile(
                tileColor: COLOR_grey,
                onTap: () {
                  context.push(APP_PAGE.addGameFav.toPath);
                },
              );
            }),
      ]),
    );
  }
}

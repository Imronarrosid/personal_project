import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/domain/reporsitory/auth_reposotory.dart';
import 'package:personal_project/presentation/router/route_utils.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    AuthRepository authRepository =
        RepositoryProvider.of<AuthRepository>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Seting'),
      ),
      body: Column(children: [
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
        ListTile(
          title: Text('Caches'),
          onTap: () {
            context.push(APP_PAGE.cachesPage.toPath);
          },
        )
      ]),
    );
  }
}

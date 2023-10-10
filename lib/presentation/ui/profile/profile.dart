import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_project/presentation/shared_components/not_authenticated_page.dart';
import 'package:personal_project/presentation/ui/auth/bloc/auth_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            debugPrint(state.toString());
            if (state is NotAuthenticated) {
              return const NotAuthenticatedPage();
            }
            return Container();
          },
        ),
      ),
    );
  }
}

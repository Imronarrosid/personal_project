import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:personal_project/presentation/router/app_router.dart';
import 'package:provider/provider.dart';

class HandleBackButton extends StatelessWidget {
  final Widget child;
  const HandleBackButton({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BackButtonListener(
      onBackButtonPressed: () async {
        final AppRouter appRouter = Provider.of(context, listen: false);

        appRouter.onBackButtonPressed(context);
        return true;
      },
      child: child,
    );
  }
}

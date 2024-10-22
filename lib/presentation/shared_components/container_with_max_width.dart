import 'package:flutter/material.dart';

class ContainerWidthMaxWidth extends StatelessWidget {
  final double? maxWidth;
  final Widget child;
  const ContainerWidthMaxWidth({super.key, this.maxWidth, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth > (maxWidth ?? constraints.maxWidth)
            ? (maxWidth ?? constraints.maxWidth)
            : constraints.maxWidth;
        return Center(
          child: SizedBox(
              width: width, // Use calculated width
              child: child),
        );
      },
    );
  }
}

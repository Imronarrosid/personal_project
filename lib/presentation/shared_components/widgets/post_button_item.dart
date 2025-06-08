import 'package:flutter/material.dart';

class PostButtonItem extends StatelessWidget {
  const PostButtonItem({
    super.key,
    required this.onPressed,
    required this.icon,
    this.style,
    this.label,
    this.labelText,
  });

  final void Function() onPressed;
  final Widget icon;
  final ButtonStyle? style;
  final String? labelText;
  final Widget? label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          onPressed: onPressed,
          icon: icon,
          style: style,
        ),
        label ?? (label != null ? Text(labelText!) : SizedBox.shrink()),
      ],
    );
  }
}

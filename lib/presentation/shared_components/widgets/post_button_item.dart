import 'package:flutter/material.dart';

class PostButtonItem extends StatelessWidget {
  const PostButtonItem({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.style,
    this.label,
    this.labelText,
  });

  final void Function() onPressed;
  final Widget icon;
  final ButtonStyle style;
  final String? labelText;
  final Widget? label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(onPressed: onPressed, icon: icon),
        label ?? (label != null ? Text(labelText!) : SizedBox.shrink()),
      ],
    );
  }
}

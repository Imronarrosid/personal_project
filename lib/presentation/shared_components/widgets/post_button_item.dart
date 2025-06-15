import 'package:flutter/material.dart';

class PostButtonItem extends StatelessWidget {
  const PostButtonItem({
    super.key,
    required this.onPressed,
    required this.icon,
    this.label,
    this.labelText,
  });

  final void Function() onPressed;
  final Widget icon;
  final String? labelText;
  final Widget? label;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(50),
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        splashColor: Theme.of(context).splashColor,
        onTap: onPressed,
        child: Container(
          width: 62,
          height: 62,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              label ?? (label != null ? Text(labelText!) : SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );
  }
}

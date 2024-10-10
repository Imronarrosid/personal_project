import 'package:easy_localization/easy_localization.dart' as locale;
import 'package:flutter/material.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  const ExpandableText({super.key, required this.text});

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400, // Set max width to 400
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, size) {
              // TextPainter to check if text overflows
              final span = TextSpan(
                text: widget.text,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              );
              final tp = TextPainter(
                text: span,
                maxLines: 3,
                textDirection: TextDirection.ltr,
              );
              tp.layout(maxWidth: size.maxWidth);

              // Check if the text exceeds 3 lines
              bool isTextOverflowing = tp.didExceedMaxLines;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.text,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    maxLines: isExpanded ? null : 3, // Expand if needed
                    overflow:
                        TextOverflow.ellipsis, // Ellipsis when text overflows
                  ),
                  if (isTextOverflowing)
                    InkWell(
                      onTap: () {
                        setState(() {
                          isExpanded = !isExpanded;
                        });
                      },
                      borderRadius: BorderRadius.circular(
                          4), // Match the TextButton shape
                      splashColor:
                          Colors.grey.withOpacity(0.3), // Same splash effect
                      highlightColor:
                          Colors.transparent, // Remove default highlight
                      child: Text(
                        isExpanded
                            ? LocaleKeys.label_see_less.tr().toLowerCase()
                            : LocaleKeys.label_see_more.tr().toLowerCase(),
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface.withOpacity(0.6), // Same color as TextButton
                          fontSize: 14, // Match default text size of TextButton
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

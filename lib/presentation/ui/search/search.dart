import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: COLOR_white_fff5f5f5,
        title: TextField(
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: LocaleKeys.label_search.tr(),
                contentPadding: const EdgeInsets.all(5),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: COLOR_black_ff121212)),
                border: OutlineInputBorder(borderSide: BorderSide(color: COLOR_black_ff121212)),
              ),
            )
      ),
    );
  }
}

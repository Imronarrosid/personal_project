import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:personal_project/constant/color.dart';
import 'package:personal_project/presentation/l10n/stings.g.dart';
import 'package:personal_project/presentation/ui/message/message.dart';
import 'package:personal_project/presentation/ui/post/post.dart';
import 'package:personal_project/presentation/ui/profile/profile.dart';
import 'package:personal_project/presentation/ui/search/search.dart';
import 'package:personal_project/presentation/ui/video/video.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedindex = 0;
  List<Widget> pages = <Widget>[
    const VideoPage(),
    const SearchPage(),
    const PostPage(),
    const MessagePage(),
    const ProfilePage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedindex],
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: COLOR_white_fff5f5f5.withOpacity(0.6),
        selectedItemColor: COLOR_white_fff5f5f5,
        type: BottomNavigationBarType.fixed,
        backgroundColor: COLOR_black_ff121212,
        items: [
          BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined), label: LocaleKeys.label_home.tr()),
          BottomNavigationBarItem(
              icon: const Icon(Icons.search_rounded), label: LocaleKeys.label_search.tr()),
          const BottomNavigationBarItem(
              icon: Icon(Icons.add), label: ''),
          BottomNavigationBarItem(
              icon: const Icon(Icons.message), label: LocaleKeys.label_message.tr()),
          BottomNavigationBarItem(
              icon: const Icon(Icons.person_2_outlined), label: LocaleKeys.label_profile.tr()),
        ],
        currentIndex: selectedindex,
        onTap: (value) {
          setState(() {
            selectedindex = value;
          });
        },
      ),
    );
  }
}

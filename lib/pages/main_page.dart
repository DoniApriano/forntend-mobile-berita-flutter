// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, avoid_print

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/colors/custom_color.dart';
import 'package:flutter_application_1/screen/bookmark_screen.dart';
import 'package:flutter_application_1/screen/explore_screen.dart';
import 'package:flutter_application_1/screen/news_follows_screen.dart';
import 'package:flutter_application_1/screen/news_screen.dart';
import 'package:flutter_application_1/screen/profile_screen.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;
  CustomColor customColor = CustomColor();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> myWidget = [
      Center(
        child: NewsScreen(),
      ),
      ExploreScreen(),
      BookmarkScreen(),
      Center(child: ProfileScreen()),
    ];

    return MaterialApp(
      home: Scaffold(
        body: myWidget[currentIndex],
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: GNav(
            tabBorderRadius: 50,
            haptic: true,
            tabBackgroundColor: Colors.black,
            activeColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            tabMargin:
                EdgeInsets.only(top: 10, bottom: 20, left: 10, right: 10),
            onTabChange: (value) {
              setState(() {
                currentIndex = value;
              });
            },
            tabs: [
              GButton(
                icon: Icons.home_rounded,
                text: 'Beranda',
              ),
              GButton(
                icon: Icons.search_rounded,
                text: 'Eksplorasi',
              ),
              GButton(
                icon: Icons.bookmark,
                text: 'Penanda',
              ),
              GButton(
                icon: Icons.person,
                text: 'Profil',
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, avoid_print

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/colors/custom_color.dart';
import 'package:flutter_application_1/pages/screen/news_follows_screen.dart';
import 'package:flutter_application_1/pages/screen/news_screen.dart';
import 'package:flutter_application_1/pages/screen/user_me_detail_screen.dart';

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
      NewsFollowsScreen(),
      Center(
        child: Text(
          "Halaman 3",
          style: TextStyle(fontSize: 20),
        ),
      ),
      Center(child: UserMeDetailScreen()),
    ];

    return MaterialApp(
      home: Scaffold(
        body: myWidget[currentIndex],
        bottomNavigationBar: CurvedNavigationBar(
          animationCurve: Curves.easeOutExpo,
          backgroundColor: customColor.light,
          items: [
            Icon(
              Icons.home_outlined,
              size: 30,
              color: Colors.white,
            ),
            Icon(
              Icons.explore_outlined,
              size: 30,
              color: Colors.white,
            ),
            Icon(
              Icons.notifications_outlined,
              size: 30,
              color: Colors.white,
            ),
            Icon(
              Icons.person_outline,
              size: 30,
              color: Colors.white,
            ),
          ],
          onTap: (int i) {
            setState(() {
              currentIndex = i;
            });
          },
          index: currentIndex,
          color: Color.fromRGBO(105, 108, 255, 1),
        ),
      ),
    );
  }
}

// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, avoid_print

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/screen/news_screen.dart';
import 'package:flutter_application_1/pages/screen/user_me_detail_screen.dart';

class Yes extends StatefulWidget {
  final int initialIndex;
  const Yes({Key? key, required this.initialIndex}) : super(key: key);

  @override
  State<Yes> createState() => _YesState();
}

class _YesState extends State<Yes> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> myWidget = [
      Center(
        child: NewsScreen(),
      ),
      Center(
        child: Text(
          "Halaman 2",
          style: TextStyle(fontSize: 20),
        ),
      ),
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
          backgroundColor: Colors.transparent,
          items: [
            Icon(
              Icons.home_filled,
              size: 30,
              color: Colors.white,
            ),
            Icon(
              Icons.follow_the_signs_rounded,
              size: 30,
              color: Colors.white,
            ),
            Icon(
              Icons.notifications,
              size: 30,
              color: Colors.white,
            ),
            Icon(
              Icons.person,
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
          color: Colors.blue,
        ),
      ),
    );
  }
}
